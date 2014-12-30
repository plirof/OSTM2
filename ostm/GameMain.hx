package ostm;

import js.*;

import jengine.*;

import ostm.map.*;

class SineMover extends Component {
    var _v :Float;
    var _p :Float;

    public function new(v :Float, p :Float) { _v = v; _p = p; }
    public override function update() :Void {
        getComponent(Transform).pos.y += Time.dt * _v * Math.sin(Time.elapsed * Math.PI * _p);
    }
}

class GameMain extends JEngineMain {
	public static function main() {
		new GameMain();
	}

	public function new() {
		var entityList = [
            new Entity([
                new MapGenerator(),
            ]),
        ];

        // for (i in 0...5) {
        //     var e = new Entity([
        //         new HtmlRenderer(new Vec2(75, 75)),
        //         new Transform(new Vec2(30 + 85 * i, 570)),
        //     ]);
        //     var elem = e.getComponent(HtmlRenderer).getElement();
        //     elem.style.border = '1px solid black';
        //     elem.style.background = 'white';
        //     entityList.push(e);
        // }

        MouseManager.init();

		super(entityList);
	}
}
