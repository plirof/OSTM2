package ostm.battle;

class StatType {
    var baseValue :Float;
    var perLevel :Float;

    public function new(base :Float, perLevel: Float) {
        this.baseValue = base;
        this.perLevel = perLevel;
    }
    public function value(level :Int, isPlayer :Bool) :Int {
        var l = level - 1;
        var v = baseValue;
        v += perLevel * l;
        if (!isPlayer) {
            v += 0.1 * perLevel * Math.pow(l, 1.75);
        }
        return Math.floor(v);
    }
}

class ClassType {
    public var name(default, null) :String;
    public var image(default, null) :String;
    public var strength(default, null) :StatType;
    public var dexterity(default, null) :StatType;
    public var intelligence(default, null) :StatType;
    public var vitality(default, null) :StatType;
    public var endurance(default, null) :StatType;

    public function new(data) {
        name = data.name;
        image = data.image;
        strength = data.str;
        dexterity = data.dex;
        intelligence = data.int;
        vitality = data.vit;
        endurance = data.end;
    }

    public static var playerType = new ClassType({
        name: 'Adventurer',
        image: 'classes/Adventurer.png',
        str: new StatType(5, 2.5),
        dex: new StatType(5, 2.5),
        int: new StatType(5, 2.5),
        vit: new StatType(5, 2.5),
        end: new StatType(5, 2.5),
    });
    public static var enemyType = new ClassType({
        name: 'Slime',
        image: 'enemies/Slime.png',
        str: new StatType(3.2, 0.8),
        dex: new StatType(3.2, 0.8),
        int: new StatType(3.2, 0.8),
        vit: new StatType(3.2, 0.8),
        end: new StatType(3.2, 0.8),
    });
}
