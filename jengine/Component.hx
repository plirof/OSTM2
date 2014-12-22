package jengine;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

@:allow(jengine.Entity)
class Component {
    var _entity :Entity = null;

    public function init() :Void { }
    public function deinit() :Void { }
    public function update() :Void { }
    public function draw() :Void { }

    public function handleMessage(message :String, arg :Dynamic) :Void { }

    public inline function getComponent<T :Component>(c :Class<T>) :T {
        return _entity.getComponent(c);
    }

    public inline function getTransform() :Transform {
        return _entity.getComponent(Transform);
    }
}
