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
    
    var _generated = new Map<Int, Map<Int, MapNode>>();
    var _gridGeneratedFlags = new Map<Int, Map<Int, Bool>>();
    var _start :MapNode;
    var _checkpoint :MapNode;

    var _rand = new StaticRandom();

    var _scrollHelper :Entity;

    static inline var kMoveTime :Float = 12.0;
    static inline var kMoveBarWidth :Float = 500;
    var _moveBar :Element;
    var _moveTimer :Float = 0;
    var _movePath :Array<MapNode> = null;

    static inline var kGridSize :Int = 5;
    static inline var kLevelsPerCellDist :Int = 5;
    static var kHalfGrid :Int = Math.floor(kGridSize / 2);

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

        // _generated.push(new Map<Int, MapNode>());
        
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

        // var startTime = Time.raw;

        generateSurroundingCells(0, 0);
        selectedNode = _start; // _start is generated as part of generateGridCell(0, 0)
        _checkpoint = _start;


        // var baseGen = 3;
        // for (i in -baseGen...(baseGen + 1)) {
        //     for (j in -baseGen...(baseGen + 1)) {
        //         generateGridCell(i, j);
        //     }
        // }

        // var nodeCount = debugNodeCount();
        // var elapsed = Time.raw - startTime;
        // var rate = nodeCount / elapsed;
        // trace('Map Nodes: ' + nodeCount);
        // trace('Time to generate: ' + elapsed + ' s (' + rate + ' nodes/s)');

        _start.setOccupied();
        centerCurrentNode();
    }

    public override function update() {
        if (BattleManager.instance.isInBattle() ||
            BattleManager.instance.isPlayerDead()) {
            return;
        }

        var player = BattleManager.instance.getPlayer();
        _moveTimer += Time.dt * player.moveSpeed();
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

    function debugNodeCount() {
        var nodeCount = 0;
        forAllNodes(function (node) { nodeCount++; });
        return nodeCount;
    }

    function getGridCoord(i :Int, j :Int) {
        return {
            x: Math.floor(i / kGridSize),
            y: Math.floor(j / kGridSize),
        };
    }

    function getPosForGridCoord(x :Int, y :Int) {
        return {
            i: x * kGridSize,
            j: y * kGridSize,
        };
    }

    function setSelected(next :MapNode) {
        selectedNode.clearPath();
        selectedNode.clearOccupied();

        selectedNode = next;
        generateSurroundingCells(next.depth, next.height);
        selectedNode.setOccupied();
        BattleManager.instance.resetKillCount();

        if (next.town) {
            _checkpoint = next;
        }

        forAllNodes(function (node) {
            if (node.isHint()) {
                node.markDirty();
            }
        });
    }

    function generateSurroundingCells(i :Int, j :Int) :Void {
        var p = getGridCoord(i, j);
        var xs = [0, -1, 1, 0, 0];
        var ys = [0, 0, 0, -1, 1];
        for (i in 0...xs.length) {
            generateGridCell(p.x + xs[i], p.y + ys[i]);
        }
    }

    function cellSeed(x :Int, y :Int) :Int {
        return 3724684 + 21487 * x + 54013 * y + 127 * x * y;
    }

    function didGenerateCell(x :Int, y :Int) :Bool {
        if (_gridGeneratedFlags.get(x) == null) {
            _gridGeneratedFlags[x] = new Map<Int, Bool>();
        }
        return _gridGeneratedFlags[x].get(y);
    }

    function generateGridCell(x :Int, y :Int) :Void {
        if (didGenerateCell(x, y)) {
            return;
        }

        _gridGeneratedFlags[x][y] = true;

        var isOriginCell = x == 0 && y == 0;

        var pos = getPosForGridCoord(x, y);
        var seed = cellSeed(x, y);

        var leftSeed = cellSeed(x - 1, y);
        var rightSeed = cellSeed(x + 1, y);
        var upSeed = cellSeed(x, y + 1);
        var downSeed = cellSeed(x, y - 1);
        
        var leftY = _rand.setSeed(seed + leftSeed).randomInt(kGridSize);
        var rightY = _rand.setSeed(seed + rightSeed).randomInt(kGridSize);
        var downX = _rand.setSeed(seed + downSeed).randomInt(kGridSize);
        var upX = _rand.setSeed(seed + upSeed).randomInt(kGridSize);

        _rand.setSeed(seed);
        if (_rand.randomBool(0.11) && !isOriginCell) {
            return;
        }

        var left = addNode(null, pos.i, pos.j + leftY);
        var right = addNode(null, pos.i + kGridSize - 1, pos.j + rightY);
        var down = addNode(null, pos.i + downX, pos.j);
        var up = addNode(null, pos.i + upX, pos.j + kGridSize - 1);

        var startNodes = [left];
        if (startNodes.indexOf(right) == -1) { startNodes.push(right); }
        if (startNodes.indexOf(down) == -1) { startNodes.push(down); }
        if (startNodes.indexOf(up) == -1) { startNodes.push(up); }

        var cellNodes = startNodes.copy(); //[left, right, up, down];

        var distToOrigin = Math.floor(Math.abs(x) + Math.abs(y));
        var cellLevel = distToOrigin * kLevelsPerCellDist;
        var cellRegion = _rand.randomInt(Util.clampInt(distToOrigin, 2, MapNode.kMaxRegions - 1));
        if (isOriginCell) {
            cellRegion = 0;
        }

        for (node in startNodes) {
            node.level = cellLevel + 1;
            node.region = cellRegion;
        }

        var findPathWithinCell = function(start :MapNode, end :MapNode) {
            return bfsPath(start,
                function (node :MapNode) {
                    return node == end;
                },
                function (node :MapNode) {
                    return cellNodes.indexOf(node) != -1;
                });
        };

        var isDone = function() {
            if (cellNodes.length == kGridSize * kGridSize) {
                trace('boop');
                return true;
            }
            return findPathWithinCell(left, right) != null
                && findPathWithinCell(left, up) != null
                && findPathWithinCell(left, down) != null;
        };

        var xs = [-1, 1, 0, 0];//, 1, 1, -1, -1];
        var ys = [0, 0, -1, 1];//, 1, -1, 1, -1];
        while (!isDone()) {
            var node = _rand.randomElement(cellNodes);
            var k = _rand.randomInt(xs.length);
            var i = node.depth + xs[k];
            var j = node.height + ys[k];
            if (i >= pos.i && i < pos.i + kGridSize && j >= pos.j && j < pos.j + kGridSize) {
                var n = getNode(i, j);
                if (n == null) {
                    n = addNode(node, i, j);
                    var lev = node.level + (_rand.randomBool(0.65) ? 1 : 0);
                    n.level = Util.intMin(lev, cellLevel + kLevelsPerCellDist);
                    n.region = node.region;
                    cellNodes.push(n);
                } else if (_rand.randomBool(0.1)) {
                    n.addNeighbor(node);
                }
            }
        }

        var canTrim = function(node :MapNode) {
            return startNodes.indexOf(node) == -1 && node.neighbors.length == 1;
        };
        var trimmable = function() {
            return cellNodes.filter(canTrim);
        };
        while (trimmable().length > 0) {
            var toTrim = trimmable();
            for (node in toTrim) {
                removeNode(node.depth, node.height);
                cellNodes.remove(node);
            }
        }

        if (isOriginCell) {
            var minLevelNode :MapNode = null;
            for (node in cellNodes) {            
                if (minLevelNode == null || minLevelNode.level > node.level) {
                    minLevelNode = node;
                }
            }
            _start = minLevelNode;
            _start.town = true;
        }
        else {
            var townNode = _rand.randomElement(cellNodes);
            townNode.town = true;            
        }


        var tryConnect = function(i1, j1, i2, j2, force = false) {
            var a = getNode(i1, j1);
            var b = getNode(i2, j2);
            if ((force || _rand.randomBool(0.35)) && a != null && b != null) {
                a.addNeighbor(b);
            }
        };
        tryConnect(pos.i - 1, pos.j + leftY, left.depth, left.height, true);
        tryConnect(pos.i + kGridSize, pos.j + rightY, right.depth, right.height, true);
        tryConnect(pos.i + downX, pos.j - 1, down.depth, down.height, true);
        tryConnect(pos.i + upX, pos.j + kGridSize, up.depth, up.height, true);

        for (k in 0...kGridSize) {
            tryConnect(pos.i + k, pos.j, pos.i + k, pos.j - 1);
            tryConnect(pos.i + k, pos.j + kGridSize - 1, pos.i + k, pos.j + kGridSize);
            tryConnect(pos.i, pos.j + k, pos.i - 1, pos.j + k);
            tryConnect(pos.i + kGridSize - 1, pos.j + k, pos.i + kGridSize, pos.j + k);
        }

        forAllNodes(function(node) {
            node.markDirty();
        });
        updateScrollBounds();
    }

    public function getNode(i :Int, j :Int) :MapNode {
        if (_generated.get(i) != null && _generated.get(i).get(j) != null) {
            return _generated[i][j];
        }
        return null;
    }

    function addNode(parent :MapNode, i :Int, j :Int) :MapNode {
        if (getNode(i, j) != null) {
            return getNode(i, j);
        }
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

        if (_generated.get(i) == null) {
            _generated[i] = new Map<Int, MapNode>();
        }
        _generated[i][j] = node;
        return node;
    }

    function removeNode(i :Int, j :Int) :Void {
        var node = getNode(i, j);
        if (node == null) {
            return;
        }

        for (n in node.neighbors) {
            n.removeNeighbor(node);
        }

        entity.getSystem().removeEntity(node.entity);
        _generated[i].remove(j);
    }

    function tryUncross(i :Int, j :Int) :Void {
        if (_generated.get(i) == null || _generated.get(i - 1) == null) {
            return;
        }

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

    function bfsPath(start :MapNode, 
            endFunction :MapNode -> Bool,
            allowedFunction :MapNode -> Bool) :Array<MapNode> {
        if (endFunction(start)) {
            return [start];
        }

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
                var canVisit = node.hasVisited() && allowedFunction(n);
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
            },
            function (node :MapNode) {
                return true;
            });
    }

    public function returnToCheckpoint() {
        setSelected(_checkpoint);

        if (_movePath != null) {
            for (n in _movePath) {
                n.clearPath();
            }
            _movePath = null;
        }
    }

    public function isInTown() :Bool {
        return selectedNode.isTown();
    }

    public function serialize() :Dynamic {
        var nodes = [];
        forAllNodes(function (node) {
            nodes.push(node.serialize());
        });
        var cells = [];
        for (x in _gridGeneratedFlags.keys()) {
            for (y in _gridGeneratedFlags[x].keys()) {
                if (_gridGeneratedFlags[x][y]) {
                    cells.push({ x: x, y: y});
                }
            }
        }
        return {
            selected: { i: selectedNode.depth, j: selectedNode.height },
            checkpoint: { i: _checkpoint.depth, j: _checkpoint.height },
            cells: cells,
            nodes: nodes,
        };
    }
    public function deserialize(data :Dynamic) {
        var nodes :Array<Dynamic> = data.nodes;
        var cells :Array<Dynamic> = data.cells;
        for (c in cells) {
            generateGridCell(c.x, c.y);
        }
        for (n in nodes) {
            var arr = _generated.get(n.i);
            var node = null;
            if (arr != null) {
                node = arr.get(n.j);
            }
            if (node != null) {
                node.deserialize(n);
            }
        }
        var sel = getNode(data.selected.i, data.selected.j);
        if (sel != null) {
            selectedNode.clearOccupied();
            selectedNode = sel;
            sel.setOccupied();
        }
        var chk = getNode(data.checkpoint.i, data.checkpoint.j);
        if (chk != null) {
            _checkpoint = chk;
        }
    }
}
