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
