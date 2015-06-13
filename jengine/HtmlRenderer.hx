package jengine;

import js.*;
import js.html.*;

import jengine.util.*;

class HtmlRenderer extends Component {
    public var size(default, default) :Vec2;
    public var floating(default, default) :Bool = false;

    var _options :Dynamic;
    var _elem :Element;

    var _transform :Transform;
    var _cachedPos :Vec2;
    var _cachedSize :Vec2;
    var _noPos :Bool = false;

    public function new(options :Dynamic) {
        _options = options;

        var size = _options.size;
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
        _elem = Browser.document.createSpanElement();
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
        styleElement(_elem, _options.style);

        parent.appendChild(_elem);
    }

    public override function start() :Void {
        _transform = getTransform();
    }

    public static function styleElement(elem :Element, style :Map<String, String>) :Void {
        if (style != null) {
            for (k in style.keys()) {
                elem.style.setProperty(k, style[k], '');
            }
        }
    }

    public override function deinit() :Void {
        if (_elem.parentElement != null) {
            _elem.parentElement.removeChild(_elem);
        }
    }

    function getPos() :Vec2 {
        if (_transform == null) {
            return null;
        }

        var pos = _transform.pos;
        if (floating) {
            var container = _elem.parentElement;
            var scroll = new Vec2(container.scrollLeft, container.scrollTop);
            pos += scroll;
        }
        return pos;
    }

    function isDirty() :Bool {
        if (_noPos) {
            return false;
        }

        var pos = getPos();
        if (pos == null && size == null) {
            _noPos = true;
            return false;
        }
        return _cachedPos != pos || _cachedSize != size;
    }
    function markClean() :Void {
        _cachedPos = getPos();
        _cachedSize = size;
    }

    public override function draw() :Void {
        if (_options.textFunc != null) {
            _elem.innerText = _options.textFunc();
        }

        if (isDirty()) {
            markClean();

            var pos = getPos();
            if (pos != null) {
                _elem.style.left = cast pos.x;
                _elem.style.top = cast pos.y;
            }

            if (size != null) {
                _elem.style.width = cast size.x;
                _elem.style.height = cast size.y;
            }
        }
    }

    public function getElement() :Element {
        return _elem;
    }
}
