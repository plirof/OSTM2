package jengine;

private class Vec2_Impl {
    public var x: Float;
    public var y: Float;

    public function new(x_: Float = 0, y_: Float = 0) {
        x = x_;
        y = y_;
    }
}

@:forward
abstract Vec2(Vec2_Impl) to Vec2_Impl from Vec2_Impl {
    public function new(x_: Float = 0, y_: Float = 0) {
        return new Vec2_Impl(x_, y_);
    }

    @:op(A + B) public static inline function add(lhs: Vec2, rhs :Vec2) :Vec2 {
        return new Vec2(lhs.x + rhs.x, lhs.y + rhs.y);
    }
    @:op(A - B) public static inline function sub(lhs: Vec2, rhs :Vec2) :Vec2 {
        return new Vec2(lhs.x - rhs.x, lhs.y - rhs.y);
    }

    @:op(A * B) public static inline function scMult(lhs: Vec2, rhs :Float) :Vec2 {
        return new Vec2(lhs.x * rhs, lhs.y * rhs);
    }
    @:op(A / B) public static inline function scDiv(lhs: Vec2, rhs :Float) :Vec2 {
        return new Vec2(lhs.x / rhs, lhs.y / rhs);
    }
}
