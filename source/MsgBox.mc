using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Timer as Timer;


class Alert extends Ui.View
{
    hidden var timer;
    hidden var timeout;
    hidden var text;
    hidden var font;
    hidden var fgcolor;
    hidden var bgcolor;
    hidden var bBack;

    function initialize(params) {
        View.initialize();

        text = params.get(:text);
        if (text == null) {
            text = "Alert";
        }
    

        font = params.get(:font);
        if (font == null) {
            font = Gfx.FONT_MEDIUM;
        }

        fgcolor = params.get(:fgcolor);
        if (fgcolor == null) {
            fgcolor = Gfx.COLOR_BLACK;
        }

        bgcolor = params.get(:bgcolor);
        if (bgcolor == null) {
            bgcolor = Gfx.COLOR_WHITE;
        }

        timeout = params.get(:timeout);
        if (timeout == null) {
            timeout = 2000;
        }

        bBack = params.get(:back);
        if (bBack == null) {
            bBack = false;
        }

        timer = new Timer.Timer();
    }

    function onShow() {
        timer.start(method(:dismiss), timeout, false);
    }

    function onHide() {
        timer.stop();
    }

    function onUpdate(dc) {
        var tWidth = dc.getTextWidthInPixels(text, font);
        var tHeight = dc.getFontHeight(font);

        var bWidth = tWidth + 14;
        var bHeight = tHeight + 14;

        var bX = (dc.getWidth() - bWidth) / 2;
        var bY = (dc.getHeight() - bHeight) / 2;

        dc.setColor(bgcolor, bgcolor);
        dc.fillRectangle(bX, bY, bWidth, bHeight);

        dc.setColor(fgcolor, bgcolor);
        for (var i = 0; i < 3; ++i) {
            bX += i;
            bY += i;
            bWidth -= (2 * i);
            bHeight -= (2 * i);

            dc.drawRectangle(bX, bY, bWidth, bHeight);
        }

        var tX = dc.getWidth() / 2;
        var tY = bY + bHeight / 2;

        dc.setColor(fgcolor, bgcolor);
        dc.drawText(tX, tY, font, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function dismiss() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        //if(bBack){
        //    Ui.popView(Ui.SLIDE_UP);
        //}
    }

    function pushView(transition) {
        Ui.pushView(self, new Delegate(self), transition);
       
    }
}


class GraphicInfo extends Ui.View
{
    hidden var timer;
    hidden var timeout;
    hidden var gsymbol;
    hidden var fgcolor;
    hidden var bgcolor;
    hidden var bBack;

    // gsymbol = 0 => ( )
    //         = 1 => ( || ) /Pause/
    //         = 2 => ( |> ) /Start/

    function initialize(params) {
        View.initialize();

        gsymbol = params.get(:gsymbol);
        if (gsymbol == null) {
            gsymbol = 0; //null
        }

        fgcolor = params.get(:fgcolor);
        if (fgcolor == null) {
            fgcolor = Gfx.COLOR_BLACK;
        }

        bgcolor = params.get(:bgcolor);
        if (bgcolor == null) {
            bgcolor = Gfx.COLOR_WHITE;
        }

        timeout = params.get(:timeout);
        if (timeout == null) {
            timeout = 2000;
        }

        bBack = params.get(:back);
        if (bBack == null) {
            bBack = false;
        }

        timer = new Timer.Timer();
    }

    function onShow() {
        timer.start(method(:dismiss), timeout, false);
    }

    function onHide() {
        timer.stop();
    }

    function onUpdate(dc) {
        var centerX;
        var centerY;
        
        switch (gsymbol)
        {
            
            
            case 1:
                var rectHeight = 60; // Wysokość prostokątów
                var totalWidth = 40; // Całkowita szerokość (w tym przerwa między prostokątami)
                var rectWidth = 15;  // Szerokość każdego prostokąta
                var gap = 10;        // Przerwa między prostokątami

                centerX = dc.getWidth() / 2;
                centerY = dc.getHeight() / 2;

                // Współrzędne lewego prostokąta
                var leftRectX = centerX - (rectWidth + gap / 2);
                var leftRectY = centerY - rectHeight / 2;

                // Współrzędne prawego prostokąta
                var rightRectX = centerX + gap / 2;
                var rightRectY = centerY - rectHeight / 2;

                dc.setColor(fgcolor, bgcolor);

                // Rysowanie lewego prostokąta
                dc.fillRectangle(leftRectX, leftRectY, rectWidth, rectHeight);

                // Rysowanie prawego prostokąta
                dc.fillRectangle(rightRectX, rightRectY, rectWidth, rectHeight);
                break;
            case 2:
                var baseWidth = 40; // Szerokość podstawy trójkąta
                var height = 60;    // Wysokość trójkąta

                centerX = dc.getWidth() / 2;
                centerY = dc.getHeight() / 2;

                var points = [];
                points.add([centerX + baseWidth / 2, centerY]);
                points.add([centerX - baseWidth / 2, centerY - height / 2]);
                points.add([centerX - baseWidth / 2, centerY + height / 2]);
                 
                dc.setColor(fgcolor, bgcolor);
                dc.fillPolygon(points);

                break;
            default:
                break;
        }

    }

    function dismiss() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        //if(bBack){
        //    Ui.popView(Ui.SLIDE_UP);
        //}
    }

    function pushView(transition) {
        Ui.pushView(self, new Delegate(self), transition);
       
    }
}

class Delegate extends Ui.InputDelegate
{
    hidden var view;

    function initialize(view) {
        InputDelegate.initialize();
        self.view = view;
    }

    function onKey(evt) {
        view.dismiss();
        return true;
    }
}