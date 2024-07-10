import Toybox.Lang;
import Toybox.WatchUi;

class OrientDelegate extends WatchUi.InputDelegate {

    private var _parentView as OrienteeringView;

    function initialize(view as OrienteeringView) {
        InputDelegate.initialize();
         _parentView = view;
    }

    /*public function onKey(evt as KeyEvent) as Boolean {
        var key = evt.getKey();

       // var button = getButton(key);
        System.println("test");
        return true;
    } */

    public function onKey(evt as KeyEvent) as Boolean {
        var key = evt.getKey();

       if (key != null) {
           //System.println("test");
           System.println(key.toString());
            if (key == WatchUi.KEY_ENTER) {
                _parentView.startActivity();
            } else {
                _parentView.zeroLapDistance(key);
            }

            if (key == WatchUi.KEY_DOWN){
                _parentView.appExit();
            }
        }
        return true;
    }

}