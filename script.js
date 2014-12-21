(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.remove = function(a,obj) {
	var i = HxOverrides.indexOf(a,obj,0);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
var haxe = {};
haxe.Timer = function() { };
haxe.Timer.__name__ = true;
haxe.Timer.stamp = function() {
	return new Date().getTime() / 1000;
};
var jengine = {};
jengine.Component = function() {
	this._entity = null;
};
jengine.Component.__name__ = true;
jengine.Component.prototype = {
	init: function() {
	}
	,deinit: function() {
	}
	,update: function() {
	}
	,draw: function() {
	}
	,getComponent: function(c) {
		return this._entity.getComponent(c);
	}
	,getTransform: function() {
		return this._entity.getComponent(jengine.Transform);
	}
	,__class__: jengine.Component
};
jengine.Entity = function(components) {
	this._components = components;
	if(this.getComponent(jengine.Transform) == null) this._components.push(new jengine.Transform());
	var _g = 0;
	var _g1 = this._components;
	while(_g < _g1.length) {
		var cmp = _g1[_g];
		++_g;
		cmp._entity = this;
		cmp.init();
	}
};
jengine.Entity.__name__ = true;
jengine.Entity.prototype = {
	forAllComponents: function(f) {
		var _g = 0;
		var _g1 = this._components;
		while(_g < _g1.length) {
			var cmp = _g1[_g];
			++_g;
			f(cmp);
		}
	}
	,getComponent: function(c) {
		var _g = 0;
		var _g1 = this._components;
		while(_g < _g1.length) {
			var cmp = _g1[_g];
			++_g;
			if(js.Boot.__instanceof(cmp,c)) return cmp;
		}
		return null;
	}
	,__class__: jengine.Entity
};
jengine.EntitySystem = function() {
	this._entities = new Array();
};
jengine.EntitySystem.__name__ = true;
jengine.EntitySystem.prototype = {
	addEntity: function(ent) {
		this._entities.push(ent);
		ent._system = this;
	}
	,update: function() {
		var _g = 0;
		var _g1 = this._entities;
		while(_g < _g1.length) {
			var ent = _g1[_g];
			++_g;
			ent.forAllComponents(function(cmp) {
				cmp.update();
			});
		}
		var _g2 = 0;
		var _g11 = this._entities;
		while(_g2 < _g11.length) {
			var ent1 = _g11[_g2];
			++_g2;
			ent1.forAllComponents(function(cmp1) {
				cmp1.draw();
			});
		}
	}
	,removeEntity: function(ent) {
		var _g = 0;
		var _g1 = this._entities;
		while(_g < _g1.length) {
			var e = _g1[_g];
			++_g;
			if(e == ent) {
				e.forAllComponents(function(cmp) {
					cmp.deinit();
				});
				e._system = null;
				HxOverrides.remove(this._entities,e);
				return;
			}
		}
		jengine.util.Log.log("Failed to find entity " + Std.string(ent));
	}
	,removeAll: function() {
		while(this._entities.length > 0) this.removeEntity(this._entities[0]);
	}
	,__class__: jengine.EntitySystem
};
jengine.HtmlRenderer = function(size) {
	jengine.Component.call(this);
	if(size == null) size = jengine._Vec2.Vec2_Impl_._new(50,50);
	this._size = size;
};
jengine.HtmlRenderer.__name__ = true;
jengine.HtmlRenderer.__super__ = jengine.Component;
jengine.HtmlRenderer.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		var doc = window.document;
		this._elem = doc.createElement("span");
		doc.body.appendChild(this._elem);
		this._elem.style.position = "absolute";
	}
	,deinit: function() {
		jengine.util.Log.log("poo");
		this._elem.parentElement.removeChild(this._elem);
	}
	,draw: function() {
		var trans = this._entity.getComponent(jengine.Transform);
		this._elem.style.left = trans.pos.x;
		this._elem.style.top = trans.pos.y;
		this._elem.style.width = this._size.x;
		this._elem.style.height = this._size.y;
		this._elem.style.background = "#ff0000";
	}
	,getElement: function() {
		return this._elem;
	}
	,__class__: jengine.HtmlRenderer
});
jengine.JEngineMain = function(entityList) {
	this._updateInterval = 16;
	this._entitySystem = new jengine.EntitySystem();
	var _g = 0;
	while(_g < entityList.length) {
		var ent = entityList[_g];
		++_g;
		this._entitySystem.addEntity(ent);
	}
	jengine.Time.init();
	window.setInterval($bind(this,this.update),this._updateInterval);
};
jengine.JEngineMain.__name__ = true;
jengine.JEngineMain.prototype = {
	update: function() {
		jengine.Time.update();
		this._entitySystem.update();
	}
	,__class__: jengine.JEngineMain
};
jengine.Time = function() { };
jengine.Time.__name__ = true;
jengine.Time.init = function() {
	jengine.Time.dt = 0;
	jengine.Time.elapsed = 0;
	jengine.Time._startTime = haxe.Timer.stamp();
	jengine.Time._lastTime = jengine.Time._startTime;
};
jengine.Time.update = function() {
	var curTime = haxe.Timer.stamp();
	jengine.Time.dt = curTime - jengine.Time._lastTime;
	jengine.Time.elapsed = curTime - jengine.Time._startTime;
	jengine.Time._lastTime = curTime;
};
jengine.Transform = function(pos_) {
	jengine.Component.call(this);
	if(pos_ != null) this.pos = pos_; else this.pos = jengine._Vec2.Vec2_Impl_._new();
};
jengine.Transform.__name__ = true;
jengine.Transform.__super__ = jengine.Component;
jengine.Transform.prototype = $extend(jengine.Component.prototype,{
	__class__: jengine.Transform
});
jengine._Vec2 = {};
jengine._Vec2.Vec2_Impl = function(x_,y_) {
	if(y_ == null) y_ = 0;
	if(x_ == null) x_ = 0;
	this.x = x_;
	this.y = y_;
};
jengine._Vec2.Vec2_Impl.__name__ = true;
jengine._Vec2.Vec2_Impl.prototype = {
	__class__: jengine._Vec2.Vec2_Impl
};
jengine._Vec2.Vec2_Impl_ = function() { };
jengine._Vec2.Vec2_Impl_.__name__ = true;
jengine._Vec2.Vec2_Impl_._new = function(x_,y_) {
	if(y_ == null) y_ = 0;
	if(x_ == null) x_ = 0;
	var this1;
	return new jengine._Vec2.Vec2_Impl(x_,y_);
	return this1;
};
jengine._Vec2.Vec2_Impl_.add = function(lhs,rhs) {
	return jengine._Vec2.Vec2_Impl_._new(lhs.x + rhs.x,lhs.y + rhs.y);
};
jengine._Vec2.Vec2_Impl_.sub = function(lhs,rhs) {
	return jengine._Vec2.Vec2_Impl_._new(lhs.x - rhs.x,lhs.y - rhs.y);
};
jengine._Vec2.Vec2_Impl_.scMult = function(lhs,rhs) {
	return jengine._Vec2.Vec2_Impl_._new(lhs.x * rhs,lhs.y * rhs);
};
jengine._Vec2.Vec2_Impl_.scDiv = function(lhs,rhs) {
	return jengine._Vec2.Vec2_Impl_._new(lhs.x / rhs,lhs.y / rhs);
};
jengine.util = {};
jengine.util.Log = function() { };
jengine.util.Log.__name__ = true;
jengine.util.Log.log = function(message) {
	console.log(message);
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = true;
js.Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else return o.__class__;
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) str2 += ", \n";
		str2 += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js.Boot.__interfLoop(js.Boot.getClass(o),cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
var ostm = {};
ostm.Draggable = function() {
	jengine.Component.call(this);
};
ostm.Draggable.__name__ = true;
ostm.Draggable.__super__ = jengine.Component;
ostm.Draggable.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		var elem = this._entity.getComponent(jengine.HtmlRenderer).getElement();
		jengine.util.Log.log("initing w/: " + Std.string(elem));
		elem.draggable = true;
		elem.ondragenter = $bind(this,this.onDragEnter);
		elem.ondrag = $bind(this,this.onDrag);
	}
	,onDragEnter: function(event) {
		this._clickPos = ostm.MouseManager.mousePos;
		this._origPos = this._entity.getComponent(jengine.Transform).pos;
	}
	,onDrag: function(event) {
		var lhs;
		var lhs1 = ostm.MouseManager.mousePos;
		var rhs = this._clickPos;
		lhs = jengine._Vec2.Vec2_Impl_._new(lhs1.x - rhs.x,lhs1.y - rhs.y);
		var rhs1 = this._origPos;
		this._entity.getComponent(jengine.Transform).pos = jengine._Vec2.Vec2_Impl_._new(lhs.x + rhs1.x,lhs.y + rhs1.y);
	}
	,__class__: ostm.Draggable
});
ostm.SineMover = function(v,p) {
	jengine.Component.call(this);
	this._v = v;
	this._p = p;
};
ostm.SineMover.__name__ = true;
ostm.SineMover.__super__ = jengine.Component;
ostm.SineMover.prototype = $extend(jengine.Component.prototype,{
	update: function() {
		this._entity.getComponent(jengine.Transform).pos.y += jengine.Time.dt * this._v * Math.sin(jengine.Time.elapsed * Math.PI * this._p);
	}
	,__class__: ostm.SineMover
});
ostm.GameMain = function() {
	var entityList = [new jengine.Entity([new ostm.SineMover(15,2.3),new jengine.HtmlRenderer(jengine._Vec2.Vec2_Impl_._new(20,20)),new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(320,20))]),new jengine.Entity([new jengine.HtmlRenderer(),new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(210,320)),new ostm.SineMover(45,1.2)])];
	ostm.MouseManager.init();
	window.document.getElementById("btn-add").onclick = $bind(this,this.addRandomSquare);
	window.document.getElementById("btn-clear").onclick = $bind(this,this.clearSquares);
	jengine.JEngineMain.call(this,entityList);
	this.addRandomSquare(null);
	this.addRandomSquare(null);
};
ostm.GameMain.__name__ = true;
ostm.GameMain.main = function() {
	new ostm.GameMain();
};
ostm.GameMain.randomRange = function(lo,hi) {
	return (hi - lo) * Math.random() + lo;
};
ostm.GameMain.__super__ = jengine.JEngineMain;
ostm.GameMain.prototype = $extend(jengine.JEngineMain.prototype,{
	addRandomSquare: function(arg) {
		var size = ostm.GameMain.randomRange(20,75);
		var pos = jengine._Vec2.Vec2_Impl_._new(ostm.GameMain.randomRange(50,550),ostm.GameMain.randomRange(50,550));
		this._entitySystem.addEntity(new jengine.Entity([new jengine.HtmlRenderer(jengine._Vec2.Vec2_Impl_._new(size,size)),new jengine.Transform(pos),new ostm.Draggable()]));
	}
	,clearSquares: function(arg) {
		this._entitySystem.removeAll();
	}
	,__class__: ostm.GameMain
});
ostm.MouseManager = function() { };
ostm.MouseManager.__name__ = true;
ostm.MouseManager.init = function() {
	window.document.onmousemove = ostm.MouseManager.onMouseMove;
	window.document.ondrag = ostm.MouseManager.onMouseMove;
	ostm.MouseManager.mousePos = jengine._Vec2.Vec2_Impl_._new();
};
ostm.MouseManager.onMouseMove = function(event) {
	ostm.MouseManager.mousePos = jengine._Vec2.Vec2_Impl_._new(event.clientX,event.clientY);
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i1) {
	return isNaN(i1);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
ostm.GameMain.main();
})();
