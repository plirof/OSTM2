package ostm.battle;

import jengine.*;

class BattleManager extends Component {
    var _player :Entity;
    var _enemy :Entity;
    var _battleMembers :Array<Entity> = [];

    public override function start() :Void {
        _player = addBattleMember(new Vec2(50, 300));
        _enemy = addBattleMember(new Vec2(300, 300));
    }

    function addBattleMember(pos :Vec2) :Entity {
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
            }),
        ]);
        system.addEntity(ent);

        var hpBar = new Entity([
            new Transform(new Vec2(barX, -60)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => 'none',
                    'border' => '1px solid black',
                ],
            }),
            new ProgressBar(function() {
                return 0.4;
            }, [
                'background' => '#ff0000',
            ]),
        ]);
        system.addEntity(hpBar);
        var attackBar = new Entity([
            new Transform(new Vec2(barX, -40)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => 'none',
                    'border' => '1px solid black',
                ],
            }),
            new ProgressBar(function() {
                return 0.8;
            }, [
                'background' => '#00ff00',
            ]),
        ]);
        system.addEntity(attackBar);

        _battleMembers.push(ent);
        return ent;
    }
}
