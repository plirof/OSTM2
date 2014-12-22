package ostm;

import jengine.*;
import jengine.util.*;

import js.*;
import js.html.*;

class Draggable extends Component {
	var _clickPos :Vec2;
	var _origPos :Vec2;

	public override function init() {
		var elem :Element = getComponent(HtmlRenderer).getElement();
		elem.draggable = true;
		elem.ondragenter = onDragEnter;
		elem.ondrag = onDrag;
	}

	function onDragEnter(event :Dynamic) :Void {
		_clickPos = MouseManager.mousePos;
		_origPos = getTransform().pos;
	}

	function onDrag(event :Dynamic) :Void {
        if (_clickPos != null) {
    		getTransform().pos = MouseManager.mousePos - _clickPos + _origPos;
        }
	}
}
