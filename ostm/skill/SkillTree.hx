package ostm.skill;

import js.*;
import js.html.*;

import jengine.*;
import jengine.SaveManager;
import jengine.util.Util;
import jengine.util.JsUtil;

import ostm.battle.BattleManager;
import ostm.map.MapNode;

class SkillTree extends Component
        implements Saveable {
    public var saveId(default, null) :String = 'skill-tree';

    public static var instance(default, null) :SkillTree;

    var _skillNodes = new Array<SkillNode>();
    var _skillPoints :Element;

    public var skills(default, null) :Array<PassiveSkill>;

    public override function init() :Void {
        instance = this;
        skills = PassiveData.skills.copy();
    }

    public override function start() :Void {
        SaveManager.instance.addItem(this);

        var screen = Browser.document.getElementById('skill-screen');
        JsUtil.createSpan('Skill points: ', screen);
        _skillPoints = JsUtil.createSpan('', screen);

        for (skill in skills) {
            for (s2 in skills) {
                if (skill.requirementIds.indexOf(s2.id) != -1) {
                    skill.addRequirement(s2);
                }
            }
            // TODO: skills must have requirements listed before them in PassiveData, fix that
            addNode(skill);
        }

        updateScrollBounds();
    }

    public override function update() :Void {
        _skillPoints.innerText = Util.format(availableSkillPoints());

        for (node in _skillNodes) {
            var bg;
            if (node.skill.level > 0) {
                bg = '#ff3333';
            }
            else if (node.skill.hasMetRequirements() && availableSkillPoints() > 0) {
                bg = '#992222';
            }
            else {
                bg = '#444444';
            }
            node.elem.style.backgroundColor = bg;
        }
    }

    function maxSkillPoints() :Int {
        var player = BattleManager.instance.getPlayer();
        return player.level - 1;
    }

    function spentSkillPoints() :Int {
        var count = 0;
        for (skill in skills) {
            count += skill.level;
        }
        return count;
    }

    public function availableSkillPoints() :Int {
        return maxSkillPoints() - spentSkillPoints();
    }

    function addNode(skill :PassiveSkill) :SkillNode {
        var size :Vec2 = new Vec2(50, 50);

        var node = new SkillNode(skill, this);
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

        _skillNodes.push(node);
        return node;
    }

    function updateScrollBounds() :Void {
        var topLeft = new Vec2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var botRight = new Vec2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
        var origin :Vec2 = new Vec2(25, 25);
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
        return {
            skills: skills.map(function(skill) { return skill.serialize(); }),
        };
    }
    public function deserialize(data :Dynamic) :Void {
        if (SaveManager.instance.loadedVersion < 3) {
            return;
        }

        var savedSkills :Array<Dynamic> = data.skills;
        for (save in savedSkills) {
            for (skill in skills) {
                if (save.id == skill.id) {
                    skill.deserialize(save);
                }
            }
        }
    }
}

class SkillNode extends GameNode {
    public var skill(default, null) :PassiveSkill;
    var _description :Element;
    var _curValue :Element;
    var _nextValue :Element;
    var _count :Element;
    var _tree :SkillTree;

    public function new(skill :PassiveSkill, tree :SkillTree) {
        super(skill.pos.y, skill.pos.x);

        this.skill = skill;
        _tree = tree;
    }

    public override function start() :Void {
        super.start();

        var doc = Browser.document;

        JsUtil.createSpan(skill.abbreviation, elem);
        elem.appendChild(doc.createBRElement());
        _count = JsUtil.createSpan('', elem);

        _description = doc.createUListElement();
        JsUtil.createSpan(skill.name, _description);
        _description.appendChild(doc.createBRElement());
        JsUtil.createSpan(skill.description, _description);

        _description.appendChild(doc.createBRElement());

        JsUtil.createSpan('Current: ', _description);
        _curValue = JsUtil.createSpan('', _description);
        if (skill.isPercent) { JsUtil.createSpan('%', _description); }

        _description.appendChild(doc.createBRElement());

        JsUtil.createSpan('Next: ', _description);
        _nextValue = JsUtil.createSpan('', _description);
        if (skill.isPercent) { JsUtil.createSpan('%', _description); }

        _description.style.display = 'none';
        _description.style.position = 'absolute';
        _description.style.background = '#444444';
        _description.style.border = '2px solid #000000';
        _description.style.width = cast 220;
        _description.style.zIndex = cast 10;

        doc.getElementById('popup-container').appendChild(_description);
    }

    public override function update() :Void {
        _count.innerText = Util.format(skill.level);
        _curValue.innerText = Util.format(skill.currentValue());
        _nextValue.innerText = Util.format(skill.nextValue());
    }

    public override function onMouseOver(event :MouseEvent) :Void {
        _description.style.display = '';
        _description.style.left = cast event.x;
        _description.style.top = cast event.y;
    }

    public override function onMouseOut(event :MouseEvent) :Void {
        _description.style.display = 'none';
    }

    override function onClick(event) {
        if (_tree.availableSkillPoints() > 0 &&
            skill.hasMetRequirements()) {
            skill.levelUp();
        }
    }
}
