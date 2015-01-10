package ostm;

import js.*;
import js.html.*;

import jengine.Component;
import jengine.util.Random;

import ostm.battle.Item;
import ostm.battle.BattleManager;

class Inventory extends Component {
    var _itemTypes = [
        new ItemType('Sword', Weapon, 3, 1),
        new ItemType('Axe', Weapon, 4, 0),
        new ItemType('Armor', Body, 0, 2),
        new ItemType('Helm', Helmet, 0, 1),
        new ItemType('Boots', Boots, 0, 1),
    ];
    var _inventory :Array<Item> = [];
    static inline var kMaxInventoryCount :Int = 10;

    public static var instance(default, null) :Inventory;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        updateInventoryHtml();
    }

    public function updateInventoryHtml() :Void {
        var inventory = Browser.document.getElementById('inventory');
        while (inventory.children.length > 0) {
            inventory.removeChild(inventory.children[0]);
        }

        var count = Browser.document.createLIElement();
        count.innerText = 'Capacity: ' + _inventory.length + ' / ' + kMaxInventoryCount;
        inventory.appendChild(count);

        for (item in _inventory) {
            var li = item.createElement();
            inventory.appendChild(li);
        }
    }

    public function push(item :Item) {
        _inventory.push(item);
    }
    public function remove(item :Item) {
        _inventory.remove(item);
    }

    public function tryRewardItem(maxLevel :Int) :Void {
        if (Random.randomBool(10.35) && _inventory.length < kMaxInventoryCount) {
            var type = Random.randomElement(_itemTypes);
            var level = Random.randomIntRange(1, maxLevel + 1);
            _inventory.push(new Item(type, level));
            updateInventoryHtml();
        }
    }
}
