package ostm.battle;

enum ItemSlot {
    Weapon;
    Body;
    Helmet;
    Boots;
}

class ItemType {
    public var name :String;
    public var slot :ItemSlot;
    public var attack :Float;
    public var defense :Float;

    public function new(name, slot, attack, defense) {
        this.name = name;
        this.slot = slot;
        this.attack = attack;
        this.defense = defense;
    }
}

class Item {
    public var type :ItemType;
    public var level :Int;

    public function new(type :ItemType, level :Int) {
        this.type = type;
        this.level = level;
    }

    public function name() :String {
        return 'L' + level + ' ' + type.name + ' (A:' + attack() + ' D:' + defense() + ')';
    }

    public function attack() :Int {
        return Math.round(type.attack * (1 + 0.2 * (level - 1)));
    }
    public function defense() :Int {
        return Math.round(type.defense * (1 + 0.2 * (level - 1)));
    }
}
