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

    public function applyModifier(value :Int, mod :AffixModifier) :Void { }
}

class FlatHealthAffixType extends AffixType {
    public function new() {
        super('HP', 5, 2.5, [ Weapon => 1.0 ]);
    }
    public override function applyModifier(value :Int, mod :AffixModifier) :Void {
        mod.flatHealth += value;
    }
}
class FlatAttackAffixType extends AffixType {
    public function new() {
        super('Attack', 2, 1, [ Weapon => 1.0 ]);
    }
    public override function applyModifier(value :Int, mod :AffixModifier) :Void {
        mod.flatAttack += value;
    }
}
class FlatDefenseAffixType extends AffixType {
    public function new() {
        super('Defense', 1, 0.75, [ Weapon => 1.0 ]);
    }
    public override function applyModifier(value :Int, mod :AffixModifier) :Void {
        mod.flatDefense += value;
    }
}
class PercentHealthAffixType extends AffixType {
    public function new() {
        super('HP%', 2, 0.5, [ Weapon => 1.0 ]);
    }
    public override function applyModifier(value :Int, mod :AffixModifier) :Void {
        mod.percentHealth += value;
    }
}

class Affix {
    var type :AffixType;
    var level :Int;
    var slot :ItemSlot;

    public static var affixTypes = [
        new FlatAttackAffixType(),
        new FlatDefenseAffixType(),
        new FlatHealthAffixType(),
        new PercentHealthAffixType(),
    ];

    public function new(type :AffixType, level :Int, slot :ItemSlot) {
        this.type = type;
        this.level = level;
        this.slot = slot;
    }

    public function text() :String {
        return '+' + type.valueForLevel(slot, level) + ' ' + type.description;
    }

    public function applyModifier(mod :AffixModifier) :Void {
        type.applyModifier(type.valueForLevel(slot, level), mod);
    }
}

class AffixModifier {
    public var flatAttack :Int = 0;
    public var flatDefense :Int = 0;
    public var flatHealth :Int = 0;
    public var percentHealth :Int = 0;

    public function new() { }
}
