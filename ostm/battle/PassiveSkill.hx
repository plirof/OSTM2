package ostm.battle;

import jengine.*;
import jengine.SaveManager;

class PassiveSkill {
    public var abbreviation(default, null) :String;
    public var description(default, null) :String;
    public var level(default, null) :Int = 0;
    public var requirements(default, null) :Array<PassiveSkill> = [];

    public function new(abbrev :String, desc :String) {
        abbreviation = abbrev;
        description = desc;
    }

    public function addRequirement(req :PassiveSkill) :Void {
        if (requirements.indexOf(req) == -1) {
            requirements.push(req);
        }
    }

    public function levelUp() :Void {
        level++;
    }
}
