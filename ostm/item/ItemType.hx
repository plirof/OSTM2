package ostm.item;

enum ItemSlot {
    Weapon;
    Body;
    Helmet;
    Boots;
    Gloves;
    Ring;
    Jewel;
}

class ItemType {
    public var id(default, null) :String;
    public var image(default, null) :String;
    public var names(default, null) :Array<String>;
    public var slot(default, null) :ItemSlot;
    public var attack(default, null) :Float;
    public var defense(default, null) :Float;

    public function new(data) {
        id = data.id;
        image = data.image;
        names = data.names;
        slot = data.slot;
        attack = data.attack;
        defense = data.defense;
    }
}
