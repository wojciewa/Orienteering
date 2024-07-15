using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;
using Toybox.System as System;
using Toybox.Activity as Act;
using Toybox.ActivityRecording as Se;
using Toybox.Graphics as Gfx;
import Toybox.Lang;

class OrienteeringView extends Ui.View {

    //hidden var mValue as Numeric;

    hidden const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    hidden const HEADER_FONT = Graphics.FONT_XTINY;
    hidden const VALUE_FONT = Graphics.FONT_NUMBER_MEDIUM;
    hidden const ZERO_TIME = "0:00";
    hidden const ZERO_DISTANCE = "0.00";
    
    hidden var kmOrMileInMeters = 1000;
    hidden var is24Hour = true;
    hidden var distanceUnits = System.UNIT_METRIC;
    hidden var textColor = Graphics.COLOR_BLACK;
    hidden var inverseTextColor = Graphics.COLOR_WHITE;
    hidden var backgroundColor = Graphics.COLOR_WHITE;
    hidden var inverseBackgroundColor = Graphics.COLOR_BLACK;
    hidden var inactiveGpsBackground = Graphics.COLOR_LT_GRAY;
    hidden var batteryBackground = Graphics.COLOR_WHITE;
    hidden var batteryColor1 = Graphics.COLOR_GREEN;
    hidden var hrColor = Graphics.COLOR_RED;
    hidden var headerColor = Graphics.COLOR_DK_GRAY;
        
    hidden var paceStr, avgPaceStr, hrStr, distanceStr, durationStr, tmpDistStr;
    
    //hidden var paceData = new DataQueue(10);

    hidden var doUpdates = 0;

    //hidden var avgSpeed= 0;
    //hidden var hr = 0;
    hidden var distance = 0;
    var lastLapDistance = 0;
    var lapDistance = 0;
    hidden var elapsedTime = 0;
    hidden var gpsSignal = 0;
    
    hidden var currentCadence = 0;
    hidden var averageCadence = 0;
    hidden var maxCadence = 0;
    
    hidden var hasBackgroundColorOption = false;
    var myTimer;
    hidden var hasGPSSignal=false;
   
    var activityInProgress = false; // To track if activity is in progress
    private var _session as Se.Session?;
    
    function initialize() {
        View.initialize();
        setupTimer();
        
    }

    function doUpdate() as Void {
        Ui.requestUpdate();    
    }

    function setupTimer() {
        myTimer = new Timer.Timer();
        myTimer.start(method(:doUpdate), 1000, true);
    }

     //! The given info object contains all the current workout
    function compute(info) {
        
        elapsedTime = info.timerTime != null ? info.timerTime : 0;        
        distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
        
        // Calculate the lap distance
        //lastLapDistance = distance - lastLapDistance;
        lapDistance = distance - lastLapDistance;
        //System.println("compute_distance = " + distance.toString());
        //System.println("compute_lastLapDistance = " + lastLapDistance.toString());
        //System.println("compute_lapDistance = " + lapDistance.toString());

        gpsSignal = info.currentLocationAccuracy != null ? info.currentLocationAccuracy : 0;

        maxCadence = info.maxCadence != null ? info.maxCadence : 0;
        averageCadence = info.averageCadence != null ? info.averageCadence : 0;
        currentCadence = info.currentCadence != null ? info.currentCadence : 0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) as Void {
       setDeviceSettingsDependentVariables();
    }

    function setDeviceSettingsDependentVariables() {
        hasBackgroundColorOption = (self has :getBackgroundColor);
        
        distanceUnits = System.getDeviceSettings().distanceUnits;
        if (distanceUnits == System.UNIT_METRIC) {
            kmOrMileInMeters = 1000;
        } else {
            kmOrMileInMeters = 1610;
        }
        is24Hour = System.getDeviceSettings().is24Hour;
        
        distanceStr = Ui.loadResource(Rez.Strings.distance);
        durationStr = Ui.loadResource(Rez.Strings.duration);
        tmpDistStr = Ui.loadResource(Rez.Strings.tmpDist);
    }

    function onShow() {
        doUpdates = true;
        return;
    }
    
    function onHide() {
        doUpdates = false;
    }
    
    function onUpdate(dc) {
        if(doUpdates == false) {
            return;
        }

        //if (!doUpdates || !activityInProgress) {
        //    return;
        //}
        
        setColors();
        // reset background
        dc.setColor(backgroundColor, backgroundColor);
        dc.fillRectangle(0, 0, 218, 218);
        var activityInfo = Act.getActivityInfo();
        compute(activityInfo);
        drawValues(dc);
    }

    function setColors() {
        if (hasBackgroundColorOption) {
            backgroundColor = Graphics.COLOR_BLACK; //getBackgroundColor();
            textColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
            inverseTextColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_WHITE;
            inverseBackgroundColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_DK_GRAY: Graphics.COLOR_BLACK;
            headerColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_LT_GRAY: Graphics.COLOR_DK_GRAY;
            batteryColor1 = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_BLUE : Graphics.COLOR_DK_GREEN;
        }
    }

    function drawCurrentTime(dc)
    {
        var clockTime = System.getClockTime();
        var time, ampm;
        if (is24Hour) {
            time = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
            ampm = "";
        } else {
            time = Lang.format("$1$:$2$", [computeHour(clockTime.hour), clockTime.min.format("%.2d")]);
            ampm = (clockTime.hour < 12) ? "am" : "pm";
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0,0,218,25);
        dc.setColor(inverseTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(109, 12, Graphics.FONT_MEDIUM, time, CENTER);
        dc.drawText(148, 15, HEADER_FONT, ampm, CENTER);
        
    }

    function drawGPS(dc)
    {
        // gps 
        if (gpsSignal < 2) {
            drawGpsSign(dc, 136, 181, inactiveGpsBackground, inactiveGpsBackground, inactiveGpsBackground);
        } else if (gpsSignal == 2) {
            drawGpsSign(dc, 136, 181, batteryColor1, inactiveGpsBackground, inactiveGpsBackground);
        } else if (gpsSignal == 3) {          
            drawGpsSign(dc, 136, 181, batteryColor1, batteryColor1, inactiveGpsBackground);
        } else {
            drawGpsSign(dc, 136, 181, batteryColor1, batteryColor1, batteryColor1);
        }
    }

    function drawHeaders(dc)
    {
         // headers:
        dc.setColor(headerColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(57, 160, HEADER_FONT, distanceStr, CENTER);
        dc.drawText(102, 38, HEADER_FONT, tmpDistStr, CENTER);
        dc.drawText(158, 160, HEADER_FONT, durationStr, CENTER);

        
        //grid
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, 104, dc.getWidth(), 104);
    }

    function getDistString(distanceL) // as String //distStr
    {
        var _tmpStr;
        if (distanceL > 0) {
            var distanceKmOrMiles = distanceL / kmOrMileInMeters;
            if (distanceKmOrMiles < 100) {
                _tmpStr = distanceKmOrMiles.format("%.2f");
            } else {
                _tmpStr = distanceKmOrMiles.format("%.1f");
            }
        } else {
            _tmpStr = ZERO_DISTANCE;
        }

        return _tmpStr;
        
    }

    function drawValues(dc) {
        //time
        drawCurrentTime(dc);
        
        //distance
        var distStr;
        var lastLapString;

        distStr = getDistString(distance);
        lastLapString = getDistString(lapDistance);
        //System.println("drawValues_distance = " + distance.toString());
        //System.println("drawValues_distance_string = " + distStr);
        //System.println("drawValues_lapDistance = " + lapDistance.toString());
        //System.println("drawValues_lapDistance_string = " + lastLapString);
        
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(108 , 70, VALUE_FONT, lastLapString, CENTER);
        dc.drawText(54, 130, VALUE_FONT, distStr, CENTER);
                
        //duration
        var duration;
        if (elapsedTime != null && elapsedTime > 0) {
            var hours = null;
            var minutes = elapsedTime / 1000 / 60;
            var seconds = elapsedTime / 1000 % 60;
            
            if (minutes >= 60) {
                hours = minutes / 60;
                minutes = minutes % 60;
            }
            
            if (hours == null) {
                duration = minutes.format("%d") + ":" + seconds.format("%02d");
            } else {
                duration = hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
            }
        } else {
            duration = ZERO_TIME;
        } 
        dc.drawText(173, 130, VALUE_FONT, duration, CENTER);
        
        //signs background
        dc.setColor(inverseBackgroundColor, inverseBackgroundColor);
        dc.fillRectangle(0,180,218,38);
        
        // km/miles
        dc.setColor(inverseTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(112, 207, HEADER_FONT, distanceUnits == System.UNIT_METRIC ? "(km)" : "(mi)", CENTER);
        
        drawBattery(System.getSystemStats().battery, dc, 64, 186, 25, 15);
        
        drawGPS(dc);
        drawHeaders(dc);
       
    }

    function drawBattery(battery, dc, xStart, yStart, width, height) {                
        dc.setColor(batteryBackground, inactiveGpsBackground);
        dc.fillRectangle(xStart, yStart, width, height);
        if (battery < 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xStart+3 + width / 2, yStart + 6, HEADER_FONT, format("$1$%", [battery.format("%d")]), CENTER);
        }
        
        if (battery < 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else if (battery < 30) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(batteryColor1, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(xStart + 1, yStart + 1, (width-2) * battery / 100, height - 2);
            
        dc.setColor(batteryBackground, batteryBackground);
        dc.fillRectangle(xStart + width - 1, yStart + 3, 4, height - 6);
    }

    function drawGpsSign(dc, xStart, yStart, color1, color2, color3) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(xStart - 1, yStart + 11, 8, 10);
        dc.setColor(color1, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart, yStart + 12, 6, 8);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(xStart + 6, yStart + 7, 8, 14);
        dc.setColor(color2, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart + 7, yStart + 8, 6, 12);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(xStart + 13, yStart + 3, 8, 18);
        dc.setColor(color3, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart + 14, yStart + 4, 6, 16);
    }
    
    function computeHour(hour) {
        if (hour < 1) {
            return hour + 12;
        }
        if (hour >  12) {
            return hour - 12;
        }
        return hour;      
    }

    //! convert to integer - round ceiling 
    function toNumberCeil(float) {
        var floor = float.toNumber();
        if (float - floor > 0) {
            return floor + 1;
        }
        return floor;
    }
    
    function getMinutesPerKmOrMile(speedMetersPerSecond) {
        if (speedMetersPerSecond != null && speedMetersPerSecond > 0.2) {
            var metersPerMinute = speedMetersPerSecond * 60.0;
            var minutesPerKmOrMilesDecimal = kmOrMileInMeters / metersPerMinute;
            var minutesPerKmOrMilesFloor = minutesPerKmOrMilesDecimal.toNumber();
            var seconds = (minutesPerKmOrMilesDecimal - minutesPerKmOrMilesFloor) * 60;
            return minutesPerKmOrMilesDecimal.format("%2d") + ":" + seconds.format("%02d");
        } 
        return ZERO_TIME;
    }

    public function zeroLapDistance() as Void {
        
        /*var alert = new Alert({
                        :timeout => 2000,
                        :font => Gfx.FONT_MEDIUM,
                        :text => Ui.loadResource(Rez.Strings.gpsSig),
                        :fgcolor => Gfx.COLOR_RED,
                        :bgcolor => Gfx.COLOR_WHITE
                        });

        alert.pushView(Ui.SLIDE_UP);
        */
        
        //if (newKey == Ui.KEY_ESC) {
            var activityInfo = Act.getActivityInfo();
            lastLapDistance = activityInfo.elapsedDistance != null ? activityInfo.elapsedDistance : 0;
            //System.println("===== ZERO =====");
        //}
        
        
    }

    public function startActivity() as Void {
       
            activityInProgress = !activityInProgress;
            if (activityInProgress) {
                startRecording();
                //System.println("Activity Started");
            } else {
                stopRecording(false);
                //System.println("Activity Stopped");
            }
        
    }

    //! Start recording a session
    public function startRecording() as Void {
        var session = _session;
        if ((Toybox has :ActivityRecording) && (session != null)) {
            _session.start();
        } else {
            _session = Se.createSession({:name=>"Walk", :sport=>ActivityRecording.SPORT_WALKING});
            _session.start();
        }

        doUpdate();
    }

     //! Stop the recording if necessary
    public function stopRecording(bSave as Boolean) as Void {
        var session = _session;
        if ((Toybox has :ActivityRecording) && isSessionRecording() && (session != null)) {
            session.stop();

            if(bSave){
                session.save();
                _session = null;
            

            var alert = new Alert({
                                :timeout => 2000,
                                :font => Gfx.FONT_MEDIUM,
                                :text => Ui.loadResource(Rez.Strings.saved),
                                :fgcolor => Gfx.COLOR_RED,
                                :bgcolor => Gfx.COLOR_WHITE,
                                :bBack => true
                                });

                alert.pushView(Ui.SLIDE_UP);
            }
            doUpdate();
        }
    }

    //! Get whether a session is currently recording
    //! @return true if there is a session currently recording, false otherwise
    public function isSessionRecording() as Boolean {
        if (_session != null) {
            return _session.isRecording();
        }
        return false;
    }

    //Exit app
    public function appExit() as Void {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    public function getGPSPower(int) as Void {
        System.println("Sila sygnalu: " + int.toString());
        
        if(!hasGPSSignal)
        {
            hasGPSSignal=!hasGPSSignal;
            
            var alert = new Alert({
                            :timeout => 2000,
                            :font => Gfx.FONT_MEDIUM,
                            :text => "GPS!",
                            :fgcolor => Gfx.COLOR_RED,
                            :bgcolor => Gfx.COLOR_WHITE
                            });

            alert.pushView(Ui.SLIDE_UP);
        }
        
    }

}