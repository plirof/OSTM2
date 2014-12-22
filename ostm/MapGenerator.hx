package ostm;

import jengine.*;
import jengine.util.*;

import js.*;
import js.html.Element;
import js.html.MouseEvent;

@:allow(ostm.MapGenerator)
class MapNode extends Component {
    var line :Element;
    var map :MapGenerator;
    var parent :MapNode;
    var depth :Int;

    var elem :Element;

    var color :String = 'red';
    var _cachedColor :String = '';

    function new(gen :MapGenerator, dep :Int, par :MapNode) {
        map = gen;
        depth = dep;
        parent = par;
    }

    public override function start() :Void {
        elem = entity.getComponent(HtmlRenderer).getElement();

        elem.onmousedown = onMouseDown;
        elem.onmouseout = onMouseUp;
        elem.onmouseup = onMouseUp;
        elem.onclick = onClick;
    }

    public override function update() :Void {
        if (color != _cachedColor) {
            _cachedColor = color;
            elem.style.background = color;
        }
    }

    function onMouseDown(event :MouseEvent) :Void {
    }
    function onMouseUp(event :MouseEvent) :Void {
    }

    function onClick(event :MouseEvent) :Void {
        map.click(this);
    }
}

class MapGenerator extends Component {    
    var _generated :Array<Map<Int, MapNode>>;
    var _selected :MapNode;

    var _lineWidth :Float = 3;

    public override function start() :Void {
        _generated = new Array<Map<Int, MapNode>>();
        _generated.push(new Map<Int, MapNode>());
        
        _selected = addNode(null, 0, 0);

        for (i in 1...2) {
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
        var elem = ent.getComponent(HtmlRenderer).getElement();
        
        elem.style.borderRadius = cast 32;
        elem.style.border = _lineWidth + 'px solid black';

        entity.getSystem().addEntity(ent);

        var line :Element = null;
        if (parent != null) {
            var center = pos + size / 2;
            var pCenter = parent.entity.getTransform().pos + size / 2;
            line = addLine(pCenter, center);
        }

        _generated[i][j] = node;
        return node;
    }

    function addLine(a :Vec2, b :Vec2) :Element {
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
        return elem;
    }

    public function click(node :MapNode) :Void {
        if (isAdjacent(node, _selected)) {
            _selected = node;

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
                    node.color = '#ffff00';
                }
                else if (!hasPathToStart(node)) {
                    node.color = '#000000';
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
