package ostm;

import js.*;
import js.html.*;

import jengine.*;
import jengine.SaveManager;
import jengine.util.Util;

import ostm.battle.PassiveSkill;
import ostm.map.MapNode;

class SkillTree extends Component
        implements Saveable {
    public var saveId(default, null) :String = 'skill-tree';

    public static var instance(default, null) :SkillTree;
    public var skills(default, null) = [
        new PassiveSkill({
            id: 'str',
            requirements: [],
            icon: 'STR+',
            pos: {x: 0, y: 0},
            name: 'Strength+',
            description: 'Increases strength',
            isPercent: false,
            leveling: function(level) {
                return 3 * level;
            },
            modifier: function(value, mod) {
                mod.flatStrength += value;
            },
        }),
        new PassiveSkill({
            id: 'vit',
            requirements: ['str'],
            icon: 'VIT+',
            pos: {x: -1, y: 1},
            name: 'Vitality+',
            description: 'Increases vitality',
            isPercent: false,
            leveling: function(level) {
                return 4 * level;
            },
            modifier: function(value, mod) {
                mod.flatVitality += value;
            },
        }),
        new PassiveSkill({
            id: 'spd',
            requirements: ['str'],
            icon: 'SPD+',
            pos: {x: 1, y: 1},
            name: 'Speed+',
            description: 'Increases movement speed',
            isPercent: true,
            leveling: function(level) {
                return 6 * level;
            },
            modifier: function(value, mod) {
                mod.percentMoveSpeed += value;
            },
        }),
        new PassiveSkill({
            id: 'cch',
            requirements: ['spd'],
            icon: 'CCH+',
            pos: {x: 1, y: 2},
            name: 'Crit Chance+',
            description: 'Increases global critical hit chance',
            isPercent: true,
            leveling: function(level) {
                return 15 * level;
            },
            modifier: function(value, mod) {
                mod.percentCritChance += value;
            },
        }),
    ];
    var _skillNodes = new Array<SkillNode>();


    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        SaveManager.instance.addItem(this);

        for (skill in skills) {
            for (s2 in skills) {
                if (skill.requirementIds.indexOf(s2.id) != -1) {
                    skill.addRequirement(s2);
                }
            }
            addNode(skill, skill.pos.x, skill.pos.y);
        }

        updateScrollBounds();
    }

    function addNode(skill :PassiveSkill, y :Int, x :Int) :SkillNode {
        var size :Vec2 = new Vec2(50, 50);

        var node = new SkillNode(x, y, skill);
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
        var origin :Vec2 = new Vec2(15, 15);
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

    public function new(x :Int, y :Int, skill :PassiveSkill) {
        super(x, y);
        this.skill = skill;
    }

    public override function start() :Void {
        super.start();

        createSpan(skill.abbreviation, elem);
        elem.appendChild(Browser.document.createBRElement());
        _count = createSpan('', elem);

        _description = Browser.document.createUListElement();
        createSpan(skill.name, _description);
        _description.appendChild(Browser.document.createBRElement());
        createSpan(skill.description, _description);

        _description.appendChild(Browser.document.createBRElement());

        createSpan('Current: ', _description);
        _curValue = createSpan('', _description);
        if (skill.isPercent) { createSpan('%', _description); }

        _description.appendChild(Browser.document.createBRElement());

        createSpan('Next: ', _description);
        _nextValue = createSpan('', _description);
        if (skill.isPercent) { createSpan('%', _description); }

        _description.style.display = 'none';
        _description.style.position = 'absolute';
        _description.style.background = '#444444';
        _description.style.border = '2px solid #000000';
        _description.style.width = cast 220;
        _description.style.zIndex = cast 10;

        Browser.document.getElementById('popup-container').appendChild(_description);
    }

    function createSpan(text :String, parent :Element) :Element {
        var elem = Browser.document.createSpanElement();
        elem.innerText = text;
        if (parent != null) {
            parent.appendChild(elem);
        }
        return elem;
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
        skill.levelUp();
    }
}
