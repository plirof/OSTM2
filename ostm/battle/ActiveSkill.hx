package ostm.battle;

class ActiveSkill {
    public var name(default, null) :String;
    public var manaCost(default, null) :Int;
    public var damage(default, null) :Float;
    public var speed(default, null) :Float;

    public static var skills = [
        new ActiveSkill('Attack', 0, 1, 1),
        new ActiveSkill('Quick Attack', 12, 1, 1.6),
        new ActiveSkill('Power Attack', 16, 2.2, 0.65),
    ];

    public function new(name, mana, damage, speed) {
        this.name = name;
        this.manaCost = mana;
        this.damage = damage;
        this.speed = speed;
    }
}
