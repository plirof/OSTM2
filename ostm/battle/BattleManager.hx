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
    static inline var kEnemySpawnTime :Float = 2;
    static inline var kPlayerDeathTime :Float = 5;

    public static var instance(default, null) :BattleManager;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        _player = addBattleMember(true, new Vec2(75, 80));
        _player.elem.style.background = '#0088ff';
        _enemy = addBattleMember(false, new Vec2(350, 80));

        var nBtns = 0;
        for (skill in ActiveSkill.skills) {
            var html = new HtmlRenderer({
                parent: 'battle-screen',
                size: new Vec2(80, 80),
                style: [
                    'border' => '2px solid black',
                    'background' => 'white',
                ],
            });
            var btn = new Entity([
                new Transform(new Vec2(100 * nBtns + 50, 200)),
                html,
            ]);
            var elem = html.getElement();
            elem.innerText = skill.name;
            elem.onclick = function (event) {
                _player.setActiveSkill(skill);
            };
            nBtns++;
            entity.getSystem().addEntity(btn);
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

    public override function update() :Void {
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
            var attackTime = 1.0 / mem.attackSpeed();
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

                Inventory.instance.tryRewardItem(_enemy.level);
            }
        }
    }

    function addBattleMember(isPlayer :Bool, pos :Vec2) :BattleMember {
        var id = 'battle-member-' + _battleMembers.length;
        var size = new Vec2(60, 60);
        var barSize = new Vec2(150, 20);
        var barX = (size.x - barSize.x) / 2;
        var system = entity.getSystem();
        var bat = new BattleMember(isPlayer);
        var statRenderer = new StatRenderer(bat);
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
            statRenderer,
        ]);
        system.addEntity(ent);

        bat.entity = ent;
        bat.elem = ent.getComponent(HtmlRenderer).getElement();
        bat.setActiveSkill(ActiveSkill.skills[0]);

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
                id: id + '-attack-bar',
                parent: id,
                size: barSize,
                style: [
                    'background' => '#226622',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return bat.attackSpeed() * bat.attackTimer;
            }, [
                'background' => '#00ff00',
            ]),
        ]);
        system.addEntity(attackBar);
        statRenderer.setBars(hpBar, attackBar);

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
