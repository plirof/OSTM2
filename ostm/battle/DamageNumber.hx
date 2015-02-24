package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.Util;

class DamageNumber extends Component {
    var _damage :Int;
    var _dist :Float = 180;
    var _timer :Float = 0;
    var _startPos :Vec2;
    var _elem :Element;
    var _alphaFadeoutPct = 0.15;

    static inline var kRemoveTime :Float = 1.25;

    public function new(damage :Int) {
        _damage = damage;
    }

    public override function start() :Void {
        _startPos = getTransform().pos;

        _elem = getComponent(HtmlRenderer).getElement();
        _elem.innerText = Util.format(_damage);
    }

    public override function update() :Void {
        _timer += Time.dt;

        var t = _timer / kRemoveTime;
        var s = t * (2 - t); // 1 - (x - 1)^2 = 2x - x^2
        getTransform().pos = _startPos + new Vec2(0, -_dist * s);
        if (t > 1 - _alphaFadeoutPct) {
            var a = (t - (1 - _alphaFadeoutPct)) / _alphaFadeoutPct;
            _elem.style.opacity = cast (1 - a);
        }

        if (_timer >= kRemoveTime) {
            entity.getSystem().removeEntity(entity);
        }
    }
}
