package jengine;

import js.*;
import js.html.*;

import jengine.util.*;

class HtmlRenderer extends Component {
    public var size(default, default) :Vec2;
    public var floating(default, default) :Bool = false;

    var _parentId :String;
    var _elem :Element;

    var _cachedPos :Vec2;
    var _cachedSize :Vec2;

    public function new(parent :String, ?siz: Vec2) {
        _parentId = parent;
        if (siz == null) {
            siz = new Vec2(50, 50);
        }
        size = siz;
    }

    public override function init() :Void {
        var parent = Browser.document.getElementById(_parentId);
        _elem = Browser.document.createElement('span');
        parent.appendChild(cast _elem);
        _elem.style.position = 'absolute';
        _elem.style.background = 'red';
    }

    public override function deinit() :Void {
        _elem.parentElement.removeChild(_elem);
    }

    function getPos() :Vec2 {
        var pos = getTransform().pos;
        if (floating) {
            var container = _elem.parentElement;
            // var container = Browser.document.body;
            var scroll = new Vec2(container.scrollLeft, container.scrollTop);
            pos += scroll;
        }
        return pos;
    }

    function isDirty() :Bool {
        return _cachedPos != getPos() || _cachedSize != size;
    }
    function markClean() :Void {
        _cachedPos = getPos();
    }

    public override function draw() :Void {
        if (isDirty()) {
            markClean();

            var pos = getPos();
            _elem.style.left = cast pos.x;
            _elem.style.top = cast pos.y;
            _elem.style.width = cast size.x;
            _elem.style.height = cast size.y;
        }
    }

    public function getElement() :Element {
        return _elem;
    }
}
