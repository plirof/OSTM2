package ostm.battle;

import js.html.Element;

import jengine.Entity;

class BattleMember {
    public var entity :Entity;
    public var elem :Element;
    public var isPlayer :Bool = false;

    public var level :Int;
    public var attackSpeed :Float;
    public var baseHealth :Int;
    public var baseDamage :Int;
    public var baseDefense :Int;

    public var xp :Int = 0;
    public var health :Int;
    public var healthPartial :Float = 0;
    public var attackTimer :Float = 0;

    public function new(entity :Entity) {
        this.entity = entity;
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
        return scaleStat(baseDamage, 0.17);
    }
    public function defense() :Int {
        return scaleStat(baseDefense, 0.12);
    }
    public function healthRegen() :Float {
        return maxHealth() * 0.015;
    }
}
