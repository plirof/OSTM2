package ostm;

import js.*;
import js.html.*;

import jengine.*;
import jengine.SaveManager;

import ostm.battle.PassiveSkill;
import ostm.map.MapNode;

class SkillTree extends Component
        implements Saveable {
    public var saveId(default, null) :String = 'skill-tree';

    public static var instance(default, null) :SkillTree;
    public var skills(default, null) = new Array<PassiveSkill>();
    var _skillNodes = new Array<SkillNode>();

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        SaveManager.instance.addItem(this);

        var str = new PassiveSkill('STR+', 'Strength+');
        var vit = new PassiveSkill('VIT+', 'Vitality+');
        var spd = new PassiveSkill('SPD+', 'Speed+');
        var crit = new PassiveSkill('CCH+', 'Crit Chance+');

        vit.addRequirement(str);
        spd.addRequirement(str);
        crit.addRequirement(spd);

        addNode(str, 0, 0);
        addNode(vit, 1, -1);
        addNode(spd, 1, 1);
        addNode(crit, 2, 1);

        updateScrollBounds();
    }

    function addNode(skill :PassiveSkill, y :Int, x :Int) :SkillNode {
        var size :Vec2 = new Vec2(50, 50);

        var node = new SkillNode(y, x, skill);
        var ent = new Entity([
            new HtmlRenderer({
                parent: 'skill-screen',
                size: size,
            }),
            new Transform(),
            node,
        ]);
        for (req in skill.requirements) {
            for (n in _skillNodes) {
                if (n.skill == req) {
                    node.addNeighbor(n);
                }
            }
        }
        entity.getSystem().addEntity(ent);

        skills.push(skill);
        _skillNodes.push(node);
        return node;
    }

    function updateScrollBounds() :Void {
        var topLeft = new Vec2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var botRight = new Vec2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
        var origin :Vec2 = new Vec2(100, 100);
        for (node in _skillNodes) {
            var pos = node.getOffset();
            topLeft = Vec2.min(topLeft, pos);
        }

        for (node in _skillNodes) {
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
    public var skill(default, null) :PassiveSkill;
    var _description :Element;
    var _count :Element;

    public function new(x :Int, y :Int, skill :PassiveSkill) {
        super(x, y);
        this.skill = skill;
    }

    public override function start() :Void {
        super.start();

        var name = Browser.document.createSpanElement();
        name.innerText = skill.abbreviation;
        elem.appendChild(name);
        elem.appendChild(Browser.document.createBRElement());
        _count = Browser.document.createSpanElement();
        elem.appendChild(_count);

        _description = Browser.document.createUListElement();
        var descText = Browser.document.createSpanElement();
        descText.innerText = skill.description;
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
        _count.innerText = cast skill.level;
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
        skill.levelUp();
    }
}
