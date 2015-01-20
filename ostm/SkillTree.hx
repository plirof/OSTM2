package ostm;

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

        var a = addNode(null, 0, 0);
        var b = addNode(a, 1, -1);
        var c = addNode(a, 1, 1);
        var d = addNode(c, 2, 0);
        var e = addNode(c, 2, 1);

        updateScrollBounds();
    }

    function addNode(parent :SkillNode, i :Int, j :Int) :SkillNode {
        var size :Vec2 = new Vec2(40, 40);

        var node = new SkillNode(i, j);
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

    public override function update() :Void {
        elem.innerText = cast val;
    }

    override function onClick(event) {
        val++;
    }
}
