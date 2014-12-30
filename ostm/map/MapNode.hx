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
    var _selectedPath :Array<MapNode> = null;
    var _highlightedPath :Array<MapNode> = null;
    var _isOccupied :Bool = false;
    var _dirtyFlag :Bool = true;

    var _lineWidth :Float = 3;
    var _highlightedLineWidth :Float = 8;

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
            var color = '#ff0000';
            if (!_isVisited) {
                color = '#888888';
            }

            var borderColor = '#000000';
            var isHighlighted = true;
            if (_isOccupied) { borderColor = '#ffff00'; }
            else if (_highlightedPath != null) { borderColor = '#00ffff'; }
            else if (_selectedPath != null) { borderColor = '#00ff00'; }
            else { isHighlighted = false; }
            // var borderWidth = isHighlighted ? _highlightedLineWidth : _lineWidth;
            var borderWidth = _lineWidth;

            elem.style.background = color;
            elem.style.border = borderWidth + 'px solid ' + borderColor;
            elem.style.display = hasSeen() ? '' : 'none';

            var size = getComponent(HtmlRenderer).getSize();
            var pos = getTransform().pos;
            for (line in lines) {
                var disp = isPathVisible(line.node);
                line.elem.style.display = disp ? '' : 'none';

                var lineColor = '#000000';
                var lineIsHighlighted = true;
                if (_highlightedPath != null &&
                    _highlightedPath.indexOf(line.node) != -1) {
                    lineColor = '#00ffff';
                }
                else if (_selectedPath != null &&
                    _selectedPath.indexOf(line.node) != -1) {
                    lineColor = '#00ff00';
                }
                else {
                    lineIsHighlighted = false;
                }
                var lineWidth = lineIsHighlighted ? _highlightedLineWidth : _lineWidth;

                line.elem.style.left = cast pos.x + line.offset.x;
                line.elem.style.top = cast pos.y + line.offset.y;
                line.elem.style.background = lineColor;
                line.elem.style.width = cast lineWidth;
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
    public function setPath(path :Array<MapNode>) :Void {
        _selectedPath = path;
        _isVisited = true;
        markDirty();
    }
    public function clearPath() :Void {
        _selectedPath = null;
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
    public function setPathHighlight(path :Array<MapNode>) :Void {
        _highlightedPath = path;
        markDirty();
    }
    public function clearPathHighlight() :Void {
        _highlightedPath = null;
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
