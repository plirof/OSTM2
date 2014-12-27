package ostm.map;

import js.Browser;
import js.html.Element;
import js.html.MouseEvent;

import jengine.*;

typedef MapLine = {
    var elem :Element;
    var node :MapNode;
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
                var pos = getTransform().pos;
                var size = renderer.getSize();
                var center = pos + size / 2;
                var pCenter = node.getTransform().pos + size / 2;
                lines.push(addLine(pCenter, center, node));
            }
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

    public function isPathVisible(node :MapNode) :Bool {
        return hasSeen() && (hasVisited() || node.hasVisited());
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
            for (line in lines) {
                var disp = isPathVisible(line.node);
                line.elem.style.display = disp ? '' : 'none';
            }

            _cachedState = state;
            _dirtyFlag = false;
        }
    }

    function isDirty() :Bool {
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

    public function ratchetState() :Void {
        if (state > MapNodeState.Visited) {
            state = MapNodeState.Visited;
        }
    }
    function upgradeState(s :MapNodeState) {
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
