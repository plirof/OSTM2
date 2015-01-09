package ostm.map;

class StaticRandom {
    var seed :Int = 0;

    static var kRandMax :Int = 19001;
    static var kRandBoolPrecision :Int = 1000;

    public function setSeed(s :Int) :Void {
        seed = s;
    }

    public function randomInt(?max :Int) :Int {
        if (max == null) {
            max = kRandMax;
        }
        seed++;
        var s = (Math.sin(seed) + 1) / 2;
        return Math.floor(s * kRandMax) % max;
    }
    public function randomFloat() :Float {
        return randomInt() / kRandMax;
    }
    public function randomBool(prob :Float = 0.5) :Bool {
        return randomInt(kRandBoolPrecision) < prob * kRandBoolPrecision;
    }
    public function randomElement<T>(array :Array<T>) :T {
        if (array.length > 0) {
            return array[randomInt(array.length)];
        }
        return null;
    }
}
