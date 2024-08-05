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

        if(!_parentView.isActivityRunning()){
            menu.addItem(WatchUi.loadResource(Rez.Strings.mActivityType), :m_type);
        }
        menu.addItem(WatchUi.loadResource(Rez.Strings.mStart), :m_start);
        menu.addItem(WatchUi.loadResource(Rez.Strings.mPause), :m_pause);
        menu.addItem(WatchUi.loadResource(Rez.Strings.mStop), :m_stop);
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
                 _parentView.stopRecording(true, true);
                _parentView.appExit();
            } else if (key == WatchUi.KEY_ENTER){
                _parentView.StopStart();
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
            _parentView.startRecording();
        } else if (item == :m_pause) {
            _parentView.stopRecording(false, false);
        } else if (item == :m_stop) {
            _parentView.stopRecording(true, false);
             
        } else if (item == :m_type) {
            var menu = new WatchUi.Menu();
            var delegate;
            
            menu.addItem(WatchUi.loadResource(Rez.Strings.sportWalk), :m_walk);
            menu.addItem(WatchUi.loadResource(Rez.Strings.sportRun), :m_run);
            menu.addItem(WatchUi.loadResource(Rez.Strings.sportBike), :m_bike); 
            menu.addItem(WatchUi.loadResource(Rez.Strings.sportPaddling), :m_paddling);
            delegate = new MenuIActivityDelegate(_parentView); 
            WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

//! Input handler to respond to main menu selections
class MenuIActivityDelegate extends WatchUi.MenuInputDelegate {

    private var _parentView as OrienteeringView;

    //! Constructor
    public function initialize(view as OrienteeringView) {
        MenuInputDelegate.initialize(); 
        _parentView = view;
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onMenuItem(item as Symbol) as Void {
        if (item == :m_walk) {
            _parentView.setActivityType(ActivityRecording.SPORT_WALKING);
        } else if (item == :m_run) {
            _parentView.setActivityType(ActivityRecording.SPORT_RUNNING);
        } else if (item == :m_bike) {
            _parentView.setActivityType(ActivityRecording.SPORT_CYCLING);
        }else if (item == :m_paddling) {
            _parentView.setActivityType(ActivityRecording.SPORT_PADDLING);
        } 
    }
}