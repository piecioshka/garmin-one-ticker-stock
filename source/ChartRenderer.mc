using Toybox.Lang;
using Toybox.Graphics as Gfx;

module ChartRenderer {

    // Maps a value series onto pixel points inside the given box.
    // Returns [] when the series is too short to draw a line.
    function scalePoints(closes, x, y, width, height) {
        if (!(closes instanceof Lang.Array) || closes.size() < 2) {
            return [];
        }
        var min = closes[0].toFloat();
        var max = min;
        for (var i = 1; i < closes.size(); i++) {
            var v = closes[i].toFloat();
            if (v < min) { min = v; }
            if (v > max) { max = v; }
        }
        var range = max - min;
        if (range <= 0.0) {
            range = 1.0;
        }
        var points = new [closes.size()];
        var step = width.toFloat() / (closes.size() - 1);
        for (var i = 0; i < closes.size(); i++) {
            var px = x + step * i;
            var py = y + height - ((closes[i].toFloat() - min) * height / range);
            points[i] = [px, py];
        }
        return points;
    }

    // Maps OHLC series onto candle geometry inside the given box: one
    // [xCenter, yOpen, yHigh, yLow, yClose] entry per candle, scaled to the
    // min low / max high of the window. [] when the series is too short or
    // the arrays disagree (e.g. a quote cached by an older version).
    function scaleCandles(opens, highs, lows, closes, x, y, width, height) {
        if (!(closes instanceof Lang.Array) || closes.size() < 2
            || !(opens instanceof Lang.Array) || opens.size() != closes.size()
            || !(highs instanceof Lang.Array) || highs.size() != closes.size()
            || !(lows instanceof Lang.Array) || lows.size() != closes.size()) {
            return [];
        }
        var min = lows[0].toFloat();
        var max = highs[0].toFloat();
        for (var i = 1; i < closes.size(); i++) {
            var lo = lows[i].toFloat();
            var hi = highs[i].toFloat();
            if (lo < min) { min = lo; }
            if (hi > max) { max = hi; }
        }
        var range = max - min;
        if (range <= 0.0) {
            range = 1.0;
        }
        var candles = new [closes.size()];
        var step = width.toFloat() / closes.size();
        for (var i = 0; i < closes.size(); i++) {
            var cx = x + step * i + step / 2.0;
            candles[i] = [
                cx,
                y + height - ((opens[i].toFloat() - min) * height / range),
                y + height - ((highs[i].toFloat() - min) * height / range),
                y + height - ((lows[i].toFloat() - min) * height / range),
                y + height - ((closes[i].toFloat() - min) * height / range)
            ];
        }
        return candles;
    }

    function drawCandles(dc, candles, upColor, downColor) {
        if (candles.size() < 2) {
            return;
        }
        var step = candles[1][0] - candles[0][0];
        var bodyWidth = (step - 2.0).toNumber();
        if (bodyWidth < 1) { bodyWidth = 1; }
        if (bodyWidth > 9) { bodyWidth = 9; }
        dc.setPenWidth(1);
        for (var i = 0; i < candles.size(); i++) {
            var c = candles[i];
            // y grows downwards: close above open on screen = rising candle
            dc.setColor(c[4] <= c[1] ? upColor : downColor,
                Gfx.COLOR_TRANSPARENT);
            dc.drawLine(c[0], c[2], c[0], c[3]);
            var top = c[4] < c[1] ? c[4] : c[1];
            var bodyHeight = (c[4] - c[1]).abs();
            if (bodyHeight < 1) { bodyHeight = 1; }
            dc.fillRectangle(c[0] - bodyWidth / 2.0, top, bodyWidth,
                bodyHeight);
        }
    }

    // X coordinates of session-break markers: each break index (first candle
    // of a new session) maps to the midpoint between it and its predecessor.
    function breakXs(points, breaks) {
        var xs = [];
        if (!(breaks instanceof Lang.Array)) {
            return xs;
        }
        for (var i = 0; i < breaks.size(); i++) {
            var b = breaks[i];
            if (b instanceof Lang.Number && b >= 1 && b < points.size()) {
                xs.add((points[b - 1][0] + points[b][0]) / 2.0);
            }
        }
        return xs;
    }

    // Dashed vertical line across the chart box at every session break.
    function drawBreaks(dc, points, breaks, y, height, color) {
        var xs = breakXs(points, breaks);
        if (xs.size() == 0) {
            return;
        }
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < xs.size(); i++) {
            var yy = y;
            while (yy < y + height) {
                var yEnd = yy + 4;
                if (yEnd > y + height) {
                    yEnd = y + height;
                }
                dc.drawLine(xs[i], yy, xs[i], yEnd);
                yy += 8;
            }
        }
    }

    function draw(dc, points, color) {
        if (points.size() < 2) {
            return;
        }
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var i = 1; i < points.size(); i++) {
            dc.drawLine(points[i - 1][0], points[i - 1][1],
                points[i][0], points[i][1]);
        }
        dc.setPenWidth(1);
    }
}
