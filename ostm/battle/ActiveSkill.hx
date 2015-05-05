package ostm.battle;

class ActiveSkill {
    public var name(default, null) :String;
    public var manaCost(default, null) :Int;
    public var damage(default, null) :Float;
    public var speed(default, null) :Float;

    public static var skills = [
        new ActiveSkill('Attack', 0, 1, 1),
        new ActiveSkill('Quick Attack', 15, 0.8, 1.5),
        new ActiveSkill('Power Attack', 20, 1.8, 0.6),
    ];

    public function new(name, mana, damage, speed) {
        this.name = name;
        this.manaCost = mana;
        this.damage = damage;
        this.speed = speed;
    }
}
