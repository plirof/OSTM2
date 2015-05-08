package ostm.battle;

import js.Browser;
import js.html.Element;

import jengine.Component;
import jengine.HtmlRenderer;
import jengine.Vec2;
import jengine.util.Util;

class ActiveSkillButton extends Component {
    private var _player :BattleMember;
    private var _skill :ActiveSkill;
    private var _idx :Int;
    private var _body :Element;

    public function new(idx :Int, skill :ActiveSkill) {
        _idx = idx;
        _skill = skill;
    }

    public override function start() {
        _player = BattleManager.instance.getPlayer();

        var html = getComponent(HtmlRenderer);
        var elem = html.getElement();

        elem.innerText = '(' + (_idx + 1) + ') ' + _skill.name;
        elem.onclick = function (event) {
            _player.setActiveSkill(_skill);
        };

        elem.onmouseover = function(event) {
            _body.style.display = '';
            var pos = new Vec2(event.x + 20, event.y - 180);
            _body.style.left = cast pos.x;
            _body.style.top = cast pos.y;
        };
        elem.onmouseout = function(event) {
            _body.style.display = 'none';
        };

        _body = Browser.document.createUListElement();

        _body.style.display = 'none';
        _body.style.position = 'absolute';
        _body.style.background = '#444444';
        _body.style.border = '2px solid #000000';
        _body.style.width = cast 220;
        _body.style.zIndex = cast 10;

        var bodyItems = [
            _skill.name,
            'Mana Cost: ' + Util.format(_skill.manaCost),
            'Power: ' + Util.format(Math.round(100 * _skill.damage)) + '%',
            'Speed: ' + Util.format(Math.round(100 * _skill.speed)) + '%',
        ];
        for (item in bodyItems) {
            var stat = Browser.document.createLIElement();
            stat.innerText = item;
            _body.appendChild(stat);
        }

        Browser.document.getElementById('popup-container').appendChild(_body);
    }
}
