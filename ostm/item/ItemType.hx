package ostm.item;

enum ItemSlot {
    Weapon;
    Body;
    Helmet;
    Boots;
}

class ItemType {
    public var id(default, null) :String;
    public var names(default, null) :Array<String>;
    public var slot(default, null) :ItemSlot;
    public var attack(default, null) :Float;
    public var defense(default, null) :Float;

    public function new(data) {
        id = data.id;
        names = data.names;
        slot = data.slot;
        attack = data.attack;
        defense = data.defense;
    }
}
