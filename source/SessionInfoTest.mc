using Toybox.Test;

(:test)
function testSessionPhaseBeforeDuringAfter(logger) {
    Test.assert(SessionInfo.phase(5, 10, 20) == :before);
    Test.assert(SessionInfo.phase(10, 10, 20) == :during);
    Test.assert(SessionInfo.phase(15, 10, 20) == :during);
    Test.assert(SessionInfo.phase(20, 10, 20) == :after);
    Test.assert(SessionInfo.phase(25, 10, 20) == :after);
    return true;
}

(:test)
function testSessionPhaseMissingBounds(logger) {
    Test.assert(SessionInfo.phase(5, null, 20) == null);
    Test.assert(SessionInfo.phase(5, 10, null) == null);
    Test.assert(SessionInfo.phase(5, "10", 20) == null);
    return true;
}
