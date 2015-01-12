package ostm.item;

import ostm.item.ItemType;

@:allow(ostm.item.Affix)
class AffixType {
    var description :String;
    var baseValue :Float;
    var valuePerLevel :Float;
    var slotMultipliers :Map<ItemSlot, Float>;

    public function new(description, base, perLevel, multipliers) {
        this.description = description;
        this.baseValue = base;
        this.valuePerLevel = perLevel;
        this.slotMultipliers = multipliers;
    }

    inline function multiplierFor(slot :ItemSlot) :Float {
        return 1;
        // var mult = slotMultipliers.get(slot);
        // return mult == null ? 0 : mult;
    }

    public function valueForLevel(slot :ItemSlot, level :Int) :Int {
        var val = baseValue + (level - 1) * valuePerLevel;
        var mult = multiplierFor(slot);
        return Math.floor(val * mult);
    }

    public function canGoInSlot(slot :ItemSlot) :Bool {
        return multiplierFor(slot) > 0;
    }
}

class Affix {
    var type :AffixType;
    var level :Int;
    var slot :ItemSlot;

    public static var affixTypes = [
        new AffixType('Attack', 2, 1, [ Weapon => 1.0 ]),
        new AffixType('Defense', 1, 0.75, [ Weapon => 1.0 ]),
        new AffixType('HP', 5, 2.5, [ Weapon => 1.0 ]),
        new AffixType('HP%', 2, 1, [ Weapon => 1.0 ]),
    ];

    public function new(type :AffixType, level :Int, slot :ItemSlot) {
        this.type = type;
        this.level = level;
        this.slot = slot;
    }

    public function text() :String {
        return '+' + type.valueForLevel(slot, level) + ' ' + type.description;
    }
}

class AffixModifier {
    public var flatAttack :Int = 0;
    public var flatDefense :Int = 0;
    public var flatHealth :Int = 0;
}
