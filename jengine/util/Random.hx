package jengine.util;

class Random {
    public static function randomBool(prob :Float) :Bool {
        return Math.random() < prob;
    }
    public static function randomRange(lo :Float, hi :Float) :Float {
        return (hi - lo) * Math.random() + lo;
    }
    public static function randomIntRange(lo :Int, hi :Int) :Int {
        return Math.floor(randomRange(lo, hi + 1));
    }
    public static function randomElement<T>(array :Array<T>) :T {
        if (array.length > 0) {
            return array[randomIntRange(0, array.length - 1)];
        }
        return null;
    }
    public static function randomElements<T>(array :Array<T>, count :Int) :Array<T> {
        var rets = [];
        var num = Util.intMin(count, array.length);
        for (n in 0...num) {
            var startIndex = randomIntRange(0, array.length - 1);
            for (i in 0...array.length) {
                var index = (startIndex + i) % array.length;
                var item = array[index];
                if (rets.indexOf(item) == -1) {
                    rets.push(item);
                    break;
                }
            }
        }
        return rets;
    }
}
