package ostm.map;

import js.Browser;
import js.html.Element;
import js.html.MouseEvent;

import jengine.*;

typedef MapLine = {
    var elem :Element;
    var node :MapNode;
    var offset :Vec2;
};

@:allow(ostm.map.MapGenerator)
class MapNode extends Component {
    var lines :Array<MapLine>;
    var map :MapGenerator;
    var neighbors :Array<MapNode>;
    var depth :Int;
    var height :Int;

    var elem :Element;

    var _isVisible :Bool = false;
    var _isVisited :Bool = false;
    var _isPathHighlighted :Bool = false;
    var _isPathSelected :Bool = false;
    var _isOccupied :Bool = false;
    var _dirtyFlag :Bool = true;

    var _lineWidth :Float = 3;

    function new(gen :MapGenerator, d :Int, h :Int, par :MapNode) {
        map = gen;
        depth = d;
        height = h;
        lines = [];
        neighbors = new Array<MapNode>();
        if (par != null) {
            neighbors.push(par);
        }
    }

    public function addNeighbor(node :MapNode) :Void {
        if (neighbors.indexOf(node) == -1) {
            neighbors.push(node);
            node.addNeighbor(this);
        }
    }
    public function removeNeighbor(node :MapNode) :Void {
        if (neighbors.indexOf(node) != -1) {
            neighbors.remove(node);
            node.removeNeighbor(this);
        }
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        elem = renderer.getElement();

        elem.style.borderRadius = cast 18;
        elem.style.border = _lineWidth + 'px solid black';

        elem.onmouseover = onMouseOver;
        elem.onmouseout = onMouseOut;
        elem.onclick = onClick;

        for (node in neighbors) {
            if (node.depth < depth) {
                lines.push(addLine(node));
            }
        }
    }

    function addLine(endPoint :MapNode) :MapLine {
        var size = getComponent(HtmlRenderer).getSize();
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
        elem.style.zIndex = cast -1;

        Browser.document.body.appendChild(elem);
        return {
            elem: elem,
            node: endPoint,
            offset: (delta + size) / 2 - new Vec2(0, height / 2),
        };
    }

    public function isPathVisible(node :MapNode) :Bool {
        return (hasSeen() && node.hasVisited()) || (hasVisited() && node.hasSeen());
    }

    public override function update() :Void {
        if (isDirty()) {
            var color = '';
            if (_isOccupied) { color = '#ffff00'; }
            else if (_isPathHighlighted) { color = '#00ffff'; }
            else if (_isPathSelected) { color = '#00ff00'; }
            else if (_isVisited) { color = '#ff0000'; }
            else if (_isVisible) { color = '#888888'; }

            elem.style.background = color;
            elem.style.display = hasSeen() ? '' : 'none';

            var size = getComponent(HtmlRenderer).getSize();
            var pos = getTransform().pos;
            for (line in lines) {
                var disp = isPathVisible(line.node);
                line.elem.style.display = disp ? '' : 'none';

                line.elem.style.left = cast pos.x + line.offset.x;
                line.elem.style.top = cast pos.y + line.offset.y;
            }

            _dirtyFlag = false;
        }
    }

    inline function isDirty() :Bool {
        return _dirtyFlag;
    }
    public inline function markDirty() :Void {
        _dirtyFlag = true;
    }

    function onMouseOver(event :MouseEvent) :Void {
        map.hover(this);
    }
    function onMouseOut(event :MouseEvent) :Void {
        map.hoverOver(this);
    }
    function onClick(event :MouseEvent) :Void {
        map.click(this);
    }

    public function getOffset(origin :Vec2) :Vec2 {
        var spacing :Vec2 = new Vec2(80, 60);
        return origin + new Vec2(depth * spacing.x, height * spacing.y);
    }

    public function setVisible() :Void {
        _isVisible = true;
        markDirty();
    }
    public function setPath() :Void {
        _isPathSelected = true;
        _isVisited = true;
        markDirty();
    }
    public function clearPath() :Void {
        _isPathSelected = false;
        markDirty();
    }
    public function setOccupied() :Void {
        _isVisible = true;
        _isVisited = true;
        _isOccupied = true;
        markDirty();

        markNeighborsVisible();
    }
    public function clearOccupied() :Void {
        _isOccupied = false;
        markDirty();
    }
    public function setPathHighlight() :Void {
        _isPathHighlighted = true;
        markDirty();
    }
    public function clearPathHighlight() :Void {
        _isPathHighlighted = false;
        markDirty();
    }
    public function markNeighborsVisible() :Void {
        for (node in neighbors) {
            node.setVisible();
        }
    }

    public function hasSeen() :Bool {
        return _isVisible;
    }
    public function hasVisited() :Bool {
        return _isVisited;
    }

    public function posString() :String {
        return '(' + depth + ', ' + height + ')';
    }
}
