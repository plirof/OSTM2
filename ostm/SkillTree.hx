package ostm;

import js.*;
import js.html.*;

import jengine.*;
import jengine.SaveManager;

import ostm.map.MapNode;

class SkillTree extends Component
        implements Saveable {
    public var saveId(default, null) :String = 'skill-tree';

    public static var instance(default, null) :SkillTree;
    var _skills = new Array<SkillNode>();

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        SaveManager.instance.addItem(this);

        var a = addNode(null, 0, 0, "A node");
        var b = addNode(a, 1, -1, "B node");
        var c = addNode(a, 1, 1, "Another node");
        var d = addNode(c, 2, 0, "Ein Doe");
        var e = addNode(c, 2, 1, "Dich mach");

        updateScrollBounds();
    }

    function addNode(parent :SkillNode, i :Int, j :Int, desc :String) :SkillNode {
        var size :Vec2 = new Vec2(40, 40);

        var node = new SkillNode(i, j, desc);
        var ent = new Entity([
            new HtmlRenderer({
                parent: 'skill-screen',
                size: size,
            }),
            new Transform(),
            node,
        ]);
        if (parent != null) {
            node.addNeighbor(parent);
        }
        entity.getSystem().addEntity(ent);

        _skills.push(node);
        return node;
    }

    function updateScrollBounds() :Void {
        var topLeft = new Vec2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var botRight = new Vec2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
        var origin :Vec2 = new Vec2(100, 100);
        for (node in _skills) {
            var pos = node.getOffset();
            topLeft = Vec2.min(topLeft, pos);
        }

        for (node in _skills) {
            var pos = origin + node.getOffset() - topLeft;
            node.getTransform().pos = pos;
            botRight = Vec2.max(botRight, pos);
        }
    }

    public function serialize() :Dynamic {
        return { };
    }
    public function deserialize(data :Dynamic) :Void {
    }
}

class SkillNode extends GameNode {
    var val = 0;
    var _desc :String;
    var _description :Element;

    public function new(x :Int, y :Int, desc :String) {
        super(x, y);
        _desc = desc;
    }

    public override function start() :Void {
        super.start();

        _description = Browser.document.createUListElement();
        var descText = Browser.document.createSpanElement();
        descText.innerText = _desc;
        _description.appendChild(descText);

        _description.style.display = 'none';
        _description.style.position = 'absolute';
        _description.style.background = '#444444';
        _description.style.border = '2px solid #000000';
        _description.style.width = cast 220;
        _description.style.zIndex = cast 10;

        Browser.document.getElementById('popup-container').appendChild(_description);
    }

    public override function update() :Void {
        elem.innerText = cast val;
    }

    public override function onMouseOver(event :MouseEvent) :Void {
        _description.style.display = '';
        _description.style.left = cast event.x;
        _description.style.top = cast event.y;
        trace(event.x, event.pageX, event.layerX, event.clientX, event.offsetX, event.screenX, event.movementX);
        trace(event.y, event.pageY, event.layerY, event.clientY, event.offsetY, event.screenY, event.movementY);
    }

    public override function onMouseOut(event :MouseEvent) :Void {
        _description.style.display = 'none';
    }

    override function onClick(event) {
        val++;
    }
}
