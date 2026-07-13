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
                "timestamp" => [0, 900, 1800, 100000],
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
    // kept candles at 0, 1800, 100000: only the 1800 -> 100000 jump is a
    // session break, and its index points into the filtered closes array
    var breaks = parsed.get("breaks");
    Test.assertEqual(1, breaks.size());
    Test.assertEqual(2, breaks[0]);
    return true;
}

(:test)
function testParseChartNoTimestampsMeansNoBreaks(logger) {
    var data = {
        "chart" => {
            "result" => [{
                "meta" => {
                    "symbol" => "AAPL",
                    "regularMarketPrice" => 123.45
                },
                "indicators" => {"quote" => [{"close" => [1.0, 2.0]}]}
            }]
        }
    };
    var parsed = YahooClient.parseChart(data);
    Test.assert(parsed != null);
    Test.assertEqual(0, parsed.get("breaks").size());
    return true;
}

(:test)
function testWindowParams(logger) {
    var session = YahooClient.windowParams(YahooClient.WINDOW_SESSION, 1000000);
    Test.assertEqual("1d", session.get("range"));
    var day = YahooClient.windowParams(YahooClient.WINDOW_24H, 1000000);
    Test.assertEqual(1000000 - 86400, day.get("period1"));
    Test.assertEqual(1000000, day.get("period2"));
    var twoDays = YahooClient.windowParams(YahooClient.WINDOW_48H, 1000000);
    Test.assertEqual(1000000 - 172800, twoDays.get("period1"));
    // unknown or missing mode falls back to the 24h window
    Test.assertEqual(1000000 - 86400,
        YahooClient.windowParams(null, 1000000).get("period1"));
    return true;
}

(:test)
function testParseChartAlignsOhlcWithFilteredCloses(logger) {
    var data = {
        "chart" => {
            "result" => [{
                "meta" => {
                    "symbol" => "AAPL",
                    "regularMarketPrice" => 123.45
                },
                "indicators" => {
                    "quote" => [{
                        "close" => [10.0, null, 30.0],
                        "open" => [9.0, 19.0, 29.0],
                        "high" => [11.0, 21.0, null],
                        "low" => [8.0, 18.0, 28.0]
                    }]
                }
            }]
        }
    };
    var parsed = YahooClient.parseChart(data);
    Test.assert(parsed != null);
    // the null close drops the whole candle from every series
    Test.assertEqual(2, parsed.get("opens").size());
    Test.assertEqual(9.0, parsed.get("opens")[0]);
    Test.assertEqual(29.0, parsed.get("opens")[1]);
    // a hole in one OHLC array falls back to that candle's close
    Test.assertEqual(30.0, parsed.get("highs")[1]);
    Test.assertEqual(28.0, parsed.get("lows")[1]);
    return true;
}

(:test)
function testSessionBreaksIgnoresSmallGaps(logger) {
    // 15-minute candles with up to 3 candles missing (45 min) are still one
    // session; anything wider marks the next candle as a new session
    Test.assertEqual(0, YahooClient.sessionBreaks([0, 900, 3600]).size());
    var breaks = YahooClient.sessionBreaks([0, 900, 7200, 8100]);
    Test.assertEqual(1, breaks.size());
    Test.assertEqual(2, breaks[0]);
    Test.assertEqual(0, YahooClient.sessionBreaks([]).size());
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
