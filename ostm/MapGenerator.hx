package ostm;

import jengine.*;
import jengine.util.*;

import js.*;
import js.html.Element;

typedef MapNode = {
    entity :Entity,
    line :Element,
}

class MapGenerator extends Component {    
    var _generated :Array<Map<Int, MapNode>>;

    var _lineWidth :Float = 3;

    public override function start() :Void {
        _generated = new Array<Map<Int, MapNode>>();
        _generated.push(new Map<Int, MapNode>());
        addNode(null, 0, 0);

        for (i in 1...40) {
            addLayer();
        }
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

    function addNode(parent :MapNode, i :Int, j :Int) :Void {
        var origin :Vec2 = new Vec2(100, 300);
        var pos :Vec2 = origin + new Vec2(80 * i, 55 * j);
        var size :Vec2 = new Vec2(40, 40);

        var ent = new Entity([
            new HtmlRenderer(size),
            new Transform(pos),
        ]);
        var elem = ent.getComponent(HtmlRenderer).getElement();
        
        elem.style.borderRadius = cast 32;
        elem.style.border = _lineWidth + 'px solid black';

        _entity.getSystem().addEntity(ent);

        var line :Element = null;
        if (parent != null) {
            var center = pos + size / 2;
            var pCenter = parent.entity.getTransform().pos + size / 2;
            line = addLine(pCenter, center);
        }

        _generated[i][j] = {
            entity: ent,
            line: line,
        };
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
}
