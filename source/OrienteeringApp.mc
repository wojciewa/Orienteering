import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
using Toybox.System as System;

class OrienteeringApp extends Application.AppBase {

    var _mainView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPositionUpdate));
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPositionUpdate));
    }

    //! Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        _mainView = new $.OrienteeringView();
        var delegate = new $.OrientDelegate(_mainView);
        
        return [ _mainView, delegate] as Array<Views or InputDelegates>;
    }

    function onPositionUpdate(info) {
        var posinfo = info;
        if (info.accuracy >= Position.QUALITY_POOR){
           
            _mainView.getGPSPower(info.accuracy);
        }
        
    }

}

function getApp() as OrienteeringApp {
    return Application.getApp() as OrienteeringApp;
}