package jengine.util;

class Random {
    public static function randomBool(prob :Float) :Bool {
        return Math.random() < prob;
    }
    public static function randomRange(lo :Float, hi :Float) :Float {
        return (hi - lo) * Math.random() + lo;
    }
    public static function randomIntRange(lo :Int, hi :Int) :Int {
        return Math.floor(randomRange(lo, hi));
    }
    public static function randomElement<T>(array :Array<T>) :T {
        if (array.length > 0) {
            return array[randomIntRange(0, array.length)];
        }
        return null;
    }
}
