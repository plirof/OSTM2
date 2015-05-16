package ostm;

import js.*;
import js.html.*;

import jengine.Component;

import ostm.battle.BattleManager;

class KeyboardManager extends Component {
    public static var instance(default, null) :KeyboardManager;

    public var isShiftHeld(default, null) :Bool = false;
    public var isCtrlHeld(default, null) :Bool = false;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        Browser.document.onkeydown = function(event :KeyboardEvent) {
            var key = event.keyCode;
            // trace('Key pressed: ' + key);

            if (key >= 49 && key <= 57) { // between '1' and '9'
                BattleManager.instance.keyDown(key);
            }

            updateKey(key, true);
        };

        Browser.document.onkeyup = function(event :KeyboardEvent) {
            var key = event.keyCode;
            updateKey(key, false);
        };
    }

    function updateKey(key :Int, pressed :Bool) {
        if (key == 16) {
            isShiftHeld = pressed;
        }
        if (key == 17 || key == 91) { //ctrl or command?
            isCtrlHeld = pressed;
        }
    }
}
