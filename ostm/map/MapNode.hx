package ostm.map;

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
    var _lineWidth :Float = 3;

    function new(depth :Int, height :Int) {
        this.depth = depth;
        this.height = height;
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        elem = renderer.getElement();

        elem.style.borderRadius = cast 18;
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

class MapNode extends GameNode {
    var map :MapGenerator;
    public var region(default, null) :Int = 0;
    public var isGoldPath(default, null) :Bool = false;
    var _parent :MapNode;

    var _isVisible :Bool = false;
    var _isVisited :Bool = false;
    var _selectedPath :Array<MapNode> = null;
    var _highlightedPath :Array<MapNode> = null;
    var _isOccupied :Bool = false;
    var _dirtyFlag :Bool = true;
    var _hintLevel :Int = -1;

    var _highlightedLineWidth :Float = 8;

    public static inline var kMaxRegions = 12;
    public static inline var kMaxVisibleRegion = 4;
    public static inline var kLaunchRegions = 4;

    static var _highestVisited = 0;

    function new(gen :MapGenerator, d :Int, h :Int, par :MapNode) {
        super(d, h);

        map = gen;
        if (par != null) {
            _parent = par;
            region = _parent.region;
            addNeighbor(par);
        }
    }

    public function setHint(hint) :Void {
        _hintLevel = hint.level;
    }

    function getRandomRegion(rand :StaticRandom) :Int {
        var d = rand.randomElement([-1, 1, 1, 2]);
        var max = isGoldPath ? kLaunchRegions : kMaxRegions;
        return (region + max + d) % max;
    }

    public override function start() :Void {
        super.start();

        if (_isOccupied) {
            map.centerCurrentNode();
        }
    }

    public function isPathVisible(node :MapNode) :Bool {
        return (hasSeen() && node.hasVisited()) || (hasVisited() && node.hasSeen());
    }

    public function isLinePartOfPath(line :NodeLine, path :Array<MapNode>) :Bool {
        var node = cast (line.node, MapNode);
        return (path.indexOf(this) != -1 ||
            path.indexOf(node) != -1) &&
            (node._highlightedPath == path || node._selectedPath == path);
    }

    public override function update() :Void {
        if (isDirty()) {
            var color = getColor().asHtml();

            var borderColor = '#000000';
            var isHighlighted = true;
            if (_isOccupied) { borderColor = '#ffff00'; }
            else if (_highlightedPath != null) { borderColor = '#00ffff'; }
            else if (_selectedPath != null) { borderColor = '#00ff00'; }
            else if (hasUnseenNeighbors()) { borderColor = '#008888'; }
            else { isHighlighted = false; }
            var borderWidth = _lineWidth;

            elem.style.background = color;
            elem.style.border = borderWidth + 'px solid ' + borderColor;
            elem.style.display = hasSeen() ? '' : 'none';

            if (isHintVisible() && !hasVisited()) {
                elem.innerText = '?';
                elem.style.fontSize = '30px';
            }
            else {
                var lev = areaLevel();
                elem.innerText = cast lev;
                elem.style.fontSize = lev < 100 ? '30px' : '20px';
            }

            var size = getComponent(HtmlRenderer).size;
            var pos = getTransform().pos;
            for (line in lines) {
                var disp = isPathVisible(cast (line.node, MapNode));
                line.elem.style.display = disp ? '' : 'none';
                if (!disp) {
                    continue;
                }

                var lineColor = '#000000';
                var lineIsHighlighted = true;
                if (_highlightedPath != null &&
                    isLinePartOfPath(line, _highlightedPath)) {
                    lineColor = '#00ffff';
                }
                else if (_selectedPath != null &&
                    isLinePartOfPath(line, _selectedPath)) {
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

    function getColor() :Color {
        var color :Color = null;
        switch (region) {
            case 0: color = new Color(0xff, 0x00, 0x00);
            case 1: color = new Color(0xff, 0x88, 0x00);
            case 2: color = new Color(0xff, 0xff, 0x00);
            case 3: color = new Color(0x88, 0xff, 0x00);
            case 4: color = new Color(0x00, 0xff, 0x00);
            case 5: color = new Color(0x00, 0xff, 0x88);
            case 6: color = new Color(0x00, 0xff, 0xff);
            case 7: color = new Color(0x00, 0x88, 0xff);
            case 8: color = new Color(0x00, 0x00, 0xff);
            case 9: color = new Color(0x88, 0x00, 0xff);
            case 10: color = new Color(0xff, 0x00, 0xff);
            case 11: color = new Color(0xff, 0x00, 0x88);
            default: color = new Color(0, 0, 0);
        }
        if (!_isVisited) {
            color = color.multiply(0.5);
        }
        return color;
    }

    inline function isDirty() :Bool {
        return _dirtyFlag;
    }
    public inline function markDirty() :Void {
        _dirtyFlag = true;
    }

    override function onMouseOver(event :MouseEvent) :Void {
        map.hover(this);
    }
    override function onMouseOut(event :MouseEvent) :Void {
        map.hoverOver(this);
    }
    override function onClick(event :MouseEvent) :Void {
        map.click(this);
    }

    public function setVisible() :Void {
        _isVisible = true;
        markDirty();
    }
    public function setPath(path :Array<MapNode>) :Void {
        _selectedPath = path;
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
        _highestVisited = Util.intMax(_highestVisited, depth);
        markNeighborsVisible();
        markDirty();

        var bg = Browser.document.getElementById('battle-screen');
        bg.style.background = getColor().mix(new Color(0x80, 0x80, 0x80)).asHtml();
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
    public function setGoldPath() :Void {
        isGoldPath = true;
    }
    public function markNeighborsVisible() :Void {
        for (node in neighbors) {
            cast (node, MapNode).setVisible();
        }
    }

    public function canBeSeen() :Bool {
        return region < kMaxVisibleRegion;
    }
    public function canMarkSeen() :Bool {
        return !_isVisible && canBeSeen();
    }

    public function hasSeen() :Bool {
        return _isVisible && canBeSeen() || isHintVisible();
    }
    public function hasVisited() :Bool {
        return _isVisited && canBeSeen();
    }

    public function hasUnseenNeighbors() :Bool {
        for (node in neighbors) {
            if (cast(node, MapNode).canMarkSeen()) {
                return true;
            }
        }
        return false;
    }

    public function unlockRandomNeighbor() :Void {
        var unseen = neighbors.filter(function (node) { return cast (node, MapNode).canMarkSeen(); });
        if (unseen.length > 0) {
            var node = Random.randomElement(unseen);
            cast (node, MapNode).setVisible();
            markDirty();
        }
        else {
            trace('warning: trying to unlock neighbor on node with no unseen neighbors');
        }
    }

    public function areaLevel() :Int {
        return depth + Math.floor(Math.abs(height) / 2) + 1;
    }

    public function isHint() :Bool {
        return _hintLevel >= 0;
    }
    public function isHintVisible() :Bool {
        return isHint() && _highestVisited >= _hintLevel;
    }

    public function setNewRegion(parent :MapNode, rand :StaticRandom) :Void {
        region = parent.getRandomRegion(rand);
    }

    public function serialize() :Dynamic {
        return {
            x: depth,
            y: height,
            visible: _isVisible,
            visited: _isVisited,
        };
    }
    public function deserialize(data :Dynamic) :Void {
        _isVisible = data.visible;
        _isVisited = data.visited;
        markDirty();
    }
}
