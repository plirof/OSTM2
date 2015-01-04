package jengine.util;

class Util {
    public static function clamp(t :Float, lo :Float, hi :Float) :Float {
        if (t > hi) { return hi; }
        if (t < lo) { return lo; }
        return t;
    }
    public static inline function clamp01(t :Float) :Float {
        return clamp(t, 0, 1);
    }
    public static inline function clampInt(t :Int, lo :Int, hi :Int) :Int {
        return Math.round(clamp(t, lo, hi));
    }
    public static inline function lerp(t :Float, lo :Float, hi :Float) :Float {
        return clamp01(t) * (hi - lo) + lo;
    }
}
