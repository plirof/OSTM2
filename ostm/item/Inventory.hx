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
    var _sizeUpgrades :Int = 0;

    static inline var kBaseInventoryCount :Int = 10;

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
        count.innerText = 'Capacity: ' + _inventory.length + ' / ' + capacity();
        inventory.appendChild(count);

        var clear = Browser.document.createButtonElement();
        clear.innerText = 'Discard All';
        clear.onclick = function (event) {
            var inv = _inventory.copy();
            for (item in inv) {
                item.discard();
            }
            updateInventoryHtml();
        };
        inventory.appendChild(clear);

        for (item in _inventory) {
            appendItemHtml(item);
        }
    }

    function appendItemHtml(item :Item) {
        var inventory = Browser.document.getElementById('inventory');
        var li = item.createElement([
            'Equip' => function(event) {
                item.equip();
                updateInventoryHtml();
            },
            'Discard' => function(event) {
                item.discard();
                updateInventoryHtml();
            },
        ]);
        inventory.appendChild(li);
    }

    public function push(item :Item) :Void {
        _inventory.push(item);
    }
    public function remove(item :Item) :Void {
        _inventory.remove(item);
    }
    public function swap(item :Item, forItem :Item) :Void {
        var i = _inventory.indexOf(item);
        if (i >= 0 && i < _inventory.length) {
            _inventory[i] = forItem;
        }
    }

    public function capacity() :Int {
        return kBaseInventoryCount + _sizeUpgrades;
    }

    public function capacityUpgradeCost() :Int {
        return 10 + 5 * _sizeUpgrades;
    }

    public function upgradeCapacity() :Void {
        _sizeUpgrades++;
        updateInventoryHtml();
    }

    public function hasSpaceForItem() :Bool {
        return _inventory.length < capacity();
    }

    public function randomItem(maxLevel :Int) :Item {
        var type = Random.randomElement(ItemData.types);
        var item = new Item(type, maxLevel);
        item.setDropLevel(Random.randomIntRange(1, maxLevel));
        var affixOdds = [
            7 => 0.01,
            4 => 0.05,
            3 => 0.08,
            2 => 0.12,
            1 => 0.25,
        ];
        var nAffixes = 0;
        for (n in affixOdds.keys()) {
            if (Random.randomBool(affixOdds[n])) {
                nAffixes = n;
                break;
            }
        }
        item.rollAffixes(nAffixes);
        return item;
    }

    public function tryRewardItem(maxLevel :Int) :Void {
        if (Random.randomBool(0.35) && hasSpaceForItem()) {
            _inventory.push(randomItem(maxLevel));

            updateInventoryHtml();
        }
    }

    public function serialize() :Dynamic {
        return {
            items: _inventory.map(function (item) { return item.serialize(); }),
            size: _sizeUpgrades,
        };
    }
    public function deserialize(data :Dynamic) {
        _inventory = data.items.map(function (d) { return Item.loadItem(d); });
        _sizeUpgrades = data.size;

        if (SaveManager.instance.loadedVersion < 2) {
            _sizeUpgrades = 0;
        }

        updateInventoryHtml();
    }
}
