package ostm;

import js.*;

import jengine.*;

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
	            new SineMover(15, 2.3),
	            new HtmlRenderer(new Vec2(20, 20)),
	            new Transform(new Vec2(320, 20)),
	        ]),
	        new Entity([
	            new HtmlRenderer(),
	            new Transform(new Vec2(210, 320)),
	            new SineMover(45, 1.2),
	        ]),
        ];

        for (i in 0...5) {
            var e = new Entity([
                new HtmlRenderer(new Vec2(75, 75)),
                new Transform(new Vec2(30 + 85 * i, 570)),
            ]);
            var elem = e.getComponent(HtmlRenderer).getElement();
            elem.style.border = '1px solid black';
            elem.style.background = 'white';
            entityList.push(e);
        }

        MouseManager.init();

        Browser.document.getElementById('btn-add').onclick = addRandomSquare;
        Browser.document.getElementById('btn-clear').onclick = clearSquares;

		super(entityList);

        addRandomSquare(null);
        addRandomSquare(null);
	}

    public static function randomRange(lo :Float, hi :Float) {
        return (hi - lo) * Math.random() + lo;
    }

    public function addRandomSquare(arg :Dynamic) {
        var size :Float = randomRange(20, 75);
        var pos :Vec2 = new Vec2(randomRange(50, 550), randomRange(50, 550));
        _entitySystem.addEntity(new Entity([
            new HtmlRenderer(new Vec2(size, size)),
            new Transform(pos),
            new Draggable(),
        ]));
    }

    public function clearSquares(arg :Dynamic) {
        _entitySystem.removeAll();
    }
}
