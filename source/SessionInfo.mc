using Toybox.Lang;

module SessionInfo {

    // Where "now" falls against the regular session: :before, :during or
    // :after. Null when the session bounds are missing or not numeric.
    function phase(now, start, end) {
        if (!(start instanceof Lang.Number) && !(start instanceof Lang.Long)) {
            return null;
        }
        if (!(end instanceof Lang.Number) && !(end instanceof Lang.Long)) {
            return null;
        }
        if (now < start) {
            return :before;
        }
        if (now < end) {
            return :during;
        }
        return :after;
    }
}
