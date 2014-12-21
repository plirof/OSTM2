package ostm;

import js.*;

import jengine.*;

class MouseManager {
	public static var mousePos(default, null) :Vec2;

	public static function init() {
		Browser.document.onmousemove = onMouseMove;
		Browser.document.ondrag = onMouseMove;
		mousePos = new Vec2();
	}

	static function onMouseMove(event :Dynamic) :Void {
		mousePos = new Vec2(event.clientX, event.clientY);
	}
}

