package ostm;

import js.*;
import js.html.*;

import jengine.*;

class ProgressBar extends Component {
    var _elem :Element;
    var _func :Void -> Float;

    public function new(func :Void -> Float) {
        _func = func;
    } 

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        if (renderer != null) {
            _elem = Browser.document.createSpanElement();
            _elem.style.position = 'absolute';
            _elem.style.height = '100%';
            _elem.style.background = 'white';
            renderer.getElement().appendChild(_elem);
        }
    }

    public override function update() :Void {
        _elem.style.width = (100 * _func()) + '%';
    }
}
