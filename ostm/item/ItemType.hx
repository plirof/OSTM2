package ostm.item;

enum ItemSlot {
    Weapon;
    Body;
    Helmet;
    Boots;
}

class ItemType {
    public var id(default, null) :String;
    public var name(default, null) :String;
    public var slot(default, null) :ItemSlot;
    public var attack(default, null) :Float;
    public var defense(default, null) :Float;

    public function new(id, name, slot, attack, defense) {
        this.id = id;
        this.name = name;
        this.slot = slot;
        this.attack = attack;
        this.defense = defense;
    }
}

class WeaponType extends ItemType {
    public var attackSpeed(default, null) :Float;

    public function new (id, name, attack, attackSpeed, defense) {
        super(id, name, Weapon, attack, defense);

        this.attackSpeed = attackSpeed;
    }
}
