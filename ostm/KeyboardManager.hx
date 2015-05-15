package ostm;

import js.*;
import js.html.*;

import jengine.Component;

import ostm.battle.BattleManager;

class KeyboardManager extends Component {
    public static var instance(default, null) :KeyboardManager;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        Browser.document.onkeydown = function(event :KeyboardEvent) {
            if (event.keyCode >= 49 && event.keyCode <= 57) { // between '1' and '9'
                BattleManager.instance.keyDown(event.keyCode);
            }
        }
    }
}
