package ostm.map;

import jengine.*;
import jengine.util.*;

import js.*;
import js.html.Element;

class MapGenerator extends Component {    
    var _generated :Array<Map<Int, MapNode>>;
    var _selected :MapNode;
    var _start :MapNode;

    var _rand :MapRandom;

    var _scrollHelper :Entity;

    static var kMoveTime :Float = 3.0;
    static var kMoveBarWidth :Float = 500;
    var _moveBar :Element;
    var _moveTimer :Float = 0;

    public override function start() :Void {
        _rand = new MapRandom();
        _generated = new Array<Map<Int, MapNode>>();
        _generated.push(new Map<Int, MapNode>());
        
        _scrollHelper = new Entity([
            new HtmlRenderer('map-screen', new Vec2(1, 1)),
            new Transform(new Vec2(0, 0)),
        ]);
        entity.getSystem().addEntity(_scrollHelper);

        var moveHtml = new HtmlRenderer('game-header', new Vec2(kMoveBarWidth, 25));
        var moveEntity = new Entity([
            moveHtml,
            new Transform(new Vec2(200, 100)),
        ]);
        entity.getSystem().addEntity(moveEntity);
        _moveBar = Browser.document.createSpanElement();
        _moveBar.style.position = 'absolute';
        _moveBar.style.height = '100%';
        _moveBar.style.background = 'white';
        moveHtml.getElement().appendChild(_moveBar);

        _start = addNode(null, 0, 0);
        _start.isGoldPath = true;
        _selected = _start;

        for (i in 1...3) {
            addLayer();
        }

        _start.setOccupied();
    }

    public override function update() {
        _moveTimer += Time.dt;
        if (_moveTimer > kMoveTime) {
            _moveTimer = 0;
        }
        _moveBar.style.width = (100 * _moveTimer / kMoveTime) + '%';
    }

    function addLayer() :Void {
        var kBackPathChance = 0.15;
        var kSidePathChance = 0.1;
        var kNewRegionChance = 0.15;
        var kChildCountPossibles = [1, 2, 3];
        var kHeightChangePossibles = [-1, 0, 0, 0, 1];

        _generated.push(new Map<Int, MapNode>());
        var i = _generated.length - 1;
        var p = i - 1;
        _rand.setSeed(35613 * i + 273);

        var hMin = _generated.length * 11;
        var hMax = -hMin;
        for (parent in _generated[p]) {
            var nChildren = _rand.randomElement(kChildCountPossibles);
            var didAddPath = false;
            var possibles = kHeightChangePossibles.copy();
            while (possibles.length > nChildren) {
                possibles.remove(_rand.randomElement(possibles));
            }
            var k = 0;
            while (k < possibles.length) {
                var n = possibles[k];
                k++;
                if (possibles.indexOf(n, k + 1) != -1) {
                    possibles.remove(n);
                    k = 0;
                }
            }
            var shouldSetGold = parent.isGoldPath;
            while (possibles.length > 0) {
                var j = _rand.randomElement(possibles);
                possibles.remove(j);
                j += parent.height;
                var node = _generated[i].get(j);
                if (node == null) {
                    node = addNode(parent, i, j);
                    node.region = parent.region;
                    if (_rand.randomBool(kNewRegionChance)) {
                        node.region = parent.getRandomRegion(_rand);
                    }
                    node.isGoldPath = shouldSetGold;
                    didAddPath = true;
                    shouldSetGold = false;
                }
                else if (_rand.randomBool(kBackPathChance) ||
                        (possibles.length == 0 && !didAddPath)) {
                    node.addNeighbor(parent);
                    if (shouldSetGold &&
                        (_rand.randomBool(kNewRegionChance) || node.region >= MapNode.kLaunchRegions)) {
                        node.region = parent.getRandomRegion(_rand);
                    }
                    if (shouldSetGold) {
                        node.isGoldPath = true;
                    }
                    didAddPath = true;
                    shouldSetGold = false;
                }
            }
        }

        for (node in _generated[i]) {
            tryUncross(node.depth, node.height);
            var prev = _generated[i].get(node.height - 1);
            if (prev != null && _rand.randomBool(kSidePathChance)) {
                node.addNeighbor(prev);
            }
            node.markDirty();
        }

        updateScrollBounds();
    }

    function addNode(parent :MapNode, i :Int, j :Int) :MapNode {
        var size :Vec2 = new Vec2(40, 40);

        var node = new MapNode(this, i, j, parent);
        var ent = new Entity([
            new HtmlRenderer('map-screen', size),
            new Transform(),
            node,
        ]);
        entity.getSystem().addEntity(ent);
        if (parent != null) {
            parent.neighbors.push(node);
        }

        _generated[i][j] = node;
        return node;
    }

    function tryUncross(i :Int, j :Int) :Void {
        if (i > 0) {
            var ul = _generated[i - 1].get(j - 1);
            var ur = _generated[i].get(j - 1);
            var dl = _generated[i - 1].get(j);
            var dr = _generated[i].get(j);
            if (ul != null && ur != null &&
                dl != null && dr != null &&
                isAdjacent(ul, dr) && isAdjacent(ur, dl)) {
                if ((_rand.randomBool() &&
                    !(ul.isGoldPath && dr.isGoldPath)) ||
                    (ur.isGoldPath && dl.isGoldPath)) {
                    ul.removeNeighbor(dr);
                }
                else {
                    ur.removeNeighbor(dl);
                }
                ul.addNeighbor(ur);
                dl.addNeighbor(dr);
            }
        }
    }

    public function click(node :MapNode) :Void {
        var path = findPath(_selected, node);
        if (path != null) {
            forAllNodes(function (node) {
                node.clearPath();
            });

            _selected.clearOccupied();
            _selected = node;
            if (_selected.depth + 1 == _generated.length) {
                addLayer();
            }

            for (n in path) {
                n.setPath(path);
            }
            _selected.setOccupied();

            centerCurrentNode();
        }
    }

    public function hover(node :MapNode) :Void {
        var path = findPath(_selected, node);
        if (path != null) {
            for (n in path) {
                n.setPathHighlight(path);
            }
        }
    }

    public function hoverOver(node :MapNode) :Void {
        forAllNodes(function (node) { node.clearPathHighlight(); });
    }

    function forAllNodes(f :MapNode -> Void) :Void {
        for (map in _generated) {
            for (node in map) {
                f(node);
            }
        }
    }

    function updateScrollBounds() :Void {
        var topLeft = new Vec2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var botRight = new Vec2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
        var origin :Vec2 = new Vec2(100, 300);
        forAllNodes(function (node) {
            var pos = node.getOffset();
            topLeft = Vec2.min(topLeft, pos);
        });

        forAllNodes(function (node) {
            var pos = origin + node.getOffset() - topLeft;
            node.getTransform().pos = pos;
            botRight = Vec2.max(botRight, pos);
        });
        
        var scrollBuffer = new Vec2(750, 350);
        _scrollHelper.getTransform().pos = origin + botRight + scrollBuffer;
    }

    public function centerCurrentNode() :Void {
        if (_selected.elem != null) {
            var container = _selected.elem.parentElement;
            var size = new Vec2(container.clientWidth, container.clientHeight);
            var pos = _selected.getTransform().pos;
            var scroll = new Vec2(container.scrollLeft, container.scrollTop);
            var relPos = pos - scroll;
            var scrollToPos = new Vec2(scroll.x, scroll.y);
            var tlBound = size / 3;
            var brBound = size * 2 / 3;
            scrollToPos = new Vec2(scroll.x, scroll.y);
            if (relPos.x < tlBound.x) { scrollToPos.x += relPos.x - tlBound.x; }
            if (relPos.y < tlBound.y) { scrollToPos.y += relPos.y - tlBound.y; }
            if (relPos.x > brBound.x) { scrollToPos.x += relPos.x - brBound.x; }
            if (relPos.y > brBound.y) { scrollToPos.y += relPos.y - brBound.y; }
            Browser.window.scrollTo(cast scrollToPos.x, cast scrollToPos.y);
        }
    }

    function rgb(r :Int, g :Int, b :Int) :String {
        var hexC = function(i :Int) :String {
            if (i < 10) {
                return '' + i;
            }
            switch (i) {
                case 10: return 'a';
                case 11: return 'b';
                case 12: return 'c';
                case 13: return 'd';
                case 14: return 'e';
                case 15: return 'f';
            }
            return '';
        }
        var toHex = function(c :Int) :String {
            if (c < 0) { return '00'; }
            if (c > 255) { return 'ff'; }
            return hexC(Math.floor(c / 16)) + hexC(c % 16);
        }
        return '#' + toHex(r) + toHex(g) + toHex(b);
    }

    function clamp(t :Float, lo :Float, hi :Float) :Float {
        if (t > hi) { return hi; }
        if (t < lo) { return lo; }
        return t;
    }
    inline function clamp01(t :Float) :Float {
        return clamp(t, 0, 1);
    }
    inline function lerp(t :Float, lo :Float, hi :Float) :Float {
        return clamp01(t) * (hi - lo) + lo;
    }

    function isAdjacent(a :MapNode, b :MapNode) :Bool {
        return a.neighbors.indexOf(b) != -1;
    }

    function bfsPath(start :MapNode, endFunction :MapNode -> Bool) :Array<MapNode> {
        var openSet = new Array<MapNode>();
        var closedSet = new Map<MapNode, MapNode>(); //key: item, val: parent
        openSet.push(start);
        closedSet[start] = start;

        var constructPath = function (node :MapNode) :Array<MapNode> {
            var path = new Array<MapNode>();
            var n = node;
            while (n != start) {
                path.push(n);
                n = closedSet[n];
            }
            path.push(start);
            path.reverse();
            return path;
        };

        while (openSet.length > 0) {
            var node = openSet[0];
            openSet.remove(node);

            for (n in node.neighbors) {
                var canVisit = node.hasVisited();
                if (canVisit) {
                    if (closedSet.get(n) == null) {
                        openSet.push(n);
                        closedSet[n] = node;
                    }
                    if (endFunction(n)) {
                        return constructPath(n);
                    }
                }
            }
        }

        return null;
    }

    function findPath(start :MapNode, end :MapNode) :Array<MapNode> {
        return bfsPath(start,
            function (node :MapNode) {
                return node == end;
            });
    }
}
