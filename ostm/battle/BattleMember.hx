package ostm.battle;

import js.html.Element;

import jengine.Entity;
import jengine.SaveManager;
import jengine.Time;
import jengine.util.Random;

import ostm.item.Affix;
import ostm.item.Item;
import ostm.item.ItemData;
import ostm.item.ItemType;
import ostm.skill.PassiveSkill;
import ostm.skill.SkillTree;

enum HuntType {
    Normal;
    Hunting;
    Hiding;
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
    public var mana :Int = 0;
    public var manaPartial :Float = 0;
    public var attackTimer :Float = 0;
    public var curSkill :ActiveSkill;
    public var classType :ClassType;

    public var huntType :HuntType = Normal;

    var _cachedStatMod = null;

    public function new(isPlayer :Bool) {
        if (isPlayer) {
            classType = ClassType.playerType;
        }
        else {
            classType = Random.randomElement(ClassType.enemyTypes);
        }

        for (k in ItemSlot.createAll()) {
            equipment[k] = null;
        }

        this.isPlayer = isPlayer;
        if (this.isPlayer) {
            this.saveId = 'player';
            var swordType = ItemData.getItemType('sword');
            if (swordType != null) {
                var sword = new Item(swordType, 1);
                equipment[ItemSlot.Weapon] = sword;
            }
            SaveManager.instance.addItem(this);
        }
    }

    function levelUp() :Void {
        level++;

        _cachedStatMod = null;
        
        untyped ga('send', 'event', 'player', 'level-up', '', level);
    }

    public function addXp(xp :Int) :Void {
        this.xp += xp;
        var tnl = xpToNextLevel();
        while (this.xp >= tnl) {
            this.xp -= tnl;

            levelUp();
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
        var val = classType.strength.value(level);
        val += mod.flatStrength;
        return Math.round(val);
    }
    public function dexterity() :Int {
        var mod = sumAffixes();
        var val = classType.dexterity.value(level);
        val += mod.flatDexterity;
        return Math.round(val);
    }
    public function intelligence() :Int {
        var mod = sumAffixes();
        var val = classType.intelligence.value(level);
        val += mod.flatIntelligence;
        return Math.round(val);
    }
    public function vitality() :Int {
        var mod = sumAffixes();
        var val = classType.vitality.value(level);
        val += mod.flatVitality;
        return Math.round(val);
    }
    public function endurance() :Int {
        var mod = sumAffixes();
        var val = classType.endurance.value(level);
        val += mod.flatEndurance;
        return Math.round(val);
    }

    public function updateCachedAffixes() :Void {
        _cachedStatMod = null;
    }
    function sumAffixes() :StatModifier {
        if (_cachedStatMod == null) {
            _cachedStatMod = new StatModifier();
            for (item in equipment) {
                if (item != null) {
                    item.sumAffixes(_cachedStatMod);
                }
            }

            _cachedStatMod.flatAttack = 0;
            _cachedStatMod.flatDefense = 0;
            
            for (passive in SkillTree.instance.skills) {
                passive.sumAffixes(_cachedStatMod);
            }
        }
        return _cachedStatMod;
    }
    public function maxHealth() :Int {
        var mod = sumAffixes();
        var hp = vitality() * 5 + 20;
        if (isPlayer) {
            hp += 55;
        }
        hp += mod.flatHealth;
        hp = Math.round(hp * (1 + mod.percentHealth / 100));
        return hp;
    }
    public function maxMana() :Int {
        var mod = sumAffixes();
        var mp = 100;
        mp += mod.flatMana;
        mp = Math.round(mp * (1 + mod.percentMana / 100));
        return mp;
    }
    function baseHealthRegenInCombat() :Float {
        var mod = sumAffixes();
        var reg = 0.0;
        reg += mod.flatHealthRegen;
        return reg;
    }
    function baseHealthRegenOutOfCombat() :Float {
        var reg = 6 + maxHealth() * 0.0125;
        return reg;
    }
    public function healthRegenInCombat() :Float {
        var rIn = baseHealthRegenInCombat();
        var rOut = baseHealthRegenOutOfCombat();
        return rIn + 0.15 * rOut;
    }
    public function healthRegenOutOfCombat() :Float {
        var rIn = baseHealthRegenInCombat();
        var rOut = baseHealthRegenOutOfCombat();
        return rIn + rOut;
    }
    public function manaRegen() :Float {
        var mod = sumAffixes();
        var reg = 2 + maxMana() * 0.015;
        reg *= 1 + mod.percentManaRegen / 100;
        return reg;
    }
    
    public function damage() :Int {
        var mod = sumAffixes();
        var atk :Float = 0;
        if (equipment.get(Weapon) == null) {
            atk = classType.unarmedAttack.value(level);
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
        floatRating *= 1 + mod.percentCritRating / 100;
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
    public function manaCost() :Int {
        return curSkill.manaCost;
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
        var mod = sumAffixes();
        for (item in equipment) {
            def += item != null ? item.defense() : 0;
        }
        def += mod.flatDefense;
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

    public function power(targetLevel :Int) :Int {
        return Math.round(Math.sqrt(dps(targetLevel) * ehp(targetLevel)));
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

        updateCachedAffixes();
    }
    public function unequip(item :Item) :Void {
        equipment[item.type.slot] = null;

        updateCachedAffixes();
    }

    public function setActiveSkill(skill :ActiveSkill) :Void {
        if (curSkill != skill && skill.manaCost <= mana) {
            curSkill = skill;
        }
    }

    public function updateRegen(inBattle :Bool) :Void {
        var hpReg;
        if (inBattle) {
            hpReg = healthRegenInCombat();
        }
        else {
            hpReg = healthRegenOutOfCombat();
        }
        var mpReg = manaRegen();
        healthPartial += hpReg * Time.dt;
        manaPartial += mpReg * Time.dt;
        var dHealth = Math.floor(healthPartial);
        var dMana = Math.floor(manaPartial);
        health += dHealth;
        healthPartial -= dHealth;
        if (health >= maxHealth()) {
            health = maxHealth();

        }
        mana += dMana;
        manaPartial -= dMana;
        if (mana >= maxMana()) {
            mana = maxMana();
        }
    }

    public function huntSkill() :Int {
        var mod = sumAffixes();
        var hunt = 10;
        hunt += mod.flatHuntSkill;
        return hunt;
    }
    public function enemySpawnModifier() :Float {
        var mod = huntSkill() / 40;
        return switch huntType {
            case Normal: 1;
            case Hunting: 1 / (1 + mod);
            case Hiding: 1 + mod;
        };
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
            mana: this.mana,
            equipment: equips,
            hunt: this.huntType,
        };
    }
    public function deserialize(data :Dynamic) :Void {
        xp = data.xp;
        gold = data.gold;
        gems = data.gems;
        level = data.level;
        health = data.health;
        mana = data.mana;
        huntType = data.hunt != null ? data.hunt : Normal;
        for (k in equipment.keys()) {
            equipment[k] = null;
        }
        var equips :Array<Dynamic> = data.equipment;
        for (d in equips) {
            var item = Item.loadItem(d);
            equipment[item.type.slot] = item;
        }

        _cachedStatMod = null;
    }
}
