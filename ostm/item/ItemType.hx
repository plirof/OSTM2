package ostm.item;

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
