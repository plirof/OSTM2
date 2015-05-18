package ostm.battle;

import js.*;
import js.html.*;

import jengine.Component;
import jengine.HtmlRenderer;

class CenteredText extends Component {
    var _elem :Element;
    var _textFunc :Void -> String;
    var _fontSize :Int;

    public function new(textFunc :Void -> String, fontSize :Int = 16) {
        _textFunc = textFunc;
        _fontSize = fontSize;
    }

    public override function update() :Void {
        if (_elem == null) {
            var renderer = getComponent(HtmlRenderer);
            if (renderer != null) {
                _elem = Browser.document.createSpanElement();
                _elem.style.position = 'absolute';
                _elem.style.width = cast renderer.size.x;
                _elem.style.textAlign = 'center';
                _elem.style.fontSize = cast _fontSize;
                _elem.style.zIndex = cast 1;
                renderer.getElement().appendChild(_elem);
            }
        }
        if (_elem != null) {
            _elem.innerText = _textFunc();
        }
    }
}
