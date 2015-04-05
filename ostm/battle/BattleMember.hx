package ostm.battle;

import js.html.Element;

import jengine.Entity;
import jengine.SaveManager;

import ostm.item.Affix;
import ostm.item.Item;
import ostm.item.ItemType;
import ostm.skill.PassiveSkill;
import ostm.skill.SkillTree;

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

    public var isPlayer(default, null) :Bool;
    public var entity :Entity;
    public var elem :Element;

    public var equipment = new Map<ItemSlot, Item>();

    public var level :Int;

    public var xp :Int = 0;
    public var gold :Int = 0;
    public var gems :Int = 0;
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
    public function addGold(gold :Int) :Void {
        this.gold += gold;
    }
    public function addGems(gems :Int) :Void {
        this.gems += gems;
    }
    public function xpToNextLevel() :Int {
        return Math.round(10 + 5 * Math.pow(level - 1, 2.6));
    }
    public function xpReward() :Int {
        return Math.round(Math.pow(level, 2) + 2);
    }
    public function goldReward() :Int {
        return Math.round(Math.pow(level, 1.75) + 2);
    }

    public function strength() :Int {
        var mod = sumAffixes();
        var val = classType.strength.value(level, isPlayer);
        val += mod.flatStrength;
        return Math.round(val);
    }
    public function vitality() :Int {
        var mod = sumAffixes();
        var val = classType.vitality.value(level, isPlayer);
        val += mod.flatVitality;
        return Math.round(val);
    }
    public function endurance() :Int {
        var mod = sumAffixes();
        var val = classType.endurance.value(level, isPlayer);
        val += mod.flatEndurance;
        return Math.round(val);
    }
    public function dexterity() :Int {
        var mod = sumAffixes();
        var val = classType.dexterity.value(level, isPlayer);
        val += mod.flatDexterity;
        return Math.round(val);
    }

    function sumAffixes() :StatModifier {
        var mod = new StatModifier();
        for (item in equipment) {
            if (item != null) {
                item.sumAffixes(mod);
            }
        }
        for (passive in SkillTree.instance.skills) {
            passive.sumAffixes(mod);
        }
        return mod;
    }
    public function maxHealth() :Int {
        var mod = sumAffixes();
        var hp = vitality() * 10;
        if (isPlayer) {
            hp += 50;
        }
        hp += mod.flatHealth;
        hp = Math.round(hp * (1 + mod.percentHealth / 100));
        return hp;
    }
    public function damage() :Int {
        var mod = sumAffixes();
        var atk :Float = equipment.get(Weapon) != null ? 0 : 2;
        if (!isPlayer) {
            atk = 1 + level;
        }
        for (item in equipment) {
            atk += item != null ? item.attack() : 0;
        }
        atk *= curSkill.damage;
        atk *= 1 + strength() * 0.02;
        atk *= 1 + mod.percentAttack / 100;
        return Math.round(atk);
    }
    public function attackSpeed() :Float {
        var wep = equipment.get(Weapon);
        var mod = sumAffixes();
        var spd = wep != null ? wep.attackSpeed() : 1.5;
        spd *= (1 + mod.percentAttackSpeed / 100);
        spd *= curSkill.speed;
        return spd;
    }
    public function critInfo(targetLevel :Int) {
        var wep = equipment.get(Weapon);
        var mod = sumAffixes();
        
        var floatRating :Float = wep != null ? wep.critRating() : 3;
        floatRating *= 1 + dexterity() * 0.02;
        var rating = Math.round(floatRating);

        var offense = 0.02 * rating;
        var defense = 4 + targetLevel;
        var totalDamage = 1 + offense / defense;

        var baseChance = Math.pow(rating, 0.7) / 100;
        var chance = 0.025 + baseChance / Math.pow(defense, 0.5);
        var damage = (totalDamage - 1) / chance;

        chance *= (1 + mod.percentCritChance / 100);
        damage *= 1 + mod.percentCritDamage / 100;

        return {
            rating: rating,
            chance: chance,
            damage: damage,
        };
    }
    public function dps(targetLevel :Int) :Float {
        var atk = damage();
        var spd = attackSpeed();
        var crit = critInfo(targetLevel);
        var critMod = 1 + crit.chance * crit.damage;
        return atk * spd * critMod;
    }

    public function defense() :Int {
        var def :Float = 0;
        for (item in equipment) {
            def += item != null ? item.defense() : 0;
        }
        def *= 1 + endurance() * 0.02;
        return Math.round(def);
    }
    public function damageReduction(attackerLevel :Int) :Float {
        var def = defense();
        return def / (10 + 2.5 * attackerLevel + def);
    }
    public function ehp(attackerLevel :Int) :Float {
        var hp = maxHealth();
        var mitigated = 1 / (1 - damageReduction(attackerLevel));
        return hp * mitigated;
    }
    public function healthRegenInCombat() :Float {
        var mod = sumAffixes();
        return mod.flatHealthRegen;
    }
    public function healthRegenOutOfCombat() :Float {
        var inCombat = healthRegenInCombat();
        var out = maxHealth() * 0.025;
        out += inCombat;
        return out;
    }
    public function moveSpeed() :Float {
        var mod = sumAffixes();
        var spd :Float = 1;
        spd *= 1 + mod.percentMoveSpeed / 100;
        return spd;
    }

    public function equip(item :Item) :Void {
        var oldItem = equipment[item.type.slot];
        if (oldItem != null) {
            oldItem.cleanupElement();
        }

        equipment[item.type.slot] = item;
    }
    public function unequip(item :Item) :Void {
        equipment[item.type.slot] = null;
    }

    public function setActiveSkill(skill :ActiveSkill) :Void {
        if (curSkill != skill) {
            curSkill = skill;
        }
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
            gold: this.gold,
            gems: this.gems,
            level: this.level,
            health: this.health,
            equipment: equips,
        };
    }
    public function deserialize(data :Dynamic) :Void {
        xp = data.xp;
        gold = data.gold;
        gems = data.gems;
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
