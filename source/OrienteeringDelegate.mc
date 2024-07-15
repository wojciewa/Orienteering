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
    //! @return true if handled, false otherwise
    public function onMenu() as Boolean {
        //WatchUi.pushView(new $.Rez.Menus.MainMenu(), new $.MenuTestMenuDelegate(), WatchUi.SLIDE_UP);
        //return true;
        var menu = new WatchUi.Menu();
        var delegate;
        //menu.setTitle("My Menu");
        menu.addItem("Start", :m_start);
        menu.addItem("Pause", :m_pause);
        menu.addItem("Stop", :m_stop);
        delegate = new MenuIDelegate(_parentView); // a WatchUi.MenuInputDelegate
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
        return false;
    }

    public function onKey(evt as KeyEvent) as Boolean {
        var key = evt.getKey();

       if (key != null) {
           //System.println("test");
           System.println(key.toString());

           if (key == WatchUi.KEY_ESC) {
                _parentView.zeroLapDistance();
            } else if(key == WatchUi.KEY_DOWN){
                _parentView.appExit();
            }
           
            /*if (key == WatchUi.KEY_ENTER) {
                _parentView.startActivity();
            } else {
                _parentView.zeroLapDistance(key);
            }

            if (key == WatchUi.KEY_DOWN){
                _parentView.appExit();
            }*/
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
            System.println("Start");
            _parentView.startActivity();
            //WatchUi.pushView(new $.Rez.Menus.AuxMenu(), new $.AuxMenuDelegate(), WatchUi.SLIDE_UP);
        } else if (item == :m_pause) {
            System.println("Item 2");
            _parentView.startActivity();
        } else if (item == :m_stop) {
            _parentView.stopRecording(true);
             Ui.popView(Ui.SLIDE_UP);
        }
    }
}