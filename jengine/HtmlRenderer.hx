package jengine;

import js.*;
import js.html.*;

import jengine.util.*;

class HtmlRenderer extends Component {
    public var size(default, default) :Vec2;
    public var floating(default, default) :Bool = false;

    var _options :Dynamic;
    var _elem :Element;

    var _cachedPos :Vec2;
    var _cachedSize :Vec2;

    public function new(options :Dynamic) {
        _options = options;

        var size = _options.size;
        if (size == null) {
            size = new Vec2(50, 50);
        }
        this.size = size;
    }

    public override function init() :Void {
        var parent;
        if (_options.parent != null) {
            parent = Browser.document.getElementById(_options.parent);
        }
        else {
            parent = Browser.document.body;
        }
        _elem = Browser.document.createElement('span');
        if (_options.id != null) {
            _elem.id = _options.id;
        }
        if (_options.className != null) {
            _elem.className = _options.className;
        }
        if (_options.text != null) {
            _elem.innerText = _options.text;
        }

        _elem.style.position = 'absolute';
        _elem.style.background = 'red';
        styleElement(_elem, _options.style);

        parent.appendChild(_elem);
    }

    public static function styleElement(elem :Element, style :Map<String, String>) :Void {
        if (style != null) {
            for (k in style.keys()) {
                elem.style.setProperty(k, style[k], '');
            }
        }
    }

    public override function deinit() :Void {
        _elem.parentElement.removeChild(_elem);
    }

    function getPos() :Vec2 {
        var pos = getTransform().pos;
        if (floating) {
            var container = _elem.parentElement;
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
        _cachedSize = size;
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
