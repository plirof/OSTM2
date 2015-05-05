package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.*;

import ostm.map.MapGenerator;
import ostm.item.Item;
import ostm.item.Inventory;

class BattleManager extends Component {
    var _player :BattleMember;
    var _enemy :BattleMember;
    var _battleMembers :Array<BattleMember> = [];

    var _enemySpawnTimer :Float = 0;
    var _isPlayerDead :Bool = false;
    var _killCount :Int = 0;
    static inline var kEnemySpawnTime :Float = 4;
    static inline var kPlayerDeathTime :Float = 5;

    public static var instance(default, null) :BattleManager;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        _player = addBattleMember(true, new Vec2(75, 80));
        _player.elem.style.background = '#0088ff';
        _enemy = addBattleMember(false, new Vec2(350, 80));

        entity.getSystem().addEntity(new Entity([
            new HtmlRenderer({
                id: 'kill-bar',
                parent: 'game-header',
                size: new Vec2(500, 25),
                style: [
                    'background' => '#885500',
                    'border' => '1px solid #000000',
                ],
            }),
            new Transform(new Vec2(20, 37)),
            new ProgressBar(function() {
                return _enemySpawnTimer / kEnemySpawnTime;
            }, [
                'background' => '#ffaa00',
            ]),
        ]));

        var buttons = [];
        for (skill in ActiveSkill.skills) {
            var i = buttons.length;
            var html = new HtmlRenderer({
                parent: 'battle-screen',
                size: new Vec2(80, 80),
                style: [
                    'border' => '2px solid black',
                    'background' => 'white',
                ],
            });
            var btn = new Entity([
                new Transform(new Vec2(100 * i + 50, 200)),
                html,
                new ActiveSkillButton(i, skill),
            ]);
            entity.getSystem().addEntity(btn);
            var elem = html.getElement();
            buttons.push(elem);
        }
        Browser.document.onkeydown = function (event :KeyboardEvent) :Void {
            var i = event.keyCode - 49; //49 == keycode for '1'
            if (i >= 0 && i < buttons.length) {
                buttons[i].onclick(null);
            }
        }

        _player.level = 1;
        _enemy.level = 1;
        
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

    public function spawnLevel() :Int {
        return MapGenerator.instance.selectedNode.areaLevel();
    }

    function playerRegenUpdate() :Void {
        if (MapGenerator.instance.isInTown()) {
            _player.health = _player.maxHealth();
            _isPlayerDead = false;
            return;
        }

        var healthRegen;
        if (_isPlayerDead) {
            healthRegen = _player.maxHealth() / kPlayerDeathTime;
        }
        else if (isInBattle()) {
            healthRegen = _player.healthRegenInCombat();
        }
        else {
            healthRegen = _player.healthRegenOutOfCombat();
        }
        var manaRegen = _player.manaRegen();
        _player.healthPartial += healthRegen * Time.dt;
        _player.manaPartial += manaRegen * Time.dt;
        var dHealth = Math.floor(_player.healthPartial);
        var dMana = Math.floor(_player.manaPartial);
        _player.health += dHealth;
        _player.healthPartial -= dHealth;
        if (_player.health >= _player.maxHealth()) {
            _player.health = _player.maxHealth();

            if (_isPlayerDead) {
                _isPlayerDead = false;
                _enemySpawnTimer = 0;
            }
        }
        _player.mana += dMana;
        _player.manaPartial -= dMana;
        if (_player.mana >= _player.maxMana()) {
            _player.mana = _player.maxMana();
        }
    }

    public override function update() :Void {
        var hasEnemySpawned = isInBattle();
        _enemy.elem.style.display = hasEnemySpawned ? '' : 'none';

        playerRegenUpdate();

        var inTown = MapGenerator.instance.isInTown();
        Browser.document.getElementById('battle-screen').style.display = !inTown ? '' : 'none';
        if (inTown) {
            _enemySpawnTimer = 0;
            return;
        }

        if (!hasEnemySpawned) {
            _enemySpawnTimer += Time.dt;

            if (_enemySpawnTimer >= kEnemySpawnTime) {
                _enemy.level = spawnLevel();
                _enemy.health = _enemy.maxHealth();
            }

            return;
        }

        for (mem in _battleMembers) {
            mem.attackTimer += Time.dt;
            var attackTime = 1.0 / mem.attackSpeed();
            if (mem.attackTimer > attackTime) {
                mem.attackTimer -= attackTime;
                var target = mem.isPlayer ? _enemy : _player;
                dealDamage(target, mem);
                mem.setActiveSkill(ActiveSkill.skills[0]);
            }
        }
    }

    function dealDamage(target :BattleMember, attacker :BattleMember) :Void {
        var baseDamage = attacker.damage();
        var damage = Math.round(baseDamage * (1 - target.damageReduction(attacker.level)));
        var crit = attacker.critInfo(target.level);
        var isCrit = Random.randomBool(crit.chance);
        if (isCrit) {
            damage = Math.round(damage * (1 + crit.damage));
        }
        target.health -= damage;

        var elem = target.entity.getComponent(HtmlRenderer).getElement();
        var rect = elem.getBoundingClientRect();
        var pos = new Vec2(rect.left + rect.width / 3, rect.top + rect.height / 4);
        var numEnt = new Entity([
            new Transform(pos),
            new HtmlRenderer({
                parent: 'popup-container',
            }),
            new DamageNumber(damage, isCrit, target.isPlayer),
        ]);
        entity.getSystem().addEntity(numEnt);

        if (target.health <= 0) {
            target.health = target.isPlayer ? 0 : target.maxHealth();
            for (mem in _battleMembers) {
                mem.attackTimer = 0;
            }
            _enemySpawnTimer = 0;

            if (target.isPlayer) {
                _isPlayerDead = true;
                MapGenerator.instance.returnToCheckpoint();
                _enemy.level = spawnLevel();
                _enemy.health = _enemy.maxHealth();
            }
            else {
                _killCount++;
                var xp = _enemy.xpReward();
                var gold = _enemy.goldReward();
                var gems = Random.randomBool(0.07) ? 1 : 0;
                _player.addXp(xp);
                _player.addGold(gold);
                _player.addGems(gems);

                var xpStr = Util.format(xp) + 'XP';
                entity.getSystem().addEntity(new Entity([
                    new Transform(pos),
                    new HtmlRenderer({
                        parent: 'popup-container',
                    }),
                    new PopupNumber(xpStr, '#33ff33', 22, 170, 2.5),
                ]));
                var goldStr = Util.format(gold) + 'G';
                entity.getSystem().addEntity(new Entity([
                    new Transform(pos + new Vec2(0, 30)),
                    new HtmlRenderer({
                        parent: 'popup-container',
                    }),
                    new PopupNumber(goldStr, '#ffff33', 22, 170, 2.5),
                ]));
                if (gems > 0) {
                var goldStr = Util.format(gems) + 'Gem';
                entity.getSystem().addEntity(new Entity([
                    new Transform(pos + new Vec2(0, 60)),
                    new HtmlRenderer({
                        parent: 'popup-container',
                    }),
                    new PopupNumber(goldStr, '#ff3333', 22, 170, 2.5),
                ]));
                }

                Inventory.instance.tryRewardItem(_enemy.level);
            }
        }
    }

    function addBattleMember(isPlayer :Bool, pos :Vec2) :BattleMember {
        var id = 'battle-member-' + _battleMembers.length;
        var system = entity.getSystem();
        var size = new Vec2(60, 60);
        var bat = new BattleMember(isPlayer);
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
            new BattleRenderer(bat),
        ]);
        if (isPlayer) {
            ent.addComponent(new StatRenderer(bat));
        }
        system.addEntity(ent);

        bat.entity = ent;
        bat.elem = ent.getComponent(HtmlRenderer).getElement();
        bat.setActiveSkill(ActiveSkill.skills[0]);

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

    public function getPlayer() :BattleMember {
        return _player;
    }
}
