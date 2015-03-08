package ostm.item;

import js.*;
import js.html.*;

import jengine.Component;
import jengine.SaveManager;
import jengine.util.Random;

import ostm.battle.BattleManager;
import ostm.item.ItemType;

class Inventory extends Component
        implements Saveable {
    public var saveId(default, null) :String = 'inventory';
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
        for (item in _inventory) {
            item.cleanupElement();
        }

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

        var generate = Browser.document.createButtonElement();
        generate.innerText = 'Generate All';
        generate.onclick = function (event) {
            _inventory = [];
            while (hasSpaceForItem()) {
                tryRewardItem(3);
            }
            updateInventoryHtml();
        };
        inventory.appendChild(generate);

        for (item in _inventory) {
            appendItemHtml(item);
        }
    }

    function appendItemHtml(item :Item) {
        var inventory = Browser.document.getElementById('inventory');
        var li = item.createElement('li');
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
            var type = Random.randomElement(ItemData.types);
            var item = new Item(type, maxLevel);
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
