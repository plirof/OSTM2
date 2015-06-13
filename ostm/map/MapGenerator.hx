package ostm.map;

import js.*;
import js.html.*;

import jengine.*;
import jengine.SaveManager;
import jengine.util.Util;

import ostm.TownManager;
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
    var _shouldCenter :Bool = true;

    static inline var kMoveTime :Float = 12.0;
    var _moveBarTransform :Transform;
    var _mapScreenElem :Element;
    var _moveTimer :Float = 0;
    var _movePath :Array<MapNode> = null;

    static inline var kGridSize :Int = 5;
    static inline var kLevelsPerCellDist :Int = 6;
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

        _scrollHelper = new Entity([
            new HtmlRenderer({
                parent: 'map-screen',
                size: new Vec2(1, 1),
            }),
            new Transform(new Vec2(0, 0)),
        ]);
        entity.getSystem().addEntity(_scrollHelper);

        _moveBarTransform = new Transform();
        var moveBarEntity = new Entity([
            _moveBarTransform,
            new HtmlRenderer({
                parent: 'map-screen',
                className: 'move-bar',
                style: [
                    'position' => 'fixed',
                ],
            }),
            new ProgressBar(function() {
                return _moveTimer / kMoveTime;
            }),
        ]);
        entity.getSystem().addEntity(moveBarEntity);
        _mapScreenElem = Browser.document.getElementById('map-screen');

        generateSurroundingCells(0, 0);
        setSelected(_start); // _start is generated as part of generateGridCell(0, 0)

        // var baseGen = 6;
        // for (i in -baseGen...(baseGen + 1)) {
        //     for (j in -baseGen...(baseGen + 1)) {
        //         generateGridCell(i, j);
        //     }
        // }

        updateScrollBounds();
        centerCurrentNode();

        Browser.window.setTimeout(function() {
            NotificationManager.instance.queueNotification(MapUpdate);
        }, 0);
    }

    public override function update() {
        var rect = _mapScreenElem.getBoundingClientRect();
        _moveBarTransform.pos = new Vec2(rect.left + 20, rect.top + 20);

        if (_shouldCenter && selectedNode.elem != null) {
            js.Browser.window.setTimeout(function() {
                selectedNode.elem.scrollIntoViewIfNeeded(true);
            }, 0);
            _shouldCenter = false;
        }


        if (BattleManager.instance.isInBattle() ||
            BattleManager.instance.isPlayerDead()) {
            return;
        }

        var player = BattleManager.instance.getPlayer();
        _moveTimer += Time.dt * player.moveSpeed();
        if (isInTown()) {
            _moveTimer = kMoveTime;
        }

        if (_movePath != null) {
            if (_moveTimer >= kMoveTime && !BattleManager.instance.isInBattle()) {
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
        if (selectedNode != null) {
            selectedNode.clearPath();
            selectedNode.clearOccupied();
        }

        selectedNode = next;
        generateSurroundingCells(next.depth, next.height);
        selectedNode.setOccupied();
        BattleManager.instance.resetKillCount();

        if (next.isTown()) {
            _checkpoint = next;

            var gridPos = getGridCoord(next.depth, next.height);
            forAllNodesInGridCell(gridPos.x, gridPos.y, function (node) {
                node.setVisible();
            });
            var xs = [1, -1, 0, 0];
            var ys = [0, 0, 1, -1];
            for (i in 0...xs.length) {
                forAllNodesInGridCell(gridPos.x + xs[i], gridPos.y + ys[i], function(node) {
                    if (node.isTown()) {
                        node.setVisible();
                    }
                });
            }
        }

        forAllNodes(function (node) {
            if (node.isHint()) {
                node.markDirty();
            }
        });

        updateScrollBounds();
        centerCurrentNode();

        NotificationManager.instance.queueNotification(MapUpdate);
    }

    function generateSurroundingCells(i :Int, j :Int) :Void {
        var p = getGridCoord(i, j);
        var xs = [0, -1, 1, 0, 0];
        var ys = [0, 0, 0, -1, 1];
        for (k in 0...xs.length) {
            generateGridCell(p.x + xs[k], p.y + ys[k]);
        }
    }

    function cellSeed(x :Int, y :Int) :Int {
        return 4613767 + 21487 * x + 54013 * y + 147 * x * y;
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

        // No grid cell under origin
        if (x == 1 && y == 0) {
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
        
        var leftY = _rand.setSeed(seed + leftSeed).randomInt(kGridSize - 2) + 1;
        var rightY = _rand.setSeed(seed + rightSeed).randomInt(kGridSize - 2) + 1;
        var downX = _rand.setSeed(seed + downSeed).randomInt(kGridSize - 2) + 1;
        var upX = _rand.setSeed(seed + upSeed).randomInt(kGridSize - 2) + 1;

        _rand.setSeed(seed);

        var left = addNode(null, pos.i, pos.j + leftY);
        var right = addNode(null, pos.i + kGridSize - 1, pos.j + rightY);
        var down = addNode(null, pos.i + downX, pos.j);
        var up = addNode(null, pos.i + upX, pos.j + kGridSize - 1);

        var startNodes = [left];
        if (startNodes.indexOf(right) == -1) { startNodes.push(right); }
        if (startNodes.indexOf(up) == -1) { startNodes.push(up); }
        if (startNodes.indexOf(down) == -1) { startNodes.push(down); }

        var cellNodes = startNodes.copy(); //[left, right, up, down];

        var findPathWithinCell = function(start :MapNode, end :MapNode) {
            return bfsPath(start,
                function (node :MapNode) {
                    return node == end;
                },
                function (node :MapNode) {
                    return true;
                });
        };

        var isDone = function() {
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

        // Connect this grid cell to its neighbors
        var tryConnect = function(i1, j1, i2, j2, force = false) {
            var a = getNode(i1, j1);
            var b = getNode(i2, j2);
            if ((force || _rand.randomBool(0.35)) && a != null && b != null) {
                a.addNeighbor(b);
            }
        };
        tryConnect(left.depth - 1, left.height, left.depth, left.height, true);
        tryConnect(right.depth + 1, right.height, right.depth, right.height, true);
        tryConnect(down.depth, down.height - 1, down.depth, down.height, true);
        tryConnect(up.depth, up.height + 1, up.depth, up.height, true);

        for (k in 0...kGridSize) {
            tryConnect(pos.i + k, pos.j, 
                       pos.i + k, pos.j - 1);
            tryConnect(pos.i + k, pos.j + kGridSize - 1,
                       pos.i + k, pos.j + kGridSize);
            tryConnect(pos.i, pos.j + k,
                       pos.i - 1, pos.j + k);
            tryConnect(pos.i + kGridSize - 1, pos.j + k,
                       pos.i + kGridSize, pos.j + k);
        }

        // Set levels for cells
        var distToOrigin = Math.floor(Math.abs(x) + Math.abs(y));
        var cellLevel = distToOrigin * kLevelsPerCellDist;
        var cellRegion = _rand.randomInt(Util.clampInt(distToOrigin, 2, MapNode.kMaxRegions - 1));
        if (isOriginCell) {
            cellRegion = 0;
        }

        for (node in cellNodes) {
            node.level = cellLevel + 1;
            node.region = cellRegion;
        }

        var leftLev = Math.abs(x - 1) > Math.abs(x) ? kLevelsPerCellDist : 1;
        var rightLev = Math.abs(x + 1) > Math.abs(x) ? kLevelsPerCellDist : 1;
        var downLev = Math.abs(y - 1) > Math.abs(y) ? kLevelsPerCellDist : 1;
        var upLev = Math.abs(y + 1) > Math.abs(y) ? kLevelsPerCellDist : 1;
        if (isOriginCell) { rightLev = 1; }

        startNodes = [left, right, down, up];
        var startLevels = [leftLev, rightLev, downLev, upLev];

        for (node in cellNodes) {
            var lev;
            if (startNodes.indexOf(node) != -1) {
                lev = startLevels[startNodes.indexOf(node)];
            }
            else {
                var dists = [];
                for (s in startNodes) {
                    dists.push(findPathWithinCell(node, s).length - 1);
                }
                var loDist = 2 * kGridSize * kGridSize;
                for (i in 0...dists.length) {
                    var d = dists[i];
                    if (d < loDist && startLevels[i] == 1) {
                        loDist = d;
                    }
                }
                var loInd = dists.indexOf(loDist);
                var hiInd = (loInd + 1) % 2 + (loInd >= 2 ? 2 : 0);
                var hiDist = dists[hiInd];
                var totDist = loDist + hiDist;
                lev = Math.round(Util.lerp(loDist / totDist, 1, kLevelsPerCellDist));
                lev = Util.clampInt(lev + _rand.randomElement([-1, 0, 0, 1]), 1, kLevelsPerCellDist);
            }

            node.level = lev + cellLevel;
        }

        // Setup town node
        if (!isOriginCell) {
            var townNode = _rand.randomElement(cellNodes);
            townNode.town = true;            
        }
        else {
            var minLevelNode :MapNode = null;
            for (node in cellNodes) {            
                if (minLevelNode == null || minLevelNode.level > node.level) {
                    minLevelNode = node;
                }
            }
            _start = minLevelNode;
            _start.town = true;
        }

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

        if (TownManager.instance.shouldWarp && node.isTown() && node.hasVisited()) {
            setPath(null);
            setSelected(node);
            return;
        }

        var path = findPath(selectedNode, node);
        if (path == null) {
            return;
        }

        setPath(path);

        NotificationManager.instance.queueNotification(MapUpdate);
    }

    public function hover(node :MapNode) :Void {
        var path = findPath(selectedNode, node);
        if (path != null) {
            for (n in path) {
                n.setPathHighlight(path);
            }
        }
        NotificationManager.instance.queueNotification(MapUpdate);
    }

    public function hoverOver(node :MapNode) :Void {
        forAllNodes(function (node) { node.clearPathHighlight(); });
        NotificationManager.instance.queueNotification(MapUpdate);
    }

    function forAllNodes(f :MapNode -> Void) :Void {
        for (map in _generated) {
            for (node in map) {
                f(node);
            }
        }
    }

    function forAllNodesInGridCell(x :Int, y :Int, f :MapNode -> Void) :Void {
        for (i in (x * kGridSize)...((x + 1) * kGridSize)) {
            var row = _generated.get(i);
            if (row != null) {
                for (j in (y * kGridSize)...(y + 1) * kGridSize) {
                    var node = row.get(j);
                    if (node != null) {
                        f(node);
                    }
                }
            }
        }
    }

    function updateScrollBounds() :Void {
        var topLeft = new Vec2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var botRight = new Vec2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
        var origin :Vec2 = new Vec2(100, 100);
        forAllNodes(function (node) {
            if (node.hasSeen()) {
                var pos = node.getOffset();
                topLeft = Vec2.min(topLeft, pos);
            }
        });

        forAllNodes(function (node) {
            var pos = origin + node.getOffset() - topLeft;
            node.getTransform().pos = pos;
            if (node.hasSeen()) {
                botRight = Vec2.max(botRight, pos);
            }
        });
        
        var scrollBuffer = new Vec2(250, 150);
        _scrollHelper.getTransform().pos = origin + botRight + scrollBuffer;
        
        forAllNodes(function(node) {
            node.markDirty();
        });
    }

    public function centerCurrentNode() :Void {
        _shouldCenter = true;
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
                var canVisit = allowedFunction(n);
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
                return node == end || node.hasVisited();
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

        updateScrollBounds();
        centerCurrentNode();

        Browser.window.setTimeout(function() {
            NotificationManager.instance.queueNotification(MapUpdate);
        }, 0);
    }
}
