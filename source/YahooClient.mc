using Toybox.Lang;
using Toybox.Communications as Comm;
using Toybox.Time;

module YahooClient {

    // Values of the chartWindow setting (resources/settings/settings.xml).
    const WINDOW_SESSION = 0;
    const WINDOW_24H = 1;
    const WINDOW_48H = 2;

    // Query params for the chosen chart window: WINDOW_SESSION charts the
    // current/last trading day, WINDOW_24H (default) and WINDOW_48H chart
    // a trailing window, so around-the-clock instruments (crypto, futures)
    // always fill a chart regardless of the UTC-day boundary.
    function windowParams(mode, now) {
        if (mode == WINDOW_SESSION) {
            return {"range" => "1d", "interval" => "15m"};
        }
        var span = mode == WINDOW_48H ? 172800 : 86400;
        return {
            "period1" => now - span,
            "period2" => now,
            "interval" => "15m"
        };
    }

    function requestChart(ticker, mode, callback) {
        request(ticker, windowParams(mode, Time.now().value()), callback);
    }

    function requestChartRange(ticker, range, callback) {
        request(ticker, {
            "range" => range,
            "interval" => "15m"
        }, callback);
    }

    function request(ticker, params, callback) {
        var url = "https://query1.finance.yahoo.com/v8/finance/chart/" + ticker;
        var options = {
            :method => Comm.HTTP_REQUEST_METHOD_GET,
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Comm.makeWebRequest(url, params, options, callback);
    }

    // True when the response parsed fine but carries no candles — the
    // instrument did not trade in the last 24 hours (stock exchanges on
    // weekends, before the session) and a wider range is worth a retry.
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
        var opens = [];
        var highs = [];
        var lows = [];
        var times = [];
        var timesValid = false;
        var indicators = result.get("indicators");
        if (indicators instanceof Lang.Dictionary) {
            var quotes = indicators.get("quote");
            if (quotes instanceof Lang.Array && quotes.size() > 0
                && quotes[0] instanceof Lang.Dictionary) {
                var raw = quotes[0].get("close");
                if (raw instanceof Lang.Array) {
                    var rawOpen = quotes[0].get("open");
                    var rawHigh = quotes[0].get("high");
                    var rawLow = quotes[0].get("low");
                    var stamps = result.get("timestamp");
                    timesValid = stamps instanceof Lang.Array
                        && stamps.size() == raw.size();
                    for (var i = 0; i < raw.size(); i++) {
                        if (raw[i] != null) {
                            closes.add(raw[i]);
                            opens.add(pick(rawOpen, i, raw[i]));
                            highs.add(pick(rawHigh, i, raw[i]));
                            lows.add(pick(rawLow, i, raw[i]));
                            if (timesValid) {
                                var ts = stamps[i];
                                if (ts instanceof Lang.Number
                                    || ts instanceof Lang.Long) {
                                    times.add(ts);
                                } else {
                                    timesValid = false;
                                }
                            }
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
            "opens" => opens,
            "highs" => highs,
            "lows" => lows,
            "breaks" => timesValid ? sessionBreaks(times) : [],
            "sessionStart" => sessionBound(meta, "start"),
            "sessionEnd" => sessionBound(meta, "end")
        };
    }

    // Value of a parallel OHLC array at the given index; the close value
    // when Yahoo did not send that array or left a hole in it.
    function pick(arr, i, fallback) {
        if (arr instanceof Lang.Array && i < arr.size() && arr[i] != null) {
            return arr[i];
        }
        return fallback;
    }

    // A gap wider than 3 missing 15-minute candles separates two trading
    // sessions (overnight, weekend); anything narrower is just illiquidity.
    const SESSION_GAP_SECONDS = 2700;

    // Indices (into the filtered closes series) of candles that open a new
    // session, i.e. sit more than SESSION_GAP_SECONDS after their neighbour.
    function sessionBreaks(times) {
        var breaks = [];
        for (var i = 1; i < times.size(); i++) {
            if (times[i] - times[i - 1] > SESSION_GAP_SECONDS) {
                breaks.add(i);
            }
        }
        return breaks;
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
