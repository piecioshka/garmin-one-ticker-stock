using Toybox.Application as App;

class StocksApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new StocksView()];
    }

    function onSettingsChanged() {
        App.Storage.deleteValue("quote");
    }
}
