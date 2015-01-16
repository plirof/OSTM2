package ostm.battle;

import js.html.Element;

import jengine.Entity;
import jengine.SaveManager;

import ostm.item.Affix;
import ostm.item.Item;
import ostm.item.ItemType;

class StatType {
    var baseValue :Float;
    var perLevel :Float;

    public function new(base :Float, perLevel: Float) {
        this.baseValue = base;
        this.perLevel = perLevel;
    }
    public function value(level :Int) :Int {
        return Math.floor(baseValue + (level - 1) * perLevel);
    }
}

class ClassType {
    public var strength(default, null) :StatType;
    public var vitality(default, null) :StatType;
    public var endurance(default, null) :StatType;
    public var dexterity(default, null) :StatType;

    public function new(str, vit, end, dex) {
        strength = str;
        vitality = vit;
        endurance = end;
        dexterity = dex;
    }

    public static var playerType = new ClassType(
        new StatType(5, 2.5),
        new StatType(5, 2.5),
        new StatType(5, 2.5),
        new StatType(5, 2.5)
    );
    public static var enemyType = new ClassType(
        new StatType(3, 1.5),
        new StatType(3, 1.5),
        new StatType(3, 1.5),
        new StatType(3, 1.5)
    );
}

class BattleMember implements Saveable {
    public var saveId(default, null) :String;

    public var entity :Entity;
    public var elem :Element;
    public var isPlayer(default, null) :Bool;

    public var equipment = new Map<ItemSlot, Item>();

    public var level :Int;

    public var xp :Int = 0;
    public var health :Int = 0;
    public var healthPartial :Float = 0;
    public var attackTimer :Float = 0;
    public var curSkill :ActiveSkill;
    var classType :ClassType;

    public function new(isPlayer :Bool) {
        classType = isPlayer ? ClassType.playerType : ClassType.enemyType;
        for (k in ItemSlot.createAll()) {
            equipment[k] = null;
        }

        this.isPlayer = isPlayer;
        if (this.isPlayer) {
            this.saveId = 'player';
            SaveManager.instance.addItem(this);
        }
    }

    public function addXp(xp :Int) :Void {
        this.xp += xp;
        var tnl = xpToNextLevel();
        if (this.xp >= tnl) {
            this.xp -= tnl;
            level++;
        }
    }
    public function xpToNextLevel() :Int {
        return 10 + 5 * (level - 1);
    }
    public function xpReward() :Int {
        return level + 2;
    }

    public function strength() :Int {
        return classType.strength.value(level);
    }
    public function vitality() :Int {
        return classType.vitality.value(level);
    }
    public function endurance() :Int {
        return classType.endurance.value(level);
    }
    public function dexterity() :Int {
        return classType.dexterity.value(level);
    }

    function sumAffixes() :AffixModifier {
        var mod = new AffixModifier();
        for (item in equipment) {
            if (item != null) {
                item.sumAffixes(mod);
            }
        }
        return mod;
    }
    public function maxHealth() :Int {
        var mod = sumAffixes();
        var hp = vitality() * 10 + 50;
        hp += mod.flatHealth;
        hp = Math.floor(hp * (1 + mod.percentHealth / 100));
        return hp;
    }
    public function damage() :Int {
        var atk = Math.floor(strength() * 0.65 + 2);
        for (item in equipment) {
            atk += item != null ? item.attack() : 0;
        }
        atk = Math.round(atk * curSkill.damage);
        return atk;
    }
    public function defense() :Int {
        var def = Math.floor(endurance() * 0.35 + 1);
        for (item in equipment) {
            def += item != null ? item.defense() : 0;
        }
        return def;
    }
    public function attackSpeed() :Float {
        var spd = Math.log(dexterity()) + 0.8;
        spd *= curSkill.speed;
        return spd;
    }
    public function healthRegen() :Float {
        return maxHealth() * 0.015;
    }

    public function equip(item :Item) :Void {
        equipment[item.type.slot] = item;
    }
    public function unequip(item :Item) :Void {
        equipment[item.type.slot] = null;
    }

    public function setActiveSkill(skill :ActiveSkill) :Void {
        curSkill = skill;
        attackTimer = 0;
    }

    public function serialize() :Dynamic {
        var equips = [];
        for (item in equipment) {
            if (item != null) {
                equips.push(item.serialize());
            }
        }
        return {
            xp: this.xp,
            level: this.level,
            health: this.health,
            equipment: equips,
        };
    }
    public function deserialize(data :Dynamic) :Void {
        xp = data.xp;
        level = data.level;
        health = data.health;
        for (k in equipment.keys()) {
            equipment[k] = null;
        }
        var equips :Array<Dynamic> = data.equipment;
        for (d in equips) {
            var item = Item.loadItem(d);
            equipment[item.type.slot] = item;
        }
    }
}
