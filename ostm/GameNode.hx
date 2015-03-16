package ostm;

import js.Browser;
import js.html.Element;
import js.html.MouseEvent;

import jengine.*;
import jengine.util.*;

typedef NodeLine = {
    var elem :Element;
    var node :GameNode;
    var offset :Vec2;
};

class GameNode extends Component {
    public var depth(default, null) :Int;
    public var height(default, null) :Int;
    public var neighbors(default, null) = new Array<GameNode>();
    public var elem(default, null) :Element;
    var lines = new Array<NodeLine>();
    var _lineWidth :Float = 5;

    function new(depth :Int, height :Int) {
        this.depth = depth;
        this.height = height;
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        elem = renderer.getElement();

        elem.style.borderRadius = '18px';
        elem.style.zIndex = cast 1;

        elem.style.textAlign = 'center';
        elem.style.color = '#ffffff';

        elem.onmouseover = onMouseOver;
        elem.onmouseout = onMouseOut;
        elem.onclick = onClick;

        for (node in neighbors) {
            if (!node.hasLineTo(this)) {
                lines.push(addLine(node));
            }
        }
    }

    public function addNeighbor(node :GameNode) :Void {
        if (node == null) {
            return;
        }
        
        if (neighbors.indexOf(node) == -1) {
            neighbors.push(node);
        }
        if (node.neighbors.indexOf(this) == -1) {
            node.neighbors.push(this);
        }
    }
    public function removeNeighbor(node :GameNode) :Void {
        neighbors.remove(node);
        node.neighbors.remove(this);
    }

    function hasLineTo(node :GameNode) :Bool {
        for (line in lines) {
            if (line.node == node) {
                return true;
            }
        }
        return false;
    }

    function addLine(endPoint :GameNode) :NodeLine {
        var renderer = getComponent(HtmlRenderer);
        var size = renderer.size;
        var a = getTransform().pos + size / 2;
        var b = endPoint.getTransform().pos + size / 2;
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

        renderer.getElement().parentElement.appendChild(elem);
        return {
            elem: elem,
            node: endPoint,
            offset: (delta + size) / 2 - new Vec2(0, height / 2),
        };
    }

    public function getOffset() :Vec2 {
        var spacing :Vec2 = new Vec2(60, 60);
        return new Vec2(height * spacing.x, depth * spacing.y);
    }

    function onMouseOver(event :MouseEvent) :Void { }
    function onMouseOut(event :MouseEvent) :Void { }
    function onClick(event :MouseEvent) :Void { }
}
