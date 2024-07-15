import Toybox.Lang;
import Toybox.WatchUi;


//! Handle input for the home view
class OrientDelegate extends WatchUi.BehaviorDelegate {
    
    private var _parentView as OrienteeringView;

    //! Constructor
    public function initialize(view as OrienteeringView) {
        BehaviorDelegate.initialize();
        _parentView = view;
    }

    //! Handle the menu event
    //! return false to onKey procced
    public function onMenu() as Boolean {
        var menu = new WatchUi.Menu();
        var delegate;
       
        menu.addItem("Start", :m_start);
        menu.addItem("Pause", :m_pause);
        menu.addItem("Stop", :m_stop);
        delegate = new MenuIDelegate(_parentView); 
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
        return false;
    }

    public function onKey(evt as KeyEvent) as Boolean {
        var key = evt.getKey();

       if (key != null) {
           
           if (key == WatchUi.KEY_ESC) {
                _parentView.zeroLapDistance();
            } else if(key == WatchUi.KEY_DOWN){
                _parentView.appExit();
            }
        }
        return true;
    }
}

//! Input handler to respond to main menu selections
class MenuIDelegate extends WatchUi.MenuInputDelegate {

    private var _parentView as OrienteeringView;

    //! Constructor
    public function initialize(view as OrienteeringView) {
        MenuInputDelegate.initialize(); 
        _parentView = view;
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onMenuItem(item as Symbol) as Void {
        if (item == :m_start) {
            _parentView.startActivity();
        } else if (item == :m_pause) {
            _parentView.startActivity();
        } else if (item == :m_stop) {
            _parentView.stopRecording(true);
        }
    }
}