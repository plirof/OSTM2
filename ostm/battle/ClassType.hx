package ostm.battle;

class StatType {
    var baseValue :Float;
    var perLevel :Float;

    public function new(base :Float, perLevel: Float) {
        this.baseValue = base;
        this.perLevel = perLevel;
    }
    public function value(level :Int) :Int {
        var l = level - 1;
        var v = baseValue;
        v += perLevel * l;
        return Math.floor(v);
    }
}

class ExpStatType extends StatType {
    public override function value(level :Int) :Int {
        var v :Float = super.value(level);
        v += 0.1 * perLevel * Math.pow(level - 1, 1.75);
        return Math.floor(v);
    }
}

class ClassType {
    public var name(default, null) :String;
    public var image(default, null) :String;
    public var unarmedAttack(default, null) :StatType;
    public var baseArmor(default, null) :StatType;
    public var strength(default, null) :StatType;
    public var dexterity(default, null) :StatType;
    public var intelligence(default, null) :StatType;
    public var vitality(default, null) :StatType;
    public var endurance(default, null) :StatType;

    public function new(data :Dynamic) {
        name = data.name;
        image = data.image;
        unarmedAttack = data.attack != null ? data.attack : new StatType(2, 0);
        baseArmor = data.armor != null ? data.armor : new StatType(0, 0);
        strength = data.str;
        dexterity = data.dex;
        intelligence = data.int;
        vitality = data.vit;
        endurance = data.end;
    }

    public static var playerType = new ClassType({
        name: 'Adventurer',
        image: 'classes/Adventurer.png',
        str: new StatType(5, 1.5),
        dex: new StatType(5, 1.5),
        int: new StatType(5, 1.5),
        vit: new StatType(5, 1.5),
        end: new StatType(5, 1.5),
    });
    public static var enemyTypes = [
        new ClassType({
            name: 'Slime',
            image: 'enemies/Slime.png',
            attack: new StatType(1.5, 0.75),
            armor: new StatType(1, 1.25),
            str: new ExpStatType(2.2, 0.6),
            dex: new ExpStatType(2.2, 0.6),
            int: new ExpStatType(2.2, 0.6),
            vit: new ExpStatType(4.2, 1.6),
            end: new ExpStatType(2.2, 0.6),
        }),
        new ClassType({
            name: 'Snake',
            image: 'enemies/Snake.png',
            attack: new StatType(2.25, 1.15),
            armor: new StatType(1, 1.25),
            str: new ExpStatType(4.6, 1.1),
            dex: new ExpStatType(5.2, 1.3),
            int: new ExpStatType(2.2, 0.8),
            vit: new ExpStatType(2.8, 0.6),
            end: new ExpStatType(2.2, 0.6),
        }),
        new ClassType({
            name: 'Goblin',
            image: 'enemies/Goblin.png',
            attack: new StatType(2, 1.1),
            armor: new StatType(1, 1.25),
            str: new ExpStatType(3.5, 0.9),
            dex: new ExpStatType(5, 1.2),
            int: new ExpStatType(3.2, 0.8),
            vit: new ExpStatType(3.8, 0.9),
            end: new ExpStatType(3.2, 0.8),
        }),
    ];
}
