package ostm;

import jengine.*;
import jengine.util.*;

import js.*;
import js.html.Element;

class MapGenerator extends Component {    
    var _generated :Array<Map<Int, MapNode>>;
    var _selected :MapNode;
    var _start :MapNode;

    public override function start() :Void {
        _generated = new Array<Map<Int, MapNode>>();
        _generated.push(new Map<Int, MapNode>());
        
        _start = addNode(null, 0, 0);
        _start.hasVisited = true;
        _selected = _start;

        for (i in 1...25) {
            addLayer();
        }

        updateColors();
    }

    function addLayer() :Void {
        _generated.push(new Map<Int, MapNode>());
        var i = _generated.length - 1;

        var v :Int = Math.floor(i / 2);
        for (j in -v...(v+1)) {
            var possibleParents :Array<MapNode> = [];
            for (k in (j - 1)...(j + 2)) {
                var p = _generated[i - 1][k];
                if (p != null) {
                    possibleParents.push(p);
                }
            }
            var parent :MapNode = Random.randomElement(possibleParents);
            var prob = parent == null ? 0.25 : 0.75;
            if (Random.randomBool(prob)) {
                addNode(parent, i, j);
            }
        }
    }

    function addNode(parent :MapNode, i :Int, j :Int) :MapNode {
        var origin :Vec2 = new Vec2(100, 300);
        var pos :Vec2 = origin + new Vec2(80 * i, 55 * j);
        var size :Vec2 = new Vec2(40, 40);

        var node = new MapNode(this, i, parent);
        var ent = new Entity([
            new HtmlRenderer(size),
            new Transform(pos),
            node,
        ]);
        entity.getSystem().addEntity(ent);

        _generated[i][j] = node;
        return node;
    }

    public function click(node :MapNode) :Void {
        var path = findPath(_selected, node);
        if (path != null) {
            forAllNodes(function (node :MapNode) { node.isMarked = false; });
            for (n in path) {
                n.isMarked = true;
            }

            _selected = node;
            node.hasVisited = true;

            if (node.depth + 1 == _generated.length) {
                addLayer();
            }

            updateColors();
        }
    }

    function forAllNodes(f :MapNode -> Void) :Void {
        for (map in _generated) {
            for (node in map) {
                f(node);
            }
        }
    }

    function updateColors() :Void {
        forAllNodes(function (node :MapNode) {
            if (isAdjacent(node, _selected)) {
                node.hasSeen = true;
            }
            if (node == _selected) {
                node.color = '#00ff00';
            }
            else if (!hasPathToStart(node)) {
                node.color = '#000000';
            }
            else if (node.isMarked) {
                node.color = '#00ffff';
            }
            else if (!node.hasSeen) {
                node.color = '';
            }
            else if (!node.hasVisited) {
                node.color = '#888888';
            }
            else {
                node.color = '#ff0000';
            }
        });
    }

    function isAdjacent(a :MapNode, b :MapNode) :Bool {
        return b.parent == a || a.parent == b;
    }
    function getAdjacentNodes(node :MapNode) :Array<MapNode> {
        var adjacent = new Array<MapNode>();
        forAllNodes(function (n :MapNode) {
            if (isAdjacent(n, node)) {
                adjacent.push(n);
            }
        });
        return adjacent;
    }

    function findPath(start :MapNode, end :MapNode) :Array<MapNode> {
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

            var neighbors = getAdjacentNodes(node);
            for (n in neighbors) {
                if (closedSet.get(n) == null) {
                    openSet.push(n);
                    closedSet[n] = node;
                }
                if (n == end) {
                    return constructPath(n);
                }
            }
        }

        return null;
    }

    function hasPathToStart(node :MapNode) :Bool {
        var n = node;
        while (n.parent != null) {
            n = n.parent;
        }
        return n.depth == 0;
    }
}
