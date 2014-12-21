package jengine;

import js.*;
import js.html.*;

import jengine.util.*;

class HtmlRenderer extends Component {
    var _size :Vec2;

    var _elem :Element;

    public function new(?size: Vec2) {
        if (size == null) {
            size = new Vec2(50, 50);
        }
        _size = size;
    }

    public override function init() :Void {
        var doc :Document = Browser.document;
        _elem = doc.createElement('span');
        doc.body.appendChild(cast _elem);
        _elem.style.position = 'absolute';
    }

    public override function deinit() :Void {
        Log.log('poo');
        _elem.parentElement.removeChild(_elem);
    }

    public override function draw() :Void {
        var trans = getComponent(Transform);
        _elem.style.left = cast trans.pos.x;
        _elem.style.top = cast trans.pos.y;
        _elem.style.width = cast _size.x;
        _elem.style.height = cast _size.y;
        _elem.style.background = '#ff0000';
    }

    public function getElement() :Element {
        return _elem;
    }
}
