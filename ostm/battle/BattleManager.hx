package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;

class BattleMember {
    public var entity :Entity;
    public var elem :Element;
    public var isPlayer :Bool = false;

    public var level :Int;
    public var maxHealth :Int;
    public var healthRegen :Float;
    public var attackSpeed :Float;
    public var damage :Int;

    public var xp :Int = 0;
    public var health :Int;
    public var healthPartial :Float = 0;
    public var attackTimer :Float = 0;

    public function new(entity :Entity) {
        this.entity = entity;
    }

    public function xpToNextLevel() :Int {
        return 10 + 5 * (level - 1);
    }
    public function addXp(xp :Int) :Void {
        this.xp += xp;
        var tnl = xpToNextLevel();
        if (this.xp >= tnl) {
            this.xp -= tnl;
            level++;
            maxHealth += 5;
            damage += 1;
        }
    }
}

class BattleManager extends Component {
    var _player :BattleMember;
    var _enemy :BattleMember;
    var _battleMembers :Array<BattleMember> = [];

    var _enemySpawnTimer :Float = 0;
    var _isPlayerDead :Bool = false;
    var _killCount :Int = 0;
    static inline var kEnemySpawnTime :Float = 4;
    static inline var kPlayerDeathTime :Float = 15;

    public static var instance(default, null) :BattleManager;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        _player = addBattleMember(new Vec2(125, 200));
        _player.elem.style.background = '#0088ff';
        _enemy = addBattleMember(new Vec2(400, 200));

        _player.isPlayer = true;
        _player.level = 1;
        _player.maxHealth = 100;
        _player.attackSpeed = 1.2;
        _player.healthRegen = 2.5;
        _player.damage = 6;

        _enemy.level = 1;
        _enemy.maxHealth = 50;
        _enemy.attackSpeed = 0.9;
        _enemy.damage = 4;
        
        for (mem in _battleMembers) {
            mem.health = mem.maxHealth;
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
        var stats = Browser.document.getElementById('stat-screen');
        stats.innerHTML = '<ul>' +
                '<li>Level: ' + _player.level + '</li>' +
                '<li>XP: ' + _player.xp + ' / ' + _player.xpToNextLevel() + '</li>' +
                '<li>HP: ' + _player.health + ' / ' + _player.maxHealth + '</li>' +
                '<li>Attack: ' + _player.damage + '</li>' +
            '</ul>';

        var hasEnemySpawned = isInBattle();
        _enemy.elem.style.display = hasEnemySpawned ? '' : 'none';
        if (!hasEnemySpawned) {
            _enemySpawnTimer += Time.dt;

            var regen = _isPlayerDead ? _player.maxHealth / kPlayerDeathTime : _player.healthRegen;
            _player.healthPartial += regen * Time.dt;
            var dHealth = Math.floor(_player.healthPartial);
            _player.health += dHealth;
            _player.healthPartial -= dHealth;
            if (_player.health >= _player.maxHealth) {
                _player.health = _player.maxHealth;

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
                dealDamage(target, mem.damage);
            }
        }
    }

    function dealDamage(target :BattleMember, damage :Int) :Void {
        target.health -= damage;
        if (target.health <= 0) {
            target.health = target.isPlayer ? 0 : target.maxHealth;
            for (mem in _battleMembers) {
                mem.attackTimer = 0;
            }
            _enemySpawnTimer = 0;

            if (target.isPlayer) {
                _isPlayerDead = true;
                _enemy.health = _enemy.maxHealth;
            }
            else {
                _killCount++;
                _player.addXp(2);
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
                return bat.health / bat.maxHealth;
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
