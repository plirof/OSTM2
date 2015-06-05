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
    var _battleMembers :Array<BattleMember> = [];
    var _activeButtons :Array<ActiveSkillButton> = [];

    var _enemies :Array<BattleMember> = [];

    var _enemySpawnPct :Float = 0;
    var _isPlayerDead :Bool = false;
    var _killCount :Int = 0;

    var _battleScreen :Element;
    var _huntButton :Element;

    static inline var kBaseEnemySpawnTime :Float = 4;
    static inline var kPlayerDeathTime :Float = 5;

    public static var instance(default, null) :BattleManager;

    public override function init() :Void {
        instance = this;
    }

    public override function start() :Void {
        _player = addBattleMember(true, new Vec2(75, 80));

        entity.getSystem().addEntity(new Entity([
            new HtmlRenderer({
                parent: 'battle-screen',
                className: 'spawn-bar',
            }),
            new ProgressBar(function() {
                return _enemySpawnPct;
            }),
        ]));

        entity.getSystem().addEntity(new Entity([
            new HtmlRenderer({
                parent: 'battle-screen',
                className: 'xp-bar',
            }),
            new ProgressBar(function() {
                return _player.xp / _player.xpToNextLevel();
            }),
        ]));

        _activeButtons = [];
        for (skill in ActiveSkill.skills) {
            var i = _activeButtons.length;
            var x = i % 2;
            var y = Math.floor(i / 2);
            var btn = new ActiveSkillButton(i, skill);
            var btnEnt = new Entity([
                new Transform(new Vec2(90 * x + 20, 90 * y + 200)),
                new HtmlRenderer({
                    parent: 'battle-screen',
                    size: new Vec2(80, 80),
                    style: [
                        'border' => '2px solid black',
                        'background' => 'white',
                    ],
                }),
                btn,
            ]);
            entity.getSystem().addEntity(btnEnt);
            _activeButtons.push(btn);
        }

        _player.level = 1;

        for (mem in _battleMembers) {
            mem.health = mem.maxHealth();
            mem.mana = mem.maxMana();
        }

        _battleScreen = Browser.document.getElementById('battle-screen');

        _huntButton = Browser.document.createButtonElement();
        _huntButton.className = 'hunt-button';
        _huntButton.onclick = function(event) {
            _player.huntType = switch _player.huntType {
                case Normal: Hunting;
                case Hunting: Hiding;
                case Hiding: Normal;
            };
        };
        _battleScreen.appendChild(_huntButton);
    }

    public function spawnLevel() :Int {
        return MapGenerator.instance.selectedNode.areaLevel();
    }

    public function keyDown(keyCode :Int) :Void {
        var i = keyCode - 49; //49 == keycode for '1'
        if (i >= 0 && i < _activeButtons.length) {
            _activeButtons[i].onClick();
        }
    }

    function regenUpdate() :Void {
        if (MapGenerator.instance.isInTown()) {
            _player.health = _player.maxHealth();
            _player.mana = _player.maxMana();
            _isPlayerDead = false;
            return;
        }

        for (mem in _battleMembers) {
            mem.updateRegen(isInBattle());
        }

        if (_isPlayerDead && _player.health == _player.maxHealth()) {
            _isPlayerDead = false;
            _enemySpawnPct = 0;
        }
    }

    public override function update() :Void {
        var hasEnemySpawned = isInBattle();

        regenUpdate();

        var inTown = MapGenerator.instance.isInTown();
        _battleScreen.style.display = !inTown ? '' : 'none';
        _huntButton.innerText = switch _player.huntType {
            case Normal: 'Normal';
            case Hunting: 'Hunting';
            case Hiding: 'Hiding';
        };
        if (inTown) {
            _enemySpawnPct = 0;
            return;
        }

        if (!hasEnemySpawned) {
            _enemySpawnPct += Time.dt / enemySpawnTime();

            if (_enemySpawnPct >= 1) {
                spawnEnemies();
            }

            return;
        }

        for (mem in _battleMembers) {
            mem.attackTimer += Time.dt;
            var attackTime = 1.0 / mem.attackSpeed();
            if (mem.attackTimer > attackTime) {
                mem.attackTimer -= attackTime;
                var target = mem.isPlayer ? _enemies[0] : _player;
                dealDamage(target, mem);
                mem.setActiveSkill(ActiveSkill.skills[0]);
            }
        }
    }

    function spawnEnemies() :Void {
        var nEnemies = 1;
        for (i in 0...nEnemies) {
            var enemy = addBattleMember(false, new Vec2(350, 80 + 170 * i));
            enemy.level = spawnLevel();
            enemy.health = enemy.maxHealth();
            enemy.mana = enemy.maxMana();
            _enemies.push(enemy);
        }
    }

    function despawnEnemy(enemy :BattleMember) :Void {
        enemy.entity.getSystem().removeEntity(enemy.entity);
        _enemies.remove(enemy);
        _battleMembers.remove(enemy);
    }

    function dealDamage(target :BattleMember, attacker :BattleMember) :Void {
        var baseDamage = attacker.damage();
        var damage = Math.round(baseDamage * (1 - target.damageReduction(attacker.level, attacker.armorPierce())));
        var crit = attacker.critInfo(target.level);
        var isCrit = Random.randomBool(crit.chance);
        if (isCrit) {
            damage = Math.round(damage * (1 + crit.damage));
        }
        target.health -= damage;
        attacker.mana -= attacker.manaCost();

        var elem = target.entity.getComponent(HtmlRenderer).getElement();
        var rect = elem.getBoundingClientRect();
        var pos = new Vec2(rect.left + rect.width / 3, rect.top + rect.height / 4);
        var damagePos = new Vec2(Random.randomRange(rect.left, rect.right),
                                 Random.randomRange(rect.top, rect.bottom));
        var numEnt = new Entity([
            new Transform(damagePos),
            new HtmlRenderer({
                parent: 'popup-container',
            }),
            new DamageNumber(damage, isCrit, target.isPlayer),
        ]);
        entity.getSystem().addEntity(numEnt);

        if (target.health <= 0) {
            var isBattleDone = false;

            if (target.isPlayer) {
                target.health = 0;
                _isPlayerDead = true;
                MapGenerator.instance.returnToCheckpoint();

                var enemies = _enemies.copy();
                for (e in enemies) {
                    despawnEnemy(e);
                }

                isBattleDone = true;
            }
            else {
                _killCount++;
                var mod = _player.sumAffixes();

                var xp = target.xpReward();
                xp = Math.round(xp * (1 + mod.percentXpGained / 100));
                var gold = target.goldReward();
                gold = Math.round(gold * (1 + mod.percentGoldGained / 100));
                var gemChance = 0.07 * (1 + mod.percentGemDropRate / 100);
                var gems = Random.randomBool(gemChance) ? 1 : 0;
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
                    var gemStr = Util.format(gems) + 'Gem';
                    entity.getSystem().addEntity(new Entity([
                        new Transform(pos + new Vec2(0, 60)),
                        new HtmlRenderer({
                            parent: 'popup-container',
                        }),
                        new PopupNumber(gemStr, '#ff3333', 22, 170, 2.5),
                    ]));
                }

                Inventory.instance.tryRewardItem(target, mod);

                despawnEnemy(target);
                isBattleDone = _enemies.length == 0;
            }

            if (isBattleDone) {
                for (mem in _battleMembers) {
                    mem.attackTimer = 0;
                }
                _enemySpawnPct = 0;
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
                    'background' => 'none',
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
        return _enemies.length > 0 && !_isPlayerDead;
    }

    public function getKillCount() :Int {
        return _killCount;
    }
    public function resetKillCount() :Void {
        _killCount = 0;
    }

    public function enemySpawnTime() :Float {
        return kBaseEnemySpawnTime * _player.enemySpawnModifier();
    }

    public function getPlayer() :BattleMember {
        return _player;
    }
}
