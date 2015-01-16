package ostm.battle;

class ActiveSkill {
    public var name(default, null) :String;
    public var damage(default, null) :Float;
    public var speed(default, null) :Float;

    public static var skills = [
        new ActiveSkill('Attack', 1, 1),
        new ActiveSkill('Quick Attack', 0.8, 1.5),
        new ActiveSkill('Power Attack', 1.8, 0.6),
    ];

    public function new(name, damage, speed) {
        this.name = name;
        this.damage = damage;
        this.speed = speed;
    }
}
