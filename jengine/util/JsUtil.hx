package jengine.util;

import js.Browser;
import js.html.Element;

class JsUtil {
    public static function createSpan(text :String, parent :Element) :Element {
        var elem = Browser.document.createSpanElement();
        elem.innerText = text;
        if (parent != null) {
            parent.appendChild(elem);
        }
        return elem;
    }
}
