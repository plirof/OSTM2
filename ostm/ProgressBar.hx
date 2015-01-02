package ostm;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.*;

class ProgressBar extends Component {
    var _elem :Element;
    var _style :Map<String, String>;
    var _func :Void -> Float;

    public function new(func :Void -> Float, ?style :Map<String, String>) {
        _func = func;
        _style = style;
    } 

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        if (renderer != null) {
            _elem = Browser.document.createSpanElement();
            _elem.style.position = 'absolute';
            _elem.style.height = '100%';
            _elem.style.background = 'white';

            HtmlRenderer.styleElement(_elem, _style);

            renderer.getElement().appendChild(_elem);
        }
    }

    public override function update() :Void {
        _elem.style.width = (100 * Util.clamp01(_func())) + '%';
    }

    public function setFunction(f) :Void {
        _func = f;
    }
}
