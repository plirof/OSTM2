package jengine;

import js.*;
import js.html.Document;

class SineMover extends Component {
    var _v :Float;
    var _p :Float;

    public function new(v :Float, p :Float) { _v = v; _p = p; }
    public override function update() :Void {
        getComponent(Transform).pos.y += Time.dt * _v * Math.sin(Time.elapsed * Math.PI * _p);
    }
}

class JEngineMain {
    public static function main() {
        new JEngineMain();
    }

    var _entitySystem :EntitySystem = new EntitySystem();
    var _updateInterval :Int = 16;

    public function new() {
        _entitySystem.addEntity(new Entity([
            new SineMover(15, 2.3),
            new HtmlRenderer(new Vec2(20, 20)),
            new Transform(new Vec2(320, 20)),
        ]));
        _entitySystem.addEntity(new Entity([
            new HtmlRenderer(),
            new Transform(new Vec2(210, 320)),
            new SineMover(45, 1.2),
        ]));

        Browser.document.getElementById('btn-add').onclick = addRandomSquare;
        Browser.document.getElementById('btn-clear').onclick = clearSquares;

        Time.init();

        Browser.window.setInterval(update, _updateInterval);
    }

    public static function randomRange(lo :Float, hi :Float) {
        return (hi - lo) * Math.random() + lo;
    }

    public function addRandomSquare(arg :Dynamic) {
        var size :Float = randomRange(20, 75);
        var pos :Vec2 = new Vec2(randomRange(50, 550), randomRange(50, 550));
        // var v = randomRange(15, 75);
        // var p = randomRange(0.8, 4.5);
        _entitySystem.addEntity(new Entity([
            new HtmlRenderer(new Vec2(size, size)),
            // new SineMover(v, p),
            new Transform(pos),
        ]));
    }

    public function clearSquares(arg :Dynamic) {
        _entitySystem.removeAll();
    }

    public function update() :Void {
        Time.update();

        _entitySystem.update();
    }
}
