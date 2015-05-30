package ostm.skill;

import jengine.Point;
import jengine.SaveManager;
import jengine.util.Util;

import ostm.battle.StatModifier;

class PassiveSkill {
    public var id(default, null) :String;
    public var requirementIds(default, null) :Array<String>;
    public var abbreviation(default, null) :String;
    public var name(default, null) :String;
    public var level(default, null) :Int = 0;
    public var requirements(default, null) :Array<PassiveSkill> = [];
    public var pos(default, null) :Point;
    var modifierFunction :Int -> StatModifier -> Void;

    public function new(data) {
        id = data.id;
        requirementIds = data.requirements != null ? data.requirements : [];
        name = data.name;
        abbreviation = data.icon;
        modifierFunction = data.modifier;
        pos = data.pos;
    }

    public function addRequirement(req :PassiveSkill) :Void {
        if (!Util.contains(requirements, req)) {
            if (requirements.length == 0) {
                pos = { x: pos.x + req.pos.x, y: pos.y + req.pos.y };
            }
            requirements.push(req);
        }
    }

    public function hasSpentEnoughPoints(tree :SkillTree) :Bool {
        var spendReq = requiredPointsSpent();
        return spendReq <= 0 || tree.spentSkillPoints() >= spendReq;
    }

    public function hasMetRequirements(tree :SkillTree) :Bool {
        if (!hasSpentEnoughPoints(tree)) {
            return false;
        }
        for (req in requirements) {
            if (req.level > 0) {
                return true;
            }
        }
        return requirements.length == 0;
    }

    public function requiredPointsSpent() :Int {
        return Math.floor(pos.y * (4 + 1.5 * level) - 2);
    }

    public function levelUp() :Void {
        level++;

        untyped ga('send', 'event', 'player', 'spend-skill-point', id, level);
    }

    public function currentValue() :StatModifier {
        var mod = new StatModifier();
        modifierFunction(level, mod);
        return mod;
    }
    public function nextValue() :StatModifier {
        var mod = new StatModifier();
        modifierFunction(level + 1, mod);
        return mod;
    }

    public function sumAffixes(mod :StatModifier) {
        modifierFunction(level, mod);
    }

    public function serialize() :Dynamic {
        return {
            id: id,
            level: level,
        };
    }

    public function deserialize(data :Dynamic) {
        level = data.level;
    }
}
