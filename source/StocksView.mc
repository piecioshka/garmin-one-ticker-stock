using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class StocksView extends Ui.View {

    // Vertical layout of the 240x240 round MIP face, top to bottom.
    const SYMBOL_Y = 10;
    const NAME_Y = 34;
    const NAME_MAX_WIDTH = 180;
    const PRICE_Y = 48;
    const CHANGE_Y = 94;
    const CHART_X = 30;
    const CHART_Y = 126;
    const CHART_WIDTH = 180;
    const CHART_HEIGHT = 66;
    const CHART_MESSAGE_Y = 150;
    const FOOTER_Y = 202;

    // Dark orange; an exact color of the FR945 RGB222 palette, so the MIP
    // display renders it without quantization.
    const SESSION_COLOR = 0xFFAA00;

    var mData;
    var mError;
    var mLoading;
    var mWiderRangeTried;

    function initialize() {
        View.initialize();
        mData = App.Storage.getValue("quote");
        mError = null;
        mLoading = false;
        mWiderRangeTried = false;
    }

    function onShow() {
        fetchQuote();
    }

    function fetchQuote() {
        if (mLoading) {
            return;
        }
        mLoading = true;
        mWiderRangeTried = false;
        YahooClient.requestChart(currentTicker(),
            numberProperty("chartWindow", YahooClient.WINDOW_24H),
            method(:onQuote));
        Ui.requestUpdate();
    }

    function currentTicker() {
        var ticker = App.Properties.getValue("ticker");
        if (ticker instanceof Lang.String && ticker.length() > 0) {
            return ticker;
        }
        return "AAPL";
    }

    function numberProperty(key, fallback) {
        var value = App.Properties.getValue(key);
        if (value instanceof Lang.Number) {
            return value;
        }
        return fallback;
    }

    function onQuote(responseCode, data) {
        mLoading = false;
        if (responseCode == 200) {
            var parsed = YahooClient.parseChart(data);
            if (YahooClient.needsWiderRange(parsed) && !mWiderRangeTried) {
                // no trades in the last 24 hours (stock exchanges on
                // weekends, before the session): retry once with the last
                // two trading days before giving up on a chart
                mWiderRangeTried = true;
                mLoading = true;
                YahooClient.requestChartRange(currentTicker(), "2d",
                    method(:onQuote));
                return;
            }
            if (parsed != null) {
                parsed.put("updatedAt", Time.now().value());
                mData = parsed;
                mError = null;
                App.Storage.setValue("quote", parsed);
            } else {
                mError = "Bad data: " + currentTicker();
            }
        } else {
            mError = errorLabel(responseCode);
        }
        Ui.requestUpdate();
    }

    function errorLabel(code) {
        if (code == 404) {
            return "Unknown ticker";
        }
        if (code == Comm.BLE_CONNECTION_UNAVAILABLE) {
            return "No phone";
        }
        return "Error " + code;
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        if (mData == null) {
            var msg = mLoading ? "Loading..." : (mError != null ? mError : "No data");
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Gfx.FONT_MEDIUM,
                msg, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
            return;
        }
        drawQuote(dc);
    }

    function drawQuote(dc) {
        var cx = dc.getWidth() / 2;

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, SYMBOL_Y, Gfx.FONT_SMALL, mData.get("symbol"),
            Gfx.TEXT_JUSTIFY_CENTER);
        var name = nameLabel(dc, NAME_MAX_WIDTH);
        if (name != null) {
            dc.drawText(cx, NAME_Y, Gfx.FONT_XTINY, name, Gfx.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, PRICE_Y, Gfx.FONT_NUMBER_MEDIUM,
            formatPrice(mData.get("price")), Gfx.TEXT_JUSTIFY_CENTER);

        drawChange(dc, cx);
        drawChart(dc);
        drawFooter(dc, cx);
    }

    // Instrument name truncated to maxWidth pixels so the line fits the
    // chord of the round screen at its height; null when Yahoo sent none.
    function nameLabel(dc, maxWidth) {
        var name = mData.get("name");
        if (name == null) {
            return null;
        }
        if (dc.getTextWidthInPixels(name, Gfx.FONT_XTINY) <= maxWidth) {
            return name;
        }
        while (name.length() > 1
            && dc.getTextWidthInPixels(name + "...", Gfx.FONT_XTINY) > maxWidth) {
            name = name.substring(0, name.length() - 1);
        }
        return name + "...";
    }

    function drawChange(dc, cx) {
        var price = mData.get("price");
        var prevClose = mData.get("prevClose");
        if (prevClose == null || prevClose.toFloat() == 0.0) {
            return;
        }
        var change = price.toFloat() - prevClose.toFloat();
        var pct = change * 100.0 / prevClose.toFloat();
        var color = change >= 0 ? Gfx.COLOR_GREEN : Gfx.COLOR_RED;
        var sign = change >= 0 ? "+" : "";
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, CHANGE_Y, Gfx.FONT_SMALL,
            sign + change.format("%.2f") + " (" + sign + pct.format("%.2f") + "%)",
            Gfx.TEXT_JUSTIFY_CENTER);
    }

    // Values of the chartType setting (resources/settings/settings.xml).
    const CHART_TYPE_LINE = 0;
    const CHART_TYPE_CANDLES = 1;

    function drawChart(dc) {
        if (numberProperty("chartType", CHART_TYPE_LINE) == CHART_TYPE_CANDLES
            && drawCandleChart(dc)) {
            return;
        }
        var points = ChartRenderer.scalePoints(mData.get("closes"), CHART_X, CHART_Y, CHART_WIDTH, CHART_HEIGHT);
        if (points.size() < 2) {
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, CHART_MESSAGE_Y, Gfx.FONT_XTINY,
                "No chart data", Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }
        // "breaks" is absent in quotes cached by older versions
        ChartRenderer.drawBreaks(dc, points, mData.get("breaks"),
            CHART_Y, CHART_HEIGHT, Gfx.COLOR_DK_GRAY);
        ChartRenderer.draw(dc, points, Gfx.COLOR_BLUE);
    }

    // False when OHLC series are unavailable (e.g. a quote cached by an
    // older version) — the caller then falls back to the line chart.
    function drawCandleChart(dc) {
        var candles = ChartRenderer.scaleCandles(mData.get("opens"),
            mData.get("highs"), mData.get("lows"), mData.get("closes"),
            CHART_X, CHART_Y, CHART_WIDTH, CHART_HEIGHT);
        if (candles.size() < 2) {
            return false;
        }
        ChartRenderer.drawBreaks(dc, candles, mData.get("breaks"),
            CHART_Y, CHART_HEIGHT, Gfx.COLOR_DK_GRAY);
        ChartRenderer.drawCandles(dc, candles, Gfx.COLOR_GREEN, Gfx.COLOR_RED);
        return true;
    }

    // Update time in gray plus the session status in dark orange,
    // e.g. "10:31 | Closes 22:00", centered as a whole.
    function drawFooter(dc, cx) {
        if (mError != null) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, FOOTER_Y, Gfx.FONT_XTINY, mError, Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }
        var updated = updatedLabel();
        var session = sessionLabel();
        if (session == null) {
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, FOOTER_Y, Gfx.FONT_XTINY, updated, Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }
        var lead = updated.length() > 0 ? updated + " | " : "";
        var leadWidth = dc.getTextWidthInPixels(lead, Gfx.FONT_XTINY);
        var x = cx - (leadWidth + dc.getTextWidthInPixels(session, Gfx.FONT_XTINY)) / 2;
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, FOOTER_Y, Gfx.FONT_XTINY, lead, Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(SESSION_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x + leadWidth, FOOTER_Y, Gfx.FONT_XTINY, session, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function sessionLabel() {
        var phase = SessionInfo.phase(Time.now().value(),
            mData.get("sessionStart"), mData.get("sessionEnd"));
        if (phase == :before) {
            return "Opens " + timeLabel(mData.get("sessionStart"));
        }
        if (phase == :during) {
            return "Closes " + timeLabel(mData.get("sessionEnd"));
        }
        if (phase == :after) {
            return "Closed";
        }
        return null;
    }

    function updatedLabel() {
        var updatedAt = mData.get("updatedAt");
        if (updatedAt == null) {
            return "";
        }
        return timeLabel(updatedAt);
    }

    function timeLabel(epoch) {
        var info = Gregorian.info(new Time.Moment(epoch), Time.FORMAT_SHORT);
        return info.hour.format("%02d") + ":" + info.min.format("%02d");
    }

    function formatPrice(price) {
        return price.toFloat().format("%.2f");
    }
}
