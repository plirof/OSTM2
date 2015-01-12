package ostm.battle;

import js.html.Element;

import jengine.Entity;

import ostm.item.Item;
import ostm.item.ItemType;

class BattleMember {
    public var entity :Entity;
    public var elem :Element;
    public var isPlayer :Bool = false;

    public var equipment = new Map<ItemSlot, Item>();

    public var level :Int;
    public var attackSpeed :Float;
    public var baseHealth :Int;
    public var baseDamage :Int;
    public var baseDefense :Int;

    public var xp :Int = 0;
    public var health :Int = 0;
    public var healthPartial :Float = 0;
    public var attackTimer :Float = 0;

    public function new() {
        for (k in ItemSlot.createAll()) {
            equipment[k] = null;
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

    function scaleStat(base :Int, scale :Float) :Int {
        return Math.round(base * (1 + (level - 1) * scale));
    }
    public function maxHealth() :Int {
        return scaleStat(baseHealth, 0.15);
    }
    public function damage() :Int {
        var damage = scaleStat(baseDamage, 0.17);
        for (item in equipment) {
            damage += item != null ? item.attack() : 0;
        }
        return damage;
    }
    public function defense() :Int {
        var defense = scaleStat(baseDefense, 0.12);
        for (item in equipment) {
            defense += item != null ? item.defense() : 0;
        }
        return defense;
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
}
