package ostm.item;

import js.*;
import js.html.*;

import jengine.Component;
import jengine.SaveManager;
import jengine.util.Random;

import ostm.battle.BattleManager;

class Inventory extends Component
        implements Saveable {
    public var saveId(default, null) :String = 'inventory';
    public static var itemTypes = [
        new ItemType('sword', 'Sword', Weapon, 3, 1),
        new ItemType('axe', 'Axe', Weapon, 4, 0),
        new ItemType('armor', 'Armor', Body, 0, 2),
        new ItemType('helm', 'Helm', Helmet, 0, 1),
        new ItemType('boots', 'Boots', Boots, 0, 1),
    ];
    var _inventory :Array<Item> = [];

    static inline var kMaxInventoryCount :Int = 10;

    public static var instance(default, null) :Inventory;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        updateInventoryHtml();

        SaveManager.instance.addItem(this);
    }

    public function updateInventoryHtml() :Void {
        var inventory = Browser.document.getElementById('inventory');
        while (inventory.childElementCount > 0) {
            inventory.removeChild(inventory.firstChild);
        }

        var count = Browser.document.createLIElement();
        count.innerText = 'Capacity: ' + _inventory.length + ' / ' + kMaxInventoryCount;
        inventory.appendChild(count);

        var clear = Browser.document.createButtonElement();
        clear.innerText = 'Discard All';
        clear.onclick = function (event) {
            _inventory = [];
            updateInventoryHtml();
        };
        inventory.appendChild(clear);

        for (item in _inventory) {
            appendItemHtml(item);
        }
    }

    function appendItemHtml(item :Item) {
        var inventory = Browser.document.getElementById('inventory');
        var li = item.createElement('li', false);
        inventory.appendChild(li);
    }

    public function push(item :Item) {
        _inventory.push(item);
    }
    public function remove(item :Item) {
        _inventory.remove(item);
    }

    public function hasSpaceForItem() :Bool {
        return _inventory.length < kMaxInventoryCount;
    }

    public function tryRewardItem(maxLevel :Int) :Void {
        if (Random.randomBool(0.35) && hasSpaceForItem()) {
            var type = Random.randomElement(itemTypes);
            var level = Random.randomIntRange(1, maxLevel + 1);
            var item = new Item(type, level);
            _inventory.push(item);

            updateInventoryHtml();
        }
    }

    public function serialize() :Dynamic {
        return {
            items: _inventory.map(function (item) { return item.serialize(); }),
        };
    }
    public function deserialize(data :Dynamic) {
        _inventory = data.items.map(function (d) { return Item.loadItem(d); });
        updateInventoryHtml();
    }
}
