package ostm.map;

import js.Browser;
import js.html.Element;
import js.html.MouseEvent;

import jengine.*;

@:allow(ostm.map.MapGenerator)
class MapNode extends Component {
    var line :Element;
    var map :MapGenerator;
    var parent :MapNode;
    var depth :Int;
    var hasSeen :Bool = false;
    var hasVisited :Bool = false;
    var pathMark :Float = -1;

    var elem :Element;

    var color :String = 'red';
    var _cachedColor :String = 'notacoloratall';

    var _lineWidth :Float = 3;

    function new(gen :MapGenerator, dep :Int, par :MapNode) {
        map = gen;
        depth = dep;
        parent = par;
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        elem = renderer.getElement();

        elem.style.borderRadius = cast 32;
        elem.style.border = _lineWidth + 'px solid black';

        elem.onmousedown = onMouseDown;
        elem.onmouseout = onMouseUp;
        elem.onmouseup = onMouseUp;
        elem.onclick = onClick;

        if (parent != null) {
            var pos = getTransform().pos;
            var size = renderer.getSize();
            var center = pos + size / 2;
            var pCenter = parent.getTransform().pos + size / 2;
            line = addLine(pCenter, center);
        }
    }

    function addLine(a :Vec2, b :Vec2) :Element {
        var elem = Browser.document.createElement('div');
        var pos = (a + b) / 2;
        var delta = b - a;
        var width = _lineWidth;
        var height = delta.length();
        var angle = Math.atan2(delta.y, delta.x) * 180 / Math.PI + 90;

        elem.style.background = 'black';
        elem.style.position = 'absolute';

        elem.style.left = cast pos.x;
        elem.style.top = cast pos.y - height / 2;
        elem.style.width = cast width;
        elem.style.height = cast height;
        elem.style.transform = 'rotate(' + angle + 'deg)';
        elem.style.zIndex = cast -1;

        Browser.document.body.appendChild(elem);
        return elem;
    }

    public override function update() :Void {
        if (color != _cachedColor) {
            elem.style.background = color;

            if (color == '' || _cachedColor == '') {
                var disp = (color == '') ? 'none' : '';
                elem.style.display = disp;
                line.style.display = disp;
            }

            _cachedColor = color;
        }
    }

    function onMouseDown(event :MouseEvent) :Void {
    }
    function onMouseUp(event :MouseEvent) :Void {
    }

    function onClick(event :MouseEvent) :Void {
        map.click(this);
    }
}
