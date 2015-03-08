package ostm.item;

class ItemData {
    public static var types = [
        new WeaponType({
            id: 'sword',
            names: [
                'Rusted Sword',
                'Copper Sword',
                'Short Sword',
                'Long Sword',
            ],
            attack: 3.5,
            attackSpeed: 1.6,
            defense: 1,
        }),
        new WeaponType({
            id: 'axe',
            names: [
                'Rusted Axe',
                'Hatchet',
                'Tomahawk',
                'Battle Axe',
            ],
            attack: 4.5,
            attackSpeed: 1.4,
            defense: 0,
        }),
        new WeaponType({
            id: 'dagger',
            names: [
                'Rusted Dagger',
                'Knife',
                'Dagger',
                'Kris',
            ],
            attack: 3,
            attackSpeed: 1.85,
            defense: 0,
        }),
        new ItemType({
            id: 'armor',
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
    ];
}
