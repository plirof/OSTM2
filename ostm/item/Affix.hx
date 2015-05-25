package ostm.item;

import jengine.util.Random;

import ostm.battle.StatModifier;
import ostm.item.ItemType;

@:allow(ostm.item.Affix)
class AffixType {
    public var id(default, null) :String;
    var description :String;
    var baseValue :Float;
    var valuePerLevel :Float;
    var levelPower :Float;
    var modifierFunc :Int -> StatModifier -> Void;
    var slotMultipliers :Map<ItemSlot, Float>;
    public static inline var kMaxRolls :Int = 1000;

    public function new(data :Dynamic) {
        this.id = data.id;
        this.description = data.description;
        this.baseValue = data.base;
        this.valuePerLevel = data.perLevel;
        this.levelPower = data.levelPower != null ? data.levelPower : 1;
        this.modifierFunc = data.modifierFunc;
        this.slotMultipliers = data.multipliers;
    }

    function levelModifier(baseLevel :Int) :Int {
        return Math.round(Math.pow(baseLevel, levelPower) + 2);
    }

    inline function multiplierFor(slot :ItemSlot) :Float {
        var mult = slotMultipliers.get(slot);
        return mult == null ? 0 : mult;
    }

    public function valueForLevel(slot :ItemSlot, baseLevel :Int, roll :Int) :Int {
        var level = levelModifier(baseLevel);
        var val = baseValue + level * (roll / kMaxRolls) * valuePerLevel;
        var mult = multiplierFor(slot);
        return Math.floor(val * mult);
    }

    public function canGoInSlot(slot :ItemSlot) :Bool {
        return multiplierFor(slot) > 0;
    }

    public function applyModifier(value :Int, mod :StatModifier) :Void {
        modifierFunc(value, mod);
    }
}

class Affix {
    var type :AffixType;
    var level :Int;
    var roll :Int;
    var slot :ItemSlot;

    public function new(type :AffixType, slot :ItemSlot) {
        this.type = type;
        this.slot = slot;
    }

    public function rollItemLevel(itemLevel :Int) {
        level = itemLevel;
        roll = Random.randomIntRange(1, AffixType.kMaxRolls);
    }

    public function text() :String {
        return '+' + type.valueForLevel(slot, level, roll) + ' ' + type.description;
    }

    public function applyModifier(mod :StatModifier) :Void {
        type.applyModifier(type.valueForLevel(slot, level, roll), mod);
    }

    public function value() :Float {
        return 1 + 0.2 * level * roll / AffixType.kMaxRolls;
    }

    public function serialize() :Dynamic {
        return {
            id: type.id,
            level: level,
            roll: roll,
            slot: slot,
        };
    }
    public static function loadAffix(data :Dynamic) :Affix {
        for (type in AffixData.affixTypes) {
            if (type.id == data.id) {
                var affix = new Affix(type, data.slot);
                affix.level = data.level;
                affix.roll = data.roll;
                return affix;
            }
        }
        return null;
    }
}
