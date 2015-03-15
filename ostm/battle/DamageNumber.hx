package ostm.battle;

import jengine.util.Util;

class DamageNumber extends PopupNumber {
    public function new(damage :Int, isCrit :Bool, isPlayer :Bool) {
        var text = Util.format(damage);
        if (isCrit) {
            text += '!';
        }
        var color = switch [isPlayer, isCrit] {
            case [false, false]: '#ffffff';
            case [false, true]: '#ffff66';
            case [true, false]: '#ff2244';
            case [true, true]: '#ff33aa';
        }
        var size = isCrit ? 40 : 26;
        super(text, color, size, 180, 1.25);
    }
}
