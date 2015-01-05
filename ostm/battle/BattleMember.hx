package ostm.battle;

import js.html.Element;

import jengine.Entity;

import ostm.battle.Item;

class BattleMember {
    public var entity :Entity;
    public var elem :Element;
    public var isPlayer :Bool = false;

    public var equipment :Map<ItemSlot, Item> = new Map<ItemSlot, Item>();

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

    public function statHtml() :String {
        var html = '<ul>' +
                '<li>Level: ' + level + '</li>' +
                '<li>XP: ' + xp + ' / ' + xpToNextLevel() + '</li>' +
                '<li>HP: ' + health + ' / ' + maxHealth() + '</li>' +
                '<li>Damage: ' + damage() + '</li>' +
                '<li>Defense: ' + defense() + '</li>' +
            '</ul>';
        html += '<ul>';
        for (k in equipment.keys()) {
            var item = equipment[k];
            var desc = item != null ? item.name() : '(none)';
            html += '<li>' + k + ': ' + desc + '</li>';
        }
        html += '</ul>';
        return html;
    }
}
