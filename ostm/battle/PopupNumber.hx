package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;

class PopupNumber extends Component {
    var _color :String;
    var _text :String;
    var _fontSize :Int;

    var _dist :Float;
    var _removeTime :Float;
    var _startPos :Vec2;
    var _elem :Element;
    var _timer :Float = 0;
    var _alphaFadeoutPct = 0.15;


    public function new(text :String, color :String, fontSize :Int, dist :Float, time :Float) {
        _text = text;
        _color = color;
        _fontSize = fontSize;
        _dist = dist;
        _removeTime = time;
    }

    public override function start() :Void {
        _startPos = getTransform().pos;

        _elem = getComponent(HtmlRenderer).getElement();

        _elem.innerText = _text;

        _elem.style.color = _color;

        _elem.style.background = 'none';
        _elem.style.zIndex = '10';
        _elem.style.fontSize = _fontSize + 'px';
    }

    public override function update() :Void {
        _timer += Time.dt;

        var t = _timer / _removeTime;
        var s = t * (2 - t); // 1 - (x - 1)^2 = 2x - x^2
        getTransform().pos = _startPos + new Vec2(0, -_dist * s);
        if (t > 1 - _alphaFadeoutPct) {
            var a = (t - (1 - _alphaFadeoutPct)) / _alphaFadeoutPct;
            _elem.style.opacity = cast (1 - a);
        }

        if (_timer >= _removeTime) {
            entity.getSystem().removeEntity(entity);
        }
    }
}
