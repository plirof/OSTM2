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
    public static inline var kRollCounts :Int = 10;

    public function new(id, description, base, perLevel, modifierFunc, multipliers) {
        this.id = id;
        this.description = description;
        this.baseValue = base;
        this.valuePerLevel = perLevel;
        this.modifierFunc = modifierFunc;
        this.slotMultipliers = multipliers;
    }

    inline function multiplierFor(slot :ItemSlot) :Float {
        var mult = slotMultipliers.get(slot);
        return mult == null ? 0 : mult;
    }

    public function valueForLevel(slot :ItemSlot, level :Int) :Int {
        var val = baseValue + level / kRollCounts * valuePerLevel;
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
    var slot :ItemSlot;

    public static var affixTypes = [
        new AffixType('flat-attack', 'Attack', 2, 1, function(value, mod) {
            mod.flatAttack += value;
        }, [ Weapon => 1.0, Gloves => 0.5, Ring => 0.5 ]),
        new AffixType('local-percent-attack-speed', '% Attack Speed', 5, 1, function(value, mod) {
            mod.localPercentAttackSpeed += value;
        }, [ Weapon => 1.0 ]),
        new AffixType('local-percent-attack', '% Attack', 5, 1.5, function(value, mod) {
            mod.localPercentAttack += value;
        }, [ Weapon => 1.0 ]),
        new AffixType('flat-crit-rating', 'Crit Rating', 2, 1, function(value, mod) {
            mod.flatCritRating += value;
        }, [ Weapon => 1.0 ]),
        new AffixType('local-percent-crit-rating', '% Crit Rating', 5, 1, function(value, mod) {
            mod.localPercentCritRating += value;
        }, [ Weapon => 1.0 ]),
        new AffixType('flat-defense', 'Defense', 2, 1.25, function(value, mod) {
            mod.flatDefense += value;
        }, [ Body => 1.0, Boots => 0.5, Helmet => 1.0 ]),
        new AffixType('flat-hp', 'HP', 5, 2.5, function(value, mod) {
            mod.flatHealth += value;
        }, [ Body => 1.0, Helmet => 0.5, Ring => 0.5, Boots => 0.5, Gloves => 0.5 ]),
        new AffixType('flat-hp-regen', 'HP Regen', 1, 0.35, function(value, mod) {
            mod.flatHealthRegen += value;
        }, [ Body => 1.0, Ring => 0.5 ]),
        new AffixType('percent-hp', '% HP', 2, 0.5, function(value, mod) {
            mod.percentHealth += value;
        }, [ Helmet => 1.0 ]),
        new AffixType('local-percent-defense', '% Defense', 10, 5, function(value, mod) {
            mod.localPercentDefense += value;
        }, [ Body => 1.0, Helmet => 1.0, Boots => 0.5, Gloves => 0.5 ]),
        new AffixType('percent-attack-speed', '% Global Attack Speed', 3, 1, function(value, mod) {
            mod.percentAttackSpeed += value;
        }, [ Gloves => 1.0, Ring => 0.5 ]),
        new AffixType('percent-crit-chance', '% Global Crit Chance', 2, 1, function(value, mod) {
            mod.percentCritChance += value;
        }, [ Weapon => 1.0, Ring => 0.5 ]),
        new AffixType('percent-crit-damage', '% Global Crit Damage', 10, 2, function(value, mod) {
            mod.percentCritDamage += value;
        }, [ Weapon => 1.0, Ring => 0.5 ]),
        new AffixType('percent-move-speed', '% Move Speed', 10, 2, function(value, mod) {
            mod.percentMoveSpeed += value;
        }, [ Boots => 1.0 ]),
    ];

    public function new(type :AffixType, slot :ItemSlot) {
        this.type = type;
        this.slot = slot;
    }

    public function rollItemLevel(itemLevel :Int) {
        level = Random.randomIntRange(0, itemLevel * AffixType.kRollCounts - 1);
    }

    public function text() :String {
        return '+' + type.valueForLevel(slot, level) + ' ' + type.description;
    }

    public function applyModifier(mod :StatModifier) :Void {
        type.applyModifier(type.valueForLevel(slot, level), mod);
    }

    public function value() :Float {
        return 1 + 0.2 * level / AffixType.kRollCounts;
    }

    public function serialize() :Dynamic {
        return {
            id: type.id,
            level: level,
            slot: slot,
        };
    }
    public static function loadAffix(data :Dynamic) :Affix {
        for (type in affixTypes) {
            if (type.id == data.id) {
                var affix = new Affix(type, data.slot);
                affix.level = data.level;
                return affix;
            }
        }
        return null;
    }
}
