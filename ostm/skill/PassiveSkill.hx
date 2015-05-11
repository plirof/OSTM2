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
    public var description(default, null) :String;
    public var isPercent(default, null) :Bool;
    public var level(default, null) :Int = 0;
    public var requirements(default, null) :Array<PassiveSkill> = [];
    public var pos(default, null) :Point;
    var levelValueFunction :Int -> Int;
    var modifierFunction :Int -> StatModifier -> Void;

    public function new(data :Dynamic) {
        id = data.id;
        requirementIds = data.requirements != null ? data.requirements : [];
        name = data.name;
        abbreviation = data.icon;
        description = data.description;
        isPercent = data.isPercent != null ? data.isPercent : false;
        levelValueFunction = data.leveling;
        modifierFunction = data.modifier;
        pos = data.pos;
    }

    public function addRequirement(req :PassiveSkill) :Void {
        if (!Util.contains(requirements, req)) {
            requirements.push(req);
        }
    }

    public function hasMetRequirements() :Bool {
        for (req in requirements) {
            if (req.level > 0) {
                return true;
            }
        }
        return requirements.length == 0;
    }

    public function levelUp() :Void {
        level++;
    }

    public function currentValue() :Int {
        return levelValueFunction(level);
    }
    public function nextValue() :Int {
        return levelValueFunction(level + 1);
    }

    public function sumAffixes(mod :StatModifier) {
        modifierFunction(currentValue(), mod);
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
