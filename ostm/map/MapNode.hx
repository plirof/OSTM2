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

@:enum @:forward
abstract MapNodeState(Int) to Int from Int {
    var Invisible = 0;
    var Visible = 1;
    var Visited = 2;
    var PathHighlight = 3;
    var Occupied = 4;

    @:op(A > B) public static inline function
    gt(lhs :MapNodeState, rhs :MapNodeState) {
        return lhs > rhs;
    }
    @:op(A >= B) public static inline function
    gte(lhs :MapNodeState, rhs :MapNodeState) {
        return lhs >= rhs;
    }
}

@:allow(ostm.map.MapGenerator)
class MapNode extends Component {
    var lines :Array<MapLine>;
    var map :MapGenerator;
    var neighbors :Array<MapNode>;
    var depth :Int;
    var height :Int;

    var elem :Element;

    var state :MapNodeState = MapNodeState.Invisible;
    var _dirtyFlag :Bool = true;
    var _cachedState :MapNodeState = MapNodeState.Invisible;

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

        elem.style.borderRadius = cast 32;
        elem.style.border = _lineWidth + 'px solid black';

        elem.onmousedown = onMouseDown;
        elem.onmouseout = onMouseUp;
        elem.onmouseup = onMouseUp;
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
            var color;
            switch (state) {
                case Visible: color = '#888888';
                case Visited: color = '#ff0000';
                case PathHighlight: color = '#00ffff';
                case Occupied: color = '#ffff00';
                default: color = '';
            }
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

            _cachedState = state;
            _dirtyFlag = false;
        }
    }

    inline function isDirty() :Bool {
        return _dirtyFlag || state != _cachedState;
    }
    public function markDirty() :Void {
        _dirtyFlag = true;
    }

    function onMouseDown(event :MouseEvent) :Void {
    }
    function onMouseUp(event :MouseEvent) :Void {
    }
    function onClick(event :MouseEvent) :Void {
        map.click(this);
    }

    public function getOffset(origin :Vec2) :Vec2 {
        var spacing :Vec2 = new Vec2(80, 60);
        return origin + new Vec2(depth * spacing.x, height * spacing.y);
    }

    public function ratchetState() :Void {
        if (state > MapNodeState.Visited) {
            state = MapNodeState.Visited;
        }
    }
    inline function upgradeState(s :MapNodeState) {
        if (s > state) {
            state = s;
        }
        _dirtyFlag = true;
    }
    public function setVisible() :Void {
        upgradeState(MapNodeState.Visible);
    }
    public function setPath() :Void {
        upgradeState(MapNodeState.PathHighlight);
    }
    public function setOccupied() :Void {
        upgradeState(MapNodeState.Occupied);
        markNeighborsVisible();
    }
    public function markNeighborsVisible() :Void {
        for (node in neighbors) {
            node.setVisible();
        }
    }

    public function hasSeen() :Bool {
        return state >= MapNodeState.Visible;
    }
    public function hasVisited() :Bool {
        return state >= MapNodeState.Visited;
    }

    public function posString() :String {
        return '(' + depth + ', ' + height + ')';
    }
}
