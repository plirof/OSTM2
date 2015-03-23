package ostm;

import js.*;
import js.html.*;

import jengine.*;
import jengine.SaveManager;
import jengine.util.Random;
import jengine.util.Util;

import ostm.battle.BattleManager;
import ostm.battle.BattleMember;
import ostm.item.Inventory;
import ostm.item.Item;
import ostm.map.MapGenerator;
import ostm.map.MapNode;

typedef ShopData = {
    generateTime :Int,
    items :Array<Item>,
}
typedef ShopSaveData = {
    i :Int,
    j :Int,
    genTime :Int,
    items :Array<Dynamic>,
};

class TownManager extends Component
        implements Saveable {
    public var saveId(default, null) :String = 'town-manager';
    var _shops = new Map<MapNode, ShopData>();
    var _lastNode :MapNode = null;
    public var shouldWarp(default, null) :Bool = false;

    var _warpButton :Element;

    static inline var kShopRefreshTime = 120;

    public static var instance(default, null) :TownManager;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        SaveManager.instance.addItem(this);

        _warpButton = Browser.document.getElementById('town-warp-button');
        _warpButton.onclick = function(event) {
            shouldWarp = !shouldWarp;
            updateWarpButton();
        };
        updateWarpButton();
    }

    public override function update() :Void {
        var mapNode = MapGenerator.instance.selectedNode;
        var inTown = mapNode.isTown();
        Browser.document.getElementById('town-screen').style.display = inTown ? '' : 'none';

        if (inTown) {
            var shop = _shops[mapNode];
            if (shop == null) {
                shop = {
                    generateTime: 0,
                    items: [],
                };
                _shops[mapNode] = shop;
            }
            if (shop.generateTime + kShopRefreshTime <= Time.raw) {
                generateItems(mapNode);
            }

            var refreshTime = Math.round(shop.generateTime + kShopRefreshTime - Time.raw);
            Browser.document.getElementById('town-shop-clock').innerText = Util.format(refreshTime);

            if (mapNode != _lastNode) {
                updateShopHtml(mapNode);
            }
        }
        else { //not in town
            shouldWarp = false;
            updateWarpButton();
        }

        _lastNode = mapNode;
    }

    function generateItems(mapNode :MapNode) :Void {
        var items = [];

        var nItems = Random.randomIntRange(4, 6);
        for (i in 0...nItems) {
            var item = Inventory.instance.randomItem(mapNode.areaLevel());
            items.push(item);
        }

        var shop = _shops[mapNode];
        shop.items = items;
        shop.generateTime = Math.round(Time.raw);

        updateShopHtml(mapNode);
    }

    function updateShopHtml(mapNode :MapNode) :Void {
        var shopElem = Browser.document.getElementById('town-shop');
        while (shopElem.childElementCount > 0) {
            shopElem.removeChild(shopElem.firstChild);
        }

        var player = BattleManager.instance.getPlayer();
        var items = _shops[mapNode].items;
        for (item in items) {
            shopElem.appendChild(item.createElement([
                'Buy' => function(event) {
                    var price = item.buyValue();
                    if (Inventory.instance.hasSpaceForItem() &&
                        player.gold >= price) {
                        player.addGold(-price);
                        items.remove(item);
                        Inventory.instance.push(item);
                        Inventory.instance.updateInventoryHtml();
                        updateShopHtml(mapNode);
                    }
                },
            ]));
        }
    }

    function updateWarpButton() :Void {
        _warpButton.innerText = shouldWarp ? 'Disable' : 'Enable';
    }

    public function serialize() :Dynamic {
        var shops = new Array<ShopSaveData>();
        for (node in _shops.keys()) {
            var i = node.depth;
            var j = node.height;
            var shop = _shops[node];
            var items = shop.items.map(function (item) {
                return item.serialize();
            });
            shops.push({
                i: i,
                j: j,
                genTime: shop.generateTime,
                items: items,
            });
        }
        return {
            shops: shops,
        };
    }
    public function deserialize(data :Dynamic) :Void {
        var shops :Array<ShopSaveData> = data.shops;
        for (shopData in shops) {
            var i = shopData.i;
            var j = shopData.j;
            var node = MapGenerator.instance.getNode(i, j);
            var items = shopData.items.map(function (itemData) {
                return Item.loadItem(itemData);
            });
            _shops[node] = {
                generateTime: shopData.genTime,
                items: items,
            };
        }
    }
}
