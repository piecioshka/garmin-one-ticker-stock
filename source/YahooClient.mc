using Toybox.Lang;
using Toybox.Communications as Comm;

module YahooClient {

    function requestChart(ticker, callback) {
        requestChartRange(ticker, "1d", callback);
    }

    function requestChartRange(ticker, range, callback) {
        var url = "https://query1.finance.yahoo.com/v8/finance/chart/" + ticker;
        var params = {
            "range" => range,
            "interval" => "15m"
        };
        var options = {
            :method => Comm.HTTP_REQUEST_METHOD_GET,
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Comm.makeWebRequest(url, params, options, callback);
    }

    // True when the response parsed fine but carries no candles — Yahoo
    // sometimes has none for the current UTC day (e.g. crypto in the
    // morning) and a wider range is worth a retry.
    function needsWiderRange(parsed) {
        return parsed != null && parsed.get("closes").size() == 0;
    }

    // Extracts {"symbol", "price", "prevClose", "closes"} from a Yahoo
    // chart API response; null when the shape is unexpected.
    function parseChart(data) {
        if (!(data instanceof Lang.Dictionary)) {
            return null;
        }
        var chart = data.get("chart");
        if (!(chart instanceof Lang.Dictionary)) {
            return null;
        }
        var results = chart.get("result");
        if (!(results instanceof Lang.Array) || results.size() == 0) {
            return null;
        }
        var result = results[0];
        if (!(result instanceof Lang.Dictionary)) {
            return null;
        }
        var meta = result.get("meta");
        if (!(meta instanceof Lang.Dictionary)) {
            return null;
        }
        var symbol = meta.get("symbol");
        if (!(symbol instanceof Lang.String)) {
            return null;
        }
        var price = meta.get("regularMarketPrice");
        if (!isNumeric(price)) {
            return null;
        }
        var closes = [];
        var indicators = result.get("indicators");
        if (indicators instanceof Lang.Dictionary) {
            var quotes = indicators.get("quote");
            if (quotes instanceof Lang.Array && quotes.size() > 0
                && quotes[0] instanceof Lang.Dictionary) {
                var raw = quotes[0].get("close");
                if (raw instanceof Lang.Array) {
                    for (var i = 0; i < raw.size(); i++) {
                        if (raw[i] != null) {
                            closes.add(raw[i]);
                        }
                    }
                }
            }
        }
        var name = meta.get("shortName");
        if (!(name instanceof Lang.String)) {
            name = null;
        }
        var prevClose = meta.get("chartPreviousClose");
        if (!isNumeric(prevClose)) {
            prevClose = null;
        }
        return {
            "symbol" => symbol,
            "name" => name,
            "price" => price,
            "prevClose" => prevClose,
            "closes" => closes,
            "sessionStart" => sessionBound(meta, "start"),
            "sessionEnd" => sessionBound(meta, "end")
        };
    }

    function isNumeric(value) {
        return value instanceof Lang.Float || value instanceof Lang.Number
            || value instanceof Lang.Double || value instanceof Lang.Long;
    }

    // Epoch of the regular-session bound ("start" or "end") from
    // meta.currentTradingPeriod; null when Yahoo did not send one.
    function sessionBound(meta, key) {
        var period = meta.get("currentTradingPeriod");
        if (!(period instanceof Lang.Dictionary)) {
            return null;
        }
        var regular = period.get("regular");
        if (!(regular instanceof Lang.Dictionary)) {
            return null;
        }
        var bound = regular.get(key);
        if (!(bound instanceof Lang.Number) && !(bound instanceof Lang.Long)) {
            return null;
        }
        return bound;
    }
}
