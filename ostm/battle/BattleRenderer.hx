package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.Util;

class BattleRenderer extends Component {
    var _member :BattleMember;
    
    var _imageElem :ImageElement;
    var _spawnedEnts :Array<Entity> = [];

    public function new(member :BattleMember) {
        _member = member;
    }

    public override function deinit() :Void {
        for (ent in _spawnedEnts) {
            entity.getSystem().removeEntity(ent);
        }
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        var elem = renderer.getElement();
        var id = elem.id;
        var size = renderer.size;
        var nameSize = new Vec2(160, 30);
        var nameX = (size.x - nameSize.x) / 2;
        var barSize = new Vec2(160, 16);
        var barX = (size.x - barSize.x) / 2;
        var atkBarSize = new Vec2(180, 20);
        var atkBarX = (size.x - atkBarSize.x) / 2;

        _imageElem = Browser.document.createImageElement();
        _imageElem.src = 'img/' + _member.classType.image;
        _imageElem.height = Math.round(renderer.size.y);
        _imageElem.style.display = 'block';
        _imageElem.style.margin = '0px auto 0px auto';
        _imageElem.style.imageRendering = 'pixelated';
        elem.appendChild(_imageElem);

        var nameEnt = new Entity([
            new Transform(new Vec2(nameX, -78)),
            new HtmlRenderer({
                parent: id,
                size: nameSize,
                text: _member.classType.name,
                style: [
                    'background' => 'none',
                    'text-align' => 'center',
                ],
            }),
        ]);
        _spawnedEnts.push(nameEnt);

        var levelEnt = new Entity([
            new Transform(new Vec2(barX, -59)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                textFunc: function() { return 'L' + Util.format(_member.level); },
                style: [
                    'font-size' => '13px',
                ],
            }),
        ]);
        _spawnedEnts.push(levelEnt);

        var powerEnt = new Entity([
            new Transform(new Vec2(barX, -59)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                textFunc: function() { return 'Pow: ' + Util.shortFormat(_member.power()); },
                style: [
                    'font-size' => '13px',
                    'text-align' => 'right',
                ],
            }),
        ]);
        _spawnedEnts.push(powerEnt);

        var hpEnt = makeHpBar(id, new Vec2(barX, -42), barSize);
        _spawnedEnts.push(hpEnt);

        var mpEnt = new Entity([
            new Transform(new Vec2(barX, -24)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => '#222266',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return _member.mana / _member.maxMana();
            }, [
                'background' => '#0044ff',
            ]),
        ]);

        if (_member.isPlayer) {
            mpEnt.addComponent(new CenteredText(function() {
                return Util.format(_member.mana) + ' / ' + Util.format(_member.maxMana());
            }, 13));
        }
        _spawnedEnts.push(mpEnt);

        if (_member.isPlayer) {
            var hpMenuEnt = makeHpBar('game-header', new Vec2(10, 160), new Vec2(210, 20));
            _spawnedEnts.push(hpMenuEnt);
        }

        var attackBar = new Entity([
            new Transform(new Vec2(atkBarX, 70)),
            new HtmlRenderer({
                parent: id,
                size: atkBarSize,
                style: [
                    'background' => '#226622',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return _member.attackSpeed() * _member.attackTimer;
            }, [
                'background' => '#00ff00',
            ]),
            new CenteredText(function() {
                return _member.curSkill.name;
            }),
        ]);
        _spawnedEnts.push(attackBar);

        for (ent in _spawnedEnts) {
            entity.getSystem().addEntity(ent);
        }
    }

    function makeHpBar(parentId :String, pos :Vec2, barSize :Vec2) :Entity {
        var hpEnt = new Entity([
            new Transform(pos),
            new HtmlRenderer({
                parent: parentId,
                size: barSize,
                style: [
                    'background' => '#662222',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return _member.health / _member.maxHealth();
            }, [
                'background' => '#ff0000',
            ]),
        ]);
        if (_member.isPlayer) {
            hpEnt.addComponent(new CenteredText(function() {
                return Util.format(_member.health) + ' / ' + Util.format(_member.maxHealth());
            }, 13));
        }
        return hpEnt;
    }
}
