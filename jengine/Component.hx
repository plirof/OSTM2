package jengine;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

// @:autoBuild(jengine.Component.buildComponentId())
@:allow(jengine.Entity)
class Component {
    var _entity :Entity = null;

    public function init() :Void { }
    public function deinit() :Void { }
    public function update() :Void { }
    public function draw() :Void { }

    public function getComponent<T :Component>(c :Class<T>) :T {
        return _entity.getComponent(c);
    }

    // //TODO: remove this once it's source-controlled
    // //  it's cool, but it doesn't work well enough, yet
    // //  it also may be useful in the future, who knows
    // function componentId() { return -1; }

    // static var _curId = 0;
    // macro static function buildComponentId() :Array<Field> {
    //     var fields = Context.getBuildFields();

    //     var block = macro {
    //         function componentId() {
    //             return $v{_curId};
    //         }
    //     };

    //     switch (block.expr) {
    //     case EBlock(exprs):
    //         var metas = [];
    //         for (expr in exprs) {
    //             switch (expr.expr) {
    //             case EFunction(name, f):
    //                 fields.push({
    //                     name: 'componentId',
    //                     doc: null,
    //                     access: [APrivate, AOverride],
    //                     kind: FFun(f),
    //                     pos: Context.currentPos(),
    //                     meta: metas,
    //                 });
    //             default:
    //             }
    //         }
    //     default:
    //     }

    //     _curId++;
    //     return fields;
    // }
}
