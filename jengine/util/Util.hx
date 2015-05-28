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

    public static inline function intMax(a :Int, b :Int) :Int {
        return a > b ? a : b;
    }
    public static inline function intMin(a :Int, b :Int) :Int {
        return a < b ? a : b;
    }

    public static function format(num :Int) :String {
        if (num < 0) {
            return '-' + format(-num);
        }
        if (num == 0) {
            return '0';
        }

        var str = '';
        while (num > 0) {
            var seg :String = new String(cast num % 1000);
            num = Math.floor(num / 1000);
            if (num > 0) {
                while (seg.length < 3) {
                    seg = '0' + seg;
                }
                seg = ',' + seg;
            }
            str = seg + str;
        }
        return str;
    }

    public static function formatFloat(num :Float, digits :Int = 2) :String {
        if (digits <= 0) {
            return format(Math.round(num));
        }
        var mul = Math.floor(Math.pow(10, digits));
        var int = Math.round(num * mul);
        var hi = format(Math.floor(int / mul));
        if (int % mul == 0) {
            return hi;
        }
        var lo = new String(cast int % mul);
        while (lo.length < digits) {
            lo = '0' + lo;
        }
        while (lo.length > 1 && lo.charAt(lo.length - 1) == '0') {
            lo = lo.substring(0, lo.length - 1);
        }
        return hi + '.' + lo;
    }

    public static function shortFormat(num :Int, digits :Int = 2) :String {
        var suffixes = ['', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'Nn', 'Dc'];
        var k :Float = num;
        var i = 0;
        while (k >= 1000 && i < suffixes.length) {
            k /= 1000;
            i++;
        }
        if (i == 0) {
            return new String(cast num);
        }
        return formatFloat(k, digits) + suffixes[i];
    }

    public static function contains<T>(array :Array<T>, item :T) :Bool {
        return array.indexOf(item) != -1;
    }
}
