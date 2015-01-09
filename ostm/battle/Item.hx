package ostm.battle;

import js.*;
import js.html.*;

import jengine.util.*;

enum ItemSlot {
    Weapon;
    Body;
    Helmet;
    Boots;
}

class ItemType {
    public var name :String;
    public var slot :ItemSlot;
    public var attack :Float;
    public var defense :Float;

    public function new(name, slot, attack, defense) {
        this.name = name;
        this.slot = slot;
        this.attack = attack;
        this.defense = defense;
    }
}

class ItemAffix {
    var description :String;
    var level :Int;

    public function new(desc, lev) {
        description = desc;
        level = lev;
    }

    public function text() :String {
        return description + ' +' + level;
    }
}

class Item {
    public var type :ItemType;
    public var level :Int;

    public var affixes :Array<ItemAffix> = [];

    public function new(type :ItemType, level :Int) {
        this.type = type;
        this.level = level;

        var nAffixes = Random.randomIntRange(0, 3);
        while (nAffixes > 0) {
            var desc = Random.randomElement(['Attack', 'Defense', 'HP', 'Speed', 'Boop', 'Bap']);
            var lev = Random.randomIntRange(1, level + 1);
            var affix = new ItemAffix(desc, lev);
            affixes.push(affix);
            nAffixes--;
        }
    }

    public function name() :String {
        return 'L' + level + ' ' + type.name;
    }

    public function bodyHtml() :Element {
        var list = Browser.document.createUListElement();

        var atk = Browser.document.createLIElement();
        atk.innerText = 'Attack: ' + attack();
        list.appendChild(atk);

        var def = Browser.document.createLIElement();
        def.innerText = 'Defense: ' + defense();
        list.appendChild(def);

        for (affix in affixes) {
            var aff = Browser.document.createLIElement();
            aff.innerText = affix.text();
            list.appendChild(aff);
        }

        return list;
    }

    public function attack() :Int {
        return Math.round(type.attack * (1 + 0.4 * (level - 1)));
    }
    public function defense() :Int {
        return Math.round(type.defense * (1 + 0.4 * (level - 1)));
    }
}
