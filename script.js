(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
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
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var IMap = function() { };
IMap.__name__ = true;
IMap.prototype = {
	__class__: IMap
};
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.getProperty = function(o,field) {
	var tmp;
	if(o == null) return null; else if(o.__properties__ && (tmp = o.__properties__["get_" + field])) return o[tmp](); else return o[field];
};
Reflect.compare = function(a,b) {
	if(a == b) return 0; else if(a > b) return 1; else return -1;
};
Reflect.isEnumValue = function(v) {
	return v != null && v.__enum__ != null;
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
var Type = function() { };
Type.__name__ = true;
Type.allEnums = function(e) {
	return e.__empty_constructs__;
};
var haxe = {};
haxe.Timer = function() { };
haxe.Timer.__name__ = true;
haxe.Timer.stamp = function() {
	return new Date().getTime() / 1000;
};
haxe.ds = {};
haxe.ds.BalancedTree = function() {
};
haxe.ds.BalancedTree.__name__ = true;
haxe.ds.BalancedTree.prototype = {
	set: function(key,value) {
		this.root = this.setLoop(key,value,this.root);
	}
	,get: function(key) {
		var node = this.root;
		while(node != null) {
			var c = this.compare(key,node.key);
			if(c == 0) return node.value;
			if(c < 0) node = node.left; else node = node.right;
		}
		return null;
	}
	,remove: function(key) {
		try {
			this.root = this.removeLoop(key,this.root);
			return true;
		} catch( e ) {
			if( js.Boot.__instanceof(e,String) ) {
				return false;
			} else throw(e);
		}
	}
	,iterator: function() {
		var ret = [];
		this.iteratorLoop(this.root,ret);
		return HxOverrides.iter(ret);
	}
	,keys: function() {
		var ret = [];
		this.keysLoop(this.root,ret);
		return HxOverrides.iter(ret);
	}
	,setLoop: function(k,v,node) {
		if(node == null) return new haxe.ds.TreeNode(null,k,v,null);
		var c = this.compare(k,node.key);
		if(c == 0) return new haxe.ds.TreeNode(node.left,k,v,node.right,node == null?0:node._height); else if(c < 0) {
			var nl = this.setLoop(k,v,node.left);
			return this.balance(nl,node.key,node.value,node.right);
		} else {
			var nr = this.setLoop(k,v,node.right);
			return this.balance(node.left,node.key,node.value,nr);
		}
	}
	,removeLoop: function(k,node) {
		if(node == null) throw "Not_found";
		var c = this.compare(k,node.key);
		if(c == 0) return this.merge(node.left,node.right); else if(c < 0) return this.balance(this.removeLoop(k,node.left),node.key,node.value,node.right); else return this.balance(node.left,node.key,node.value,this.removeLoop(k,node.right));
	}
	,iteratorLoop: function(node,acc) {
		if(node != null) {
			this.iteratorLoop(node.left,acc);
			acc.push(node.value);
			this.iteratorLoop(node.right,acc);
		}
	}
	,keysLoop: function(node,acc) {
		if(node != null) {
			this.keysLoop(node.left,acc);
			acc.push(node.key);
			this.keysLoop(node.right,acc);
		}
	}
	,merge: function(t1,t2) {
		if(t1 == null) return t2;
		if(t2 == null) return t1;
		var t = this.minBinding(t2);
		return this.balance(t1,t.key,t.value,this.removeMinBinding(t2));
	}
	,minBinding: function(t) {
		if(t == null) throw "Not_found"; else if(t.left == null) return t; else return this.minBinding(t.left);
	}
	,removeMinBinding: function(t) {
		if(t.left == null) return t.right; else return this.balance(this.removeMinBinding(t.left),t.key,t.value,t.right);
	}
	,balance: function(l,k,v,r) {
		var hl;
		if(l == null) hl = 0; else hl = l._height;
		var hr;
		if(r == null) hr = 0; else hr = r._height;
		if(hl > hr + 2) {
			if((function($this) {
				var $r;
				var _this = l.left;
				$r = _this == null?0:_this._height;
				return $r;
			}(this)) >= (function($this) {
				var $r;
				var _this1 = l.right;
				$r = _this1 == null?0:_this1._height;
				return $r;
			}(this))) return new haxe.ds.TreeNode(l.left,l.key,l.value,new haxe.ds.TreeNode(l.right,k,v,r)); else return new haxe.ds.TreeNode(new haxe.ds.TreeNode(l.left,l.key,l.value,l.right.left),l.right.key,l.right.value,new haxe.ds.TreeNode(l.right.right,k,v,r));
		} else if(hr > hl + 2) {
			if((function($this) {
				var $r;
				var _this2 = r.right;
				$r = _this2 == null?0:_this2._height;
				return $r;
			}(this)) > (function($this) {
				var $r;
				var _this3 = r.left;
				$r = _this3 == null?0:_this3._height;
				return $r;
			}(this))) return new haxe.ds.TreeNode(new haxe.ds.TreeNode(l,k,v,r.left),r.key,r.value,r.right); else return new haxe.ds.TreeNode(new haxe.ds.TreeNode(l,k,v,r.left.left),r.left.key,r.left.value,new haxe.ds.TreeNode(r.left.right,r.key,r.value,r.right));
		} else return new haxe.ds.TreeNode(l,k,v,r,(hl > hr?hl:hr) + 1);
	}
	,compare: function(k1,k2) {
		return Reflect.compare(k1,k2);
	}
	,__class__: haxe.ds.BalancedTree
};
haxe.ds.TreeNode = function(l,k,v,r,h) {
	if(h == null) h = -1;
	this.left = l;
	this.key = k;
	this.value = v;
	this.right = r;
	if(h == -1) this._height = ((function($this) {
		var $r;
		var _this = $this.left;
		$r = _this == null?0:_this._height;
		return $r;
	}(this)) > (function($this) {
		var $r;
		var _this1 = $this.right;
		$r = _this1 == null?0:_this1._height;
		return $r;
	}(this))?(function($this) {
		var $r;
		var _this2 = $this.left;
		$r = _this2 == null?0:_this2._height;
		return $r;
	}(this)):(function($this) {
		var $r;
		var _this3 = $this.right;
		$r = _this3 == null?0:_this3._height;
		return $r;
	}(this))) + 1; else this._height = h;
};
haxe.ds.TreeNode.__name__ = true;
haxe.ds.TreeNode.prototype = {
	__class__: haxe.ds.TreeNode
};
haxe.ds.EnumValueMap = function() {
	haxe.ds.BalancedTree.call(this);
};
haxe.ds.EnumValueMap.__name__ = true;
haxe.ds.EnumValueMap.__interfaces__ = [IMap];
haxe.ds.EnumValueMap.__super__ = haxe.ds.BalancedTree;
haxe.ds.EnumValueMap.prototype = $extend(haxe.ds.BalancedTree.prototype,{
	compare: function(k1,k2) {
		var d = k1[1] - k2[1];
		if(d != 0) return d;
		var p1 = k1.slice(2);
		var p2 = k2.slice(2);
		if(p1.length == 0 && p2.length == 0) return 0;
		return this.compareArgs(p1,p2);
	}
	,compareArgs: function(a1,a2) {
		var ld = a1.length - a2.length;
		if(ld != 0) return ld;
		var _g1 = 0;
		var _g = a1.length;
		while(_g1 < _g) {
			var i = _g1++;
			var d = this.compareArg(a1[i],a2[i]);
			if(d != 0) return d;
		}
		return 0;
	}
	,compareArg: function(v1,v2) {
		if(Reflect.isEnumValue(v1) && Reflect.isEnumValue(v2)) return this.compare(v1,v2); else if((v1 instanceof Array) && v1.__enum__ == null && ((v2 instanceof Array) && v2.__enum__ == null)) return this.compareArgs(v1,v2); else return Reflect.compare(v1,v2);
	}
	,__class__: haxe.ds.EnumValueMap
});
haxe.ds.IntMap = function() {
	this.h = { };
};
haxe.ds.IntMap.__name__ = true;
haxe.ds.IntMap.__interfaces__ = [IMap];
haxe.ds.IntMap.prototype = {
	set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i];
		}};
	}
	,__class__: haxe.ds.IntMap
};
haxe.ds.ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
haxe.ds.ObjectMap.__name__ = true;
haxe.ds.ObjectMap.__interfaces__ = [IMap];
haxe.ds.ObjectMap.prototype = {
	set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe.ds.ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,get: function(key) {
		return this.h[key.__id__];
	}
	,remove: function(key) {
		var id = key.__id__;
		if(this.h.__keys__[id] == null) return false;
		delete(this.h[id]);
		delete(this.h.__keys__[id]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h.__keys__ ) {
		if(this.h.hasOwnProperty(key)) a.push(this.h.__keys__[key]);
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe.ds.ObjectMap
};
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = true;
haxe.ds.StringMap.__interfaces__ = [IMap];
haxe.ds.StringMap.prototype = {
	set: function(key,value) {
		this.h["$" + key] = value;
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,remove: function(key) {
		key = "$" + key;
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,__class__: haxe.ds.StringMap
};
var jengine = {};
jengine.Color = function(r,g,b) {
	this.r = Math.round(jengine.util.Util.clamp(r,0,255));
	this.g = Math.round(jengine.util.Util.clamp(g,0,255));
	this.b = Math.round(jengine.util.Util.clamp(b,0,255));
};
jengine.Color.__name__ = true;
jengine.Color.clamp = function(c) {
	return Math.round(jengine.util.Util.clamp(c,0,255));
};
jengine.Color.hexChar = function(i) {
	if(i < 10) return "" + i;
	switch(i) {
	case 10:
		return "a";
	case 11:
		return "b";
	case 12:
		return "c";
	case 13:
		return "d";
	case 14:
		return "e";
	case 15:
		return "f";
	}
	return "";
};
jengine.Color.intToHex = function(c) {
	if(c < 0) return "00";
	if(c > 255) return "ff";
	return jengine.Color.hexChar(Math.floor(c / 16)) + jengine.Color.hexChar(c % 16);
};
jengine.Color.prototype = {
	asHtml: function() {
		return "#" + jengine.Color.intToHex(this.r) + jengine.Color.intToHex(this.g) + jengine.Color.intToHex(this.b);
	}
	,multiply: function(s) {
		return new jengine.Color(Math.round(s * this.r),Math.round(s * this.g),Math.round(s * this.b));
	}
	,mix: function(other,amount) {
		if(amount == null) amount = 0.5;
		var s = 1 - amount;
		return new jengine.Color(Math.round(amount * other.r + s * this.r),Math.round(amount * other.g + s * this.g),Math.round(amount * other.b + s * this.b));
	}
	,__class__: jengine.Color
};
jengine.Component = function() {
	this.entity = null;
};
jengine.Component.__name__ = true;
jengine.Component.prototype = {
	init: function() {
	}
	,deinit: function() {
	}
	,start: function() {
	}
	,postStart: function() {
	}
	,update: function() {
	}
	,draw: function() {
	}
	,handleMessage: function(message,arg) {
	}
	,getComponent: function(c) {
		return this.entity.getComponent(c);
	}
	,getTransform: function() {
		return this.entity.getComponent(jengine.Transform);
	}
	,__class__: jengine.Component
};
jengine.Entity = function(components) {
	this._hasStarted = false;
	this._components = components;
	var _g = 0;
	var _g1 = this._components;
	while(_g < _g1.length) {
		var cmp = _g1[_g];
		++_g;
		cmp.entity = this;
		cmp.init();
	}
};
jengine.Entity.__name__ = true;
jengine.Entity.prototype = {
	addComponent: function(cmp) {
		this._components.push(cmp);
		cmp.entity = this;
		cmp.init();
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
	,getTransform: function() {
		return this.getComponent(jengine.Transform);
	}
	,getSystem: function() {
		return this._system;
	}
	,__class__: jengine.Entity
};
jengine.EntitySystem = function() {
	this._entitiesToRemove = [];
	this._entitiesToAdd = [];
	this._entities = [];
};
jengine.EntitySystem.__name__ = true;
jengine.EntitySystem.prototype = {
	addEntity: function(ent) {
		this._entitiesToAdd.push(ent);
		ent._system = this;
	}
	,removeEntity: function(ent) {
		this._entitiesToRemove.push(ent);
	}
	,update: function() {
		var _g = 0;
		var _g1 = this._entities;
		while(_g < _g1.length) {
			var ent = _g1[_g];
			++_g;
			if(!ent._hasStarted) {
				var _g2 = 0;
				var _g3 = ent._components;
				while(_g2 < _g3.length) {
					var cmp = _g3[_g2];
					++_g2;
					cmp.start();
				}
			}
		}
		var _g4 = 0;
		var _g11 = this._entities;
		while(_g4 < _g11.length) {
			var ent1 = _g11[_g4];
			++_g4;
			if(!ent1._hasStarted) {
				var _g21 = 0;
				var _g31 = ent1._components;
				while(_g21 < _g31.length) {
					var cmp1 = _g31[_g21];
					++_g21;
					cmp1.postStart();
				}
				ent1._hasStarted = true;
			}
		}
		var _g5 = 0;
		var _g12 = this._entities;
		while(_g5 < _g12.length) {
			var ent2 = _g12[_g5];
			++_g5;
			var _g22 = 0;
			var _g32 = ent2._components;
			while(_g22 < _g32.length) {
				var cmp2 = _g32[_g22];
				++_g22;
				cmp2.update();
			}
		}
		var _g6 = 0;
		var _g13 = this._entities;
		while(_g6 < _g13.length) {
			var ent3 = _g13[_g6];
			++_g6;
			var _g23 = 0;
			var _g33 = ent3._components;
			while(_g23 < _g33.length) {
				var cmp3 = _g33[_g23];
				++_g23;
				cmp3.draw();
			}
		}
		var _g7 = 0;
		var _g14 = this._entitiesToAdd;
		while(_g7 < _g14.length) {
			var ent4 = _g14[_g7];
			++_g7;
			this._entities.push(ent4);
		}
		var _g8 = 0;
		var _g15 = this._entitiesToRemove;
		while(_g8 < _g15.length) {
			var ent5 = _g15[_g8];
			++_g8;
			var i = HxOverrides.indexOf(this._entities,ent5,0);
			if(i >= 0) {
				var _g24 = 0;
				var _g34 = ent5._components;
				while(_g24 < _g34.length) {
					var cmp4 = _g34[_g24];
					++_g24;
					cmp4.deinit();
				}
				ent5._system = null;
				HxOverrides.remove(this._entities,ent5);
			}
		}
		this._entitiesToAdd = [];
		this._entitiesToRemove = [];
	}
	,__class__: jengine.EntitySystem
};
jengine.HtmlRenderer = function(options) {
	this._noPos = false;
	this.floating = false;
	jengine.Component.call(this);
	this._options = options;
	var size = this._options.size;
	this.size = size;
};
jengine.HtmlRenderer.__name__ = true;
jengine.HtmlRenderer.styleElement = function(elem,style) {
	if(style != null) {
		var $it0 = style.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			elem.style.setProperty(k,style.get(k),"");
		}
	}
};
jengine.HtmlRenderer.__super__ = jengine.Component;
jengine.HtmlRenderer.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		var parent;
		if(this._options.parent != null) parent = window.document.getElementById(this._options.parent); else parent = window.document.body;
		var _this = window.document;
		this._elem = _this.createElement("span");
		if(this._options.id != null) this._elem.id = this._options.id;
		if(this._options.className != null) this._elem.className = this._options.className;
		if(this._options.text != null) this._elem.innerText = this._options.text;
		this._elem.style.position = "absolute";
		jengine.HtmlRenderer.styleElement(this._elem,this._options.style);
		parent.appendChild(this._elem);
	}
	,start: function() {
		this._transform = this.entity.getComponent(jengine.Transform);
	}
	,deinit: function() {
		if(this._elem.parentElement != null) this._elem.parentElement.removeChild(this._elem);
	}
	,getPos: function() {
		if(this._transform == null) return null;
		var pos = this._transform.pos;
		if(this.floating) {
			var container = this._elem.parentElement;
			var scroll = jengine._Vec2.Vec2_Impl_._new(container.scrollLeft,container.scrollTop);
			pos = jengine._Vec2.Vec2_Impl_._new(pos.x + scroll.x,pos.y + scroll.y);
		}
		return pos;
	}
	,isDirty: function() {
		if(this._noPos) return false;
		var pos = this.getPos();
		if((pos == null?true:pos == null || true?false:pos.x == null.x && pos.y == null.y) && (function($this) {
			var $r;
			var lhs = $this.size;
			$r = lhs == null?true:lhs == null || true?false:lhs.x == null.x && lhs.y == null.y;
			return $r;
		}(this))) {
			this._noPos = true;
			return false;
		}
		return (function($this) {
			var $r;
			var lhs1 = $this._cachedPos;
			$r = !(lhs1 == null && pos == null?true:lhs1 == null || pos == null?false:lhs1.x == pos.x && lhs1.y == pos.y);
			return $r;
		}(this)) || (function($this) {
			var $r;
			var lhs2 = $this._cachedSize;
			var rhs = $this.size;
			$r = !(lhs2 == null && rhs == null?true:lhs2 == null || rhs == null?false:lhs2.x == rhs.x && lhs2.y == rhs.y);
			return $r;
		}(this));
	}
	,markClean: function() {
		this._cachedPos = this.getPos();
		this._cachedSize = this.size;
	}
	,draw: function() {
		if(this._options.textFunc != null) this._elem.innerText = this._options.textFunc();
		if(this.isDirty()) {
			this.markClean();
			var pos = this.getPos();
			if(!(pos == null?true:pos == null || true?false:pos.x == null.x && pos.y == null.y)) {
				this._elem.style.left = pos.x;
				this._elem.style.top = pos.y;
			}
			if((function($this) {
				var $r;
				var lhs = $this.size;
				$r = !(lhs == null?true:lhs == null || true?false:lhs.x == null.x && lhs.y == null.y);
				return $r;
			}(this))) {
				this._elem.style.width = this.size.x;
				this._elem.style.height = this.size.y;
			}
		}
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
jengine.Saveable = function() { };
jengine.Saveable.__name__ = true;
jengine.Saveable.prototype = {
	__class__: jengine.Saveable
};
jengine.SaveManager = function() {
	this._savingEnabled = true;
	this._saveTimer = 0;
	this._toSave = new haxe.ds.StringMap();
	this.saveId = "save-manager";
	jengine.Component.call(this);
};
jengine.SaveManager.__name__ = true;
jengine.SaveManager.__interfaces__ = [jengine.Saveable];
jengine.SaveManager.__super__ = jengine.Component;
jengine.SaveManager.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		var _g = this;
		jengine.SaveManager.instance = this;
		window.document.getElementById("save-button").onclick = function(event) {
			_g.save();
		};
		window.document.getElementById("save-clear-button").onclick = function(event1) {
			_g.clearSave();
		};
		this.addItem(this);
	}
	,postStart: function() {
		var storage = js.Browser.getLocalStorage();
		var save = storage.getItem("ostm2");
		if(save != null) this.loadString(save);
	}
	,update: function() {
		this._saveTimer += jengine.Time.dt;
		if(this._saveTimer > 15 && this._savingEnabled) this.save();
	}
	,save: function() {
		js.Browser.getLocalStorage().setItem("ostm2",this.saveString());
		this._saveTimer = 0;
		this._savingEnabled = true;
	}
	,clearSave: function() {
		js.Browser.getLocalStorage().removeItem("ostm2");
		this._savingEnabled = false;
	}
	,addItem: function(item) {
		if(item.saveId != null) {
			this._toSave.set(item.saveId,item);
			item;
		}
	}
	,addItems: function(items) {
		var _g = 0;
		while(_g < items.length) {
			var item = items[_g];
			++_g;
			this.addItem(item);
		}
	}
	,saveString: function() {
		var save = { };
		var $it0 = this._toSave.iterator();
		while( $it0.hasNext() ) {
			var item = $it0.next();
			Reflect.setField(save,item.saveId,item.serialize());
		}
		return JSON.stringify(save);
	}
	,loadString: function(saveString) {
		var save = JSON.parse(saveString);
		var keys = this._toSave.keys();
		var keyArray = [];
		this.deserialize(Reflect.getProperty(save,this.saveId));
		if(this.loadedVersion < 9) return;
		while( keys.hasNext() ) {
			var k = keys.next();
			if(k == this.saveId) continue;
			var data = Reflect.getProperty(save,k);
			var item = this._toSave.get(k);
			if(data != null) item.deserialize(data);
		}
	}
	,serialize: function() {
		return { saveVersion : 9};
	}
	,deserialize: function(data) {
		this.loadedVersion = data.saveVersion;
	}
	,__class__: jengine.SaveManager
});
jengine.Time = function() { };
jengine.Time.__name__ = true;
jengine.Time.__properties__ = {get_raw:"get_raw"}
jengine.Time.init = function() {
	jengine.Time.dt = 0;
	jengine.Time.elapsed = 0;
	jengine.Time._startTime = haxe.Timer.stamp();
	jengine.Time._lastTime = jengine.Time._startTime;
};
jengine.Time.update = function() {
	var curTime = haxe.Timer.stamp();
	jengine.Time.dt = (curTime - jengine.Time._lastTime) * jengine.Time.timeMultiplier;
	jengine.Time.elapsed = curTime - jengine.Time._startTime;
	jengine.Time._lastTime = curTime;
};
jengine.Time.get_raw = function() {
	return haxe.Timer.stamp();
};
jengine.Transform = function(pos_) {
	jengine.Component.call(this);
	if(pos_ == null?true:pos_ == null || true?false:pos_.x == null.x && pos_.y == null.y) pos_ = jengine._Vec2.Vec2_Impl_._new();
	this.pos = pos_;
};
jengine.Transform.__name__ = true;
jengine.Transform.__super__ = jengine.Component;
jengine.Transform.prototype = $extend(jengine.Component.prototype,{
	__class__: jengine.Transform
});
jengine._Vec2 = {};
jengine._Vec2.Vec2_Impl = function(x,y) {
	if(y == null) y = 0;
	if(x == null) x = 0;
	this.x = x;
	this.y = y;
};
jengine._Vec2.Vec2_Impl.__name__ = true;
jengine._Vec2.Vec2_Impl.prototype = {
	length2: function() {
		return this.x * this.x + this.y * this.y;
	}
	,length: function() {
		return Math.sqrt(this.length2());
	}
	,__class__: jengine._Vec2.Vec2_Impl
};
jengine._Vec2.Vec2_Impl_ = function() { };
jengine._Vec2.Vec2_Impl_.__name__ = true;
jengine._Vec2.Vec2_Impl_._new = function(x,y) {
	if(y == null) y = 0;
	if(x == null) x = 0;
	var this1;
	return new jengine._Vec2.Vec2_Impl(x,y);
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
jengine._Vec2.Vec2_Impl_.eq = function(lhs,rhs) {
	if(lhs == null && rhs == null) return true;
	if(lhs == null || rhs == null) return false;
	return lhs.x == rhs.x && lhs.y == rhs.y;
};
jengine._Vec2.Vec2_Impl_.neq = function(lhs,rhs) {
	return !(lhs == null && rhs == null?true:lhs == null || rhs == null?false:lhs.x == rhs.x && lhs.y == rhs.y);
};
jengine._Vec2.Vec2_Impl_.dist = function(this1,other) {
	return jengine._Vec2.Vec2_Impl_._new(other.x - this1.x,other.y - this1.y).length();
};
jengine._Vec2.Vec2_Impl_.max = function(lhs,rhs) {
	return jengine._Vec2.Vec2_Impl_._new(Math.max(lhs.x,rhs.x),Math.max(lhs.y,rhs.y));
};
jengine._Vec2.Vec2_Impl_.min = function(lhs,rhs) {
	return jengine._Vec2.Vec2_Impl_._new(Math.min(lhs.x,rhs.x),Math.min(lhs.y,rhs.y));
};
jengine._Vec2.Vec2_Impl_.unit = function(radians) {
	return jengine._Vec2.Vec2_Impl_._new(Math.cos(radians),Math.sin(radians));
};
jengine._Vec2.Vec2_Impl_.angle = function(this1) {
	return Math.atan2(this1.y,this1.x);
};
jengine._Vec2.Vec2_Impl_.rotate = function(this1,ang) {
	var lhs = jengine._Vec2.Vec2_Impl_.unit(ang + jengine._Vec2.Vec2_Impl_.angle(this1));
	var rhs = this1.length();
	return jengine._Vec2.Vec2_Impl_._new(lhs.x * rhs,lhs.y * rhs);
};
jengine.util = {};
jengine.util.JsUtil = function() { };
jengine.util.JsUtil.__name__ = true;
jengine.util.JsUtil.createSpan = function(text,parent) {
	var elem;
	var _this = window.document;
	elem = _this.createElement("span");
	elem.innerText = text;
	if(parent != null) parent.appendChild(elem);
	return elem;
};
jengine.util.Random = function() { };
jengine.util.Random.__name__ = true;
jengine.util.Random.randomBool = function(prob) {
	return Math.random() < prob;
};
jengine.util.Random.randomRange = function(lo,hi) {
	return (hi - lo) * Math.random() + lo;
};
jengine.util.Random.randomIntRange = function(lo,hi) {
	return Math.floor(jengine.util.Random.randomRange(lo,hi + 1));
};
jengine.util.Random.randomElement = function(array) {
	if(array.length > 0) return array[jengine.util.Random.randomIntRange(0,array.length - 1)];
	return null;
};
jengine.util.Random.randomElements = function(array,count) {
	var rets = [];
	var num = jengine.util.Util.intMin(count,array.length);
	var _g = 0;
	while(_g < num) {
		var n = _g++;
		var startIndex = jengine.util.Random.randomIntRange(0,array.length - 1);
		var _g2 = 0;
		var _g1 = array.length;
		while(_g2 < _g1) {
			var i = _g2++;
			var index = (startIndex + i) % array.length;
			var item = array[index];
			if(HxOverrides.indexOf(rets,item,0) == -1) {
				rets.push(item);
				break;
			}
		}
	}
	return rets;
};
jengine.util.Util = function() { };
jengine.util.Util.__name__ = true;
jengine.util.Util.clamp = function(t,lo,hi) {
	if(t > hi) return hi;
	if(t < lo) return lo;
	return t;
};
jengine.util.Util.clamp01 = function(t) {
	return jengine.util.Util.clamp(t,0,1);
};
jengine.util.Util.clampInt = function(t,lo,hi) {
	return Math.round(jengine.util.Util.clamp(t,lo,hi));
};
jengine.util.Util.lerp = function(t,lo,hi) {
	return jengine.util.Util.clamp(t,0,1) * (hi - lo) + lo;
};
jengine.util.Util.intMax = function(a,b) {
	if(a > b) return a; else return b;
};
jengine.util.Util.intMin = function(a,b) {
	if(a < b) return a; else return b;
};
jengine.util.Util.format = function(num) {
	if(num < 0) return "-" + jengine.util.Util.format(-num);
	if(num == 0) return "0";
	var str = "";
	while(num > 0) {
		var seg = new String(num % 1000);
		num = Math.floor(num / 1000);
		if(num > 0) {
			while(seg.length < 3) seg = "0" + seg;
			seg = "," + seg;
		}
		str = seg + str;
	}
	return str;
};
jengine.util.Util.formatFloat = function(num,digits) {
	if(digits == null) digits = 2;
	if(digits <= 0) return jengine.util.Util.format(Math.round(num));
	var mul = Math.floor(Math.pow(10,digits));
	var $int = Math.round(num * mul);
	var hi = jengine.util.Util.format(Math.floor($int / mul));
	if($int % mul == 0) return hi;
	var lo = new String($int % mul);
	while(lo.length < digits) lo = "0" + lo;
	while(lo.length > 1 && lo.charAt(lo.length - 1) == "0") lo = lo.substring(0,lo.length - 1);
	return hi + "." + lo;
};
jengine.util.Util.shortFormat = function(num,digits) {
	if(digits == null) digits = 2;
	var suffixes = ["","K","M","B","T","Qa","Qi","Sx","Sp","Oc","Nn","Dc"];
	var k = num;
	var i = 0;
	while(k >= 1000 && i < suffixes.length) {
		k /= 1000;
		i++;
	}
	if(i == 0) return new String(num);
	return jengine.util.Util.formatFloat(k,digits) + suffixes[i];
};
jengine.util.Util.contains = function(array,item) {
	return HxOverrides.indexOf(array,item,0) != -1;
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
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
};
js.Browser = function() { };
js.Browser.__name__ = true;
js.Browser.getLocalStorage = function() {
	try {
		var s = window.localStorage;
		s.getItem("");
		return s;
	} catch( e ) {
		return null;
	}
};
var ostm = {};
ostm.GameMain = function() {
	var entityList = [new jengine.Entity([new ostm.KeyboardManager(),new ostm.map.MapGenerator(),new ostm.battle.BattleManager(),new ostm.item.Inventory(),new jengine.SaveManager(),new ostm.skill.SkillTree(),new ostm.TownManager(),new ostm.TabManager(),new ostm.NotificationManager()])];
	ostm.MouseManager.init();
	jengine.JEngineMain.call(this,entityList);
};
ostm.GameMain.__name__ = true;
ostm.GameMain.main = function() {
	new ostm.GameMain();
};
ostm.GameMain.__super__ = jengine.JEngineMain;
ostm.GameMain.prototype = $extend(jengine.JEngineMain.prototype,{
	__class__: ostm.GameMain
});
ostm.GameNode = function(depth,height) {
	this._lineWidth = 5;
	this.lines = new Array();
	this.neighbors = new Array();
	jengine.Component.call(this);
	this.depth = depth;
	this.height = height;
};
ostm.GameNode.__name__ = true;
ostm.GameNode.__super__ = jengine.Component;
ostm.GameNode.prototype = $extend(jengine.Component.prototype,{
	start: function() {
		var renderer = this.entity.getComponent(jengine.HtmlRenderer);
		this.elem = renderer.getElement();
		this.elem.style.borderRadius = "18px";
		this.elem.style.zIndex = 1;
		this.elem.style.textAlign = "center";
		this.elem.style.color = "#ffffff";
		this.elem.onmouseover = $bind(this,this.onMouseOver);
		this.elem.onmouseout = $bind(this,this.onMouseOut);
		this.elem.onclick = $bind(this,this.onClick);
		var _g = 0;
		var _g1 = this.neighbors;
		while(_g < _g1.length) {
			var node = _g1[_g];
			++_g;
			if(!node.hasLineTo(this)) this.lines.push(this.addLine(node));
		}
	}
	,addNeighbor: function(node) {
		if(node == null) return;
		if(HxOverrides.indexOf(this.neighbors,node,0) == -1) this.neighbors.push(node);
		if(HxOverrides.indexOf(node.neighbors,this,0) == -1) node.neighbors.push(this);
	}
	,removeNeighbor: function(node) {
		HxOverrides.remove(this.neighbors,node);
		HxOverrides.remove(node.neighbors,this);
	}
	,hasLineTo: function(node) {
		var _g = 0;
		var _g1 = this.lines;
		while(_g < _g1.length) {
			var line = _g1[_g];
			++_g;
			if(line.node == node) return true;
		}
		return false;
	}
	,addLine: function(endPoint) {
		var renderer = this.entity.getComponent(jengine.HtmlRenderer);
		var size = renderer.size;
		var a;
		var lhs = this.entity.getComponent(jengine.Transform).pos;
		var rhs = jengine._Vec2.Vec2_Impl_._new(size.x / 2,size.y / 2);
		a = jengine._Vec2.Vec2_Impl_._new(lhs.x + rhs.x,lhs.y + rhs.y);
		var b;
		var lhs1 = endPoint.entity.getComponent(jengine.Transform).pos;
		var rhs1 = jengine._Vec2.Vec2_Impl_._new(size.x / 2,size.y / 2);
		b = jengine._Vec2.Vec2_Impl_._new(lhs1.x + rhs1.x,lhs1.y + rhs1.y);
		var elem = window.document.createElement("div");
		var pos;
		var lhs2 = jengine._Vec2.Vec2_Impl_._new(a.x + b.x,a.y + b.y);
		pos = jengine._Vec2.Vec2_Impl_._new(lhs2.x / 2,lhs2.y / 2);
		var delta = jengine._Vec2.Vec2_Impl_._new(b.x - a.x,b.y - a.y);
		var width = this._lineWidth;
		var height = delta.length();
		var angle = Math.atan2(delta.y,delta.x) * 180 / Math.PI + 90;
		elem.style.background = "black";
		elem.style.position = "absolute";
		elem.style.left = pos.x;
		elem.style.top = pos.y - height / 2;
		elem.style.width = width;
		elem.style.height = height;
		elem.style.transform = "rotate(" + angle + "deg)";
		renderer.getElement().parentElement.appendChild(elem);
		return { elem : elem, node : endPoint, offset : (function($this) {
			var $r;
			var lhs3;
			{
				var lhs4 = jengine._Vec2.Vec2_Impl_._new(delta.x + size.x,delta.y + size.y);
				lhs3 = jengine._Vec2.Vec2_Impl_._new(lhs4.x / 2,lhs4.y / 2);
			}
			var rhs2 = jengine._Vec2.Vec2_Impl_._new(0,height / 2);
			$r = jengine._Vec2.Vec2_Impl_._new(lhs3.x - rhs2.x,lhs3.y - rhs2.y);
			return $r;
		}(this))};
	}
	,getOffset: function() {
		var spacing = jengine._Vec2.Vec2_Impl_._new(60,60);
		return jengine._Vec2.Vec2_Impl_._new(this.height * spacing.x,this.depth * spacing.y);
	}
	,onMouseOver: function(event) {
	}
	,onMouseOut: function(event) {
	}
	,onClick: function(event) {
	}
	,__class__: ostm.GameNode
});
ostm.KeyboardManager = function() {
	this.isCtrlHeld = false;
	this.isShiftHeld = false;
	jengine.Component.call(this);
};
ostm.KeyboardManager.__name__ = true;
ostm.KeyboardManager.__super__ = jengine.Component;
ostm.KeyboardManager.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		ostm.KeyboardManager.instance = this;
	}
	,start: function() {
		var _g = this;
		window.document.onkeydown = function(event) {
			var key = event.keyCode;
			if(key >= 49 && key <= 57) ostm.battle.BattleManager.instance.keyDown(key);
			_g.updateKey(key,true);
		};
		window.document.onkeyup = function(event1) {
			var key1 = event1.keyCode;
			_g.updateKey(key1,false);
		};
	}
	,updateKey: function(key,pressed) {
	}
	,__class__: ostm.KeyboardManager
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
ostm.NotificationType = { __ename__ : true, __constructs__ : ["MapUpdate","StatUpdate"] };
ostm.NotificationType.MapUpdate = ["MapUpdate",0];
ostm.NotificationType.MapUpdate.toString = $estr;
ostm.NotificationType.MapUpdate.__enum__ = ostm.NotificationType;
ostm.NotificationType.StatUpdate = ["StatUpdate",1];
ostm.NotificationType.StatUpdate.toString = $estr;
ostm.NotificationType.StatUpdate.__enum__ = ostm.NotificationType;
ostm.NotificationType.__empty_constructs__ = [ostm.NotificationType.MapUpdate,ostm.NotificationType.StatUpdate];
ostm.NotificationReceiver = function() { };
ostm.NotificationReceiver.__name__ = true;
ostm.NotificationReceiver.prototype = {
	__class__: ostm.NotificationReceiver
};
ostm.NotificationManager = function() {
	this._pendingNotifications = [];
	this._registeredObjects = new haxe.ds.EnumValueMap();
	jengine.Component.call(this);
};
ostm.NotificationManager.__name__ = true;
ostm.NotificationManager.__super__ = jengine.Component;
ostm.NotificationManager.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		ostm.NotificationManager.instance = this;
	}
	,update: function() {
		var _g = 0;
		var _g1 = this._pendingNotifications;
		while(_g < _g1.length) {
			var notif = _g1[_g];
			++_g;
			var toFire = this._registeredObjects.get(notif);
			if(toFire != null) {
				var _g2 = 0;
				var _g3 = this._registeredObjects.get(notif);
				while(_g2 < _g3.length) {
					var obj = _g3[_g2];
					++_g2;
					obj.receivedNotification(notif);
				}
			}
		}
		this._pendingNotifications = [];
	}
	,register: function(receiver,notif) {
		if(this._registeredObjects.get(notif) == null) {
			var v = [];
			this._registeredObjects.set(notif,v);
			v;
		}
		this._registeredObjects.get(notif).push(receiver);
	}
	,queueNotification: function(notif) {
		if(HxOverrides.indexOf(this._pendingNotifications,notif,0) == -1) this._pendingNotifications.push(notif);
	}
	,__class__: ostm.NotificationManager
});
ostm.ProgressBar = function(func,style) {
	jengine.Component.call(this);
	this._func = func;
	this._style = style;
};
ostm.ProgressBar.__name__ = true;
ostm.ProgressBar.__super__ = jengine.Component;
ostm.ProgressBar.prototype = $extend(jengine.Component.prototype,{
	start: function() {
		var renderer = this.entity.getComponent(jengine.HtmlRenderer);
		if(renderer != null) {
			var _this = window.document;
			this._elem = _this.createElement("span");
			this._elem.className = "progress-bar";
			this._elem.style.position = "absolute";
			this._elem.style.height = "100%";
			jengine.HtmlRenderer.styleElement(this._elem,this._style);
			renderer.getElement().appendChild(this._elem);
		}
	}
	,update: function() {
		this._elem.style.width = 100 * jengine.util.Util.clamp01(this._func()) + "%";
	}
	,setFunction: function(f) {
		this._func = f;
	}
	,getElement: function() {
		return this._elem;
	}
	,__class__: ostm.ProgressBar
});
ostm.TabManager = function() {
	this._shouldRefresh = true;
	this._enabled = ["main-screen","map-screen"];
	this._tabs = [{ id : "stat-screen", buttonName : "Stats", column : 1},{ id : "equip-screen", buttonName : "Equipment", column : 1},{ id : "main-screen", buttonName : null, column : 2},{ id : "inventory-screen", buttonName : "Inventory", column : 2},{ id : "map-screen", buttonName : "Map", column : 3},{ id : "skill-screen", buttonName : "Skills", column : 3}];
	this.saveId = "tab-manager";
	jengine.Component.call(this);
};
ostm.TabManager.__name__ = true;
ostm.TabManager.__interfaces__ = [jengine.Saveable];
ostm.TabManager.__super__ = jengine.Component;
ostm.TabManager.prototype = $extend(jengine.Component.prototype,{
	start: function() {
		var _g2 = this;
		jengine.SaveManager.instance.addItem(this);
		var header = window.document.getElementById("header-tab-container");
		var _g = 0;
		var _g1 = this._tabs;
		while(_g < _g1.length) {
			var tab = [_g1[_g]];
			++_g;
			if(tab[0].buttonName != null) {
				var button;
				var _this = window.document;
				button = _this.createElement("button");
				button.innerText = tab[0].buttonName;
				button.onclick = (function(tab) {
					return function(event) {
						_g2.toggleTabEnabled(tab[0].id);
					};
				})(tab);
				header.appendChild(button);
			}
		}
	}
	,update: function() {
		if(this._shouldRefresh) {
			this._shouldRefresh = false;
			var columns = new haxe.ds.IntMap();
			var _g = 0;
			var _g1 = this._tabs;
			while(_g < _g1.length) {
				var tab = _g1[_g];
				++_g;
				var elem = window.document.getElementById(tab.id);
				if(HxOverrides.indexOf(this._enabled,tab.id,0) == -1) elem.style.display = "none"; else {
					elem.style.display = "";
					if(columns.get(tab.column) == null) {
						var v = [];
						columns.set(tab.column,v);
						v;
					}
					columns.get(tab.column).push(elem);
				}
			}
			var numVisibleColumns = 0;
			var $it0 = columns.iterator();
			while( $it0.hasNext() ) {
				var x = $it0.next();
				numVisibleColumns++;
			}
			var columnWidth = 100.0 / numVisibleColumns;
			var columnLeft = 0.0;
			var _g11 = 1;
			var _g2 = 4;
			while(_g11 < _g2) {
				var i = _g11++;
				var columnElem = window.document.getElementById("column-" + i);
				if(columns.get(i) == null) columnElem.style.display = "none"; else {
					columnElem.style.display = "";
					columnElem.style.width = columnWidth + "%";
					columnElem.style.left = columnLeft + "%";
					columnLeft += columnWidth;
				}
			}
			var $it1 = columns.iterator();
			while( $it1.hasNext() ) {
				var tabElems = $it1.next();
				var numVisibleRows = tabElems.length;
				var rowHeight = 100.0 / numVisibleRows;
				var rowTop = 0.0;
				var _g3 = 0;
				while(_g3 < tabElems.length) {
					var elem1 = tabElems[_g3];
					++_g3;
					elem1.style.height = rowHeight + "%";
					elem1.style.top = rowTop + "%";
					rowTop += rowHeight;
				}
			}
		}
	}
	,getTabData: function(id) {
		var _g = 0;
		var _g1 = this._tabs;
		while(_g < _g1.length) {
			var tab = _g1[_g];
			++_g;
			if(tab.id == id) return tab;
		}
		return null;
	}
	,toggleTabEnabled: function(tabId) {
		if(HxOverrides.indexOf(this._enabled,tabId,0) == -1) this._enabled.push(tabId); else HxOverrides.remove(this._enabled,tabId);
		this._shouldRefresh = true;
	}
	,serialize: function() {
		return { enabled : this._enabled};
	}
	,deserialize: function(data) {
		this._enabled = data.enabled;
		this._shouldRefresh = true;
	}
	,__class__: ostm.TabManager
});
ostm.TownManager = function() {
	this.shouldWarp = false;
	this._lastNode = null;
	this._shops = new haxe.ds.ObjectMap();
	this.saveId = "town-manager";
	jengine.Component.call(this);
};
ostm.TownManager.__name__ = true;
ostm.TownManager.__interfaces__ = [jengine.Saveable];
ostm.TownManager.__super__ = jengine.Component;
ostm.TownManager.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		ostm.TownManager.instance = this;
	}
	,start: function() {
		var _g = this;
		jengine.SaveManager.instance.addItem(this);
		this._townScreen = window.document.getElementById("town-screen");
		this._shopClock = window.document.getElementById("town-shop-clock");
		this._capacityPrice = window.document.getElementById("town-shop-capacity-price");
		this._warpButton = window.document.getElementById("town-warp-button");
		this._warpButton.onclick = function(event) {
			_g.shouldWarp = !_g.shouldWarp;
			_g.updateWarpButton();
		};
		this.updateWarpButton();
		var restockButton = window.document.getElementById("town-shop-restock-button");
		restockButton.onclick = function(event1) {
			var player = ostm.battle.BattleManager.instance.getPlayer();
			var mapNode = ostm.map.MapGenerator.instance.selectedNode;
			var price = _g.restockPrice(mapNode);
			if(price <= player.gold) {
				player.addGold(-price);
				_g.generateItems(mapNode);
				_g.updateShopHtml(mapNode);
				_g.updateRestockPrice(mapNode);
			}
		};
		var capacityButton = window.document.getElementById("town-shop-capacity-button");
		capacityButton.onclick = function(event2) {
			var player1 = ostm.battle.BattleManager.instance.getPlayer();
			var price1 = ostm.item.Inventory.instance.capacityUpgradeCost();
			if(price1 <= player1.gems) {
				player1.addGems(-price1);
				ostm.item.Inventory.instance.upgradeCapacity();
				_g.updateCapacityPrice();
			}
		};
		this.updateCapacityPrice();
	}
	,update: function() {
		var mapNode = ostm.map.MapGenerator.instance.selectedNode;
		var inTown = mapNode.isTown();
		if(!inTown) {
			this.shouldWarp = false;
			this.updateWarpButton();
		} else {
			var shop = this._shops.h[mapNode.__id__];
			if(shop == null) {
				shop = { generateTime : 0, items : []};
				this._shops.set(mapNode,shop);
				shop;
			}
			if(shop.generateTime + 300 <= jengine.Time.get_raw()) this.generateItems(mapNode);
			var refreshTime = Math.round(shop.generateTime + 300 - jengine.Time.get_raw());
			this._shopClock.innerText = jengine.util.Util.format(refreshTime);
			if(mapNode != this._lastNode) {
				this.updateShopHtml(mapNode);
				this.updateCapacityPrice();
			}
			this.updateRestockPrice(mapNode);
		}
		if(inTown) this._townScreen.style.display = ""; else this._townScreen.style.display = "none";
		this._lastNode = mapNode;
	}
	,generateItems: function(mapNode) {
		var items = [];
		var nItems = 6;
		while(items.length < nItems) {
			var item = ostm.item.Inventory.instance.randomItem(mapNode.areaLevel());
			if(item.numAffixes() > 0) items.push(item);
		}
		var shop = this._shops.h[mapNode.__id__];
		if(shop.items != null) {
			var _g = 0;
			var _g1 = shop.items;
			while(_g < _g1.length) {
				var item1 = _g1[_g];
				++_g;
				item1.cleanupElement();
			}
		}
		shop.items = items;
		shop.generateTime = Math.round(jengine.Time.get_raw());
		this.updateShopHtml(mapNode);
	}
	,updateShopHtml: function(mapNode) {
		var _g2 = this;
		var shopElem = window.document.getElementById("town-shop");
		while(shopElem.childElementCount > 0) shopElem.removeChild(shopElem.firstChild);
		var player = ostm.battle.BattleManager.instance.getPlayer();
		var items = this._shops.h[mapNode.__id__].items;
		var _g = 0;
		while(_g < items.length) {
			var item = [items[_g]];
			++_g;
			shopElem.appendChild(item[0].createElement((function($this) {
				var $r;
				var _g1 = new haxe.ds.StringMap();
				_g1.set("Buy",(function(item) {
					return function(event) {
						var price = item[0].buyValue();
						if(ostm.item.Inventory.instance.hasSpaceForItem() && player.gold >= price) {
							player.addGold(-price);
							HxOverrides.remove(items,item[0]);
							item[0].cleanupElement();
							ostm.item.Inventory.instance.push(item[0]);
							_g2.updateShopHtml(mapNode);
						}
					};
				})(item));
				$r = _g1;
				return $r;
			}(this))));
		}
	}
	,updateWarpButton: function() {
		if(this.shouldWarp) this._warpButton.innerText = "Disable"; else this._warpButton.innerText = "Enable";
	}
	,restockPrice: function(mapNode) {
		var items = this._shops.h[mapNode.__id__].items;
		var price = 0;
		var _g = 0;
		while(_g < items.length) {
			var item = items[_g];
			++_g;
			price += item.buyValue() - item.sellValue();
		}
		return price;
	}
	,updateRestockPrice: function(mapNode) {
		var label = window.document.getElementById("town-shop-restock-price");
		label.innerText = jengine.util.Util.format(this.restockPrice(mapNode));
	}
	,updateCapacityPrice: function() {
		this._capacityPrice.innerText = jengine.util.Util.format(ostm.item.Inventory.instance.capacityUpgradeCost());
	}
	,serialize: function() {
		var shops = new Array();
		var $it0 = this._shops.keys();
		while( $it0.hasNext() ) {
			var node = $it0.next();
			var i = node.depth;
			var j = node.height;
			var shop = this._shops.h[node.__id__];
			var items = shop.items.map(function(item) {
				return item.serialize();
			});
			shops.push({ i : i, j : j, genTime : shop.generateTime, items : items});
		}
		return { shops : shops};
	}
	,deserialize: function(data) {
		var shops = data.shops;
		var _g = 0;
		while(_g < shops.length) {
			var shopData = shops[_g];
			++_g;
			var i = shopData.i;
			var j = shopData.j;
			var node = ostm.map.MapGenerator.instance.getNode(i,j);
			var items = shopData.items.map(function(itemData) {
				return ostm.item.Item.loadItem(itemData);
			});
			var v = { generateTime : shopData.genTime, items : items};
			this._shops.set(node,v);
			v;
		}
	}
	,__class__: ostm.TownManager
});
ostm.battle = {};
ostm.battle.ActiveSkill = function(name,mana,damage,speed) {
	this.name = name;
	this.manaCost = mana;
	this.damage = damage;
	this.speed = speed;
};
ostm.battle.ActiveSkill.__name__ = true;
ostm.battle.ActiveSkill.prototype = {
	__class__: ostm.battle.ActiveSkill
};
ostm.battle.ActiveSkillButton = function(idx,skill) {
	jengine.Component.call(this);
	this._idx = idx;
	this._skill = skill;
};
ostm.battle.ActiveSkillButton.__name__ = true;
ostm.battle.ActiveSkillButton.__super__ = jengine.Component;
ostm.battle.ActiveSkillButton.prototype = $extend(jengine.Component.prototype,{
	start: function() {
		var _g = this;
		this._player = ostm.battle.BattleManager.instance.getPlayer();
		var html = this.entity.getComponent(jengine.HtmlRenderer);
		var elem = html.getElement();
		elem.innerText = "(" + (this._idx + 1) + ") " + this._skill.name;
		elem.onclick = function(event) {
			_g._player.setActiveSkill(_g._skill);
		};
		elem.onmouseover = function(event1) {
			_g._body.style.display = "";
			var pos = jengine._Vec2.Vec2_Impl_._new(event1.x + 20,event1.y - 180);
			_g._body.style.left = pos.x;
			_g._body.style.top = pos.y;
		};
		elem.onmouseout = function(event2) {
			_g._body.style.display = "none";
		};
		var _this = window.document;
		this._body = _this.createElement("ul");
		this._body.style.display = "none";
		this._body.style.position = "absolute";
		this._body.style.background = "#444444";
		this._body.style.border = "2px solid #000000";
		this._body.style.width = 220;
		this._body.style.zIndex = 10;
		var bodyItems = [this._skill.name,"Keyboard shortcut: " + jengine.util.Util.format(this._idx + 1),"Mana Cost: " + jengine.util.Util.format(this._skill.manaCost),"Power: " + jengine.util.Util.format(Math.round(100 * this._skill.damage)) + "%","Speed: " + jengine.util.Util.format(Math.round(100 * this._skill.speed)) + "%"];
		var _g1 = 0;
		while(_g1 < bodyItems.length) {
			var item = bodyItems[_g1];
			++_g1;
			var stat;
			var _this1 = window.document;
			stat = _this1.createElement("li");
			stat.innerText = item;
			this._body.appendChild(stat);
		}
		window.document.getElementById("popup-container").appendChild(this._body);
	}
	,onClick: function() {
		this._player.setActiveSkill(this._skill);
	}
	,__class__: ostm.battle.ActiveSkillButton
});
ostm.battle.BattleManager = function() {
	this._killCount = 0;
	this._isPlayerDead = false;
	this._enemySpawnPct = 0;
	this._enemies = [];
	this._activeButtons = [];
	this._battleMembers = [];
	jengine.Component.call(this);
};
ostm.battle.BattleManager.__name__ = true;
ostm.battle.BattleManager.__super__ = jengine.Component;
ostm.battle.BattleManager.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		ostm.battle.BattleManager.instance = this;
	}
	,start: function() {
		var _g = this;
		this._player = this.addBattleMember(true,jengine._Vec2.Vec2_Impl_._new(75,80));
		this.entity.getSystem().addEntity(new jengine.Entity([new jengine.HtmlRenderer({ parent : "battle-screen", className : "spawn-bar"}),new ostm.ProgressBar(function() {
			return _g._enemySpawnPct;
		})]));
		this.entity.getSystem().addEntity(new jengine.Entity([new jengine.HtmlRenderer({ parent : "battle-screen", className : "xp-bar"}),new ostm.ProgressBar(function() {
			return _g._player.xp / _g._player.xpToNextLevel();
		})]));
		this._activeButtons = [];
		var _g1 = 0;
		var _g11 = ostm.battle.ActiveSkill.skills;
		while(_g1 < _g11.length) {
			var skill = _g11[_g1];
			++_g1;
			var i = this._activeButtons.length;
			var x = i % 2;
			var y = Math.floor(i / 2);
			var btn = new ostm.battle.ActiveSkillButton(i,skill);
			var btnEnt = new jengine.Entity([new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(90 * x + 20,90 * y + 200)),new jengine.HtmlRenderer({ parent : "battle-screen", size : jengine._Vec2.Vec2_Impl_._new(80,80), style : (function($this) {
				var $r;
				var _g2 = new haxe.ds.StringMap();
				_g2.set("border","2px solid black");
				_g2.set("background","white");
				$r = _g2;
				return $r;
			}(this))}),btn]);
			this.entity.getSystem().addEntity(btnEnt);
			this._activeButtons.push(btn);
		}
		this._player.level = 1;
		var _g3 = 0;
		var _g12 = this._battleMembers;
		while(_g3 < _g12.length) {
			var mem = _g12[_g3];
			++_g3;
			mem.health = mem.maxHealth();
			mem.mana = mem.maxMana();
		}
		this._battleScreen = window.document.getElementById("battle-screen");
		var _this = window.document;
		this._huntButton = _this.createElement("button");
		this._huntButton.className = "hunt-button";
		this._huntButton.onclick = function(event) {
			var _g13 = _g._player.huntType;
			switch(_g13[1]) {
			case 0:
				_g._player.huntType = ostm.battle.HuntType.Hunting;
				break;
			case 1:
				_g._player.huntType = ostm.battle.HuntType.Hiding;
				break;
			case 2:
				_g._player.huntType = ostm.battle.HuntType.Normal;
				break;
			}
		};
		this._battleScreen.appendChild(this._huntButton);
	}
	,spawnLevel: function() {
		return ostm.map.MapGenerator.instance.selectedNode.areaLevel();
	}
	,keyDown: function(keyCode) {
		var i = keyCode - 49;
		if(i >= 0 && i < this._activeButtons.length) this._activeButtons[i].onClick();
	}
	,regenUpdate: function() {
		if(ostm.map.MapGenerator.instance.isInTown()) {
			this._player.health = this._player.maxHealth();
			this._player.mana = this._player.maxMana();
			this._isPlayerDead = false;
			return;
		}
		var _g = 0;
		var _g1 = this._battleMembers;
		while(_g < _g1.length) {
			var mem = _g1[_g];
			++_g;
			mem.updateRegen(this.isInBattle());
		}
		if(this._isPlayerDead && this._player.health == this._player.maxHealth()) {
			this._isPlayerDead = false;
			this._enemySpawnPct = 0;
		}
	}
	,update: function() {
		var hasEnemySpawned = this.isInBattle();
		this.regenUpdate();
		var inTown = ostm.map.MapGenerator.instance.isInTown();
		if(!inTown) this._battleScreen.style.display = ""; else this._battleScreen.style.display = "none";
		var _g = this._player.huntType;
		switch(_g[1]) {
		case 0:
			this._huntButton.innerText = "Normal";
			break;
		case 1:
			this._huntButton.innerText = "Hunting";
			break;
		case 2:
			this._huntButton.innerText = "Hiding";
			break;
		}
		if(inTown) {
			this._enemySpawnPct = 0;
			return;
		}
		if(!hasEnemySpawned) {
			this._enemySpawnPct += jengine.Time.dt / this.enemySpawnTime();
			if(this._enemySpawnPct >= 1) this.spawnEnemies();
			return;
		}
		var _g1 = 0;
		var _g11 = this._battleMembers;
		while(_g1 < _g11.length) {
			var mem = _g11[_g1];
			++_g1;
			mem.attackTimer += jengine.Time.dt;
			var attackTime = 1.0 / mem.attackSpeed();
			if(mem.attackTimer > attackTime) {
				mem.attackTimer -= attackTime;
				var target;
				if(mem.isPlayer) target = this._enemies[0]; else target = this._player;
				this.dealDamage(target,mem);
				mem.setActiveSkill(ostm.battle.ActiveSkill.skills[0]);
			}
		}
	}
	,spawnEnemies: function() {
		var nEnemies = 1;
		var _g = 0;
		while(_g < nEnemies) {
			var i = _g++;
			var enemy = this.addBattleMember(false,jengine._Vec2.Vec2_Impl_._new(350,80 + 170 * i));
			enemy.level = this.spawnLevel();
			enemy.health = enemy.maxHealth();
			enemy.mana = enemy.maxMana();
			this._enemies.push(enemy);
		}
	}
	,despawnEnemy: function(enemy) {
		enemy.entity.getSystem().removeEntity(enemy.entity);
		HxOverrides.remove(this._enemies,enemy);
		HxOverrides.remove(this._battleMembers,enemy);
	}
	,dealDamage: function(target,attacker) {
		var baseDamage = attacker.damage();
		var damage = Math.round(baseDamage * (1 - target.damageReduction(attacker.level,attacker.armorPierce())));
		var crit = attacker.critInfo(target.level);
		var isCrit = jengine.util.Random.randomBool(crit.chance);
		if(isCrit) damage = Math.round(damage * (1 + crit.damage));
		target.health -= damage;
		attacker.mana -= attacker.manaCost();
		var elem = target.entity.getComponent(jengine.HtmlRenderer).getElement();
		var rect = elem.getBoundingClientRect();
		var pos = jengine._Vec2.Vec2_Impl_._new(rect.left + rect.width / 3,rect.top + rect.height / 4);
		var damagePos = jengine._Vec2.Vec2_Impl_._new(jengine.util.Random.randomRange(rect.left,rect.right),jengine.util.Random.randomRange(rect.top,rect.bottom));
		var numEnt = new jengine.Entity([new jengine.Transform(damagePos),new jengine.HtmlRenderer({ parent : "popup-container"}),new ostm.battle.DamageNumber(damage,isCrit,target.isPlayer)]);
		this.entity.getSystem().addEntity(numEnt);
		if(target.health <= 0) {
			var isBattleDone = false;
			if(target.isPlayer) {
				target.health = 0;
				this._isPlayerDead = true;
				ostm.map.MapGenerator.instance.returnToCheckpoint();
				var enemies = this._enemies.slice();
				var _g = 0;
				while(_g < enemies.length) {
					var e = enemies[_g];
					++_g;
					this.despawnEnemy(e);
				}
				isBattleDone = true;
			} else {
				this._killCount++;
				var mod = this._player.sumAffixes();
				var xp = target.xpReward();
				xp = Math.round(xp * (1 + mod.percentXpGained / 100));
				var gold = target.goldReward();
				gold = Math.round(gold * (1 + mod.percentGoldGained / 100));
				var gemChance = 0.07 * (1 + mod.percentGemDropRate / 100);
				var gems;
				if(jengine.util.Random.randomBool(gemChance)) gems = 1; else gems = 0;
				this._player.addXp(xp);
				this._player.addGold(gold);
				this._player.addGems(gems);
				var xpStr = jengine.util.Util.format(xp) + "XP";
				this.entity.getSystem().addEntity(new jengine.Entity([new jengine.Transform(pos),new jengine.HtmlRenderer({ parent : "popup-container"}),new ostm.battle.PopupNumber(xpStr,"#33ff33",22,170,2.5)]));
				var goldStr = jengine.util.Util.format(gold) + "G";
				this.entity.getSystem().addEntity(new jengine.Entity([new jengine.Transform((function($this) {
					var $r;
					var rhs = jengine._Vec2.Vec2_Impl_._new(0,30);
					$r = jengine._Vec2.Vec2_Impl_._new(pos.x + rhs.x,pos.y + rhs.y);
					return $r;
				}(this))),new jengine.HtmlRenderer({ parent : "popup-container"}),new ostm.battle.PopupNumber(goldStr,"#ffff33",22,170,2.5)]));
				if(gems > 0) {
					var gemStr = jengine.util.Util.format(gems) + "Gem";
					this.entity.getSystem().addEntity(new jengine.Entity([new jengine.Transform((function($this) {
						var $r;
						var rhs1 = jengine._Vec2.Vec2_Impl_._new(0,60);
						$r = jengine._Vec2.Vec2_Impl_._new(pos.x + rhs1.x,pos.y + rhs1.y);
						return $r;
					}(this))),new jengine.HtmlRenderer({ parent : "popup-container"}),new ostm.battle.PopupNumber(gemStr,"#ff3333",22,170,2.5)]));
				}
				ostm.item.Inventory.instance.tryRewardItem(target,mod);
				this.despawnEnemy(target);
				isBattleDone = this._enemies.length == 0;
			}
			if(isBattleDone) {
				var _g1 = 0;
				var _g11 = this._battleMembers;
				while(_g1 < _g11.length) {
					var mem = _g11[_g1];
					++_g1;
					mem.attackTimer = 0;
				}
				this._enemySpawnPct = 0;
			}
		}
	}
	,addBattleMember: function(isPlayer,pos) {
		var id = "battle-member-" + this._battleMembers.length;
		var system = this.entity.getSystem();
		var size = jengine._Vec2.Vec2_Impl_._new(60,60);
		var bat = new ostm.battle.BattleMember(isPlayer);
		var ent = new jengine.Entity([new jengine.Transform(pos),new jengine.HtmlRenderer({ id : id, parent : "battle-screen", size : size, style : (function($this) {
			var $r;
			var _g = new haxe.ds.StringMap();
			_g.set("background","none");
			$r = _g;
			return $r;
		}(this))}),new ostm.battle.BattleRenderer(bat)]);
		if(isPlayer) ent.addComponent(new ostm.battle.StatRenderer(bat));
		system.addEntity(ent);
		bat.entity = ent;
		bat.elem = ent.getComponent(jengine.HtmlRenderer).getElement();
		bat.setActiveSkill(ostm.battle.ActiveSkill.skills[0]);
		this._battleMembers.push(bat);
		return bat;
	}
	,isPlayerDead: function() {
		return this._isPlayerDead;
	}
	,isInBattle: function() {
		return this._enemies.length > 0 && !this._isPlayerDead;
	}
	,getKillCount: function() {
		return this._killCount;
	}
	,resetKillCount: function() {
		this._killCount = 0;
	}
	,enemySpawnTime: function() {
		return 4 * this._player.enemySpawnModifier();
	}
	,getPlayer: function() {
		return this._player;
	}
	,__class__: ostm.battle.BattleManager
});
ostm.battle.HuntType = { __ename__ : true, __constructs__ : ["Normal","Hunting","Hiding"] };
ostm.battle.HuntType.Normal = ["Normal",0];
ostm.battle.HuntType.Normal.toString = $estr;
ostm.battle.HuntType.Normal.__enum__ = ostm.battle.HuntType;
ostm.battle.HuntType.Hunting = ["Hunting",1];
ostm.battle.HuntType.Hunting.toString = $estr;
ostm.battle.HuntType.Hunting.__enum__ = ostm.battle.HuntType;
ostm.battle.HuntType.Hiding = ["Hiding",2];
ostm.battle.HuntType.Hiding.toString = $estr;
ostm.battle.HuntType.Hiding.__enum__ = ostm.battle.HuntType;
ostm.battle.HuntType.__empty_constructs__ = [ostm.battle.HuntType.Normal,ostm.battle.HuntType.Hunting,ostm.battle.HuntType.Hiding];
ostm.battle.BattleMember = function(isPlayer) {
	this._cachedStatMod = null;
	this.huntType = ostm.battle.HuntType.Normal;
	this.attackTimer = 0;
	this.manaPartial = 0;
	this.mana = 0;
	this.healthPartial = 0;
	this.health = 0;
	this.gems = 0;
	this.gold = 0;
	this.xp = 0;
	this.equipment = new haxe.ds.EnumValueMap();
	if(isPlayer) this.classType = ostm.battle.ClassType.playerType; else this.classType = jengine.util.Random.randomElement(ostm.battle.ClassType.enemyTypes);
	var _g = 0;
	var _g1 = Type.allEnums(ostm.item.ItemSlot);
	while(_g < _g1.length) {
		var k = _g1[_g];
		++_g;
		this.equipment.set(k,null);
		null;
	}
	this.isPlayer = isPlayer;
	if(this.isPlayer) {
		this.saveId = "player";
		var swordType = ostm.item.ItemData.getItemType("sword");
		if(swordType != null) {
			var sword = new ostm.item.Item(swordType,1);
			this.equipment.set(ostm.item.ItemSlot.Weapon,sword);
			sword;
		}
		jengine.SaveManager.instance.addItem(this);
	}
};
ostm.battle.BattleMember.__name__ = true;
ostm.battle.BattleMember.__interfaces__ = [jengine.Saveable];
ostm.battle.BattleMember.prototype = {
	levelUp: function() {
		this.level++;
		this._cachedStatMod = null;
		ga("send","event","player","level-up","",this.level);
	}
	,addXp: function(xp) {
		this.xp += xp;
		var tnl = this.xpToNextLevel();
		while(this.xp >= tnl) {
			this.xp -= tnl;
			this.levelUp();
		}
	}
	,addGold: function(gold) {
		this.gold += gold;
	}
	,addGems: function(gems) {
		this.gems += gems;
	}
	,xpToNextLevel: function() {
		return Math.round(10 + 5 * Math.pow(this.level - 1,2.6));
	}
	,xpReward: function() {
		return Math.round(Math.pow(this.level,2) + 2);
	}
	,goldReward: function() {
		return Math.round(0.2 * Math.pow(this.level,1.65) + 1);
	}
	,strength: function() {
		var mod = this.sumAffixes();
		var val = this.classType.strength.value(this.level);
		val += mod.flatStrength;
		return Math.round(val);
	}
	,dexterity: function() {
		var mod = this.sumAffixes();
		var val = this.classType.dexterity.value(this.level);
		val += mod.flatDexterity;
		return Math.round(val);
	}
	,intelligence: function() {
		var mod = this.sumAffixes();
		var val = this.classType.intelligence.value(this.level);
		val += mod.flatIntelligence;
		return Math.round(val);
	}
	,vitality: function() {
		var mod = this.sumAffixes();
		var val = this.classType.vitality.value(this.level);
		val += mod.flatVitality;
		return Math.round(val);
	}
	,endurance: function() {
		var mod = this.sumAffixes();
		var val = this.classType.endurance.value(this.level);
		val += mod.flatEndurance;
		return Math.round(val);
	}
	,updateCachedAffixes: function() {
		this._cachedStatMod = null;
	}
	,sumAffixes: function() {
		if(this._cachedStatMod == null) {
			this._cachedStatMod = new ostm.battle.StatModifier();
			var $it0 = this.equipment.iterator();
			while( $it0.hasNext() ) {
				var item = $it0.next();
				if(item != null) item.sumAffixes(this._cachedStatMod);
			}
			if(this.isPlayer) {
				var _g = 0;
				var _g1 = ostm.skill.SkillTree.instance.skills;
				while(_g < _g1.length) {
					var passive = _g1[_g];
					++_g;
					passive.sumAffixes(this._cachedStatMod);
				}
			}
		}
		return this._cachedStatMod;
	}
	,maxHealth: function() {
		var mod = this.sumAffixes();
		var hp = this.vitality() * 5 + 20;
		if(this.isPlayer) hp += 55;
		hp += mod.flatHealth;
		hp = Math.round(hp * (1 + mod.percentHealth / 100));
		return hp;
	}
	,maxMana: function() {
		var mod = this.sumAffixes();
		var mp = 100.0;
		mp += mod.flatMana;
		mp *= 1 + mod.percentMana / 100;
		return Math.round(mp);
	}
	,baseHealthRegenInCombat: function() {
		var mod = this.sumAffixes();
		var reg = 0.0;
		reg += mod.flatHealthRegen;
		return reg;
	}
	,baseHealthRegenOutOfCombat: function() {
		var reg = 6 + this.maxHealth() * 0.0125;
		return reg;
	}
	,healthRegen: function(inCombat) {
		var rIn = this.baseHealthRegenInCombat();
		var rOut = this.baseHealthRegenOutOfCombat();
		if(inCombat) rOut *= 0.15;
		var reg = rIn + rOut;
		var mod = this.sumAffixes();
		reg *= 1 + mod.percentHealthRegen / 100;
		return reg;
	}
	,healthRegenInCombat: function() {
		return this.healthRegen(true);
	}
	,healthRegenOutOfCombat: function() {
		return this.healthRegen(false);
	}
	,manaRegen: function() {
		var mod = this.sumAffixes();
		var reg = 2 + this.maxMana() * 0.015;
		reg *= 1 + mod.percentManaRegen / 100;
		return reg;
	}
	,armorPierce: function() {
		var mod = this.sumAffixes();
		return mod.flatArmorPierce;
	}
	,damage: function() {
		var mod = this.sumAffixes();
		var atk = 0;
		if(this.equipment.get(ostm.item.ItemSlot.Weapon) == null) atk = this.classType.unarmedAttack.value(this.level);
		var $it0 = this.equipment.iterator();
		while( $it0.hasNext() ) {
			var item = $it0.next();
			if(item != null) atk += item.attack(); else atk += 0;
		}
		atk += mod.flatAttack;
		atk *= this.curSkill.damage;
		atk *= 1 + this.strength() * 0.015;
		atk *= 1 + mod.percentAttack / 100;
		return Math.round(atk);
	}
	,attackSpeed: function() {
		var wep = this.equipment.get(ostm.item.ItemSlot.Weapon);
		var mod = this.sumAffixes();
		var spd;
		if(wep != null) spd = wep.attackSpeed(); else spd = 1.5;
		spd *= 1 + mod.percentAttackSpeed / 100;
		spd *= this.curSkill.speed;
		return spd;
	}
	,critInfo: function(targetLevel) {
		var wep = this.equipment.get(ostm.item.ItemSlot.Weapon);
		var mod = this.sumAffixes();
		var floatRating;
		if(wep == null) floatRating = 3; else floatRating = 0;
		var $it0 = this.equipment.iterator();
		while( $it0.hasNext() ) {
			var item = $it0.next();
			if(item != null) floatRating += item.critRating();
		}
		floatRating += mod.flatCritRating;
		floatRating *= 1 + this.dexterity() * 0.025;
		floatRating *= 1 + mod.percentCritRating / 100;
		var rating = Math.round(floatRating);
		var offense = 0.02 * rating;
		var defense = 4 + targetLevel;
		var totalDamage = 1 + offense / defense;
		var baseChance = Math.pow(rating,0.7) / 100;
		var chance = 0.025 + baseChance / Math.pow(defense,0.5);
		var damage = (totalDamage - 1) / chance;
		chance *= 1 + mod.percentCritChance / 100;
		damage *= 1 + mod.percentCritDamage / 100;
		return { rating : rating, chance : chance, damage : damage};
	}
	,manaCost: function() {
		return this.curSkill.manaCost;
	}
	,dps: function() {
		var atk = this.damage();
		var spd = this.attackSpeed();
		var crit = this.critInfo(this.level);
		var critMod = 1 + crit.chance * crit.damage;
		return atk * spd * critMod;
	}
	,defense: function() {
		var def = this.classType.baseArmor.value(this.level);
		var mod = this.sumAffixes();
		var $it0 = this.equipment.iterator();
		while( $it0.hasNext() ) {
			var item = $it0.next();
			if(item != null) def += item.defense(); else def += 0;
		}
		def += mod.flatDefense;
		def *= 1 + this.endurance() * 0.02;
		return Math.round(def);
	}
	,damageReduction: function(attackerLevel,armorPierce) {
		if(armorPierce == null) armorPierce = 0;
		var def = this.defense();
		def -= armorPierce;
		def = Math.floor(Math.max(0,def));
		return def / (10 + 2.5 * attackerLevel + def);
	}
	,ehp: function() {
		var hp = this.maxHealth();
		var mitigated = 1 / (1 - this.damageReduction(this.level));
		return hp * mitigated;
	}
	,power: function() {
		return Math.round(Math.sqrt(this.dps() * this.ehp()));
	}
	,powerIfEquipped: function(item) {
		var slot = item.type.slot;
		var curItem = this.equipment.get(slot);
		var oldCache = this.sumAffixes();
		var newMod = this._cachedStatMod.copy();
		if(curItem != null) curItem.subtractAffixes(newMod);
		item.sumAffixes(newMod);
		this._cachedStatMod = newMod;
		this.equipment.set(slot,item);
		item;
		var pow = this.power();
		this._cachedStatMod = oldCache;
		this.equipment.set(slot,curItem);
		curItem;
		return pow;
	}
	,moveSpeed: function() {
		var mod = this.sumAffixes();
		var spd = 1;
		spd *= 1 + mod.percentMoveSpeed / 100;
		return spd;
	}
	,equip: function(item) {
		var oldItem = this.equipment.get(item.type.slot);
		if(oldItem != null) oldItem.cleanupElement();
		this.equipment.set(item.type.slot,item);
		item;
		this.updateCachedAffixes();
	}
	,unequip: function(item) {
		this.equipment.set(item.type.slot,null);
		null;
		this.updateCachedAffixes();
	}
	,setActiveSkill: function(skill) {
		if(this.curSkill != skill && skill.manaCost <= this.mana) this.curSkill = skill;
	}
	,updateRegen: function(inBattle) {
		var hpReg;
		if(inBattle) hpReg = this.healthRegenInCombat(); else hpReg = this.healthRegenOutOfCombat();
		var mpReg = this.manaRegen();
		this.healthPartial += hpReg * jengine.Time.dt;
		this.manaPartial += mpReg * jengine.Time.dt;
		var dHealth = Math.floor(this.healthPartial);
		var dMana = Math.floor(this.manaPartial);
		this.health += dHealth;
		this.healthPartial -= dHealth;
		if(this.health >= this.maxHealth()) this.health = this.maxHealth();
		this.mana += dMana;
		this.manaPartial -= dMana;
		if(this.mana >= this.maxMana()) this.mana = this.maxMana();
	}
	,huntSkill: function() {
		var mod = this.sumAffixes();
		var hunt = 10;
		hunt += mod.flatHuntSkill;
		return hunt;
	}
	,enemySpawnModifier: function() {
		var mod = this.huntSkill() / 40;
		var _g = this.huntType;
		switch(_g[1]) {
		case 0:
			return 1;
		case 1:
			return 1 / (1 + mod);
		case 2:
			return 1 + mod;
		}
	}
	,serialize: function() {
		var equips = [];
		var $it0 = this.equipment.iterator();
		while( $it0.hasNext() ) {
			var item = $it0.next();
			if(item != null) equips.push(item.serialize());
		}
		return { xp : this.xp, gold : this.gold, gems : this.gems, level : this.level, health : this.health, mana : this.mana, equipment : equips, hunt : this.huntType};
	}
	,deserialize: function(data) {
		this.xp = data.xp;
		this.gold = data.gold;
		this.gems = data.gems;
		this.level = data.level;
		this.health = data.health;
		this.mana = data.mana;
		if(data.hunt != null) this.huntType = data.hunt; else this.huntType = ostm.battle.HuntType.Normal;
		var $it0 = this.equipment.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			this.equipment.set(k,null);
			null;
		}
		var equips = data.equipment;
		var _g = 0;
		while(_g < equips.length) {
			var d = equips[_g];
			++_g;
			var item = ostm.item.Item.loadItem(d);
			this.equipment.set(item.type.slot,item);
			item;
		}
		this._cachedStatMod = null;
	}
	,__class__: ostm.battle.BattleMember
};
ostm.battle.BattleRenderer = function(member) {
	this._spawnedEnts = [];
	jengine.Component.call(this);
	this._member = member;
};
ostm.battle.BattleRenderer.__name__ = true;
ostm.battle.BattleRenderer.__super__ = jengine.Component;
ostm.battle.BattleRenderer.prototype = $extend(jengine.Component.prototype,{
	deinit: function() {
		var _g = 0;
		var _g1 = this._spawnedEnts;
		while(_g < _g1.length) {
			var ent = _g1[_g];
			++_g;
			this.entity.getSystem().removeEntity(ent);
		}
	}
	,start: function() {
		var _g1 = this;
		var renderer = this.entity.getComponent(jengine.HtmlRenderer);
		var elem = renderer.getElement();
		var id = elem.id;
		var size = renderer.size;
		var nameSize = jengine._Vec2.Vec2_Impl_._new(160,30);
		var nameX = (size.x - nameSize.x) / 2;
		var barSize = jengine._Vec2.Vec2_Impl_._new(160,16);
		var barX = (size.x - barSize.x) / 2;
		var atkBarSize = jengine._Vec2.Vec2_Impl_._new(180,20);
		var atkBarX = (size.x - atkBarSize.x) / 2;
		var _this = window.document;
		this._imageElem = _this.createElement("img");
		this._imageElem.src = "img/" + this._member.classType.image;
		this._imageElem.height = Math.round(renderer.size.y);
		this._imageElem.style.display = "block";
		this._imageElem.style.margin = "0px auto 0px auto";
		this._imageElem.style.imageRendering = "pixelated";
		elem.appendChild(this._imageElem);
		var nameEnt = new jengine.Entity([new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(nameX,-78)),new jengine.HtmlRenderer({ parent : id, size : nameSize, text : this._member.classType.name, style : (function($this) {
			var $r;
			var _g = new haxe.ds.StringMap();
			_g.set("background","none");
			_g.set("text-align","center");
			$r = _g;
			return $r;
		}(this))})]);
		this._spawnedEnts.push(nameEnt);
		var levelEnt = new jengine.Entity([new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(barX,-59)),new jengine.HtmlRenderer({ parent : id, size : barSize, textFunc : function() {
			return "L" + jengine.util.Util.format(_g1._member.level);
		}, style : (function($this) {
			var $r;
			var _g11 = new haxe.ds.StringMap();
			_g11.set("font-size","13px");
			$r = _g11;
			return $r;
		}(this))})]);
		this._spawnedEnts.push(levelEnt);
		var powerEnt = new jengine.Entity([new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(barX,-59)),new jengine.HtmlRenderer({ parent : id, size : barSize, textFunc : function() {
			return "Pow: " + jengine.util.Util.shortFormat(_g1._member.power());
		}, style : (function($this) {
			var $r;
			var _g2 = new haxe.ds.StringMap();
			_g2.set("font-size","13px");
			_g2.set("text-align","right");
			$r = _g2;
			return $r;
		}(this))})]);
		this._spawnedEnts.push(powerEnt);
		var hpEnt = new jengine.Entity([new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(barX,-42)),new jengine.HtmlRenderer({ parent : id, size : barSize, style : (function($this) {
			var $r;
			var _g3 = new haxe.ds.StringMap();
			_g3.set("background","#662222");
			_g3.set("border","2px solid black");
			$r = _g3;
			return $r;
		}(this))}),new ostm.ProgressBar(function() {
			return _g1._member.health / _g1._member.maxHealth();
		},(function($this) {
			var $r;
			var _g4 = new haxe.ds.StringMap();
			_g4.set("background","#ff0000");
			$r = _g4;
			return $r;
		}(this)))]);
		var mpEnt = new jengine.Entity([new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(barX,-24)),new jengine.HtmlRenderer({ parent : id, size : barSize, style : (function($this) {
			var $r;
			var _g5 = new haxe.ds.StringMap();
			_g5.set("background","#222266");
			_g5.set("border","2px solid black");
			$r = _g5;
			return $r;
		}(this))}),new ostm.ProgressBar(function() {
			return _g1._member.mana / _g1._member.maxMana();
		},(function($this) {
			var $r;
			var _g6 = new haxe.ds.StringMap();
			_g6.set("background","#0044ff");
			$r = _g6;
			return $r;
		}(this)))]);
		if(this._member.isPlayer) {
			hpEnt.addComponent(new ostm.battle.CenteredText(function() {
				return jengine.util.Util.format(_g1._member.health) + " / " + jengine.util.Util.format(_g1._member.maxHealth());
			},13));
			mpEnt.addComponent(new ostm.battle.CenteredText(function() {
				return jengine.util.Util.format(_g1._member.mana) + " / " + jengine.util.Util.format(_g1._member.maxMana());
			},13));
		}
		this._spawnedEnts.push(hpEnt);
		this._spawnedEnts.push(mpEnt);
		var attackBar = new jengine.Entity([new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(atkBarX,70)),new jengine.HtmlRenderer({ parent : id, size : atkBarSize, style : (function($this) {
			var $r;
			var _g7 = new haxe.ds.StringMap();
			_g7.set("background","#226622");
			_g7.set("border","2px solid black");
			$r = _g7;
			return $r;
		}(this))}),new ostm.ProgressBar(function() {
			return _g1._member.attackSpeed() * _g1._member.attackTimer;
		},(function($this) {
			var $r;
			var _g8 = new haxe.ds.StringMap();
			_g8.set("background","#00ff00");
			$r = _g8;
			return $r;
		}(this))),new ostm.battle.CenteredText(function() {
			return _g1._member.curSkill.name;
		})]);
		this._spawnedEnts.push(attackBar);
		var _g9 = 0;
		var _g10 = this._spawnedEnts;
		while(_g9 < _g10.length) {
			var ent = _g10[_g9];
			++_g9;
			this.entity.getSystem().addEntity(ent);
		}
	}
	,__class__: ostm.battle.BattleRenderer
});
ostm.battle.CenteredText = function(textFunc,fontSize) {
	if(fontSize == null) fontSize = 16;
	jengine.Component.call(this);
	this._textFunc = textFunc;
	this._fontSize = fontSize;
};
ostm.battle.CenteredText.__name__ = true;
ostm.battle.CenteredText.__super__ = jengine.Component;
ostm.battle.CenteredText.prototype = $extend(jengine.Component.prototype,{
	update: function() {
		if(this._elem == null) {
			var renderer = this.entity.getComponent(jengine.HtmlRenderer);
			if(renderer != null) {
				var _this = window.document;
				this._elem = _this.createElement("span");
				this._elem.style.position = "absolute";
				this._elem.style.width = renderer.size.x;
				this._elem.style.textAlign = "center";
				this._elem.style.fontSize = this._fontSize;
				this._elem.style.zIndex = 1;
				renderer.getElement().appendChild(this._elem);
			}
		}
		if(this._elem != null) this._elem.innerText = this._textFunc();
	}
	,__class__: ostm.battle.CenteredText
});
ostm.battle.StatType = function(base,perLevel) {
	this.baseValue = base;
	this.perLevel = perLevel;
};
ostm.battle.StatType.__name__ = true;
ostm.battle.StatType.prototype = {
	value: function(level) {
		var l = level - 1;
		var v = this.baseValue;
		v += this.perLevel * l;
		return Math.floor(v);
	}
	,__class__: ostm.battle.StatType
};
ostm.battle.ExpStatType = function(base,perLevel) {
	ostm.battle.StatType.call(this,base,perLevel);
};
ostm.battle.ExpStatType.__name__ = true;
ostm.battle.ExpStatType.__super__ = ostm.battle.StatType;
ostm.battle.ExpStatType.prototype = $extend(ostm.battle.StatType.prototype,{
	value: function(level) {
		var v = ostm.battle.StatType.prototype.value.call(this,level);
		v += 0.1 * this.perLevel * Math.pow(level - 1,1.75);
		return Math.floor(v);
	}
	,__class__: ostm.battle.ExpStatType
});
ostm.battle.ClassType = function(data) {
	this.name = data.name;
	this.image = data.image;
	if(data.attack != null) this.unarmedAttack = data.attack; else this.unarmedAttack = new ostm.battle.StatType(2,0);
	if(data.armor != null) this.baseArmor = data.armor; else this.baseArmor = new ostm.battle.StatType(0,0);
	this.strength = data.str;
	this.dexterity = data.dex;
	this.intelligence = data["int"];
	this.vitality = data.vit;
	this.endurance = data.end;
};
ostm.battle.ClassType.__name__ = true;
ostm.battle.ClassType.prototype = {
	__class__: ostm.battle.ClassType
};
ostm.battle.PopupNumber = function(text,color,fontSize,dist,time) {
	this._alphaFadeoutPct = 0.15;
	this._timer = 0;
	jengine.Component.call(this);
	this._text = text;
	this._color = color;
	this._fontSize = fontSize;
	this._dist = dist;
	this._removeTime = time;
};
ostm.battle.PopupNumber.__name__ = true;
ostm.battle.PopupNumber.__super__ = jengine.Component;
ostm.battle.PopupNumber.prototype = $extend(jengine.Component.prototype,{
	start: function() {
		this._startPos = this.entity.getComponent(jengine.Transform).pos;
		this._elem = this.entity.getComponent(jengine.HtmlRenderer).getElement();
		this._elem.innerText = this._text;
		this._elem.style.color = this._color;
		this._elem.style.background = "none";
		this._elem.style.zIndex = "10";
		this._elem.style.fontSize = this._fontSize + "px";
	}
	,update: function() {
		this._timer += jengine.Time.dt;
		var t = this._timer / this._removeTime;
		var s = t * (2 - t);
		var lhs = this._startPos;
		var rhs = jengine._Vec2.Vec2_Impl_._new(0,-this._dist * s);
		this.entity.getComponent(jengine.Transform).pos = jengine._Vec2.Vec2_Impl_._new(lhs.x + rhs.x,lhs.y + rhs.y);
		if(t > 1 - this._alphaFadeoutPct) {
			var a = (t - (1 - this._alphaFadeoutPct)) / this._alphaFadeoutPct;
			this._elem.style.opacity = 1 - a;
		}
		if(this._timer >= this._removeTime) this.entity.getSystem().removeEntity(this.entity);
	}
	,__class__: ostm.battle.PopupNumber
});
ostm.battle.DamageNumber = function(damage,isCrit,isPlayer) {
	var text = jengine.util.Util.format(damage);
	if(isCrit) text += "!";
	var color;
	switch(isPlayer) {
	case false:
		switch(isCrit) {
		case false:
			color = "#ffffff";
			break;
		case true:
			color = "#ffff66";
			break;
		}
		break;
	case true:
		switch(isCrit) {
		case false:
			color = "#ff2244";
			break;
		case true:
			color = "#ff33aa";
			break;
		}
		break;
	}
	var size;
	if(isCrit) size = 40; else size = 26;
	ostm.battle.PopupNumber.call(this,text,color,size,180,1.25);
};
ostm.battle.DamageNumber.__name__ = true;
ostm.battle.DamageNumber.__super__ = ostm.battle.PopupNumber;
ostm.battle.DamageNumber.prototype = $extend(ostm.battle.PopupNumber.prototype,{
	__class__: ostm.battle.DamageNumber
});
ostm.battle.StatModifier = function() {
	this.localPercentCritRating = 0;
	this.localPercentAttackSpeed = 0;
	this.localPercentDefense = 0;
	this.localPercentAttack = 0;
	this.localFlatCritRating = 0;
	this.localFlatDefense = 0;
	this.localFlatAttack = 0;
	this.percentItemRarity = 0;
	this.percentItemDropRate = 0;
	this.percentGemDropRate = 0;
	this.percentGoldGained = 0;
	this.percentXpGained = 0;
	this.percentCritDamage = 0;
	this.percentCritChance = 0;
	this.percentCritRating = 0;
	this.percentMoveSpeed = 0;
	this.percentAttackSpeed = 0;
	this.percentDefense = 0;
	this.percentAttack = 0;
	this.percentManaRegen = 0;
	this.percentMana = 0;
	this.percentHealthRegen = 0;
	this.percentHealth = 0;
	this.flatIntelligence = 0;
	this.flatEndurance = 0;
	this.flatVitality = 0;
	this.flatDexterity = 0;
	this.flatStrength = 0;
	this.flatHuntSkill = 0;
	this.flatMana = 0;
	this.flatHealthRegen = 0;
	this.flatHealth = 0;
	this.flatArmorPierce = 0;
	this.flatCritRating = 0;
	this.flatDefense = 0;
	this.flatAttack = 0;
};
ostm.battle.StatModifier.__name__ = true;
ostm.battle.StatModifier.prototype = {
	copy: function() {
		var mod = new ostm.battle.StatModifier();
		mod.flatAttack = this.flatAttack;
		mod.flatDefense = this.flatDefense;
		mod.flatCritRating = this.flatCritRating;
		mod.flatArmorPierce = this.flatArmorPierce;
		mod.flatHealth = this.flatHealth;
		mod.flatHealthRegen = this.flatHealthRegen;
		mod.flatMana = this.flatMana;
		mod.flatHuntSkill = this.flatHuntSkill;
		mod.flatStrength = this.flatStrength;
		mod.flatDexterity = this.flatDexterity;
		mod.flatVitality = this.flatVitality;
		mod.flatEndurance = this.flatEndurance;
		mod.flatIntelligence = this.flatIntelligence;
		mod.percentHealth = this.percentHealth;
		mod.percentHealthRegen = this.percentHealthRegen;
		mod.percentMana = this.percentMana;
		mod.percentManaRegen = this.percentManaRegen;
		mod.percentAttack = this.percentAttack;
		mod.percentDefense = this.percentDefense;
		mod.percentAttackSpeed = this.percentAttackSpeed;
		mod.percentMoveSpeed = this.percentMoveSpeed;
		mod.percentCritRating = this.percentCritRating;
		mod.percentCritChance = this.percentCritChance;
		mod.percentCritDamage = this.percentCritDamage;
		mod.percentXpGained = this.percentXpGained;
		mod.percentGoldGained = this.percentGoldGained;
		mod.percentGemDropRate = this.percentGemDropRate;
		mod.percentItemDropRate = this.percentItemDropRate;
		mod.percentItemRarity = this.percentItemRarity;
		mod.localFlatAttack = this.localFlatAttack;
		mod.localFlatDefense = this.localFlatDefense;
		mod.localFlatCritRating = this.localFlatCritRating;
		mod.localPercentAttack = this.localPercentAttack;
		mod.localPercentDefense = this.localPercentDefense;
		mod.localPercentAttackSpeed = this.localPercentAttackSpeed;
		mod.localPercentCritRating = this.localPercentCritRating;
		return mod;
	}
	,rawDisplayData: function() {
		return [{ value : this.flatAttack, name : "Attack", isPercent : false},{ value : this.flatDefense, name : "Defense", isPercent : false},{ value : this.flatCritRating, name : "Crit Rating", isPercent : false},{ value : this.flatArmorPierce, name : "Armor Piercing", isPercent : false},{ value : this.flatHealth, name : "Health", isPercent : false},{ value : this.flatHealthRegen, name : "Health Regen", isPercent : false},{ value : this.flatMana, name : "Mana", isPercent : false},{ value : this.flatHuntSkill, name : "Hunting", isPercent : false},{ value : this.flatStrength, name : "Strength", isPercent : false},{ value : this.flatDexterity, name : "Dexterity", isPercent : false},{ value : this.flatVitality, name : "Vitality", isPercent : false},{ value : this.flatEndurance, name : "Endurance", isPercent : false},{ value : this.flatIntelligence, name : "Intelligence", isPercent : false},{ value : this.percentHealth, name : "Health", isPercent : true},{ value : this.percentHealthRegen, name : "Health Regen", isPercent : true},{ value : this.percentMana, name : "Mana", isPercent : true},{ value : this.percentManaRegen, name : "Mana Regen", isPercent : true},{ value : this.percentAttack, name : "Attack", isPercent : true},{ value : this.percentDefense, name : "Defense", isPercent : true},{ value : this.percentAttackSpeed, name : "Attack Speed", isPercent : true},{ value : this.percentMoveSpeed, name : "Move Speed", isPercent : true},{ value : this.percentCritRating, name : "Crit Rating", isPercent : true},{ value : this.percentCritChance, name : "Crit Chance", isPercent : true},{ value : this.percentCritDamage, name : "Crit Damage", isPercent : true},{ value : this.percentXpGained, name : "XP Gained", isPercent : true},{ value : this.percentGoldGained, name : "Gold Gained", isPercent : true},{ value : this.percentGemDropRate, name : "Gem Drop", isPercent : true},{ value : this.percentItemDropRate, name : "Item Drop", isPercent : true},{ value : this.percentItemRarity, name : "Item Rarity", isPercent : true},{ value : this.localFlatAttack, name : "Attack", isPercent : false},{ value : this.localFlatDefense, name : "Defense", isPercent : false},{ value : this.localFlatCritRating, name : "Crit Rating", isPercent : false},{ value : this.localPercentAttack, name : "Attack", isPercent : true},{ value : this.localPercentDefense, name : "Defense", isPercent : true},{ value : this.localPercentAttackSpeed, name : "Attack Speed", isPercent : true},{ value : this.localPercentCritRating, name : "Crit Rating", isPercent : true}];
	}
	,getDisplayData: function() {
		var stats = this.rawDisplayData();
		var toReturn = [];
		var _g = 0;
		while(_g < stats.length) {
			var s = stats[_g];
			++_g;
			if(s.value > 0) toReturn.push(s);
		}
		return toReturn;
	}
	,getDisplayDataAllowingZeroes: function() {
		return this.rawDisplayData();
	}
	,__class__: ostm.battle.StatModifier
};
ostm.battle.StatElement = function(parent,title,body) {
	this.elem = window.document.createElement("li");
	parent.appendChild(this.elem);
	this.title = title;
	this.body = body;
};
ostm.battle.StatElement.__name__ = true;
ostm.battle.StatElement.prototype = {
	update: function() {
		this.elem.innerText = this.title + ": " + this.body();
	}
	,__class__: ostm.battle.StatElement
};
ostm.battle.StatRenderer = function(member) {
	this._cachedEquip = new haxe.ds.EnumValueMap();
	this._equipment = new haxe.ds.EnumValueMap();
	jengine.Component.call(this);
	this._member = member;
};
ostm.battle.StatRenderer.__name__ = true;
ostm.battle.StatRenderer.__super__ = jengine.Component;
ostm.battle.StatRenderer.prototype = $extend(jengine.Component.prototype,{
	start: function() {
		var _g = this;
		var doc = window.document;
		var stats = doc.getElementById("stats");
		var nameSpan = doc.createElement("span");
		if(this._member.isPlayer) nameSpan.innerText = "Player:"; else nameSpan.innerText = "Enemy";
		stats.appendChild(nameSpan);
		var list = this.createAndAddTo("ul",stats);
		this._elements = [new ostm.battle.StatElement(list,"Level",function() {
			return jengine.util.Util.format(_g._member.level);
		}),new ostm.battle.StatElement(list,"XP",function() {
			return jengine.util.Util.shortFormat(_g._member.xp) + " / " + jengine.util.Util.shortFormat(_g._member.xpToNextLevel());
		}),new ostm.battle.StatElement(list,"Gold",function() {
			return jengine.util.Util.shortFormat(_g._member.gold);
		}),new ostm.battle.StatElement(list,"Gems",function() {
			return jengine.util.Util.shortFormat(_g._member.gems);
		}),new ostm.battle.StatElement(list,"Health",function() {
			return jengine.util.Util.format(_g._member.health) + " / " + jengine.util.Util.format(_g._member.maxHealth());
		}),new ostm.battle.StatElement(list,"Mana",function() {
			return jengine.util.Util.format(_g._member.mana) + " / " + jengine.util.Util.format(_g._member.maxMana());
		}),new ostm.battle.StatElement(list,"Health Regen (in combat)",function() {
			return jengine.util.Util.formatFloat(_g._member.healthRegenInCombat()) + "/s";
		}),new ostm.battle.StatElement(list,"Health Regen (out of combat)",function() {
			return jengine.util.Util.formatFloat(_g._member.healthRegenOutOfCombat()) + "/s";
		}),new ostm.battle.StatElement(list,"Mana Regen",function() {
			return jengine.util.Util.formatFloat(_g._member.manaRegen()) + "/s";
		}),new ostm.battle.StatElement(list,"Damage",function() {
			return jengine.util.Util.format(_g._member.damage());
		}),new ostm.battle.StatElement(list,"Attack Speed",function() {
			return jengine.util.Util.formatFloat(_g._member.attackSpeed()) + "/s";
		}),new ostm.battle.StatElement(list,"Crit Rating",function() {
			var lev = ostm.battle.BattleManager.instance.spawnLevel();
			return jengine.util.Util.format(_g._member.critInfo(lev).rating);
		}),new ostm.battle.StatElement(list,"Crit Chance",function() {
			var lev1 = ostm.battle.BattleManager.instance.spawnLevel();
			return jengine.util.Util.formatFloat(100 * _g._member.critInfo(lev1).chance) + "% (against level " + jengine.util.Util.format(lev1) + " enemies)";
		}),new ostm.battle.StatElement(list,"Crit Damage",function() {
			var lev2 = ostm.battle.BattleManager.instance.spawnLevel();
			return "+" + jengine.util.Util.formatFloat(100 * _g._member.critInfo(lev2).damage,0) + "%";
		}),new ostm.battle.StatElement(list,"Armor",function() {
			return jengine.util.Util.format(_g._member.defense());
		}),new ostm.battle.StatElement(list,"Damage Reduction",function() {
			var lev3 = ostm.battle.BattleManager.instance.spawnLevel();
			return jengine.util.Util.formatFloat(_g._member.damageReduction(lev3) * 100) + "% (against level " + jengine.util.Util.format(lev3) + " enemies)";
		}),new ostm.battle.StatElement(list,"Move Speed",function() {
			return "+" + jengine.util.Util.formatFloat(100 * (_g._member.moveSpeed() - 1),0) + "%";
		}),new ostm.battle.StatElement(list,"Hunting",function() {
			return jengine.util.Util.format(_g._member.huntSkill());
		}),new ostm.battle.StatElement(list,"Enemy spawn time",function() {
			return jengine.util.Util.formatFloat(ostm.battle.BattleManager.instance.enemySpawnTime()) + "s";
		}),new ostm.battle.StatElement(list,"STR",function() {
			return jengine.util.Util.format(_g._member.strength());
		}),new ostm.battle.StatElement(list,"DEX",function() {
			return jengine.util.Util.format(_g._member.dexterity());
		}),new ostm.battle.StatElement(list,"INT",function() {
			return jengine.util.Util.format(_g._member.intelligence());
		}),new ostm.battle.StatElement(list,"VIT",function() {
			return jengine.util.Util.format(_g._member.vitality());
		}),new ostm.battle.StatElement(list,"END",function() {
			return jengine.util.Util.format(_g._member.endurance());
		}),new ostm.battle.StatElement(list,"Power",function() {
			return jengine.util.Util.formatFloat(_g._member.power());
		}),new ostm.battle.StatElement(list,"DPS",function() {
			return jengine.util.Util.formatFloat(_g._member.dps());
		}),new ostm.battle.StatElement(list,"EHP",function() {
			return jengine.util.Util.formatFloat(_g._member.ehp());
		})];
		if(this._member.isPlayer) {
			var equipTab = doc.getElementById("equip-screen");
			var equipContainer = this.createAndAddTo("div",equipTab);
			equipContainer.className = "equip-container";
			var $it0 = this._member.equipment.keys();
			while( $it0.hasNext() ) {
				var k = $it0.next();
				var slot = this.createAndAddTo("div",equipContainer);
				slot.className = (Std.string(k) + "-slot").toLowerCase();
				this._equipment.set(k,slot);
				slot;
				this.updateEquipSlot(k);
			}
		}
	}
	,createAndAddTo: function(tag,parent) {
		var elem = window.document.createElement(tag);
		parent.appendChild(elem);
		return elem;
	}
	,update: function() {
		var _g = 0;
		var _g1 = this._elements;
		while(_g < _g1.length) {
			var stat = _g1[_g];
			++_g;
			stat.update();
		}
		if(this._member.isPlayer) {
			var $it0 = this._equipment.keys();
			while( $it0.hasNext() ) {
				var k = $it0.next();
				var item = this._member.equipment.get(k);
				if(this._cachedEquip.get(k) != item) {
					this._cachedEquip.set(k,item);
					item;
					this.updateEquipSlot(k);
				}
			}
		}
	}
	,updateEquipSlot: function(slot) {
		var item = this._member.equipment.get(slot);
		var elem = this._equipment.get(slot);
		while(elem.childElementCount > 0) elem.removeChild(elem.firstChild);
		if(item != null) elem.appendChild(item.createElement((function($this) {
			var $r;
			var _g = new haxe.ds.StringMap();
			_g.set("Unequip",function(event) {
				item.unequip();
			});
			$r = _g;
			return $r;
		}(this))));
	}
	,__class__: ostm.battle.StatRenderer
});
ostm.item = {};
ostm.item.AffixType = function(data) {
	this.id = data.id;
	this.baseValue = data.base;
	this.valuePerLevel = data.perLevel;
	if(data.levelPower != null) this.levelPower = data.levelPower; else this.levelPower = 1;
	this.modifierFunc = data.modifierFunc;
	this.slotMultipliers = data.multipliers;
};
ostm.item.AffixType.__name__ = true;
ostm.item.AffixType.prototype = {
	levelModifier: function(baseLevel) {
		return Math.round(Math.pow(baseLevel,this.levelPower) + 2);
	}
	,multiplierFor: function(slot) {
		var mult = this.slotMultipliers.get(slot);
		if(mult == null) return 0; else return mult;
	}
	,valueForLevel: function(slot,baseLevel,roll) {
		var level = this.levelModifier(baseLevel);
		var val = this.baseValue + level * (roll / 1000) * this.valuePerLevel;
		var mult = this.multiplierFor(slot);
		return Math.floor(val * mult);
	}
	,canGoInSlot: function(slot) {
		return this.multiplierFor(slot) > 0;
	}
	,applyModifier: function(value,mod) {
		this.modifierFunc(value,mod);
	}
	,__class__: ostm.item.AffixType
};
ostm.item.Affix = function(type,slot) {
	this.type = type;
	this.slot = slot;
	var mod = new ostm.battle.StatModifier();
	type.applyModifier(100,mod);
	var displays = mod.getDisplayData();
	if(displays.length > 0) this.displayData = displays[0]; else this.displayData = null;
};
ostm.item.Affix.__name__ = true;
ostm.item.Affix.loadAffix = function(data) {
	var _g = 0;
	var _g1 = ostm.item.AffixData.affixTypes;
	while(_g < _g1.length) {
		var type = _g1[_g];
		++_g;
		if(type.id == data.id) {
			var affix = new ostm.item.Affix(type,data.slot);
			affix.level = data.level;
			affix.roll = data.roll;
			return affix;
		}
	}
	return null;
};
ostm.item.Affix.prototype = {
	rollItemLevel: function(itemLevel) {
		this.level = itemLevel;
		this.roll = jengine.util.Random.randomIntRange(1,1000);
	}
	,text: function() {
		if(this.displayData == null) return "";
		var val = this.type.valueForLevel(this.slot,this.level,this.roll);
		var str = this.displayData.name + " +" + jengine.util.Util.format(val);
		if(this.displayData.isPercent) str += "%";
		return str;
	}
	,currentValue: function() {
		return this.type.valueForLevel(this.slot,this.level,this.roll);
	}
	,applyModifier: function(mod) {
		var val = this.currentValue();
		this.type.applyModifier(val,mod);
	}
	,subtractModifier: function(mod) {
		var val = this.currentValue();
		this.type.applyModifier(-val,mod);
	}
	,value: function() {
		return 0.2 * this.level * this.roll / 1000;
	}
	,serialize: function() {
		return { id : this.type.id, level : this.level, roll : this.roll, slot : this.slot};
	}
	,__class__: ostm.item.Affix
};
ostm.item.SqrtAffixType = function(data) {
	ostm.item.AffixType.call(this,data);
};
ostm.item.SqrtAffixType.__name__ = true;
ostm.item.SqrtAffixType.__super__ = ostm.item.AffixType;
ostm.item.SqrtAffixType.prototype = $extend(ostm.item.AffixType.prototype,{
	levelModifier: function(baseLevel) {
		return Math.round(Math.sqrt(baseLevel) + 2);
	}
	,__class__: ostm.item.SqrtAffixType
});
ostm.item.ItemSlot = { __ename__ : true, __constructs__ : ["Weapon","Body","Helmet","Boots","Gloves","Ring","Jewel"] };
ostm.item.ItemSlot.Weapon = ["Weapon",0];
ostm.item.ItemSlot.Weapon.toString = $estr;
ostm.item.ItemSlot.Weapon.__enum__ = ostm.item.ItemSlot;
ostm.item.ItemSlot.Body = ["Body",1];
ostm.item.ItemSlot.Body.toString = $estr;
ostm.item.ItemSlot.Body.__enum__ = ostm.item.ItemSlot;
ostm.item.ItemSlot.Helmet = ["Helmet",2];
ostm.item.ItemSlot.Helmet.toString = $estr;
ostm.item.ItemSlot.Helmet.__enum__ = ostm.item.ItemSlot;
ostm.item.ItemSlot.Boots = ["Boots",3];
ostm.item.ItemSlot.Boots.toString = $estr;
ostm.item.ItemSlot.Boots.__enum__ = ostm.item.ItemSlot;
ostm.item.ItemSlot.Gloves = ["Gloves",4];
ostm.item.ItemSlot.Gloves.toString = $estr;
ostm.item.ItemSlot.Gloves.__enum__ = ostm.item.ItemSlot;
ostm.item.ItemSlot.Ring = ["Ring",5];
ostm.item.ItemSlot.Ring.toString = $estr;
ostm.item.ItemSlot.Ring.__enum__ = ostm.item.ItemSlot;
ostm.item.ItemSlot.Jewel = ["Jewel",6];
ostm.item.ItemSlot.Jewel.toString = $estr;
ostm.item.ItemSlot.Jewel.__enum__ = ostm.item.ItemSlot;
ostm.item.ItemSlot.__empty_constructs__ = [ostm.item.ItemSlot.Weapon,ostm.item.ItemSlot.Body,ostm.item.ItemSlot.Helmet,ostm.item.ItemSlot.Boots,ostm.item.ItemSlot.Gloves,ostm.item.ItemSlot.Ring,ostm.item.ItemSlot.Jewel];
ostm.item.AffixData = function() { };
ostm.item.AffixData.__name__ = true;
ostm.item.Inventory = function() {
	this._sizeUpgrades = 0;
	this._inventory = [];
	this.saveId = "inventory";
	jengine.Component.call(this);
};
ostm.item.Inventory.__name__ = true;
ostm.item.Inventory.__interfaces__ = [jengine.Saveable];
ostm.item.Inventory.__super__ = jengine.Component;
ostm.item.Inventory.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		ostm.item.Inventory.instance = this;
	}
	,start: function() {
		this.refreshInventoryHtml();
		jengine.SaveManager.instance.addItem(this);
	}
	,refreshInventoryHtml: function() {
		var _g2 = this;
		var _g = 0;
		var _g1 = this._inventory;
		while(_g < _g1.length) {
			var item = _g1[_g];
			++_g;
			item.cleanupElement();
		}
		var inventory = window.document.getElementById("inventory");
		while(inventory.childElementCount > 0) inventory.removeChild(inventory.firstChild);
		var _this = window.document;
		this._capacityElem = _this.createElement("li");
		inventory.appendChild(this._capacityElem);
		this.updateCapacityElem();
		var sortTexts = ["Value","Power"];
		var sortFuncs = [function(item1) {
			return item1.buyValue();
		},function(item2) {
			return item2.powerDelta();
		}];
		var _g11 = 0;
		var _g3 = sortTexts.length;
		while(_g11 < _g3) {
			var i = _g11++;
			var sortBtn;
			var _this1 = window.document;
			sortBtn = _this1.createElement("button");
			sortBtn.innerText = "Sort " + sortTexts[i];
			var f = [sortFuncs[i]];
			sortBtn.onclick = (function(f) {
				return function(event) {
					_g2._inventory.sort((function(f) {
						return function(it1,it2) {
							return -Reflect.compare(f[0](it1),f[0](it2));
						};
					})(f));
					_g2.refreshInventoryHtml();
				};
			})(f);
			inventory.appendChild(sortBtn);
		}
		inventory.appendChild((function($this) {
			var $r;
			var _this2 = window.document;
			$r = _this2.createElement("br");
			return $r;
		}(this)));
		var discardTexts = ["Basic","Magic","All"];
		var discardAffixes = [0,2,999];
		var _g12 = 0;
		var _g4 = discardTexts.length;
		while(_g12 < _g4) {
			var i1 = [_g12++];
			var clear;
			var _this3 = window.document;
			clear = _this3.createElement("button");
			clear.innerText = "Discard " + discardTexts[i1[0]];
			clear.onclick = (function(i1) {
				return function(event1) {
					var inv = _g2._inventory.slice();
					var _g31 = 0;
					while(_g31 < inv.length) {
						var item3 = inv[_g31];
						++_g31;
						if(item3.numAffixes() <= discardAffixes[i1[0]]) item3.discard();
					}
					_g2.refreshInventoryHtml();
				};
			})(i1);
			inventory.appendChild(clear);
		}
		inventory.appendChild((function($this) {
			var $r;
			var _this4 = window.document;
			$r = _this4.createElement("br");
			return $r;
		}(this)));
		var _g5 = 0;
		var _g13 = this._inventory;
		while(_g5 < _g13.length) {
			var item4 = _g13[_g5];
			++_g5;
			this.appendItemHtml(item4);
		}
	}
	,appendItemHtml: function(item) {
		var _g1 = this;
		var inventory = window.document.getElementById("inventory");
		var li = item.createElement((function($this) {
			var $r;
			var _g = new haxe.ds.StringMap();
			_g.set("Equip",function(event) {
				item.equip();
				_g1.refreshInventoryHtml();
			});
			_g.set("Discard",function(event1) {
				item.discard();
				_g1.refreshInventoryHtml();
			});
			$r = _g;
			return $r;
		}(this)));
		inventory.appendChild(li);
	}
	,push: function(item) {
		this._inventory.push(item);
		this.appendItemHtml(item);
		this.updateCapacityElem();
	}
	,remove: function(item) {
		HxOverrides.remove(this._inventory,item);
	}
	,swap: function(item,forItem) {
		var i = HxOverrides.indexOf(this._inventory,item,0);
		if(i >= 0 && i < this._inventory.length) this._inventory[i] = forItem;
	}
	,updateCapacityElem: function() {
		var str = "Capacity: " + this._inventory.length + " / " + this.capacity();
		this._capacityElem.innerText = str;
	}
	,capacity: function() {
		return 10 + this._sizeUpgrades;
	}
	,capacityUpgradeCost: function() {
		return 10 + 5 * this._sizeUpgrades;
	}
	,upgradeCapacity: function() {
		this._sizeUpgrades++;
		this.updateCapacityElem();
	}
	,hasSpaceForItem: function() {
		return this._inventory.length < this.capacity();
	}
	,randomItem: function(maxLevel,rarityMult) {
		if(rarityMult == null) rarityMult = 1;
		var type = jengine.util.Random.randomElement(ostm.item.ItemData.types);
		var item = new ostm.item.Item(type,maxLevel);
		var level = jengine.util.Random.randomIntRange(1,maxLevel);
		level = jengine.util.Random.randomIntRange(level,maxLevel);
		item.setDropLevel(level);
		var affixOdds;
		var _g = new haxe.ds.IntMap();
		_g.set(4,0.05);
		_g.set(3,0.08);
		_g.set(2,0.20);
		_g.set(1,0.30);
		affixOdds = _g;
		var nAffixes = 0;
		var keys;
		var _g1 = [];
		var _g2 = 0;
		while(_g2 < 4) {
			var i = _g2++;
			_g1.push(4 - i);
		}
		keys = _g1;
		var _g21 = 0;
		while(_g21 < keys.length) {
			var n = keys[_g21];
			++_g21;
			var rarity = affixOdds.get(n) * rarityMult;
			if(jengine.util.Random.randomBool(rarity)) {
				nAffixes = n;
				break;
			}
		}
		item.rollAffixes(nAffixes);
		return item;
	}
	,tryRewardItem: function(enemy,mod) {
		var maxLevel = enemy.level;
		var dropRate = 0.35;
		dropRate *= 1 + mod.percentItemDropRate / 100;
		while((dropRate >= 1 || jengine.util.Random.randomBool(dropRate)) && this.hasSpaceForItem()) {
			var rarityMult = 1 + mod.percentItemRarity / 100;
			this.push(this.randomItem(maxLevel,rarityMult));
			dropRate -= 1;
		}
	}
	,serialize: function() {
		return { items : this._inventory.map(function(item) {
			return item.serialize();
		}), size : this._sizeUpgrades};
	}
	,deserialize: function(data) {
		this._inventory = data.items.map(function(d) {
			return ostm.item.Item.loadItem(d);
		});
		this._sizeUpgrades = data.size;
		if(jengine.SaveManager.instance.loadedVersion < 2) this._sizeUpgrades = 0;
		window.setTimeout($bind(this,this.refreshInventoryHtml),0);
	}
	,__class__: ostm.item.Inventory
});
ostm.item.Item = function(type,level) {
	this.affixes = [];
	this.type = type;
	this.itemLevel = level;
	this.level = level;
};
ostm.item.Item.__name__ = true;
ostm.item.Item.loadItem = function(data) {
	var _g = 0;
	var _g1 = ostm.item.ItemData.types;
	while(_g < _g1.length) {
		var type = _g1[_g];
		++_g;
		if(data.id == type.id) {
			var item = new ostm.item.Item(type,0);
			item.level = data.level;
			item.isOwned = data.isOwned;
			item.itemLevel = data.itemLevel;
			item.tier = Math.floor(item.level / 5);
			item.affixes = data.affixes.map(function(d) {
				return ostm.item.Affix.loadAffix(d);
			});
			return item;
		}
	}
	return null;
};
ostm.item.Item.prototype = {
	setDropLevel: function(level) {
		this.level = level;
	}
	,rollAffixes: function(nAffixes) {
		var _g = this;
		var possibleAffixes = ostm.item.AffixData.affixTypes.filter(function(affixType) {
			return affixType.canGoInSlot(_g.type.slot);
		});
		var selectedAffixes = jengine.util.Random.randomElements(possibleAffixes,nAffixes);
		var _g1 = 0;
		while(_g1 < selectedAffixes.length) {
			var type = selectedAffixes[_g1];
			++_g1;
			var affix = new ostm.item.Affix(type,this.type.slot);
			affix.rollItemLevel(this.itemLevel);
			this.affixes.push(affix);
			nAffixes--;
		}
	}
	,name: function() {
		var t = Math.floor(this.get_tier() / this.type.names.length) + 1;
		var name = this.type.names[this.get_tier() % this.type.names.length];
		if(t > 1 && this.type.names.length > 1) name = "T" + t + " " + name;
		return name;
	}
	,image: function() {
		var image = this.type.images[this.get_tier() % this.type.images.length];
		return "img/items/" + image;
	}
	,equip: function() {
		var player = ostm.battle.BattleManager.instance.getPlayer();
		var cur = player.equipment.get(this.type.slot);
		if(cur != null) ostm.item.Inventory.instance.swap(this,cur); else ostm.item.Inventory.instance.remove(this);
		player.equip(this);
		this.hideBothBodies();
		this.cleanupElement();
	}
	,discard: function() {
		if(ostm.map.MapGenerator.instance.isInTown()) ostm.battle.BattleManager.instance.getPlayer().addGold(this.sellValue());
		ostm.item.Inventory.instance.remove(this);
		this.hideBothBodies();
		this.cleanupElement();
	}
	,unequip: function() {
		var player = ostm.battle.BattleManager.instance.getPlayer();
		var cur = player.equipment.get(this.type.slot);
		if(cur == this && ostm.item.Inventory.instance.hasSpaceForItem()) {
			player.unequip(this);
			ostm.item.Inventory.instance.push(this);
		}
	}
	,getColor: function() {
		if(this.affixes.length > 4) return "#ff2222";
		if(this.affixes.length > 2) return "#ffff22";
		if(this.affixes.length > 0) return "#2277ff";
		return "#ffffff";
	}
	,hideBothBodies: function() {
		this.hideBody();
		var player = ostm.battle.BattleManager.instance.getPlayer();
		var equipped = player.equipment.get(this.type.slot);
		if(equipped != null && equipped != this) equipped.hideBody();
	}
	,createElement: function(buttons) {
		var _g = this;
		var player = ostm.battle.BattleManager.instance.getPlayer();
		var makeNameElem = function() {
			var name;
			var _this = window.document;
			name = _this.createElement("span");
			name.innerText = _g.name();
			name.style.color = _g.getColor();
			return name;
		};
		var _elem;
		var _this1 = window.document;
		_elem = _this1.createElement("span");
		_elem.className = "item";
		_elem.style.background = this.getColor();
		var img;
		var _this2 = window.document;
		img = _this2.createElement("img");
		img.src = this.image();
		_elem.appendChild(img);
		var _this3 = window.document;
		this._buttons = _this3.createElement("span");
		this._buttons.className = "item-buttons";
		var index = 0;
		var clickFuncs = [];
		var $it0 = buttons.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			var f = buttons.get(k);
			var btn;
			var _this4 = window.document;
			btn = _this4.createElement("button");
			btn.onclick = f;
			btn.innerText = k;
			this._buttons.appendChild(btn);
			clickFuncs.push(f);
			index++;
		}
		if(clickFuncs.length > 0) img.onclick = function(event) {
			var checks = [ostm.KeyboardManager.instance.isShiftHeld,ostm.KeyboardManager.instance.isCtrlHeld];
			var _g1 = 0;
			var _g2 = checks.length;
			while(_g1 < _g2) {
				var i = _g1++;
				if(clickFuncs.length > i && checks[i]) clickFuncs[i](event);
			}
		};
		var _this5 = window.document;
		this._body = _this5.createElement("ul");
		this._body.className = "tooltip";
		this._body.appendChild(makeNameElem());
		this.hideBody();
		this._buttons.style.display = "none";
		_elem.onmouseover = function(event1) {
			_g._buttons.style.display = "";
			var pos = jengine._Vec2.Vec2_Impl_._new(event1.x + 20,event1.y - 180);
			_g.showBody(pos);
			var equipped = player.equipment.get(_g.type.slot);
			if(equipped != null && equipped != _g) equipped.showBody((function($this) {
				var $r;
				var rhs = jengine._Vec2.Vec2_Impl_._new(_g._body.clientWidth + 50,0);
				$r = jengine._Vec2.Vec2_Impl_._new(pos.x + rhs.x,pos.y + rhs.y);
				return $r;
			}(this)));
		};
		_elem.onmouseout = function(event2) {
			_g._buttons.style.display = "none";
			_g.hideBothBodies();
		};
		this._body.style.position = "absolute";
		this._body.style.background = "#444444";
		this._body.style.border = "2px solid #000000";
		this._body.style.width = 220;
		this._body.style.zIndex = 10;
		var dlvl;
		var _this6 = window.document;
		dlvl = _this6.createElement("li");
		dlvl.innerText = "Drop Lvl: " + jengine.util.Util.format(this.dropLevel());
		this._body.appendChild(dlvl);
		var ilvl;
		var _this7 = window.document;
		ilvl = _this7.createElement("li");
		ilvl.innerText = "iLvl: " + jengine.util.Util.format(this.itemLevel);
		this._body.appendChild(ilvl);
		var atk;
		var _this8 = window.document;
		atk = _this8.createElement("li");
		atk.innerText = "Attack: " + jengine.util.Util.format(this.attack());
		this._body.appendChild(atk);
		if(js.Boot.__instanceof(this.type,ostm.item.WeaponType)) {
			var spd;
			var _this9 = window.document;
			spd = _this9.createElement("li");
			spd.innerText = "Speed: " + jengine.util.Util.formatFloat(this.attackSpeed()) + "/s";
			this._body.appendChild(spd);
			var crt;
			var _this10 = window.document;
			crt = _this10.createElement("li");
			crt.innerText = "Crit Rating: " + jengine.util.Util.format(this.critRating());
			this._body.appendChild(crt);
		}
		var def;
		var _this11 = window.document;
		def = _this11.createElement("li");
		def.innerText = "Defense: " + jengine.util.Util.format(this.defense());
		this._body.appendChild(def);
		var _g3 = 0;
		var _g11 = this.affixes;
		while(_g3 < _g11.length) {
			var affix = _g11[_g3];
			++_g3;
			var aff;
			var _this12 = window.document;
			aff = _this12.createElement("li");
			aff.innerText = affix.text();
			aff.className = "item-affix";
			this._body.appendChild(aff);
		}
		var powElem;
		var _this13 = window.document;
		powElem = _this13.createElement("li");
		var oldPow = player.power();
		var newPow = player.powerIfEquipped(this);
		this._cachedPowerDelta = newPow - oldPow;
		var powStr = "Power: ";
		if(this._cachedPowerDelta > 0) {
			powElem.className = "item-power-increase";
			powStr += "+";
		} else if(this._cachedPowerDelta < 0) powElem.className = "item-power-decrease";
		powStr += jengine.util.Util.format(this._cachedPowerDelta);
		powElem.innerText = powStr;
		this._body.appendChild(powElem);
		var buy;
		var _this14 = window.document;
		buy = _this14.createElement("li");
		buy.innerText = "Buy Price: " + jengine.util.Util.shortFormat(this.buyValue());
		this._body.appendChild(buy);
		var sell;
		var _this15 = window.document;
		sell = _this15.createElement("li");
		sell.innerText = "Sell Price: " + jengine.util.Util.shortFormat(this.sellValue());
		this._body.appendChild(sell);
		if(this._cachedPowerDelta > 0) {
			var eqHint;
			var _this16 = window.document;
			eqHint = _this16.createElement("div");
			eqHint.className = "item-equip-hint";
			_elem.appendChild(eqHint);
		}
		_elem.appendChild(this._buttons);
		window.document.getElementById("popup-container").appendChild(this._body);
		return _elem;
	}
	,cleanupElement: function() {
		this.hideBothBodies();
		if(this._body != null) this._body.remove();
	}
	,showBody: function(atPos) {
		if(this._body == null) return;
		this._body.style.display = "";
		this._body.style.left = atPos.x;
		this._body.style.top = atPos.y;
	}
	,hideBody: function() {
		if(this._body == null) return;
		this._body.style.display = "none";
	}
	,sumAffixes: function(mod) {
		if(mod == null) mod = new ostm.battle.StatModifier();
		var _g = 0;
		var _g1 = this.affixes;
		while(_g < _g1.length) {
			var affix = _g1[_g];
			++_g;
			affix.applyModifier(mod);
		}
		return mod;
	}
	,subtractAffixes: function(mod) {
		var _g = 0;
		var _g1 = this.affixes;
		while(_g < _g1.length) {
			var affix = _g1[_g];
			++_g;
			affix.subtractModifier(mod);
		}
		return mod;
	}
	,attack: function() {
		var mod = this.sumAffixes();
		var atk = this.type.attack;
		atk *= 1 + 2. * this.get_tier();
		atk += mod.localFlatAttack;
		atk *= 1 + mod.localPercentAttack / 100;
		return Math.round(atk);
	}
	,attackSpeed: function() {
		if(!js.Boot.__instanceof(this.type,ostm.item.WeaponType)) return 0;
		var wep;
		wep = js.Boot.__cast(this.type , ostm.item.WeaponType);
		var mod = this.sumAffixes();
		var spd = wep.attackSpeed;
		spd *= 1 + mod.localPercentAttackSpeed / 100;
		return spd;
	}
	,critRating: function() {
		var crt = 0;
		if(js.Boot.__instanceof(this.type,ostm.item.WeaponType)) {
			var wep;
			wep = js.Boot.__cast(this.type , ostm.item.WeaponType);
			crt = wep.crit;
			crt *= 1 + 0.5 * this.get_tier();
		}
		var mod = this.sumAffixes();
		crt += mod.localFlatCritRating;
		crt *= 1 + mod.localPercentCritRating / 100;
		return Math.round(crt);
	}
	,defense: function() {
		var mod = this.sumAffixes();
		var def = this.type.defense;
		def *= 1 + 2. * this.get_tier();
		def += mod.localFlatDefense;
		def *= 1 + mod.localPercentDefense / 100;
		return Math.round(def);
	}
	,buyValue: function() {
		var value = Math.pow(this.get_tier() + 1,2.2) * 10;
		var mult = 1.0;
		var _g = 0;
		var _g1 = this.affixes;
		while(_g < _g1.length) {
			var affix = _g1[_g];
			++_g;
			mult += affix.value();
		}
		return Math.round(value * mult);
	}
	,sellValue: function() {
		return Math.round(Math.pow(this.buyValue(),0.85) * 0.5);
	}
	,numAffixes: function() {
		return this.affixes.length;
	}
	,powerDelta: function() {
		return this._cachedPowerDelta;
	}
	,get_tier: function() {
		return Math.floor(this.level / 5);
	}
	,dropLevel: function() {
		var dropLevel = this.get_tier() * 5;
		if(dropLevel > 0) return dropLevel; else return 1;
	}
	,serialize: function() {
		return { id : this.type.id, itemLevel : this.itemLevel, level : this.level, isOwned : this.isOwned, affixes : this.affixes.map(function(affix) {
			return affix.serialize();
		})};
	}
	,__class__: ostm.item.Item
	,__properties__: {get_tier:"get_tier"}
};
ostm.item.ItemType = function(data) {
	this.id = data.id;
	this.images = data.images;
	this.names = data.names;
	this.slot = data.slot;
	this.attack = data.attack;
	this.defense = data.defense;
};
ostm.item.ItemType.__name__ = true;
ostm.item.ItemType.prototype = {
	__class__: ostm.item.ItemType
};
ostm.item.WeaponType = function(data) {
	ostm.item.ItemType.call(this,{ id : data.id, images : data.images, names : data.names, slot : ostm.item.ItemSlot.Weapon, attack : data.attack, defense : data.defense});
	this.attackSpeed = data.attackSpeed;
	this.crit = data.crit;
};
ostm.item.WeaponType.__name__ = true;
ostm.item.WeaponType.__super__ = ostm.item.ItemType;
ostm.item.WeaponType.prototype = $extend(ostm.item.ItemType.prototype,{
	__class__: ostm.item.WeaponType
});
ostm.item.ItemData = function() { };
ostm.item.ItemData.__name__ = true;
ostm.item.ItemData.getItemType = function(id) {
	var _g = 0;
	var _g1 = ostm.item.ItemData.types;
	while(_g < _g1.length) {
		var type = _g1[_g];
		++_g;
		if(type.id == id) return type;
	}
	return null;
};
ostm.map = {};
ostm.map.MapGenerator = function() {
	this._hints = [{ x : 4, y : -1, level : 0},{ x : 8, y : -2, level : 5}];
	this._movePath = null;
	this._moveTimer = 0;
	this._shouldCenter = true;
	this._rand = new ostm.map.StaticRandom();
	this._gridGeneratedFlags = new haxe.ds.IntMap();
	this._generated = new haxe.ds.IntMap();
	this.saveId = "map";
	jengine.Component.call(this);
};
ostm.map.MapGenerator.__name__ = true;
ostm.map.MapGenerator.__interfaces__ = [jengine.Saveable];
ostm.map.MapGenerator.__super__ = jengine.Component;
ostm.map.MapGenerator.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		ostm.map.MapGenerator.instance = this;
	}
	,start: function() {
		var _g1 = this;
		jengine.SaveManager.instance.addItem(this);
		this._scrollHelper = new jengine.Entity([new jengine.HtmlRenderer({ parent : "map-screen", size : jengine._Vec2.Vec2_Impl_._new(1,1)}),new jengine.Transform(jengine._Vec2.Vec2_Impl_._new(0,0))]);
		this.entity.getSystem().addEntity(this._scrollHelper);
		this._moveBarTransform = new jengine.Transform();
		var moveBarEntity = new jengine.Entity([this._moveBarTransform,new jengine.HtmlRenderer({ parent : "map-screen", className : "move-bar", style : (function($this) {
			var $r;
			var _g = new haxe.ds.StringMap();
			_g.set("position","fixed");
			$r = _g;
			return $r;
		}(this))}),new ostm.ProgressBar(function() {
			return _g1._moveTimer / 12.0;
		})]);
		this.entity.getSystem().addEntity(moveBarEntity);
		this._mapScreenElem = window.document.getElementById("map-screen");
		this.generateSurroundingCells(0,0);
		this.setSelected(this._start);
		this.updateScrollBounds();
		this.centerCurrentNode();
		window.setTimeout(function() {
			ostm.NotificationManager.instance.queueNotification(ostm.NotificationType.MapUpdate);
		},0);
	}
	,update: function() {
		var _g = this;
		var rect = this._mapScreenElem.getBoundingClientRect();
		this._moveBarTransform.pos = jengine._Vec2.Vec2_Impl_._new(rect.left + 20,rect.top + 20);
		if(this._shouldCenter && this.selectedNode.elem != null) {
			window.setTimeout(function() {
				_g.selectedNode.elem.scrollIntoViewIfNeeded(true);
			},0);
			this._shouldCenter = false;
		}
		if(ostm.battle.BattleManager.instance.isInBattle() || ostm.battle.BattleManager.instance.isPlayerDead()) return;
		var player = ostm.battle.BattleManager.instance.getPlayer();
		this._moveTimer += jengine.Time.dt * player.moveSpeed();
		if(this.isInTown()) this._moveTimer = 12.0;
		if(this._movePath != null) {
			if(this._moveTimer >= 12.0 && !ostm.battle.BattleManager.instance.isInBattle()) {
				this._moveTimer = 0;
				var next = this._movePath[1];
				this.setSelected(next);
				HxOverrides.remove(this._movePath,next);
				if(this._movePath.length <= 1) {
					this.selectedNode.clearPath();
					this._movePath = null;
				}
			}
		}
	}
	,getGridCoord: function(i,j) {
		return { x : Math.floor(i / 5), y : Math.floor(j / 5)};
	}
	,getPosForGridCoord: function(x,y) {
		return { i : x * 5, j : y * 5};
	}
	,setSelected: function(next) {
		if(this.selectedNode != null) {
			this.selectedNode.clearPath();
			this.selectedNode.clearOccupied();
		}
		this.selectedNode = next;
		this.generateSurroundingCells(next.depth,next.height);
		this.selectedNode.setOccupied();
		ostm.battle.BattleManager.instance.resetKillCount();
		if(next.isTown()) {
			this._checkpoint = next;
			var gridPos = this.getGridCoord(next.depth,next.height);
			this.forAllNodesInGridCell(gridPos.x,gridPos.y,function(node) {
				node.setVisible();
			});
			var xs = [1,-1,0,0];
			var ys = [0,0,1,-1];
			var _g1 = 0;
			var _g = xs.length;
			while(_g1 < _g) {
				var i = _g1++;
				this.forAllNodesInGridCell(gridPos.x + xs[i],gridPos.y + ys[i],function(node1) {
					if(node1.isTown()) node1.setVisible();
				});
			}
		}
		this.forAllNodes(function(node2) {
			if(node2.isHint()) node2._dirtyFlag = true;
		});
		this.updateScrollBounds();
		this.centerCurrentNode();
		window.setTimeout(function() {
			ostm.NotificationManager.instance.queueNotification(ostm.NotificationType.MapUpdate);
		},0);
	}
	,generateSurroundingCells: function(i,j) {
		var p = this.getGridCoord(i,j);
		var xs = [0,-1,1,0,0];
		var ys = [0,0,0,-1,1];
		var _g1 = 0;
		var _g = xs.length;
		while(_g1 < _g) {
			var k = _g1++;
			this.generateGridCell(p.x + xs[k],p.y + ys[k]);
		}
	}
	,cellSeed: function(x,y) {
		return 4613767 + 21487 * x + 54013 * y + 147 * x * y;
	}
	,didGenerateCell: function(x,y) {
		if(this._gridGeneratedFlags.get(x) == null) {
			var v = new haxe.ds.IntMap();
			this._gridGeneratedFlags.set(x,v);
			v;
		}
		var this1 = this._gridGeneratedFlags.get(x);
		return this1.get(y);
	}
	,generateGridCell: function(x,y) {
		var _g = this;
		if(this.didGenerateCell(x,y)) return;
		if(x == 1 && y == 0) return;
		var this1 = this._gridGeneratedFlags.get(x);
		this1.set(y,true);
		true;
		var isOriginCell = x == 0 && y == 0;
		var pos = this.getPosForGridCoord(x,y);
		var seed = this.cellSeed(x,y);
		var leftSeed = this.cellSeed(x - 1,y);
		var rightSeed = this.cellSeed(x + 1,y);
		var upSeed = this.cellSeed(x,y + 1);
		var downSeed = this.cellSeed(x,y - 1);
		var leftY = this._rand.setSeed(seed + leftSeed).randomInt(3) + 1;
		var rightY = this._rand.setSeed(seed + rightSeed).randomInt(3) + 1;
		var downX = this._rand.setSeed(seed + downSeed).randomInt(3) + 1;
		var upX = this._rand.setSeed(seed + upSeed).randomInt(3) + 1;
		this._rand.setSeed(seed);
		var left = this.addNode(null,pos.i,pos.j + leftY);
		var right = this.addNode(null,pos.i + 5 - 1,pos.j + rightY);
		var down = this.addNode(null,pos.i + downX,pos.j);
		var up = this.addNode(null,pos.i + upX,pos.j + 5 - 1);
		var startNodes = [left];
		if(HxOverrides.indexOf(startNodes,right,0) == -1) startNodes.push(right);
		if(HxOverrides.indexOf(startNodes,up,0) == -1) startNodes.push(up);
		if(HxOverrides.indexOf(startNodes,down,0) == -1) startNodes.push(down);
		var cellNodes = startNodes.slice();
		var findPathWithinCell = function(start,end) {
			return _g.bfsPath(start,function(node) {
				return node == end;
			},function(node1) {
				return true;
			});
		};
		var isDone = function() {
			return findPathWithinCell(left,right) != null && findPathWithinCell(left,up) != null && findPathWithinCell(left,down) != null;
		};
		var xs = [-1,1,0,0];
		var ys = [0,0,-1,1];
		while(!isDone()) {
			var node2 = this._rand.randomElement(cellNodes);
			var k = this._rand.randomInt(xs.length);
			var i = node2.depth + xs[k];
			var j = node2.height + ys[k];
			if(i >= pos.i && i < pos.i + 5 && j >= pos.j && j < pos.j + 5) {
				var n = this.getNode(i,j);
				if(n == null) {
					n = this.addNode(node2,i,j);
					cellNodes.push(n);
				} else if(this._rand.randomBool(0.1)) n.addNeighbor(node2);
			}
		}
		var canTrim = function(node3) {
			return HxOverrides.indexOf(startNodes,node3,0) == -1 && node3.neighbors.length == 1;
		};
		var trimmable = function() {
			return cellNodes.filter(canTrim);
		};
		while(trimmable().length > 0) {
			var toTrim = trimmable();
			var _g1 = 0;
			while(_g1 < toTrim.length) {
				var node4 = toTrim[_g1];
				++_g1;
				this.removeNode(node4.depth,node4.height);
				HxOverrides.remove(cellNodes,node4);
			}
		}
		var tryConnect = function(i1,j1,i2,j2,force) {
			if(force == null) force = false;
			var a = _g.getNode(i1,j1);
			var b = _g.getNode(i2,j2);
			if((force || _g._rand.randomBool(0.35)) && a != null && b != null) a.addNeighbor(b);
		};
		tryConnect(left.depth - 1,left.height,left.depth,left.height,true);
		tryConnect(right.depth + 1,right.height,right.depth,right.height,true);
		tryConnect(down.depth,down.height - 1,down.depth,down.height,true);
		tryConnect(up.depth,up.height + 1,up.depth,up.height,true);
		var _g2 = 0;
		while(_g2 < 5) {
			var k1 = _g2++;
			tryConnect(pos.i + k1,pos.j,pos.i + k1,pos.j - 1);
			tryConnect(pos.i + k1,pos.j + 5 - 1,pos.i + k1,pos.j + 5);
			tryConnect(pos.i,pos.j + k1,pos.i - 1,pos.j + k1);
			tryConnect(pos.i + 5 - 1,pos.j + k1,pos.i + 5,pos.j + k1);
		}
		var distToOrigin = Math.floor(Math.abs(x) + Math.abs(y));
		var cellLevel = distToOrigin * 6;
		var cellRegion = this._rand.randomInt(Math.round(jengine.util.Util.clamp(distToOrigin,2,3)));
		if(isOriginCell) cellRegion = 0;
		var _g3 = 0;
		while(_g3 < cellNodes.length) {
			var node5 = cellNodes[_g3];
			++_g3;
			node5.level = cellLevel + 1;
			node5.region = cellRegion;
		}
		var leftLev;
		if(Math.abs(x - 1) > Math.abs(x)) leftLev = 6; else leftLev = 1;
		var rightLev;
		if(Math.abs(x + 1) > Math.abs(x)) rightLev = 6; else rightLev = 1;
		var downLev;
		if(Math.abs(y - 1) > Math.abs(y)) downLev = 6; else downLev = 1;
		var upLev;
		if(Math.abs(y + 1) > Math.abs(y)) upLev = 6; else upLev = 1;
		if(isOriginCell) rightLev = 1;
		startNodes = [left,right,down,up];
		var startLevels = [leftLev,rightLev,downLev,upLev];
		var _g4 = 0;
		while(_g4 < cellNodes.length) {
			var node6 = cellNodes[_g4];
			++_g4;
			var lev;
			if(HxOverrides.indexOf(startNodes,node6,0) != -1) lev = startLevels[HxOverrides.indexOf(startNodes,node6,0)]; else {
				var dists = [];
				var _g11 = 0;
				while(_g11 < startNodes.length) {
					var s = startNodes[_g11];
					++_g11;
					dists.push(findPathWithinCell(node6,s).length - 1);
				}
				var loDist = 50;
				var _g21 = 0;
				var _g12 = dists.length;
				while(_g21 < _g12) {
					var i3 = _g21++;
					var d = dists[i3];
					if(d < loDist && startLevels[i3] == 1) loDist = d;
				}
				var loInd = HxOverrides.indexOf(dists,loDist,0);
				var hiInd;
				hiInd = (loInd + 1) % 2 + (loInd >= 2?2:0);
				var hiDist = dists[hiInd];
				var totDist = loDist + hiDist;
				lev = Math.round(jengine.util.Util.clamp(loDist / totDist,0,1) * 5 + 1);
				lev = jengine.util.Util.clampInt(lev + this._rand.randomElement([-1,0,0,1]),1,6);
			}
			node6.level = lev + cellLevel;
		}
		if(!isOriginCell) {
			var townNode = this._rand.randomElement(cellNodes);
			townNode.town = true;
		} else {
			var minLevelNode = null;
			var _g5 = 0;
			while(_g5 < cellNodes.length) {
				var node7 = cellNodes[_g5];
				++_g5;
				if(minLevelNode == null || minLevelNode.level > node7.level) minLevelNode = node7;
			}
			this._start = minLevelNode;
			this._start.town = true;
		}
		this.updateScrollBounds();
	}
	,getNode: function(i,j) {
		if(this._generated.get(i) != null && (function($this) {
			var $r;
			var this1 = $this._generated.get(i);
			$r = this1.get(j);
			return $r;
		}(this)) != null) {
			var this2 = this._generated.get(i);
			return this2.get(j);
		}
		return null;
	}
	,addNode: function(parent,i,j) {
		if(this.getNode(i,j) != null) return this.getNode(i,j);
		var size = jengine._Vec2.Vec2_Impl_._new(40,40);
		var node = new ostm.map.MapNode(this,i,j,parent);
		var ent = new jengine.Entity([new jengine.HtmlRenderer({ parent : "map-screen", size : size}),new jengine.Transform(),node]);
		this.entity.getSystem().addEntity(ent);
		if(this._generated.get(i) == null) {
			var v = new haxe.ds.IntMap();
			this._generated.set(i,v);
			v;
		}
		var this1 = this._generated.get(i);
		this1.set(j,node);
		node;
		return node;
	}
	,removeNode: function(i,j) {
		var node = this.getNode(i,j);
		if(node == null) return;
		var _g = 0;
		var _g1 = node.neighbors;
		while(_g < _g1.length) {
			var n = _g1[_g];
			++_g;
			n.removeNeighbor(node);
		}
		this.entity.getSystem().removeEntity(node.entity);
		var this1 = this._generated.get(i);
		this1.remove(j);
	}
	,tryUncross: function(i,j) {
		if(this._generated.get(i) == null || this._generated.get(i - 1) == null) return;
		var ul;
		var this1 = this._generated.get(i - 1);
		ul = this1.get(j - 1);
		var ur;
		var this2 = this._generated.get(i);
		ur = this2.get(j - 1);
		var dl;
		var this3 = this._generated.get(i - 1);
		dl = this3.get(j);
		var dr;
		var this4 = this._generated.get(i);
		dr = this4.get(j);
		if(ul != null && ur != null && dl != null && dr != null && this.isAdjacent(ul,dr) && this.isAdjacent(ur,dl)) {
			if(this._rand.randomBool() && !(ul.isGoldPath && dr.isGoldPath) || ur.isGoldPath && dl.isGoldPath) ul.removeNeighbor(dr); else ur.removeNeighbor(dl);
			ul.addNeighbor(ur);
			dl.addNeighbor(dr);
		}
	}
	,setPath: function(path) {
		this._movePath = path;
		this.forAllNodes(function(node) {
			node.clearPath();
		});
		if(path != null) {
			var _g = 0;
			while(_g < path.length) {
				var n = path[_g];
				++_g;
				n.setPath(path);
			}
		}
	}
	,click: function(node) {
		if(node == this.selectedNode) {
			this.setPath(null);
			return;
		}
		if(ostm.TownManager.instance.shouldWarp && node.isTown() && node.hasVisited()) {
			this.setPath(null);
			this.setSelected(node);
			return;
		}
		var path = this.findPath(this.selectedNode,node);
		if(path == null) return;
		this.setPath(path);
		ostm.NotificationManager.instance.queueNotification(ostm.NotificationType.MapUpdate);
	}
	,hover: function(node) {
		var path = this.findPath(this.selectedNode,node);
		if(path != null) {
			var _g = 0;
			while(_g < path.length) {
				var n = path[_g];
				++_g;
				n.setPathHighlight(path);
			}
		}
		ostm.NotificationManager.instance.queueNotification(ostm.NotificationType.MapUpdate);
	}
	,hoverOver: function(node) {
		this.forAllNodes(function(node1) {
			node1.clearPathHighlight();
		});
		ostm.NotificationManager.instance.queueNotification(ostm.NotificationType.MapUpdate);
	}
	,forAllNodes: function(f) {
		var $it0 = this._generated.iterator();
		while( $it0.hasNext() ) {
			var map = $it0.next();
			var $it1 = map.iterator();
			while( $it1.hasNext() ) {
				var node = $it1.next();
				f(node);
			}
		}
	}
	,forAllNodesInGridCell: function(x,y,f) {
		var _g1 = x * 5;
		var _g = (x + 1) * 5;
		while(_g1 < _g) {
			var i = _g1++;
			var row = this._generated.get(i);
			if(row != null) {
				var _g3 = y * 5;
				var _g2 = (y + 1) * 5;
				while(_g3 < _g2) {
					var j = _g3++;
					var node = row.get(j);
					if(node != null) f(node);
				}
			}
		}
	}
	,updateScrollBounds: function() {
		var topLeft = jengine._Vec2.Vec2_Impl_._new(Math.POSITIVE_INFINITY,Math.POSITIVE_INFINITY);
		var botRight = jengine._Vec2.Vec2_Impl_._new(Math.NEGATIVE_INFINITY,Math.NEGATIVE_INFINITY);
		var origin = jengine._Vec2.Vec2_Impl_._new(100,100);
		this.forAllNodes(function(node) {
			if(node.hasSeen()) {
				var pos = node.getOffset();
				topLeft = jengine._Vec2.Vec2_Impl_.min(topLeft,pos);
			}
		});
		this.forAllNodes(function(node1) {
			var pos1;
			var lhs;
			var rhs = node1.getOffset();
			lhs = jengine._Vec2.Vec2_Impl_._new(origin.x + rhs.x,origin.y + rhs.y);
			pos1 = jengine._Vec2.Vec2_Impl_._new(lhs.x - topLeft.x,lhs.y - topLeft.y);
			node1.entity.getComponent(jengine.Transform).pos = pos1;
			if(node1.hasSeen()) botRight = jengine._Vec2.Vec2_Impl_.max(botRight,pos1);
		});
		var scrollBuffer = jengine._Vec2.Vec2_Impl_._new(250,150);
		var lhs1 = jengine._Vec2.Vec2_Impl_._new(origin.x + botRight.x,origin.y + botRight.y);
		this._scrollHelper.getComponent(jengine.Transform).pos = jengine._Vec2.Vec2_Impl_._new(lhs1.x + scrollBuffer.x,lhs1.y + scrollBuffer.y);
		this.forAllNodes(function(node2) {
			node2._dirtyFlag = true;
		});
	}
	,centerCurrentNode: function() {
		this._shouldCenter = true;
	}
	,isAdjacent: function(a,b) {
		return HxOverrides.indexOf(a.neighbors,b,0) != -1;
	}
	,bfsPath: function(start,endFunction,allowedFunction) {
		if(endFunction(start)) return [start];
		var openSet = new Array();
		var closedSet = new haxe.ds.ObjectMap();
		openSet.push(start);
		closedSet.set(start,start);
		start;
		var constructPath = function(node) {
			var path = new Array();
			var n = node;
			while(n != start) {
				path.push(n);
				n = closedSet.h[n.__id__];
			}
			path.push(start);
			path.reverse();
			return path;
		};
		while(openSet.length > 0) {
			var node1 = openSet[0];
			HxOverrides.remove(openSet,node1);
			var _g = 0;
			var _g1 = node1.neighbors;
			while(_g < _g1.length) {
				var m = _g1[_g];
				++_g;
				var n1 = m;
				var canVisit = allowedFunction(n1);
				if(canVisit) {
					if(closedSet.h[n1.__id__] == null) {
						openSet.push(n1);
						closedSet.set(n1,node1);
						node1;
					}
					if(endFunction(n1)) return constructPath(n1);
				}
			}
		}
		return null;
	}
	,findPath: function(start,end) {
		return this.bfsPath(start,function(node) {
			return node == end;
		},function(node1) {
			return node1 == end || node1.hasVisited();
		});
	}
	,returnToCheckpoint: function() {
		this.setSelected(this._checkpoint);
		if(this._movePath != null) {
			var _g = 0;
			var _g1 = this._movePath;
			while(_g < _g1.length) {
				var n = _g1[_g];
				++_g;
				n.clearPath();
			}
			this._movePath = null;
		}
	}
	,isInTown: function() {
		return this.selectedNode.isTown();
	}
	,serialize: function() {
		var nodes = [];
		this.forAllNodes(function(node) {
			nodes.push(node.serialize());
		});
		var cells = [];
		var $it0 = this._gridGeneratedFlags.keys();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			var $it1 = (function($this) {
				var $r;
				var this1 = $this._gridGeneratedFlags.get(x);
				$r = this1.keys();
				return $r;
			}(this));
			while( $it1.hasNext() ) {
				var y = $it1.next();
				if((function($this) {
					var $r;
					var this2 = $this._gridGeneratedFlags.get(x);
					$r = this2.get(y);
					return $r;
				}(this))) cells.push({ x : x, y : y});
			}
		}
		return { selected : { i : this.selectedNode.depth, j : this.selectedNode.height}, checkpoint : { i : this._checkpoint.depth, j : this._checkpoint.height}, cells : cells, nodes : nodes};
	}
	,deserialize: function(data) {
		var nodes = data.nodes;
		var cells = data.cells;
		var _g = 0;
		while(_g < cells.length) {
			var c = cells[_g];
			++_g;
			this.generateGridCell(c.x,c.y);
		}
		var _g1 = 0;
		while(_g1 < nodes.length) {
			var n = nodes[_g1];
			++_g1;
			var arr;
			var key = n.i;
			arr = this._generated.get(key);
			var node = null;
			if(arr != null) {
				var key1 = n.j;
				node = arr.get(key1);
			}
			if(node != null) node.deserialize(n);
		}
		var sel = this.getNode(data.selected.i,data.selected.j);
		if(sel != null) {
			this.selectedNode.clearOccupied();
			this.selectedNode = sel;
			sel.setOccupied();
		}
		var chk = this.getNode(data.checkpoint.i,data.checkpoint.j);
		if(chk != null) this._checkpoint = chk;
		this.updateScrollBounds();
		this.centerCurrentNode();
		window.setTimeout(function() {
			ostm.NotificationManager.instance.queueNotification(ostm.NotificationType.MapUpdate);
		},0);
	}
	,__class__: ostm.map.MapGenerator
});
ostm.map.MapNode = function(gen,d,h,par) {
	this._highlightedLineWidth = 8;
	this._hintLevel = -1;
	this._dirtyFlag = true;
	this._isOccupied = false;
	this._highlightedPath = null;
	this._selectedPath = null;
	this._isVisited = false;
	this._isVisible = false;
	this.isGoldPath = false;
	this.town = false;
	this.level = 0;
	this.region = 0;
	ostm.GameNode.call(this,d,h);
	this.map = gen;
	if(par != null) {
		this._parent = par;
		this.addNeighbor(par);
	}
};
ostm.map.MapNode.__name__ = true;
ostm.map.MapNode.__interfaces__ = [ostm.NotificationReceiver];
ostm.map.MapNode.__super__ = ostm.GameNode;
ostm.map.MapNode.prototype = $extend(ostm.GameNode.prototype,{
	setHint: function(hint) {
		this._hintLevel = hint.level;
	}
	,getRandomRegion: function(rand) {
		var d = rand.randomElement([-1,1,1,2]);
		var max;
		if(this.isGoldPath) max = 4; else max = 4;
		return (this.region + max + d) % max;
	}
	,start: function() {
		ostm.GameNode.prototype.start.call(this);
		ostm.NotificationManager.instance.register(this,ostm.NotificationType.MapUpdate);
	}
	,postStart: function() {
		if(this._isOccupied) this.map.centerCurrentNode();
	}
	,isPathVisible: function(node) {
		return this.hasSeen() && node.hasVisited() || this.hasVisited() && node.hasSeen();
	}
	,isLinePartOfPath: function(line,path) {
		var node;
		node = js.Boot.__cast(line.node , ostm.map.MapNode);
		return (HxOverrides.indexOf(path,this,0) != -1 || HxOverrides.indexOf(path,node,0) != -1) && (node._highlightedPath == path || node._selectedPath == path);
	}
	,receivedNotification: function(notification) {
		if(notification == ostm.NotificationType.MapUpdate && this._dirtyFlag) {
			this._dirtyFlag = false;
			var color = this.getColor().asHtml();
			var borderColor = "#000000";
			var isHighlighted = true;
			if(this._isOccupied) borderColor = "#ffff00"; else if(this._highlightedPath != null) borderColor = "#00ffff"; else if(this._selectedPath != null) borderColor = "#00ff00"; else if(!this.hasVisited()) borderColor = "#888888"; else isHighlighted = false;
			var borderWidth = this._lineWidth;
			this.elem.style.background = color;
			this.elem.style.border = borderWidth + "px solid " + borderColor;
			if(this.hasSeen()) this.elem.style.display = ""; else this.elem.style.display = "none";
			if(this.isHintVisible() && !this.hasVisited()) {
				this.elem.innerText = "?";
				this.elem.style.fontSize = "30px";
			} else if(this.isTown()) {
				this.elem.innerText = "T";
				this.elem.style.fontSize = "30px";
			} else {
				var lev = this.areaLevel();
				this.elem.innerText = lev;
				if(lev < 100) this.elem.style.fontSize = "30px"; else this.elem.style.fontSize = "20px";
			}
			var size = this.entity.getComponent(jengine.HtmlRenderer).size;
			var pos = this.entity.getComponent(jengine.Transform).pos;
			var _g = 0;
			var _g1 = this.lines;
			while(_g < _g1.length) {
				var line = _g1[_g];
				++_g;
				var disp = this.isPathVisible(js.Boot.__cast(line.node , ostm.map.MapNode));
				if(disp) line.elem.style.display = ""; else line.elem.style.display = "none";
				if(!disp) continue;
				var lineColor = "#000000";
				var lineIsHighlighted = true;
				if(this._highlightedPath != null && this.isLinePartOfPath(line,this._highlightedPath)) lineColor = "#00ffff"; else if(this._selectedPath != null && this.isLinePartOfPath(line,this._selectedPath)) lineColor = "#00ff00"; else lineIsHighlighted = false;
				var lineWidth;
				if(lineIsHighlighted) lineWidth = this._highlightedLineWidth; else lineWidth = this._lineWidth;
				line.elem.style.left = pos.x + line.offset.x;
				line.elem.style.top = pos.y + line.offset.y;
				line.elem.style.background = lineColor;
				line.elem.style.width = lineWidth;
			}
		}
	}
	,getColor: function() {
		var color = null;
		var _g = this.region;
		switch(_g) {
		case 0:
			color = new jengine.Color(255,0,0);
			break;
		case 1:
			color = new jengine.Color(255,136,0);
			break;
		case 2:
			color = new jengine.Color(255,255,0);
			break;
		case 3:
			color = new jengine.Color(136,255,0);
			break;
		case 4:
			color = new jengine.Color(0,255,0);
			break;
		case 5:
			color = new jengine.Color(0,255,136);
			break;
		case 6:
			color = new jengine.Color(0,255,255);
			break;
		case 7:
			color = new jengine.Color(0,136,255);
			break;
		case 8:
			color = new jengine.Color(0,0,255);
			break;
		case 9:
			color = new jengine.Color(136,0,255);
			break;
		case 10:
			color = new jengine.Color(255,0,255);
			break;
		case 11:
			color = new jengine.Color(255,0,136);
			break;
		default:
			color = new jengine.Color(0,0,0);
		}
		if(this.isTown()) color = new jengine.Color(240,240,240);
		if(!this._isVisited) color = color.multiply(0.5);
		return color;
	}
	,isDirty: function() {
		return this._dirtyFlag;
	}
	,markDirty: function() {
		this._dirtyFlag = true;
	}
	,onMouseOver: function(event) {
		this.map.hover(this);
	}
	,onMouseOut: function(event) {
		this.map.hoverOver(this);
	}
	,onClick: function(event) {
		this.map.click(this);
	}
	,setVisible: function() {
		this._isVisible = true;
		this._dirtyFlag = true;
	}
	,setPath: function(path) {
		this._selectedPath = path;
		this._dirtyFlag = true;
	}
	,clearPath: function() {
		this._selectedPath = null;
		this._dirtyFlag = true;
	}
	,setOccupied: function() {
		this._isVisible = true;
		this._isVisited = true;
		this._isOccupied = true;
		ostm.map.MapNode._highestVisited = jengine.util.Util.intMax(ostm.map.MapNode._highestVisited,this.depth);
		this.markNeighborsVisible();
		this._dirtyFlag = true;
		var bg = window.document.getElementById("battle-screen");
		bg.style.background = this.getColor().mix(new jengine.Color(128,128,128)).asHtml();
	}
	,clearOccupied: function() {
		this._isOccupied = false;
		this._dirtyFlag = true;
	}
	,setPathHighlight: function(path) {
		this._highlightedPath = path;
		this._dirtyFlag = true;
	}
	,clearPathHighlight: function() {
		this._highlightedPath = null;
		this._dirtyFlag = true;
	}
	,setGoldPath: function() {
		this.isGoldPath = true;
	}
	,markNeighborsVisible: function() {
		var _g = 0;
		var _g1 = this.neighbors;
		while(_g < _g1.length) {
			var node = _g1[_g];
			++_g;
			(js.Boot.__cast(node , ostm.map.MapNode)).setVisible();
		}
	}
	,canBeSeen: function() {
		return this.region < 4;
	}
	,canMarkSeen: function() {
		return !this._isVisible && this.canBeSeen();
	}
	,hasSeen: function() {
		return this._isVisible && this.canBeSeen() || this.isHintVisible();
	}
	,hasVisited: function() {
		return this._isVisited && this.canBeSeen();
	}
	,hasUnseenNeighbors: function() {
		var _g = 0;
		var _g1 = this.neighbors;
		while(_g < _g1.length) {
			var node = _g1[_g];
			++_g;
			if((js.Boot.__cast(node , ostm.map.MapNode)).canMarkSeen()) return true;
		}
		return false;
	}
	,unlockRandomNeighbor: function() {
		var unseen = this.neighbors.filter(function(node) {
			return (js.Boot.__cast(node , ostm.map.MapNode)).canMarkSeen();
		});
		if(unseen.length > 0) {
			var node1 = jengine.util.Random.randomElement(unseen);
			(js.Boot.__cast(node1 , ostm.map.MapNode)).setVisible();
			this._dirtyFlag = true;
		} else console.log("warning: trying to unlock neighbor on node with no unseen neighbors");
	}
	,areaLevel: function() {
		return this.level;
	}
	,isHint: function() {
		return this._hintLevel >= 0;
	}
	,isHintVisible: function() {
		return this.isHint() && ostm.map.MapNode._highestVisited >= this._hintLevel;
	}
	,isTown: function() {
		return this.town;
	}
	,setNewRegion: function(parent,rand) {
		this.region = parent.getRandomRegion(rand);
	}
	,serialize: function() {
		return { i : this.depth, j : this.height, visible : this._isVisible, visited : this._isVisited};
	}
	,deserialize: function(data) {
		this._isVisible = data.visible;
		this._isVisited = data.visited;
		this._dirtyFlag = true;
	}
	,__class__: ostm.map.MapNode
});
ostm.map.StaticRandom = function() {
	this.seed = 0;
};
ostm.map.StaticRandom.__name__ = true;
ostm.map.StaticRandom.prototype = {
	setSeed: function(s) {
		this.seed = s;
		return this;
	}
	,randomInt: function(max) {
		if(max == null) max = ostm.map.StaticRandom.kRandMax;
		this.seed++;
		var s = (Math.sin(this.seed) + 1) / 2;
		return Math.floor(s * ostm.map.StaticRandom.kRandMax) % max;
	}
	,randomFloat: function() {
		return this.randomInt() / ostm.map.StaticRandom.kRandMax;
	}
	,randomBool: function(prob) {
		if(prob == null) prob = 0.5;
		return this.randomInt(ostm.map.StaticRandom.kRandBoolPrecision) < prob * ostm.map.StaticRandom.kRandBoolPrecision;
	}
	,randomElement: function(array) {
		if(array.length > 0) return array[this.randomInt(array.length)];
		return null;
	}
	,__class__: ostm.map.StaticRandom
};
ostm.skill = {};
ostm.skill.PassiveSkill = function(data) {
	this.requirements = [];
	this.level = 0;
	this.id = data.id;
	if(data.requirements != null) this.requirementIds = data.requirements; else this.requirementIds = [];
	this.name = data.name;
	this.abbreviation = data.icon;
	this.modifierFunction = data.modifier;
	this.pos = data.pos;
};
ostm.skill.PassiveSkill.__name__ = true;
ostm.skill.PassiveSkill.prototype = {
	addRequirement: function(req) {
		if(!jengine.util.Util.contains(this.requirements,req)) {
			if(this.requirements.length == 0) this.pos = { x : this.pos.x + req.pos.x, y : this.pos.y + req.pos.y};
			this.requirements.push(req);
		}
	}
	,hasSpentEnoughPoints: function(tree) {
		var spendReq = this.requiredPointsSpent();
		return spendReq <= 0 || tree.spentSkillPoints() >= spendReq;
	}
	,hasMetRequirements: function(tree) {
		if(!this.hasSpentEnoughPoints(tree)) return false;
		var _g = 0;
		var _g1 = this.requirements;
		while(_g < _g1.length) {
			var req = _g1[_g];
			++_g;
			if(req.level > 0) return true;
		}
		return this.requirements.length == 0;
	}
	,requiredPointsSpent: function() {
		return Math.floor(this.pos.y * (4 + 1.5 * this.level) - 2);
	}
	,levelUp: function() {
		this.level++;
		ga("send","event","player","spend-skill-point",this.id,this.level);
	}
	,respec: function() {
		this.level = 0;
	}
	,currentValue: function() {
		var mod = new ostm.battle.StatModifier();
		this.modifierFunction(this.level,mod);
		return mod;
	}
	,nextValue: function() {
		var mod = new ostm.battle.StatModifier();
		this.modifierFunction(this.level + 1,mod);
		return mod;
	}
	,sumAffixes: function(mod) {
		this.modifierFunction(this.level,mod);
	}
	,serialize: function() {
		return { id : this.id, level : this.level};
	}
	,deserialize: function(data) {
		this.level = data.level;
	}
	,__class__: ostm.skill.PassiveSkill
};
ostm.skill.PassiveData = function() { };
ostm.skill.PassiveData.__name__ = true;
ostm.skill.SkillTree = function() {
	this._cachedPoints = -1;
	this._skillNodes = new Array();
	this.saveId = "skill-tree";
	jengine.Component.call(this);
};
ostm.skill.SkillTree.__name__ = true;
ostm.skill.SkillTree.__interfaces__ = [jengine.Saveable];
ostm.skill.SkillTree.__super__ = jengine.Component;
ostm.skill.SkillTree.prototype = $extend(jengine.Component.prototype,{
	init: function() {
		ostm.skill.SkillTree.instance = this;
		this.skills = ostm.skill.PassiveData.skills.slice();
	}
	,start: function() {
		var _g = this;
		jengine.SaveManager.instance.addItem(this);
		var screen = window.document.getElementById("skill-screen");
		jengine.util.JsUtil.createSpan("Skill points: ",screen);
		this._skillPoints = jengine.util.JsUtil.createSpan("",screen);
		screen.appendChild((function($this) {
			var $r;
			var _this = window.document;
			$r = _this.createElement("br");
			return $r;
		}(this)));
		jengine.util.JsUtil.createSpan("Spent points: ",screen);
		this._spentPoints = jengine.util.JsUtil.createSpan("",screen);
		screen.appendChild((function($this) {
			var $r;
			var _this1 = window.document;
			$r = _this1.createElement("br");
			return $r;
		}(this)));
		var respecBtn;
		var _this2 = window.document;
		respecBtn = _this2.createElement("button");
		respecBtn.innerText = "Refund Spent Points";
		respecBtn.onclick = function(event) {
			var player = ostm.battle.BattleManager.instance.getPlayer();
			if(player.gems >= _g.respecCost()) {
				player.addGems(-_g.respecCost());
				var _g1 = 0;
				var _g2 = _g.skills;
				while(_g1 < _g2.length) {
					var skill = _g2[_g1];
					++_g1;
					skill.respec();
				}
				var _g11 = 0;
				var _g21 = _g._skillNodes;
				while(_g11 < _g21.length) {
					var node = _g21[_g11];
					++_g11;
					node.markDirty();
				}
				player.updateCachedAffixes();
				ga("send","event","player","respec-skill-points");
			}
		};
		screen.appendChild(respecBtn);
		this._respecCost = jengine.util.JsUtil.createSpan("",screen);
		var _g3 = 0;
		var _g12 = this.skills;
		while(_g3 < _g12.length) {
			var skill1 = _g12[_g3];
			++_g3;
			var _g22 = 0;
			var _g31 = this.skills;
			while(_g22 < _g31.length) {
				var s2 = _g31[_g22];
				++_g22;
				if(HxOverrides.indexOf(skill1.requirementIds,s2.id,0) != -1) skill1.addRequirement(s2);
			}
			this.addNode(skill1);
		}
		this.updateScrollBounds();
	}
	,update: function() {
		var avail = this.availableSkillPoints();
		if(avail != this._cachedPoints) {
			this._cachedPoints = avail;
			this._skillPoints.innerText = jengine.util.Util.format(this.availableSkillPoints());
			this._spentPoints.innerText = jengine.util.Util.format(this.spentSkillPoints());
			this._respecCost.innerText = " Cost: " + jengine.util.Util.format(this.respecCost()) + "Gems";
			var _g = 0;
			var _g1 = this._skillNodes;
			while(_g < _g1.length) {
				var node = _g1[_g];
				++_g;
				node.markDirty();
			}
		}
	}
	,maxSkillPoints: function() {
		var player = ostm.battle.BattleManager.instance.getPlayer();
		return player.level - 1;
	}
	,spentSkillPoints: function() {
		var count = 0;
		var _g = 0;
		var _g1 = this.skills;
		while(_g < _g1.length) {
			var skill = _g1[_g];
			++_g;
			count += skill.level;
		}
		return count;
	}
	,availableSkillPoints: function() {
		return this.maxSkillPoints() - this.spentSkillPoints();
	}
	,respecCost: function() {
		return this.spentSkillPoints();
	}
	,addNode: function(skill) {
		var size = jengine._Vec2.Vec2_Impl_._new(50,50);
		var node = new ostm.skill.SkillNode(skill,this);
		var ent = new jengine.Entity([new jengine.HtmlRenderer({ parent : "skill-screen", size : size}),new jengine.Transform(),node]);
		var _g = 0;
		var _g1 = skill.requirements;
		while(_g < _g1.length) {
			var req = _g1[_g];
			++_g;
			var _g2 = 0;
			var _g3 = this._skillNodes;
			while(_g2 < _g3.length) {
				var n = _g3[_g2];
				++_g2;
				if(n.skill == req) node.addNeighbor(n);
			}
		}
		this.entity.getSystem().addEntity(ent);
		this._skillNodes.push(node);
		return node;
	}
	,updateScrollBounds: function() {
		var topLeft = jengine._Vec2.Vec2_Impl_._new(Math.POSITIVE_INFINITY,Math.POSITIVE_INFINITY);
		var botRight = jengine._Vec2.Vec2_Impl_._new(Math.NEGATIVE_INFINITY,Math.NEGATIVE_INFINITY);
		var origin = jengine._Vec2.Vec2_Impl_._new(25,70);
		var _g = 0;
		var _g1 = this._skillNodes;
		while(_g < _g1.length) {
			var node = _g1[_g];
			++_g;
			var pos = node.getOffset();
			topLeft = jengine._Vec2.Vec2_Impl_.min(topLeft,pos);
		}
		var _g2 = 0;
		var _g11 = this._skillNodes;
		while(_g2 < _g11.length) {
			var node1 = _g11[_g2];
			++_g2;
			var pos1;
			var lhs;
			var rhs = node1.getOffset();
			lhs = jengine._Vec2.Vec2_Impl_._new(origin.x + rhs.x,origin.y + rhs.y);
			pos1 = jengine._Vec2.Vec2_Impl_._new(lhs.x - topLeft.x,lhs.y - topLeft.y);
			node1.entity.getComponent(jengine.Transform).pos = pos1;
			botRight = jengine._Vec2.Vec2_Impl_.max(botRight,pos1);
		}
	}
	,serialize: function() {
		return { skills : this.skills.map(function(skill) {
			return skill.serialize();
		})};
	}
	,deserialize: function(data) {
		if(jengine.SaveManager.instance.loadedVersion < 3) return;
		var savedSkills = data.skills;
		var _g = 0;
		while(_g < savedSkills.length) {
			var save = savedSkills[_g];
			++_g;
			var _g1 = 0;
			var _g2 = this.skills;
			while(_g1 < _g2.length) {
				var skill = _g2[_g1];
				++_g1;
				if(save.id == skill.id) skill.deserialize(save);
			}
		}
	}
	,__class__: ostm.skill.SkillTree
});
ostm.skill.SkillNode = function(skill,tree) {
	this._isDirty = true;
	ostm.GameNode.call(this,skill.pos.y,skill.pos.x);
	this.skill = skill;
	this._tree = tree;
};
ostm.skill.SkillNode.__name__ = true;
ostm.skill.SkillNode.__super__ = ostm.GameNode;
ostm.skill.SkillNode.prototype = $extend(ostm.GameNode.prototype,{
	start: function() {
		ostm.GameNode.prototype.start.call(this);
		var doc = window.document;
		jengine.util.JsUtil.createSpan(this.skill.abbreviation,this.elem);
		this.elem.appendChild(doc.createElement("br"));
		this._count = jengine.util.JsUtil.createSpan("",this.elem);
		this._description = doc.createElement("ul");
		jengine.util.JsUtil.createSpan(this.skill.name,this._description);
		if(this.skill.requiredPointsSpent() > 0) {
			this._description.appendChild(doc.createElement("br"));
			jengine.util.JsUtil.createSpan("Req. Points Spent: ",this._description);
			this._reqSpent = jengine.util.JsUtil.createSpan("",this._description);
		}
		this._values = [];
		var nextMods = this.skill.nextValue().getDisplayData();
		var _g = 0;
		while(_g < nextMods.length) {
			var m = nextMods[_g];
			++_g;
			this._description.appendChild(doc.createElement("br"));
			jengine.util.JsUtil.createSpan(m.name,this._description);
			this._values.push(jengine.util.JsUtil.createSpan("",this._description));
		}
		this._description.style.display = "none";
		this._description.style.position = "absolute";
		this._description.style.background = "#444444";
		this._description.style.border = "2px solid #000000";
		this._description.style.width = 220;
		this._description.style.zIndex = 10;
		doc.getElementById("popup-container").appendChild(this._description);
	}
	,update: function() {
		if(this._isDirty) {
			this._isDirty = false;
			this._count.innerText = jengine.util.Util.format(this.skill.level);
			var curMods = this.skill.currentValue().getDisplayData();
			var nextMods = this.skill.nextValue().getDisplayData();
			var _g1 = 0;
			var _g = this._values.length;
			while(_g1 < _g) {
				var i = _g1++;
				var mod = nextMods[i];
				var cur;
				if(i < curMods.length) cur = curMods[i].value; else cur = 0;
				var next = mod.value;
				var str = " " + jengine.util.Util.formatFloat(cur);
				if(mod.isPercent) str += "%";
				str += " -> " + jengine.util.Util.formatFloat(next);
				if(mod.isPercent) str += "%";
				this._values[i].innerText = str;
			}
			if(this._reqSpent != null) {
				this._reqSpent.innerText = jengine.util.Util.format(this.skill.requiredPointsSpent());
				if(this.skill.hasSpentEnoughPoints(this._tree)) this._reqSpent.style.color = "#ffffff"; else this._reqSpent.style.color = "#ff2222";
			}
			var bgPoints = 0;
			if(this.skill.level > 0) bgPoints++;
			if(this.skill.hasMetRequirements(this._tree) && this._tree.availableSkillPoints() > 0) bgPoints++;
			var bg;
			switch(bgPoints) {
			case 2:
				bg = "#ff3333";
				break;
			case 1:
				bg = "#992222";
				break;
			default:
				bg = "#444444";
			}
			this.elem.style.backgroundColor = bg;
		}
	}
	,markDirty: function() {
		this._isDirty = true;
	}
	,onMouseOver: function(event) {
		this._description.style.display = "";
		this._description.style.left = event.x - 275;
		this._description.style.top = event.y - 120;
	}
	,onMouseOut: function(event) {
		this._description.style.display = "none";
	}
	,onClick: function(event) {
		if(this._tree.availableSkillPoints() > 0 && this.skill.hasMetRequirements(this._tree)) {
			this.skill.levelUp();
			this.markDirty();
			ostm.battle.BattleManager.instance.getPlayer().updateCachedAffixes();
		}
	}
	,__class__: ostm.skill.SkillNode
});
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
if(Array.prototype.map == null) Array.prototype.map = function(f) {
	var a = [];
	var _g1 = 0;
	var _g = this.length;
	while(_g1 < _g) {
		var i = _g1++;
		a[i] = f(this[i]);
	}
	return a;
};
if(Array.prototype.filter == null) Array.prototype.filter = function(f1) {
	var a1 = [];
	var _g11 = 0;
	var _g2 = this.length;
	while(_g11 < _g2) {
		var i1 = _g11++;
		var e = this[i1];
		if(f1(e)) a1.push(e);
	}
	return a1;
};
haxe.ds.ObjectMap.count = 0;
jengine.SaveManager.kSaveTime = 15;
jengine.SaveManager.kSaveKey = "ostm2";
jengine.SaveManager.kCurrentSaveVersion = 9;
jengine.SaveManager.kLastCompatibleSaveVersion = 9;
jengine.Time.timeMultiplier = 1;
ostm.TabManager.kNumColumns = 3;
ostm.TownManager.kShopRefreshTime = 300;
ostm.battle.ActiveSkill.skills = [new ostm.battle.ActiveSkill("Attack",0,1,1),new ostm.battle.ActiveSkill("Quick Attack",12,1,1.6),new ostm.battle.ActiveSkill("Power Attack",16,2.2,0.65)];
ostm.battle.BattleManager.kBaseEnemySpawnTime = 4;
ostm.battle.BattleManager.kPlayerDeathTime = 5;
ostm.battle.ClassType.playerType = new ostm.battle.ClassType({ name : "Adventurer", image : "classes/Adventurer.png", str : new ostm.battle.StatType(5,1.5), dex : new ostm.battle.StatType(5,1.5), 'int' : new ostm.battle.StatType(5,1.5), vit : new ostm.battle.StatType(5,1.5), end : new ostm.battle.StatType(5,1.5)});
ostm.battle.ClassType.enemyTypes = [new ostm.battle.ClassType({ name : "Slime", image : "enemies/Slime.png", attack : new ostm.battle.StatType(1.5,0.75), armor : new ostm.battle.StatType(1,1.25), str : new ostm.battle.ExpStatType(2.2,0.6), dex : new ostm.battle.ExpStatType(2.2,0.6), 'int' : new ostm.battle.ExpStatType(2.2,0.6), vit : new ostm.battle.ExpStatType(4.2,1.6), end : new ostm.battle.ExpStatType(2.2,0.6)}),new ostm.battle.ClassType({ name : "Snake", image : "enemies/Snake.png", attack : new ostm.battle.StatType(2.25,1.15), armor : new ostm.battle.StatType(1,1.25), str : new ostm.battle.ExpStatType(4.6,1.1), dex : new ostm.battle.ExpStatType(5.2,1.3), 'int' : new ostm.battle.ExpStatType(2.2,0.8), vit : new ostm.battle.ExpStatType(2.8,0.6), end : new ostm.battle.ExpStatType(2.2,0.6)}),new ostm.battle.ClassType({ name : "Goblin", image : "enemies/Goblin.png", attack : new ostm.battle.StatType(2,1.1), armor : new ostm.battle.StatType(1,1.25), str : new ostm.battle.ExpStatType(3.5,0.9), dex : new ostm.battle.ExpStatType(5,1.2), 'int' : new ostm.battle.ExpStatType(3.2,0.8), vit : new ostm.battle.ExpStatType(3.8,0.9), end : new ostm.battle.ExpStatType(3.2,0.8)})];
ostm.item.AffixType.kMaxRolls = 1000;
ostm.item.AffixData.affixTypes = [new ostm.item.AffixType({ id : "flat-attack", base : 2, perLevel : 1, levelPower : 0.75, modifierFunc : function(value,mod) {
	mod.localFlatAttack += value;
}, multipliers : (function($this) {
	var $r;
	var _g = new haxe.ds.EnumValueMap();
	_g.set(ostm.item.ItemSlot.Weapon,1.0);
	_g.set(ostm.item.ItemSlot.Gloves,0.5);
	_g.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "local-percent-attack-speed", base : 5, perLevel : 1, levelPower : 0.5, modifierFunc : function(value1,mod1) {
	mod1.localPercentAttackSpeed += value1;
}, multipliers : (function($this) {
	var $r;
	var _g1 = new haxe.ds.EnumValueMap();
	_g1.set(ostm.item.ItemSlot.Weapon,1.0);
	$r = _g1;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "local-percent-attack", base : 5, perLevel : 1.5, modifierFunc : function(value2,mod2) {
	mod2.localPercentAttack += value2;
}, multipliers : (function($this) {
	var $r;
	var _g2 = new haxe.ds.EnumValueMap();
	_g2.set(ostm.item.ItemSlot.Weapon,1.0);
	$r = _g2;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-crit-rating", base : 4, perLevel : 2, levelPower : 0.65, modifierFunc : function(value3,mod3) {
	mod3.localFlatCritRating += value3;
}, multipliers : (function($this) {
	var $r;
	var _g3 = new haxe.ds.EnumValueMap();
	_g3.set(ostm.item.ItemSlot.Weapon,1.0);
	_g3.set(ostm.item.ItemSlot.Gloves,0.5);
	_g3.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g3;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "local-percent-crit-rating", base : 5, perLevel : 1, modifierFunc : function(value4,mod4) {
	mod4.localPercentCritRating += value4;
}, multipliers : (function($this) {
	var $r;
	var _g4 = new haxe.ds.EnumValueMap();
	_g4.set(ostm.item.ItemSlot.Weapon,1.0);
	$r = _g4;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-defense", base : 2, perLevel : 1.25, levelPower : 0.75, modifierFunc : function(value5,mod5) {
	mod5.localFlatDefense += value5;
}, multipliers : (function($this) {
	var $r;
	var _g5 = new haxe.ds.EnumValueMap();
	_g5.set(ostm.item.ItemSlot.Body,1.0);
	_g5.set(ostm.item.ItemSlot.Boots,0.5);
	_g5.set(ostm.item.ItemSlot.Helmet,1.0);
	_g5.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g5;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-hp-regen", base : 1, perLevel : 0.35, modifierFunc : function(value6,mod6) {
	mod6.flatHealthRegen += value6;
}, multipliers : (function($this) {
	var $r;
	var _g6 = new haxe.ds.EnumValueMap();
	_g6.set(ostm.item.ItemSlot.Body,1.0);
	_g6.set(ostm.item.ItemSlot.Helmet,0.5);
	_g6.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g6;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "percent-hp", base : 8, perLevel : 2, levelPower : 0.5, modifierFunc : function(value7,mod7) {
	mod7.percentHealth += value7;
}, multipliers : (function($this) {
	var $r;
	var _g7 = new haxe.ds.EnumValueMap();
	_g7.set(ostm.item.ItemSlot.Body,0.5);
	_g7.set(ostm.item.ItemSlot.Helmet,1.0);
	$r = _g7;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-mp", base : 5, perLevel : 2.5, levelPower : 0.75, modifierFunc : function(value8,mod8) {
	mod8.flatMana += value8;
}, multipliers : (function($this) {
	var $r;
	var _g8 = new haxe.ds.EnumValueMap();
	_g8.set(ostm.item.ItemSlot.Body,0.5);
	_g8.set(ostm.item.ItemSlot.Helmet,1.0);
	_g8.set(ostm.item.ItemSlot.Ring,0.5);
	_g8.set(ostm.item.ItemSlot.Gloves,0.5);
	$r = _g8;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-hunt", base : 3, perLevel : 2, levelPower : 0.75, modifierFunc : function(value9,mod9) {
	mod9.flatHuntSkill += value9;
}, multipliers : (function($this) {
	var $r;
	var _g9 = new haxe.ds.EnumValueMap();
	_g9.set(ostm.item.ItemSlot.Helmet,0.5);
	_g9.set(ostm.item.ItemSlot.Boots,1.0);
	_g9.set(ostm.item.ItemSlot.Ring,0.5);
	_g9.set(ostm.item.ItemSlot.Jewel,0.5);
	$r = _g9;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "percent-mp-regen", base : 10, perLevel : 3, levelPower : 0.85, modifierFunc : function(value10,mod10) {
	mod10.percentManaRegen += value10;
}, multipliers : (function($this) {
	var $r;
	var _g10 = new haxe.ds.EnumValueMap();
	_g10.set(ostm.item.ItemSlot.Helmet,1.0);
	_g10.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g10;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "local-percent-defense", base : 10, perLevel : 5, modifierFunc : function(value11,mod11) {
	mod11.localPercentDefense += value11;
}, multipliers : (function($this) {
	var $r;
	var _g11 = new haxe.ds.EnumValueMap();
	_g11.set(ostm.item.ItemSlot.Body,1.0);
	_g11.set(ostm.item.ItemSlot.Helmet,1.0);
	_g11.set(ostm.item.ItemSlot.Boots,0.5);
	_g11.set(ostm.item.ItemSlot.Gloves,0.5);
	$r = _g11;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "percent-attack-speed", base : 3, perLevel : 1, levelPower : 0.65, modifierFunc : function(value12,mod12) {
	mod12.percentAttackSpeed += value12;
}, multipliers : (function($this) {
	var $r;
	var _g12 = new haxe.ds.EnumValueMap();
	_g12.set(ostm.item.ItemSlot.Gloves,1.0);
	_g12.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g12;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "percent-crit-chance", base : 2, perLevel : 1, modifierFunc : function(value13,mod13) {
	mod13.percentCritChance += value13;
}, multipliers : (function($this) {
	var $r;
	var _g13 = new haxe.ds.EnumValueMap();
	_g13.set(ostm.item.ItemSlot.Weapon,1.0);
	_g13.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g13;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "percent-crit-damage", base : 10, perLevel : 2, modifierFunc : function(value14,mod14) {
	mod14.percentCritDamage += value14;
}, multipliers : (function($this) {
	var $r;
	var _g14 = new haxe.ds.EnumValueMap();
	_g14.set(ostm.item.ItemSlot.Weapon,1.0);
	_g14.set(ostm.item.ItemSlot.Gloves,0.5);
	_g14.set(ostm.item.ItemSlot.Ring,0.5);
	$r = _g14;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "percent-move-speed", base : 10, perLevel : 2, modifierFunc : function(value15,mod15) {
	mod15.percentMoveSpeed += value15;
}, multipliers : (function($this) {
	var $r;
	var _g15 = new haxe.ds.EnumValueMap();
	_g15.set(ostm.item.ItemSlot.Boots,1.0);
	_g15.set(ostm.item.ItemSlot.Jewel,0.5);
	$r = _g15;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-strength", base : 2, perLevel : 0.75, levelPower : 0.9, modifierFunc : function(value16,mod16) {
	mod16.flatStrength += value16;
}, multipliers : (function($this) {
	var $r;
	var _g16 = new haxe.ds.EnumValueMap();
	_g16.set(ostm.item.ItemSlot.Body,1.0);
	_g16.set(ostm.item.ItemSlot.Helmet,1.0);
	_g16.set(ostm.item.ItemSlot.Boots,1.0);
	_g16.set(ostm.item.ItemSlot.Gloves,1.0);
	_g16.set(ostm.item.ItemSlot.Ring,1.0);
	$r = _g16;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-dexterity", base : 2, perLevel : 0.75, levelPower : 0.9, modifierFunc : function(value17,mod17) {
	mod17.flatDexterity += value17;
}, multipliers : (function($this) {
	var $r;
	var _g17 = new haxe.ds.EnumValueMap();
	_g17.set(ostm.item.ItemSlot.Body,1.0);
	_g17.set(ostm.item.ItemSlot.Helmet,1.0);
	_g17.set(ostm.item.ItemSlot.Boots,1.0);
	_g17.set(ostm.item.ItemSlot.Gloves,1.0);
	_g17.set(ostm.item.ItemSlot.Ring,1.0);
	$r = _g17;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-vitality", base : 2, perLevel : 0.75, levelPower : 0.9, modifierFunc : function(value18,mod18) {
	mod18.flatVitality += value18;
}, multipliers : (function($this) {
	var $r;
	var _g18 = new haxe.ds.EnumValueMap();
	_g18.set(ostm.item.ItemSlot.Body,1.0);
	_g18.set(ostm.item.ItemSlot.Helmet,1.0);
	_g18.set(ostm.item.ItemSlot.Boots,1.0);
	_g18.set(ostm.item.ItemSlot.Gloves,1.0);
	_g18.set(ostm.item.ItemSlot.Ring,1.0);
	$r = _g18;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-endurance", base : 2, perLevel : 0.75, levelPower : 0.9, modifierFunc : function(value19,mod19) {
	mod19.flatEndurance += value19;
}, multipliers : (function($this) {
	var $r;
	var _g19 = new haxe.ds.EnumValueMap();
	_g19.set(ostm.item.ItemSlot.Body,1.0);
	_g19.set(ostm.item.ItemSlot.Helmet,1.0);
	_g19.set(ostm.item.ItemSlot.Boots,1.0);
	_g19.set(ostm.item.ItemSlot.Gloves,1.0);
	_g19.set(ostm.item.ItemSlot.Ring,1.0);
	$r = _g19;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "flat-intelligence", base : 2, perLevel : 0.75, levelPower : 0.9, modifierFunc : function(value20,mod20) {
	mod20.flatIntelligence += value20;
}, multipliers : (function($this) {
	var $r;
	var _g20 = new haxe.ds.EnumValueMap();
	_g20.set(ostm.item.ItemSlot.Body,1.0);
	_g20.set(ostm.item.ItemSlot.Helmet,1.0);
	_g20.set(ostm.item.ItemSlot.Boots,1.0);
	_g20.set(ostm.item.ItemSlot.Gloves,1.0);
	_g20.set(ostm.item.ItemSlot.Ring,1.0);
	$r = _g20;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "xp-gain", base : 2, perLevel : 1, levelPower : 0.8, modifierFunc : function(value21,mod21) {
	mod21.percentXpGained += value21;
}, multipliers : (function($this) {
	var $r;
	var _g21 = new haxe.ds.EnumValueMap();
	_g21.set(ostm.item.ItemSlot.Helmet,0.5);
	_g21.set(ostm.item.ItemSlot.Jewel,1.0);
	$r = _g21;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "gold-gain", base : 5, perLevel : 2, levelPower : 0.8, modifierFunc : function(value22,mod22) {
	mod22.percentGoldGained += value22;
}, multipliers : (function($this) {
	var $r;
	var _g22 = new haxe.ds.EnumValueMap();
	_g22.set(ostm.item.ItemSlot.Ring,0.5);
	_g22.set(ostm.item.ItemSlot.Jewel,1.0);
	$r = _g22;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "gem-drop", base : 2, perLevel : 0.65, levelPower : 0.8, modifierFunc : function(value23,mod23) {
	mod23.percentGemDropRate += value23;
}, multipliers : (function($this) {
	var $r;
	var _g23 = new haxe.ds.EnumValueMap();
	_g23.set(ostm.item.ItemSlot.Jewel,1.0);
	$r = _g23;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "item-drop", base : 3, perLevel : 1, levelPower : 0.8, modifierFunc : function(value24,mod24) {
	mod24.percentItemDropRate += value24;
}, multipliers : (function($this) {
	var $r;
	var _g24 = new haxe.ds.EnumValueMap();
	_g24.set(ostm.item.ItemSlot.Jewel,1.0);
	$r = _g24;
	return $r;
}(this))}),new ostm.item.AffixType({ id : "item-rarity", base : 8, perLevel : 2, levelPower : 0.8, modifierFunc : function(value25,mod25) {
	mod25.percentItemRarity += value25;
}, multipliers : (function($this) {
	var $r;
	var _g25 = new haxe.ds.EnumValueMap();
	_g25.set(ostm.item.ItemSlot.Jewel,1.0);
	$r = _g25;
	return $r;
}(this))})];
ostm.item.Inventory.kBaseInventoryCount = 10;
ostm.item.Item.kTierLevels = 5;
ostm.item.ItemData.types = [new ostm.item.WeaponType({ id : "sword", images : ["Sword0.png","Sword1.png","Sword2.png","Sword3.png"], names : ["Rusted Sword","Copper Sword","Short Sword","Long Sword"], attack : 4.1, attackSpeed : 1.55, crit : 5, defense : 0}),new ostm.item.WeaponType({ id : "axe", images : ["Axe0.png","Axe1.png","Axe2.png","Axe3.png"], names : ["Rusted Axe","Hatchet","Tomahawk","Battle Axe"], attack : 5.25, attackSpeed : 1.35, crit : 7, defense : 0}),new ostm.item.WeaponType({ id : "dagger", images : ["Dagger0.png","Dagger1.png","Dagger2.png","Dagger3.png"], names : ["Rusted Dagger","Knife","Dagger","Kris"], attack : 3, attackSpeed : 1.8, crit : 9, defense : 0}),new ostm.item.ItemType({ id : "armor", images : ["Armor.png"], names : ["Tattered Shirt","Cloth Shirt","Padded Armor","Leather Armor"], slot : ostm.item.ItemSlot.Body, attack : 0, defense : 2}),new ostm.item.ItemType({ id : "helm", images : ["Helmet.png"], names : ["Hat","Leather Cap","Iron Hat","Chainmail Coif"], slot : ostm.item.ItemSlot.Helmet, attack : 0, defense : 1}),new ostm.item.ItemType({ id : "boots", images : ["Boot.png"], names : ["Sandals","Leather Shoes","Boots","Studded Boots"], slot : ostm.item.ItemSlot.Boots, attack : 0, defense : 1}),new ostm.item.ItemType({ id : "gloves", images : ["Glove.png"], names : ["Cuffs","Wool Gloves","Leather Gloves","Studded Gloves"], slot : ostm.item.ItemSlot.Gloves, attack : 0, defense : 1}),new ostm.item.ItemType({ id : "ring", images : ["Ring.png"], names : ["Ring"], slot : ostm.item.ItemSlot.Ring, attack : 0.2, defense : 0.3}),new ostm.item.ItemType({ id : "jewel", images : ["Jewel.png"], names : ["Jewel"], slot : ostm.item.ItemSlot.Jewel, attack : 0, defense : 0})];
ostm.map.MapGenerator.kMoveTime = 12.0;
ostm.map.MapGenerator.kGridSize = 5;
ostm.map.MapGenerator.kLevelsPerCellDist = 6;
ostm.map.MapGenerator.kHalfGrid = Math.floor(2.5);
ostm.map.MapNode.kMaxRegions = 4;
ostm.map.MapNode.kMaxVisibleRegion = 4;
ostm.map.MapNode.kLaunchRegions = 4;
ostm.map.MapNode._highestVisited = 0;
ostm.map.StaticRandom.kRandMax = 19001;
ostm.map.StaticRandom.kRandBoolPrecision = 1000;
ostm.skill.PassiveData.skills = [new ostm.skill.PassiveSkill({ id : "str", requirements : [], icon : "STR+", pos : { x : 0, y : 0}, name : "Strength+", modifier : function(level,mod) {
	mod.flatStrength += 3 * level;
}}),new ostm.skill.PassiveSkill({ id : "dex", requirements : [], icon : "DEX+", pos : { x : 2, y : 0}, name : "Dexterity+", modifier : function(level1,mod1) {
	mod1.flatDexterity += 3 * level1;
}}),new ostm.skill.PassiveSkill({ id : "vit", requirements : [], icon : "VIT+", pos : { x : 4, y : 0}, name : "Vitality+", modifier : function(level2,mod2) {
	mod2.flatVitality += 3 * level2;
}}),new ostm.skill.PassiveSkill({ id : "end", requirements : [], icon : "END+", pos : { x : 5, y : 0}, name : "Endurance+", modifier : function(level3,mod3) {
	mod3.flatEndurance += 3 * level3;
}}),new ostm.skill.PassiveSkill({ id : "dam", requirements : ["str"], icon : "DAM", pos : { x : 0, y : 1}, name : "Damage", modifier : function(level4,mod4) {
	mod4.flatStrength += 2 * level4;
	mod4.percentAttack += 9 * level4;
}}),new ostm.skill.PassiveSkill({ id : "atk-spd", requirements : ["dex"], icon : "ASPD", pos : { x : -1, y : 1}, name : "AttackSpeed+", modifier : function(level5,mod5) {
	mod5.flatDexterity += 2 * level5;
	mod5.percentAttackSpeed += Math.floor(3.5 * level5);
}}),new ostm.skill.PassiveSkill({ id : "crt", requirements : ["dex"], icon : "CRT+", pos : { x : 0, y : 1}, name : "Crit Rating+", modifier : function(level6,mod6) {
	mod6.flatDexterity += 2 * level6;
	mod6.percentCritRating += 6 * level6;
}}),new ostm.skill.PassiveSkill({ id : "mp", requirements : [], icon : "MP+", pos : { x : 3, y : 1}, name : "Mana+", modifier : function(level7,mod7) {
	mod7.flatMana += 8 * level7;
}}),new ostm.skill.PassiveSkill({ id : "hp-reg", icon : "HPRe", requirements : ["vit"], pos : { x : 0, y : 1}, name : "Health Regen+", modifier : function(level8,mod8) {
	mod8.flatVitality += 2 * level8;
	mod8.flatHealthRegen += 0.5 * level8;
}}),new ostm.skill.PassiveSkill({ id : "hp", icon : "HP+", requirements : ["vit","end"], pos : { x : 1, y : 1}, name : "Health+", modifier : function(level9,mod9) {
	mod9.flatEndurance += 2 * level9;
	mod9.percentHealth += 2.5 * level9;
}}),new ostm.skill.PassiveSkill({ id : "dam+", requirements : ["dam"], icon : "DAM+", pos : { x : 0, y : 1}, name : "Damage+", modifier : function(level10,mod10) {
	mod10.flatStrength += Math.floor(1.5 * level10);
	mod10.percentAttack += 7 * level10;
	mod10.percentHealth += 2 * level10;
}}),new ostm.skill.PassiveSkill({ id : "cch", requirements : ["crt"], icon : "CCH+", pos : { x : 0, y : 1}, name : "Crit Chance+", modifier : function(level11,mod11) {
	mod11.flatDexterity += Math.floor(1.5 * level11);
	mod11.flatCritRating += 2 * level11;
	mod11.percentCritChance += 8 * level11;
}}),new ostm.skill.PassiveSkill({ id : "mp-reg", requirements : ["mp"], icon : "MPRe", pos : { x : 0, y : 1}, name : "Mana Regen+", modifier : function(level12,mod12) {
	mod12.flatIntelligence += Math.floor(1.5 * level12);
	mod12.percentManaRegen += 10 * level12;
}}),new ostm.skill.PassiveSkill({ id : "pct-hp-reg", requirements : ["hp-reg"], icon : "HPR%", pos : { x : 0, y : 1}, name : "Health Regen++", modifier : function(level13,mod13) {
	mod13.flatVitality += Math.floor(1.5 * level13);
	mod13.percentHealthRegen += 5 * level13;
}}),new ostm.skill.PassiveSkill({ id : "arm", icon : "ARM+", requirements : ["hp"], pos : { x : 0, y : 1}, name : "Armor+", modifier : function(level14,mod14) {
	mod14.flatEndurance += Math.floor(1.5 * level14);
	mod14.flatDefense += 2 * level14;
}}),new ostm.skill.PassiveSkill({ id : "prc", requirements : ["dam+"], icon : "PRC+", pos : { x : 0, y : 1}, name : "Pierce+", modifier : function(level15,mod15) {
	mod15.flatStrength += level15;
	mod15.flatEndurance += level15;
	mod15.flatArmorPierce += 5 * level15;
	mod15.percentAttack += 5 * level15;
}}),new ostm.skill.PassiveSkill({ id : "ruth", requirements : ["atk-spd"], icon : "RTH", pos : { x : 0, y : 2}, name : "Ruthlessness", modifier : function(level16,mod16) {
	mod16.flatStrength += level16;
	mod16.flatDexterity += level16;
	mod16.percentAttack += 7 * level16;
	mod16.percentAttackSpeed += 2 * level16;
}}),new ostm.skill.PassiveSkill({ id : "cdm", requirements : ["cch"], icon : "CDM+", pos : { x : 0, y : 1}, name : "Crit Damage+", modifier : function(level17,mod17) {
	mod17.flatDexterity += level17;
	mod17.flatIntelligence += level17;
	mod17.percentAttackSpeed += Math.floor(2.5 * level17);
	mod17.percentCritDamage += 12 * level17;
}}),new ostm.skill.PassiveSkill({ id : "hnt", requirements : ["mp-reg"], icon : "HNT+", pos : { x : 0, y : 1}, name : "Hunting", modifier : function(level18,mod18) {
	mod18.flatDexterity += level18;
	mod18.flatIntelligence += level18;
	mod18.flatHuntSkill += Math.floor(3.5 * level18);
	mod18.percentMoveSpeed += 8 * level18;
}}),new ostm.skill.PassiveSkill({ id : "jgr", requirements : ["arm"], icon : "JGR", pos : { x : 0, y : 1}, name : "Juggernaut", modifier : function(level19,mod19) {
	mod19.flatDexterity += level19;
	mod19.flatEndurance += level19;
	mod19.flatAttack += Math.floor(1.5 * level19);
	mod19.percentHealth += 2 * level19;
}})];
ostm.GameMain.main();
})();
