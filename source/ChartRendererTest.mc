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
function testScalePointsTooShortSeries(logger) {
    Test.assertEqual(0, ChartRenderer.scalePoints([], 0, 0, 100, 50).size());
    Test.assertEqual(0, ChartRenderer.scalePoints([1.0], 0, 0, 100, 50).size());
    Test.assertEqual(0, ChartRenderer.scalePoints(null, 0, 0, 100, 50).size());
    return true;
}
