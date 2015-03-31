package ostm.battle;

import jengine.*;
import jengine.SaveManager;

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
        requirementIds = data.requirements;
        name = data.name;
        abbreviation = data.icon;
        description = data.description;
        isPercent = data.isPercent;
        levelValueFunction = data.leveling;
        modifierFunction = data.modifier;
        pos = data.pos;
    }

    public function addRequirement(req :PassiveSkill) :Void {
        if (requirements.indexOf(req) == -1) {
            requirements.push(req);
        }
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
