package ostm.item;

class WeaponType extends ItemType {
    public var attackSpeed(default, null) :Float;
    public var crit(default, null) :Float;

    public function new(data) {
        super({
            id: data.id,
            image: data.image,
            names: data.names,
            slot: Weapon,
            attack: data.attack,
            defense: data.defense,
        });

        attackSpeed = data.attackSpeed;
        crit = data.crit;
    }
}
