package jengine;

import js.*;
import js.html.*;

import jengine.util.*;

class HtmlRenderer extends Component {
    var _size :Vec2;

    var _elem :Element;

    var _cachedPos :Vec2;
    var _cachedSize :Vec2;

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
        _elem.style.background = '#ff0000';
    }

    public override function deinit() :Void {
        _elem.parentElement.removeChild(_elem);
    }

    function isDirty() :Bool {
        return _cachedPos != getTransform().pos;
    }
    function markClean() :Void {
        _cachedPos = getTransform().pos;
    }

    public override function draw() :Void {
        if (isDirty()) {
            markClean();

            var trans = getComponent(Transform);
            _elem.style.left = cast trans.pos.x;
            _elem.style.top = cast trans.pos.y;
            _elem.style.width = cast _size.x;
            _elem.style.height = cast _size.y;
        }
    }

    public function getElement() :Element {
        return _elem;
    }
}
