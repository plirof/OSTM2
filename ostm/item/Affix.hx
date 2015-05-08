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
    var modifierFunc :Int -> StatModifier -> Void;
    var slotMultipliers :Map<ItemSlot, Float>;
    public static inline var kMaxRolls :Int = 1000;

    public function new(id, description, base, perLevel, modifierFunc, multipliers) {
        this.id = id;
        this.description = description;
        this.baseValue = base;
        this.valuePerLevel = perLevel;
        this.modifierFunc = modifierFunc;
        this.slotMultipliers = multipliers;
    }

    function levelModifier(baseLevel :Int) :Int { return 0; };

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

class LinearAffixType extends AffixType {
    public override function levelModifier(baseLevel :Int) :Int {
        return baseLevel + 2;
    }
}

class SqrtAffixType extends AffixType {
    public override function levelModifier(baseLevel :Int) :Int {
        return Math.round(Math.sqrt(baseLevel) + 2);
    }
}

class Affix {
    var type :AffixType;
    var level :Int;
    var roll :Int;
    var slot :ItemSlot;

    public static var affixTypes = [
        new LinearAffixType('flat-attack', 'Attack', 2, 1, function(value, mod) {
            mod.flatAttack += value;
        }, [ Weapon => 1.0, Gloves => 0.5, Ring => 0.5 ]),
        new SqrtAffixType('local-percent-attack-speed', '% Attack Speed', 5, 1, function(value, mod) {
            mod.localPercentAttackSpeed += value;
        }, [ Weapon => 1.0 ]),
        new LinearAffixType('local-percent-attack', '% Attack', 5, 1.5, function(value, mod) {
            mod.localPercentAttack += value;
        }, [ Weapon => 1.0 ]),
        new LinearAffixType('flat-crit-rating', 'Crit Rating', 4, 2, function(value, mod) {
            mod.flatCritRating += value;
        }, [ Weapon => 1.0, Gloves => 0.5, Ring => 0.5 ]),
        new LinearAffixType('local-percent-crit-rating', '% Crit Rating', 5, 1, function(value, mod) {
            mod.localPercentCritRating += value;
        }, [ Weapon => 1.0 ]),
        new LinearAffixType('flat-defense', 'Defense', 2, 1.25, function(value, mod) {
            mod.flatDefense += value;
        }, [ Body => 1.0, Boots => 0.5, Helmet => 1.0, Ring => 0.5 ]),
        new LinearAffixType('flat-hp', 'Health', 5, 2.5, function(value, mod) {
            mod.flatHealth += value;
        }, [ Body => 1.0, Helmet => 0.5, Ring => 0.5, Boots => 0.5, Gloves => 0.5 ]),
        new LinearAffixType('flat-hp-regen', 'Health Regen', 1, 0.35, function(value, mod) {
            mod.flatHealthRegen += value;
        }, [ Body => 1.0, Ring => 0.5 ]),
        new LinearAffixType('percent-hp', '% Health', 2, 0.5, function(value, mod) {
            mod.percentHealth += value;
        }, [ Helmet => 1.0 ]),
        new LinearAffixType('flat-mp', 'Mana', 5, 2.5, function(value, mod) {
            mod.flatMana += value;
        }, [ Body => 0.5, Helmet => 1.0, Ring => 0.5, Gloves => 0.5 ]),
        new LinearAffixType('percent-mp-regen', '% Mana Regen', 10, 3, function(value, mod) {
            mod.percentManaRegen += value;
        }, [ Helmet => 1.0, Ring => 0.5 ]),
        new LinearAffixType('local-percent-defense', '% Defense', 10, 5, function(value, mod) {
            mod.localPercentDefense += value;
        }, [ Body => 1.0, Helmet => 1.0, Boots => 0.5, Gloves => 0.5 ]),
        new LinearAffixType('percent-attack-speed', '% Global Attack Speed', 3, 1, function(value, mod) {
            mod.percentAttackSpeed += value;
        }, [ Gloves => 1.0, Ring => 0.5 ]),
        new LinearAffixType('percent-crit-chance', '% Global Crit Chance', 2, 1, function(value, mod) {
            mod.percentCritChance += value;
        }, [ Weapon => 1.0, Ring => 0.5 ]),
        new LinearAffixType('percent-crit-damage', '% Global Crit Damage', 10, 2, function(value, mod) {
            mod.percentCritDamage += value;
        }, [ Weapon => 1.0, Ring => 0.5 ]),
        new LinearAffixType('percent-move-speed', '% Move Speed', 10, 2, function(value, mod) {
            mod.percentMoveSpeed += value;
        }, [ Boots => 1.0 ]),
    ];

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
        for (type in affixTypes) {
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
