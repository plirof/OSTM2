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
        return '+' + level + ' ' + description;
    }
}

class Item {
    public var type :ItemType;
    public var level :Int;

    public var affixes :Array<ItemAffix> = [];

    public function new(type :ItemType, level :Int) {
        this.type = type;
        this.level = level;

        var nAffixes = Random.randomIntRange(0, 4);
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

    function equip(event) {
        var player = BattleManager.instance.getPlayer();
        var cur = player.equipment[type.slot];
        if (cur != null) {
            Inventory.instance.push(cur);
        }
        player.equip(this);
        Inventory.instance.remove(this);

        Inventory.instance.updateInventoryHtml();
    }

    function discard(event) {
        Inventory.instance.remove(this);

        Inventory.instance.updateInventoryHtml();
    }

    function unequip(event) {
        var player = BattleManager.instance.getPlayer();
        var cur = player.equipment[type.slot];
        if (cur == this && Inventory.instance.hasSpaceForItem()) {
            player.unequip(this);

            Inventory.instance.push(this);
            Inventory.instance.updateInventoryHtml();
        }
    }

    function getColor() :String {
        switch (affixes.length) {
            case 3: return '#ffff00';
            case 2: return '#0099ff';
            case 1: return '#22ff22';
            default: return '#ffffff';
        }
    }

    public function createElement(elemTag :String, isEquipped :Bool) :Element {
        var elem = Browser.document.createElement(elemTag);

        var name = Browser.document.createSpanElement();
        name.innerText = this.name();
        name.style.fontSize = cast 20;
        name.style.color = getColor();
        elem.appendChild(name);

        var body = Browser.document.createUListElement();
        body.style.display = 'none';
        elem.onmouseover = function(event) {
            body.style.display = '';
        };
        elem.onmouseout = function(event) {
            body.style.display = 'none';
        };

        var atk = Browser.document.createLIElement();
        atk.innerText = 'Attack: ' + attack();
        body.appendChild(atk);

        var def = Browser.document.createLIElement();
        def.innerText = 'Defense: ' + defense();
        body.appendChild(def);

        for (affix in affixes) {
            var aff = Browser.document.createLIElement();
            aff.innerText = affix.text();
            aff.style.fontStyle = 'italic';
            body.appendChild(aff);
        }

        if (!isEquipped) {
            var equip = Browser.document.createButtonElement();
            equip.innerText = 'Equip';
            equip.onclick = this.equip;
            body.appendChild(equip);

            var discard = Browser.document.createButtonElement();
            discard.innerText = 'Discard';
            discard.onclick = this.discard;
            body.appendChild(discard);
        }
        else {
            var unequip = Browser.document.createButtonElement();
            unequip.innerText = 'Unequip';
            unequip.onclick = this.unequip;
            body.appendChild(unequip);
        }

        elem.appendChild(body);

        return elem;
    }

    public function attack() :Int {
        return Math.round(type.attack * (1 + 0.4 * (level - 1)));
    }
    public function defense() :Int {
        return Math.round(type.defense * (1 + 0.4 * (level - 1)));
    }
}
