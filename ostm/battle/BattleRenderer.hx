package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.Util;

class BattleRenderer extends Component {
    var _member :BattleMember;
    
    var _hpBar :Entity;
    var _attackBar :Entity;

    var _attackElem :Element;

    public function new(member :BattleMember) {
        _member = member;
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        var id = renderer.getElement().id;
        var size = renderer.size;
        var barSize = new Vec2(150, 20);
        var barX = (size.x - barSize.x) / 2;

        _hpBar = new Entity([
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
                return _member.health / _member.maxHealth();
            }, [
                'background' => '#ff0000',
            ]),
        ]);
        entity.getSystem().addEntity(_hpBar);
        _attackBar = new Entity([
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
                return _member.attackSpeed() * _member.attackTimer;
            }, [
                'background' => '#00ff00',
            ]),
        ]);
        entity.getSystem().addEntity(_attackBar);
    }

    public override function update() :Void {
        if (_attackElem == null) {
            _attackElem = Browser.document.createSpanElement();
            _attackElem.style.position = 'absolute';
            var atkRenderer = _attackBar.getComponent(HtmlRenderer);
            _attackElem.style.width = cast atkRenderer.size.x;
            _attackElem.style.textAlign = 'center';
            _attackElem.style.zIndex = cast 1;
            atkRenderer.getElement().appendChild(_attackElem);
        }
        _attackElem.innerText = _member.curSkill.name;
    }
}
