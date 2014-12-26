package ostm.map;

import js.Browser;
import js.html.Element;
import js.html.MouseEvent;

import jengine.*;

typedef MapLine = {
    var elem :Element;
    var node :MapNode;
};

enum MapNodeState {
}

@:allow(ostm.map.MapGenerator)
class MapNode extends Component {
    var lines :Array<MapLine>;
    var map :MapGenerator;
    var parents :Array<MapNode>;
    var neighbors :Array<MapNode>;
    var depth :Int;
    var height :Int;
    var hasSeen :Bool = false;
    var hasVisited :Bool = false;
    var pathMark :Float = -1;

    var elem :Element;

    var color :String = 'red';
    var _isDirty :Bool = true;

    var _lineWidth :Float = 3;

    function new(gen :MapGenerator, d :Int, h :Int, par :MapNode) {
        map = gen;
        depth = d;
        height = h;
        parents = [];
        lines = [];
        neighbors = new Array<MapNode>();
        if (par != null) {
            parents.push(par);
            neighbors.push(par);
        }
    }

    public function addParent(node :MapNode) {
        parents.push(node);
        neighbors.push(node);
    }
    public function addChild(node :MapNode) {
        neighbors.push(node);
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

        for (parent in parents) {
            var pos = getTransform().pos;
            var size = renderer.getSize();
            var center = pos + size / 2;
            var pCenter = parent.getTransform().pos + size / 2;
            lines.push(addLine(pCenter, center, parent));
        }
    }

    function addLine(a :Vec2, b :Vec2, endPoint :MapNode) :MapLine {
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
        return {
            elem: elem,
            node: endPoint,
        };
    }

    public override function update() :Void {
        if (_isDirty) {
            elem.style.background = color;

            elem.style.display = (color != '') ? '' : 'none';
            for (line in lines) {
                var disp = color != '' &&
                    (line.node.hasSeen && hasVisited ||
                        line.node.hasVisited && hasSeen);
                line.elem.style.display = disp ? '' : 'none';
            }
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
