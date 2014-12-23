package ostm;

import jengine.*;
import jengine.util.*;

import js.*;
import js.html.Element;

class MapGenerator extends Component {    
    var _generated :Array<Map<Int, MapNode>>;
    var _selected :MapNode;

    public override function start() :Void {
        _generated = new Array<Map<Int, MapNode>>();
        _generated.push(new Map<Int, MapNode>());
        
        _selected = addNode(null, 0, 0);
        _selected.hasVisited = true;

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
        if (isAdjacent(node, _selected)) {
            _selected = node;
            node.hasVisited = true;

            if (node.depth + 1 == _generated.length) {
                addLayer();
            }

            updateColors();
        }
    }

    function updateColors() :Void {
        for (map in _generated) {
            for (node in map) {
                if (node == _selected) {
                    node.color = '#00ff00';
                }
                else if (isAdjacent(node, _selected)) {
                    node.hasSeen = true;
                    node.color = '#ffff00';
                }
                else if (!hasPathToStart(node)) {
                    node.color = '#000000';
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
            }
        }
    }

    function isAdjacent(a :MapNode, b :MapNode) :Bool {
        return b.parent == a || a.parent == b;
    }

    function hasPathToStart(node :MapNode) :Bool {
        var n = node;
        while (n.parent != null) {
            n = n.parent;
        }
        return n.depth == 0;
    }
}
