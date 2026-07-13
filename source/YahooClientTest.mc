using Toybox.Test;

(:test)
function testParseChartHappyPath(logger) {
    var data = {
        "chart" => {
            "result" => [{
                "meta" => {
                    "symbol" => "AAPL",
                    "shortName" => "Apple Inc.",
                    "regularMarketPrice" => 123.45,
                    "chartPreviousClose" => 120.00,
                    "currentTradingPeriod" => {
                        "regular" => {"start" => 1000, "end" => 2000}
                    }
                },
                "indicators" => {
                    "quote" => [{
                        "close" => [121.0, null, 122.5, 123.45]
                    }]
                }
            }]
        }
    };
    var parsed = YahooClient.parseChart(data);
    Test.assert(parsed != null);
    Test.assertEqual("AAPL", parsed.get("symbol"));
    Test.assertEqual("Apple Inc.", parsed.get("name"));
    Test.assertEqual(123.45, parsed.get("price"));
    Test.assertEqual(120.00, parsed.get("prevClose"));
    var closes = parsed.get("closes");
    Test.assertEqual(3, closes.size());
    Test.assertEqual(121.0, closes[0]);
    Test.assertEqual(1000, parsed.get("sessionStart"));
    Test.assertEqual(2000, parsed.get("sessionEnd"));
    return true;
}

(:test)
function testParseChartRejectsGarbage(logger) {
    Test.assert(YahooClient.parseChart(null) == null);
    Test.assert(YahooClient.parseChart("not a dict") == null);
    Test.assert(YahooClient.parseChart({}) == null);
    Test.assert(YahooClient.parseChart({"chart" => {}}) == null);
    Test.assert(YahooClient.parseChart({"chart" => {"result" => []}}) == null);
    return true;
}

(:test)
function testParseChartToleratesMissingName(logger) {
    var data = {
        "chart" => {
            "result" => [{
                "meta" => {
                    "symbol" => "BZ=F",
                    "regularMarketPrice" => 78.79
                },
                "indicators" => {"quote" => [{"close" => [78.0, 78.79]}]}
            }]
        }
    };
    var parsed = YahooClient.parseChart(data);
    Test.assert(parsed != null);
    Test.assert(parsed.get("name") == null);
    Test.assertEqual("BZ=F", parsed.get("symbol"));
    // no currentTradingPeriod: session bounds tolerated as nulls
    Test.assert(parsed.get("sessionStart") == null);
    Test.assert(parsed.get("sessionEnd") == null);
    return true;
}

(:test)
function testParseChartRequiresStringSymbol(logger) {
    // a response without a usable symbol would crash drawText(null)
    var data = {
        "chart" => {
            "result" => [{
                "meta" => {"regularMarketPrice" => 78.79},
                "indicators" => {"quote" => [{"close" => [78.0]}]}
            }]
        }
    };
    Test.assert(YahooClient.parseChart(data) == null);
    return true;
}

(:test)
function testParseChartDropsNonNumericPrevClose(logger) {
    var data = {
        "chart" => {
            "result" => [{
                "meta" => {
                    "symbol" => "AAPL",
                    "regularMarketPrice" => 123.45,
                    "chartPreviousClose" => "not a number"
                },
                "indicators" => {"quote" => [{"close" => [121.0]}]}
            }]
        }
    };
    var parsed = YahooClient.parseChart(data);
    Test.assert(parsed != null);
    // change vs previous close is skipped instead of crashing on math
    Test.assert(parsed.get("prevClose") == null);
    return true;
}

(:test)
function testNeedsWiderRange(logger) {
    // empty series (Yahoo has no candles for the current UTC day, e.g.
    // crypto in the morning): worth retrying with a wider range
    Test.assert(YahooClient.needsWiderRange({"closes" => []}));
    Test.assert(!YahooClient.needsWiderRange({"closes" => [1.0, 2.0]}));
    Test.assert(!YahooClient.needsWiderRange(null));
    return true;
}

(:test)
function testParseChartRequiresPrice(logger) {
    var data = {
        "chart" => {
            "result" => [{
                "meta" => {"symbol" => "AAPL"},
                "indicators" => {"quote" => [{"close" => [1.0]}]}
            }]
        }
    };
    Test.assert(YahooClient.parseChart(data) == null);
    return true;
}
