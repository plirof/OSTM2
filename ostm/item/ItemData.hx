package ostm.item;

class ItemData {
    public static function getItemType(id :String) :ItemType {
        for (type in types) {
            if (type.id == id) {
                return type;
            }
        }
        return null;
    }

    public static var types = [
        new WeaponType({
            id: 'sword',
            images: [
                'Sword0.png',
                'Sword1.png',
                'Sword2.png',
                'Sword3.png',
            ],
            names: [
                'Rusted Sword',
                'Copper Sword',
                'Short Sword',
                'Long Sword',
            ],
            attack: 4.1,
            attackSpeed: 1.55,
            crit: 5,
            defense: 0,
        }),
        new WeaponType({
            id: 'axe',
            images: [
                'Axe0.png',
                'Axe1.png',
                'Axe2.png',
                'Axe3.png',
            ],
            names: [
                'Rusted Axe',
                'Hatchet',
                'Tomahawk',
                'Battle Axe',
            ],
            attack: 5.25,
            attackSpeed: 1.35,
            crit: 7,
            defense: 0,
        }),
        new WeaponType({
            id: 'dagger',
            images: [
                'Dagger0.png',
                'Dagger1.png',
                'Dagger2.png',
                'Dagger3.png',
            ],
            names: [
                'Rusted Dagger',
                'Knife',
                'Dagger',
                'Kris',
            ],
            attack: 3,
            attackSpeed: 1.8,
            crit: 9,
            defense: 0,
        }),
        new ItemType({
            id: 'armor',
            images: ['Armor.png'],
            names: [
                'Tattered Shirt',
                'Cloth Shirt',
                'Padded Armor',
                'Leather Armor',
            ],
            slot: Body,
            attack: 0,
            defense: 2,
        }),
        new ItemType({
            id: 'helm',
            images: ['Helmet.png'],
            names: [
                'Hat',
                'Leather Cap',
                'Iron Hat',
                'Chainmail Coif',
            ],
            slot: Helmet,
            attack: 0,
            defense: 1,
        }),
        new ItemType({
            id: 'boots',
            images: ['Boot.png'],
            names: [
                'Sandals',
                'Leather Shoes',
                'Boots',
                'Studded Boots',
            ],
            slot: Boots,
            attack: 0,
            defense: 1,
        }),
        new ItemType({
            id: 'gloves',
            images: ['Glove.png'],
            names: [
                'Cuffs',
                'Wool Gloves',
                'Leather Gloves',
                'Studded Gloves',
            ],
            slot: Gloves,
            attack: 0,
            defense: 1,
        }),
        new ItemType({
            id: 'ring',
            images: ['Ring.png'],
            names: [
                'Ring',
            ],
            slot: Ring,
            attack: 0.2,
            defense: 0.3,
        }),
        new ItemType({
            id: 'jewel',
            images: ['Jewel.png'],
            names: [
                'Jewel',
            ],
            slot: Jewel,
            attack: 0,
            defense: 0,
        }),
    ];
}
