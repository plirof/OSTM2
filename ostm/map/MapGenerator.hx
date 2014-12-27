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

    public override function start() :Void {
        _rand = new MapRandom();
        _generated = new Array<Map<Int, MapNode>>();
        _generated.push(new Map<Int, MapNode>());
        
        _scrollHelper = new Entity([
            new HtmlRenderer(new Vec2(10, 10)),
            new Transform(new Vec2(0, 0)),
        ]);
        entity.getSystem().addEntity(_scrollHelper);

        _start = addNode(null, 0, 0);
        _selected = _start;

        for (i in 1...25) {
            addLayer();
        }

        _start.setOccupied();
    }

    function addLayer() :Void {
        _generated.push(new Map<Int, MapNode>());
        var i = _generated.length - 1;
        var p = i - 1;
        _rand.setSeed(35613 * i + 273);

        for (parent in _generated[p]) {
            var nChildren = _rand.randomBool(0.4) ? 2 : 1;
            var didAddPath = false;
            var possibles = [-1, 0, 1];
            while (possibles.length > nChildren) {
                possibles.remove(_rand.randomElement(possibles));
            }
            while (possibles.length > 0) {
                var j = _rand.randomElement(possibles);
                possibles.remove(j);
                j += parent.height;
                var node = _generated[i].get(j);
                if (node == null) {
                    node = addNode(parent, i, j);
                    didAddPath = true;
                }
                else if (_rand.randomBool(0.35) ||
                        (possibles.length == 0 && !didAddPath)) {
                    node.addNeighbor(parent);
                    didAddPath = true;
                }
            }
        }

        forAllNodes(function (node) {
            tryUncross(node.depth, node.height);
        });
    }

    function addNode(parent :MapNode, i :Int, j :Int) :MapNode {
        var origin :Vec2 = new Vec2(100, 300);
        var pos :Vec2 = origin + new Vec2(80 * i, 55 * j);
        var size :Vec2 = new Vec2(40, 40);

        var node = new MapNode(this, i, j, parent);
        var ent = new Entity([
            new HtmlRenderer(size),
            new Transform(pos),
            node,
        ]);
        entity.getSystem().addEntity(ent);
        if (parent != null) {
            parent.neighbors.push(node);
        }

        var scrollBuffer = new Vec2(750, 350);
        _scrollHelper.getTransform().pos = pos + scrollBuffer;

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
                if (_rand.randomBool()) {
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
            forAllNodes(function (node) { node.ratchetState(); });

            _selected = node;
            for (i in 0...path.length) {
                var n = path[i];
                n.setPath();
            }
            _selected.setOccupied();

            if (_selected.depth + 1 == _generated.length) {
                addLayer();
            }
        }
    }

    function forAllNodes(f :MapNode -> Void) :Void {
        for (map in _generated) {
            for (node in map) {
                f(node);
            }
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
                var canVisit = node.isPathVisible(n);
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
