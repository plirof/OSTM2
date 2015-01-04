package jengine;

import jengine.util.Util;

class Color {
    public var r :Int;
    public var g :Int;
    public var b :Int;

    public function new(r :Int, g :Int, b :Int) {
        this.r = clamp(r);
        this.g = clamp(g);
        this.b = clamp(b);
    }

    static inline function clamp(c :Int) :Int {
        return Util.clampInt(c, 0x00, 0xff);
    }

    static function hexChar(i :Int) :String {
        if (i < 10) {
            return '' + i;
        }
        switch (i) {
            case 10: return 'a';
            case 11: return 'b';
            case 12: return 'c';
            case 13: return 'd';
            case 14: return 'e';
            case 15: return 'f';
        }
        return '';
    }

    static function intToHex(c :Int) :String {
        if (c < 0) { return '00'; }
        if (c > 255) { return 'ff'; }
        return hexChar(Math.floor(c / 16)) + hexChar(c % 16);
    }

    public function asHtml() :String {
        return '#' + intToHex(r) + intToHex(g) + intToHex(b);
    }

    public function multiply(s :Float) :Color {
        return new Color(Math.round(s * r), Math.round(s * g), Math.round(s * b));
    }

    public function mix(other :Color, amount :Float = 0.5) :Color {
        var s = 1 - amount;
        return new Color(
            Math.round(amount * other.r + s * r),
            Math.round(amount * other.g + s * g),
            Math.round(amount * other.b + s * b)
        );
    }
}
