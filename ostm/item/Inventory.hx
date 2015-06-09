package ostm.item;

import js.*;
import js.html.*;

import jengine.Component;
import jengine.SaveManager;
import jengine.util.Random;

import ostm.battle.BattleManager;
import ostm.battle.BattleMember;
import ostm.battle.StatModifier;
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

        var sortBtn = Browser.document.createButtonElement();
        sortBtn.innerText = 'Sort Value';
        sortBtn.onclick = function (event) {
            _inventory.sort(function(it1, it2) {
                return -Reflect.compare(it1.buyValue(), it2.buyValue());
            });
            updateInventoryHtml();
        };
        inventory.appendChild(sortBtn);

        inventory.appendChild(Browser.document.createBRElement());

        var discardTexts = ['Basic', 'Magic', 'All'];
        var discardAffixes = [0, 2, 999];
        for (i in 0...discardTexts.length) {
            var clear = Browser.document.createButtonElement();
            clear.innerText = 'Discard ' + discardTexts[i];
            clear.onclick = function (event) {
                var inv = _inventory.copy();
                for (item in inv) {
                    if (item.numAffixes() <= discardAffixes[i]) {
                        item.discard();
                    }
                }
                updateInventoryHtml();
            };
            inventory.appendChild(clear);
        }

        inventory.appendChild(Browser.document.createBRElement());

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

    public function randomItem(maxLevel :Int, rarityMult :Float = 1) :Item {
        var type = Random.randomElement(ItemData.types);
        var item = new Item(type, maxLevel);
        var level = Random.randomIntRange(1, maxLevel);
        level = Random.randomIntRange(level, maxLevel);
        item.setDropLevel(level);
        var affixOdds = [
            // 7 => 0.01,
            4 => 0.05,
            3 => 0.08,
            2 => 0.20,
            1 => 0.30,
        ];
        var nAffixes = 0;
        var keys = [for (i in 0...4) 4 - i];
        for (n in keys) {
            var rarity = affixOdds[n] * rarityMult;
            if (Random.randomBool(rarity)) {
                nAffixes = n;
                break;
            }
        }
        item.rollAffixes(nAffixes);
        return item;
    }

    public function tryRewardItem(enemy :BattleMember, mod :StatModifier) :Void {
        var maxLevel = enemy.level;
        var dropRate = 0.35;
        dropRate *= 1 + mod.percentItemDropRate / 100;

        var didAdd = false;
        while ((dropRate >= 1 || Random.randomBool(dropRate)) &&
                hasSpaceForItem()) {
            var rarityMult = 1 + mod.percentItemRarity / 100;
            _inventory.push(randomItem(maxLevel, rarityMult));
            didAdd = true;
            dropRate -= 1;
        }
        if (didAdd) {
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
        Browser.window.setTimeout(updateInventoryHtml, 0);
    }
}
