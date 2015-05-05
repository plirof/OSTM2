package ostm.battle;

import jengine.Component;
import jengine.HtmlRenderer;

class ActiveSkillButton extends Component {
    private var _player :BattleMember;
    private var _skill :ActiveSkill;
    private var _idx :Int;

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
    }
}
