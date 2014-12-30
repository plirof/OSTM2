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
    var region :Int = 0;
    var isGoldPath :Bool = false;

    var elem :Element;

    var _isVisible :Bool = false;
    var _isVisited :Bool = false;
    var _selectedPath :Array<MapNode> = null;
    var _highlightedPath :Array<MapNode> = null;
    var _isOccupied :Bool = false;
    var _dirtyFlag :Bool = true;

    var _lineWidth :Float = 3;
    var _highlightedLineWidth :Float = 8;

    static var kMaxRegions = 12;
    static var kMaxVisibleRegion = 14;
    static var kLaunchRegions = 4;

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
        }
        if (node.neighbors.indexOf(this) == -1) {
            node.neighbors.push(this);
        }
    }
    public function removeNeighbor(node :MapNode) :Void {
        neighbors.remove(node);
        node.neighbors.remove(this);
    }

    function getRandomRegion(rand :MapRandom) :Int {
        var d = rand.randomElement([-1, 1, 1, 2]);
        var max = isGoldPath ? kLaunchRegions : kMaxRegions;
        return (region + max + d) % max;
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        elem = renderer.getElement();

        elem.style.borderRadius = cast 18;

        elem.onmouseover = onMouseOver;
        elem.onmouseout = onMouseOut;
        elem.onclick = onClick;

        for (node in neighbors) {
            if (!hasLineTo(this)) {
                lines.push(addLine(node));
            }
        }

        if (_isOccupied) {
            map.centerCurrentNode();
        }
    }

    function hasLineTo(node :MapNode) :Bool {
        for (line in lines) {
            if (line.node == node) {
                return true;
            }
        }
        return false;
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
            var color;
            switch (region) {
                case 0: color = '#ff0000';
                case 1: color = '#ff8800';
                case 2: color = '#ffff00';
                case 3: color = '#88ff00';
                case 4: color = '#00ff00';
                case 5: color = '#00ff88';
                case 6: color = '#00ffff';
                case 7: color = '#0088ff';
                case 8: color = '#0000ff';
                case 9: color = '#8800ff';
                case 10: color = '#ff00ff';
                case 11: color = '#ff0088';
                default: color = '';
            }
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
                if (!disp) {
                    continue;
                }

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

    public function getOffset() :Vec2 {
        var spacing :Vec2 = new Vec2(80, 80);
        return new Vec2(depth * spacing.x, height * spacing.y);
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
        return _isVisible && region < kMaxVisibleRegion;
    }
    public function hasVisited() :Bool {
        return _isVisited && region < kMaxVisibleRegion;
    }

    public function posString() :String {
        return '(' + depth + ', ' + height + ')';
    }
}
