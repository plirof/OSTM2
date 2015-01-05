package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.*;

import ostm.map.MapGenerator;
import ostm.battle.Item;

class BattleManager extends Component {
    var _player :BattleMember;
    var _enemy :BattleMember;
    var _battleMembers :Array<BattleMember> = [];

    var _enemySpawnTimer :Float = 0;
    var _isPlayerDead :Bool = false;
    var _killCount :Int = 0;
    static inline var kEnemySpawnTime :Float = 1;
    static inline var kPlayerDeathTime :Float = 5;
    static inline var kMaxInventoryCount :Int = 10;

    public static var instance(default, null) :BattleManager;

    var _itemTypes = [
        new ItemType('Sword', Weapon, 3, 1),
        new ItemType('Axe', Weapon, 4, 0),
        new ItemType('Armor', Body, 0, 2),
        new ItemType('Helm', Helmet, 0, 1),
        new ItemType('Boots', Boots, 0, 1),
    ];
    var _inventory :Array<Item> = [];

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        _player = addBattleMember(new Vec2(125, 200));
        _player.elem.style.background = '#0088ff';
        _enemy = addBattleMember(new Vec2(400, 200));

        _player.isPlayer = true;
        _player.level = 1;
        _player.baseHealth = 100;
        _player.attackSpeed = 1.8;
        _player.baseDamage = 6;
        _player.baseDefense = 3;

        _enemy.level = 1;
        _enemy.baseHealth = 50;
        _enemy.attackSpeed = 1.4;
        _enemy.baseDamage = 5;
        _enemy.baseDefense = 2;

        updateInventoryHtml();
        
        for (mem in _battleMembers) {
            mem.health = mem.maxHealth();
        }

        entity.getSystem().addEntity(new Entity([
            new HtmlRenderer({
                id: 'xp-bar',
                parent: 'game-header',
                size: new Vec2(500, 25),
                style: [
                    'background' => '#118811',
                    'border' => '1px solid #000000',
                ],
            }),
            new Transform(new Vec2(20, 67)),
            new ProgressBar(function() {
                return _player.xp / _player.xpToNextLevel();
            }, [
                'background' => '#22ff22',
            ]),
        ]));
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
            var li = Browser.document.createLIElement();
            inventory.appendChild(li);
            
            var equip = Browser.document.createButtonElement();
            equip.innerText = 'Equip';
            equip.onclick = function (event) {
                var cur = _player.equipment[item.type.slot];
                if (cur != null) {
                    _inventory.push(cur);
                }
                _player.equip(item);
                _inventory.remove(item);
                updateInventoryHtml();
            };
            li.appendChild(equip);
            
            var name = Browser.document.createSpanElement();
            name.innerText = item.name();
            li.appendChild(name);

            var discard = Browser.document.createButtonElement();
            discard.innerText = 'Discard';
            discard.onclick = function (event) {
                _inventory.remove(item);
                updateInventoryHtml();
            };
            li.appendChild(discard);
        }
    }

    public override function update() :Void {
        var statHtml = 'Player: ' + _player.statHtml() + 'Enemy: ' + _enemy.statHtml();
        var stats = Browser.document.getElementById('stats');
        stats.innerHTML = statHtml;

        var hasEnemySpawned = isInBattle();
        _enemy.elem.style.display = hasEnemySpawned ? '' : 'none';
        if (!hasEnemySpawned) {
            _enemySpawnTimer += Time.dt;

            if (_enemySpawnTimer >= kEnemySpawnTime) {
                var node = MapGenerator.instance.selectedNode;
                _enemy.level = node.areaLevel();
                _enemy.health = _enemy.maxHealth();
            }

            var regen = _isPlayerDead ? _player.maxHealth() / kPlayerDeathTime : _player.healthRegen();
            _player.healthPartial += regen * Time.dt;
            var dHealth = Math.floor(_player.healthPartial);
            _player.health += dHealth;
            _player.healthPartial -= dHealth;
            if (_player.health >= _player.maxHealth()) {
                _player.health = _player.maxHealth();

                if (_isPlayerDead) {
                    _isPlayerDead = false;
                    _enemySpawnTimer = 0;
                }
            }

            return;
        }

        for (mem in _battleMembers) {
            mem.attackTimer += Time.dt;
            var attackTime = 1.0 / mem.attackSpeed;
            if (mem.attackTimer > attackTime) {
                mem.attackTimer -= attackTime;
                var target = mem.isPlayer ? _enemy : _player;
                dealDamage(target, mem.damage());
            }
        }
    }

    function dealDamage(target :BattleMember, damage :Int) :Void {
        var dam = Util.intMax(damage - target.defense(), 0);
        target.health -= dam;
        if (target.health <= 0) {
            target.health = target.isPlayer ? 0 : target.maxHealth();
            for (mem in _battleMembers) {
                mem.attackTimer = 0;
            }
            _enemySpawnTimer = 0;

            if (target.isPlayer) {
                _isPlayerDead = true;
                _enemy.health = _enemy.maxHealth();
            }
            else {
                _killCount++;
                _player.addXp(_enemy.xpReward());

                if (Random.randomBool(0.35) && _inventory.length < kMaxInventoryCount) {
                    var type = Random.randomElement(_itemTypes);
                    var level = Random.randomIntRange(1, _enemy.level + 1);
                    _inventory.push(new Item(type, level));
                    updateInventoryHtml();
                }
            }
        }
    }

    function addBattleMember(pos :Vec2) :BattleMember {
        var id = 'battle-member-' + _battleMembers.length;
        var size = new Vec2(60, 60);
        var barSize = new Vec2(150, 20);
        var barX = (size.x - barSize.x) / 2;
        var system = entity.getSystem();
        var ent = new Entity([
            new Transform(pos),
            new HtmlRenderer({
                id: id,
                parent: 'battle-screen',
                size: size,
                style: [
                    'border' => '2px solid black',
                ],
            }),
        ]);
        system.addEntity(ent);

        var bat = new BattleMember(ent);
        bat.elem = ent.getComponent(HtmlRenderer).getElement();

        var hpBar = new Entity([
            new Transform(new Vec2(barX, -60)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => '#662222',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return bat.health / bat.maxHealth();
            }, [
                'background' => '#ff0000',
            ]),
        ]);
        system.addEntity(hpBar);
        var attackBar = new Entity([
            new Transform(new Vec2(barX, -38)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => '#226622',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return bat.attackSpeed * bat.attackTimer;
            }, [
                'background' => '#00ff00',
            ]),
        ]);
        system.addEntity(attackBar);

        _battleMembers.push(bat);
        return bat;
    }

    public function isPlayerDead() :Bool {
        return _isPlayerDead;
    }

    public function isInBattle() :Bool {
        return _enemySpawnTimer >= kEnemySpawnTime && !_isPlayerDead;
    }

    public function getKillCount() :Int {
        return _killCount;
    }
    public function resetKillCount() :Void {
        _killCount = 0;
    }
}
