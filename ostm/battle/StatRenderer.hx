package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;

import ostm.item.Item;
import ostm.item.ItemType;

class StatElement {
    var elem :Element;
    var title :String;
    var body :Void -> String;

    public function new(parent :Element, title :String, body :Void -> String) {
        elem = Browser.document.createElement('li');
        parent.appendChild(elem);

        this.title = title;
        this.body = body;
    }

    public function update() :Void {
        elem.innerText = title + ': ' + body();
    }
}

class StatRenderer extends Component {
    var _member :BattleMember;

    var _elements :Array<StatElement>;
    var _level :Element;
    var _xp :Element;
    var _hp :Element;
    var _damage :Element;
    var _defense :Element;

    var _equipment = new Map<ItemSlot, Element>();
    var _cachedEquip = new Map<ItemSlot, Item>();

    public function new(member) {
        _member = member;
    }

    public override function start() :Void {
        var doc = Browser.document;
        var stats = doc.getElementById('stats');

        var nameSpan = doc.createSpanElement();
        nameSpan.innerText = _member.isPlayer ? 'Player:' : 'Enemy';
        stats.appendChild(nameSpan);

        var list = createAndAddTo('ul', stats);

        _elements = [
            new StatElement(list, 'Level', function() { return cast _member.level; }),
            new StatElement(list, 'XP', function() { return _member.xp + ' / ' + _member.xpToNextLevel(); }),
            new StatElement(list, 'HP', function() { return _member.health + ' / ' + _member.maxHealth(); }),
            new StatElement(list, 'Damage', function() { return cast _member.damage(); }),
            new StatElement(list, 'Speed', function() { return cast _member.attackSpeed(); }),
            new StatElement(list, 'Defense', function() { return cast _member.defense(); }),
            new StatElement(list, 'STR', function() { return cast _member.strength(); }),
            new StatElement(list, 'VIT', function() { return cast _member.vitality(); }),
            new StatElement(list, 'END', function() { return cast _member.endurance(); }),
            new StatElement(list, 'DEX', function() { return cast _member.dexterity(); }),
        ];

        if (_member.isPlayer) {
            var equip = createAndAddTo('ul', stats);
            for (k in _member.equipment.keys()) {
                _equipment[k] = createAndAddTo('li', equip);
                updateEquipSlot(k);
            }
        }
    }

    function createAndAddTo(tag :String, parent :Element) {
        var elem = Browser.document.createElement(tag);
        parent.appendChild(elem);
        return elem;
    }

    public override function update() :Void {
        for (stat in _elements) {
            stat.update();
        }

        if (_member.isPlayer) {
            for (k in _equipment.keys()) {
                var item = _member.equipment[k];
                if (_cachedEquip[k] != item) {
                    _cachedEquip[k] = item;
                    updateEquipSlot(k);
                }
            }
        }
    }

    function updateEquipSlot(slot :ItemSlot) :Void {
        var item = _member.equipment[slot];
        var elem = _equipment[slot];
        while (elem.childElementCount > 0) {
            elem.removeChild(elem.firstChild);
        }
        
        var slotName = Browser.document.createSpanElement();
        slotName.innerText = slot + ': ';
        elem.appendChild(slotName);

        if (item == null) {
            var nullItem = Browser.document.createSpanElement();
            nullItem.innerText = '(none)';
            nullItem.style.fontStyle = 'italic';
            elem.appendChild(nullItem);
        }
        else {
            elem.appendChild(item.createElement('ul', true));
        }
    }
}
