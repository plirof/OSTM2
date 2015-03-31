package ostm.battle;

import jengine.*;
import jengine.SaveManager;

class PassiveSkill {
    public var id(default, null) :String;
    public var requirementIds(default, null) :Array<String>;
    public var abbreviation(default, null) :String;
    public var description(default, null) :String;
    public var level(default, null) :Int = 0;
    public var requirements(default, null) :Array<PassiveSkill> = [];
    public var pos(default, null) :Point;
    var modify :Int -> StatModifier -> Void;

    public function new(data :Dynamic) {
        id = data.id;
        requirementIds = data.reqs;
        abbreviation = data.icon;
        description = data.desc;
        modify = data.mod;
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

    public function sumAffixes(mod :StatModifier) {
        modify(5 * level, mod);
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
