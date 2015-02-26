package ostm.map;

import js.*;
import js.html.Element;

import jengine.*;
import jengine.SaveManager;
import jengine.util.*;

import ostm.battle.*;

typedef MapHint = {
    x :Int,
    y :Int,
    level :Int,
}

class MapGenerator extends Component 
        implements Saveable {
    public var saveId(default, null) :String = 'map';
    public var selectedNode(default, null) :MapNode;
    
    var _generated :Array<Map<Int, MapNode>>;
    var _start :MapNode;

    var _rand = new StaticRandom();

    var _scrollHelper :Entity;

    static inline var kMoveTime :Float = 15.0;
    static inline var kMoveBarWidth :Float = 500;
    static inline var kKillsToUnlock :Int = 3;
    var _moveBar :Element;
    var _moveTimer :Float = 0;
    var _movePath :Array<MapNode> = null;

    var _hints :Array<MapHint> = [
        { x: 4, y: -1, level: 0 },
        { x: 8, y: -2, level: 5 },
    ];

    public static var instance(default, null) :MapGenerator;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        SaveManager.instance.addItem(this);

        _generated = new Array<Map<Int, MapNode>>();
        _generated.push(new Map<Int, MapNode>());
        
        _scrollHelper = new Entity([
            new HtmlRenderer({
                parent: 'map-screen',
                size: new Vec2(1, 1),
            }),
            new Transform(new Vec2(0, 0)),
        ]);
        entity.getSystem().addEntity(_scrollHelper);

        var moveBarEntity = new Entity([
            new HtmlRenderer({
                id: 'move-bar',
                parent: 'game-header',
                size: new Vec2(kMoveBarWidth, 25),
                style: [
                    'background' => '#888800',
                    'border' => '1px solid #000000',
                ],
            }),
            new Transform(new Vec2(20, 7)),
            new ProgressBar(function() {
                return _moveTimer / kMoveTime;
            }, [
                'background' => '#ffff00',
            ]),
        ]);
        entity.getSystem().addEntity(moveBarEntity);
        entity.getSystem().addEntity(new Entity([
            new HtmlRenderer({
                id: 'kill-bar',
                parent: 'game-header',
                size: new Vec2(kMoveBarWidth, 25),
                style: [
                    'background' => '#885500',
                    'border' => '1px solid #000000',
                ],
            }),
            new Transform(new Vec2(20, 37)),
            new ProgressBar(function() {
                if (!selectedNode.hasUnseenNeighbors()) {
                    return 0;
                }
                return BattleManager.instance.getKillCount() / kKillsToUnlock;
            }, [
                'background' => '#ffaa00',
            ]),
        ]));

        _start = addNode(null, 0, 0);
        _start.setGoldPath();
        selectedNode = _start;

        for (i in 1...10) {
            addLayer();
        }

        for (hint in _hints) {
            if (hint.x < _generated.length) {
                var node = _generated[hint.x].get(hint.y);
                if (node != null) {
                    node.setHint(hint);
                }
            }
        }

        _start.setOccupied();
        centerCurrentNode();
    }

    public override function update() {
        if (BattleManager.instance.isPlayerDead()) {
            return;
        }

        var hasUnseen = selectedNode.hasUnseenNeighbors();
        Browser.document.getElementById('kill-bar').style.background = hasUnseen ? '#885500' : '#666666';
        if (hasUnseen && BattleManager.instance.getKillCount() >= kKillsToUnlock) {
            selectedNode.unlockRandomNeighbor();
            BattleManager.instance.resetKillCount();
        }

        _moveTimer += Time.dt;
        if (_movePath != null) {
            if (_moveTimer > kMoveTime && !BattleManager.instance.isInBattle()) {
                _moveTimer = 0;
                
                var next = _movePath[1];
                setSelected(next);

                _movePath.remove(next);
                if (_movePath.length <= 1) {
                    selectedNode.clearPath();
                    _movePath = null;
                }
            }
        }
    }

    function setSelected(next :MapNode) {
        selectedNode.clearPath();
        selectedNode.clearOccupied();

        selectedNode = next;
        while (selectedNode.depth + 2 >= _generated.length) {
            addLayer();
        }
        selectedNode.setOccupied();
        BattleManager.instance.resetKillCount();

        forAllNodes(function (node) {
            if (node.isHint()) {
                node.markDirty();
            }
        });
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
        _rand.setSeed(35613 * i + 281);

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
                    if (_rand.randomBool(kNewRegionChance)) {
                        node.setNewRegion(parent, _rand);
                    }
                    if (shouldSetGold) {
                        node.setGoldPath();
                    }
                    didAddPath = true;
                    shouldSetGold = false;
                }
                else if (_rand.randomBool(kBackPathChance) ||
                        (possibles.length == 0 && !didAddPath)) {
                    node.addNeighbor(parent);
                    if (shouldSetGold &&
                        (_rand.randomBool(kNewRegionChance) || node.region >= MapNode.kLaunchRegions)) {
                        node.setNewRegion(parent, _rand);
                    }
                    if (shouldSetGold) {
                        node.setGoldPath();
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
        }
        forAllNodes(function(node) {
            node.markDirty();
        });

        updateScrollBounds();
    }

    function addNode(parent :MapNode, i :Int, j :Int) :MapNode {
        var size :Vec2 = new Vec2(40, 40);

        var node = new MapNode(this, i, j, parent);
        var ent = new Entity([
            new HtmlRenderer({
                parent: 'map-screen',
                size: size,
            }),
            new Transform(),
            node,
        ]);
        entity.getSystem().addEntity(ent);

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

    function setPath(path :Array<MapNode>) :Void {
        _movePath = path;

        forAllNodes(function (node) {
            node.clearPath();
        });

        if (path != null) {
            for (n in path) {
                n.setPath(path);
            }
        }
    }

    public function click(node :MapNode) :Void {
        if (node == selectedNode) {
            setPath(null);
            return;
        }

        var path = findPath(selectedNode, node);
        if (path == null) {
            return;
        }

        setPath(path);
    }

    public function hover(node :MapNode) :Void {
        var path = findPath(selectedNode, node);
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
        var origin :Vec2 = new Vec2(100, 100);
        forAllNodes(function (node) {
            var pos = node.getOffset();
            topLeft = Vec2.min(topLeft, pos);
        });

        forAllNodes(function (node) {
            var pos = origin + node.getOffset() - topLeft;
            node.getTransform().pos = pos;
            botRight = Vec2.max(botRight, pos);
        });
        
        var scrollBuffer = new Vec2(250, 150);
        _scrollHelper.getTransform().pos = origin + botRight + scrollBuffer;
    }

    public function centerCurrentNode() :Void {
        if (selectedNode.elem != null) {
            var container = selectedNode.elem.parentElement;
            var size = new Vec2(container.clientWidth, container.clientHeight);
            var pos = selectedNode.getTransform().pos;
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

            for (m in node.neighbors) {
                var n :MapNode = cast m;
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

    public function returnToStart() {
        setSelected(_start);

        if (_movePath != null) {
            for (n in _movePath) {
                n.clearPath();
            }
            _movePath = null;
        }
    }

    public function serialize() :Dynamic {
        var nodes = [];
        forAllNodes(function (node) {
            nodes.push(node.serialize());
        });
        return {
            selected: { x: selectedNode.depth, y: selectedNode.height },
            nodes: nodes,
        };
    }
    public function deserialize(data :Dynamic) {
        var nodes :Array<Dynamic> = data.nodes;
        for (n in nodes) {
            while (n.x + 1 > _generated.length) {
                addLayer();
            }
            var node = _generated[n.x].get(n.y);
            if (node != null) {
                node.deserialize(n);
            }
        }
        var sel = _generated[data.selected.x].get(data.selected.y);
        if (sel != null) {
            selectedNode.clearOccupied();
            selectedNode = sel;
            sel.setOccupied();
        }
    }
}
