package ostm.item;

import js.*;
import js.html.*;

import jengine.util.*;

import ostm.battle.BattleManager;
import ostm.item.Affix;

class Item {
    public var type(default, null) :ItemType;
    var level :Int;

    var affixes :Array<Affix> = [];

    public function new(type :ItemType, level :Int) {
        this.type = type;
        this.level = level;

        var nAffixes = Random.randomIntRange(0, 4);
        var selectedAffixes = Random.randomElements(Affix.affixTypes, nAffixes);
        for (type in selectedAffixes) {
            var affix = new Affix(type, this.type.slot);
            affix.rollItemLevel(level);
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
        name.style.color = getColor();
        elem.appendChild(name);

        var buttons = Browser.document.createSpanElement();
        elem.appendChild(buttons);

        if (!isEquipped) {
            var equip = Browser.document.createButtonElement();
            equip.innerText = 'Equip';
            equip.onclick = this.equip;
            buttons.appendChild(equip);

            var discard = Browser.document.createButtonElement();
            discard.innerText = 'Discard';
            discard.onclick = this.discard;
            buttons.appendChild(discard);
        }
        else {
            var unequip = Browser.document.createButtonElement();
            unequip.innerText = 'Unequip';
            unequip.onclick = this.unequip;
            buttons.appendChild(unequip);
        }

        var body = Browser.document.createUListElement();
        var setVisible = function (vis) {
            var str = vis ? '' : 'none';
            body.style.display = str;
            buttons.style.display = str;
        }
        setVisible(false);
        elem.onmouseover = function(event) {
            setVisible(true);
        };
        elem.onmouseout = function(event) {
            setVisible(false);
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

        elem.appendChild(body);

        return elem;
    }

    public function sumAffixes(?mod :AffixModifier) :AffixModifier {
        if (mod == null) {
            mod = new AffixModifier();
        }
        for (affix in affixes) {
            affix.applyModifier(mod);
        }
        return mod;
    }

    public function attack() :Int {
        var atk = Math.round(type.attack * (1 + 0.4 * (level - 1)));
        return atk + sumAffixes().flatAttack;
    }
    public function defense() :Int {
        var def = Math.round(type.defense * (1 + 0.4 * (level - 1)));
        return def + sumAffixes().flatDefense;
    }

    public function serialize() :Dynamic {
        return {
            id: type.id,
            level: level,
            affixes: affixes.map(function (affix) { return affix.serialize(); }),
        };
    }
    public static function loadItem(data :Dynamic) :Item {
        for (type in Inventory.itemTypes) {
            if (data.id == type.id) {
                var item = new Item(type, data.level);
                item.affixes = data.affixes.map(function (d) { return Affix.loadAffix(d); });
                return item;
            }
        }
        return null;
    }
}
