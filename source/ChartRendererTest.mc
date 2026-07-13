using Toybox.Test;

(:test)
function testScalePointsMapsMinMaxToBox(logger) {
    var points = ChartRenderer.scalePoints([10.0, 20.0, 15.0], 0, 100, 200, 80);
    Test.assertEqual(3, points.size());
    // first sample: min -> bottom of the box
    Test.assertEqual(0.0, points[0][0]);
    Test.assertEqual(180.0, points[0][1]);
    // second sample: max -> top of the box
    Test.assertEqual(100.0, points[1][0]);
    Test.assertEqual(100.0, points[1][1]);
    // third sample: halfway
    Test.assertEqual(200.0, points[2][0]);
    Test.assertEqual(140.0, points[2][1]);
    return true;
}

(:test)
function testScalePointsFlatSeriesStaysInBox(logger) {
    var points = ChartRenderer.scalePoints([5.0, 5.0], 10, 50, 100, 40);
    Test.assertEqual(2, points.size());
    // flat series: drawn at the bottom edge, not outside the box
    Test.assertEqual(90.0, points[0][1]);
    Test.assertEqual(90.0, points[1][1]);
    return true;
}

(:test)
function testScaleCandlesMapsExtremesToBox(logger) {
    var candles = ChartRenderer.scaleCandles(
        [12.0, 16.0], [20.0, 18.0], [10.0, 14.0], [15.0, 17.0],
        0, 100, 200, 80);
    Test.assertEqual(2, candles.size());
    // slots are 100 px wide, centers at 50 and 150
    Test.assertEqual(50.0, candles[0][0]);
    Test.assertEqual(150.0, candles[1][0]);
    // min low (10) -> bottom edge, max high (20) -> top edge
    Test.assertEqual(180.0, candles[0][3]);
    Test.assertEqual(100.0, candles[0][2]);
    // close 15 sits halfway
    Test.assertEqual(140.0, candles[0][4]);
    return true;
}

(:test)
function testScaleCandlesRejectsMismatchedSeries(logger) {
    // quote cached by an older version: no OHLC arrays next to closes
    Test.assertEqual(0, ChartRenderer.scaleCandles(
        null, null, null, [1.0, 2.0], 0, 0, 100, 50).size());
    Test.assertEqual(0, ChartRenderer.scaleCandles(
        [1.0], [1.0, 2.0], [1.0, 2.0], [1.0, 2.0], 0, 0, 100, 50).size());
    return true;
}

(:test)
function testBreakXsMidwayBetweenNeighbours(logger) {
    var points = [[0.0, 10.0], [100.0, 20.0], [200.0, 30.0]];
    var xs = ChartRenderer.breakXs(points, [1]);
    Test.assertEqual(1, xs.size());
    Test.assertEqual(50.0, xs[0]);
    return true;
}

(:test)
function testBreakXsIgnoresOutOfRangeIndexes(logger) {
    var points = [[0.0, 10.0], [100.0, 20.0]];
    // 0 has no left neighbour, 5 is past the series, null breaks tolerated
    Test.assertEqual(0, ChartRenderer.breakXs(points, [0, 5]).size());
    Test.assertEqual(0, ChartRenderer.breakXs(points, null).size());
    return true;
}

(:test)
function testScalePointsTooShortSeries(logger) {
    Test.assertEqual(0, ChartRenderer.scalePoints([], 0, 0, 100, 50).size());
    Test.assertEqual(0, ChartRenderer.scalePoints([1.0], 0, 0, 100, 50).size());
    Test.assertEqual(0, ChartRenderer.scalePoints(null, 0, 0, 100, 50).size());
    return true;
}
