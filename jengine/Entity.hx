package jengine;

@:allow(jengine.EntitySystem)
class Entity {
    var _components :Array<Component>;
    var _system :EntitySystem;
    var _hasStarted :Bool = false;

    public function new(components: Array<Component>) {
        _components = components;

        if (getComponent(Transform) == null) {
            _components.push(new Transform());
        }

        for (cmp in _components) {
            cmp._entity = this;
            cmp.init();
        }
    }

    public function forAllComponents(f :Component -> Void) :Void {
        for (cmp in _components) {
            f(cmp);
        }
    }

    public function getComponent<T :Component>(c :Class<T>) :T {
        for (cmp in _components) {
            if (Std.is(cmp, c)) {
                return cast cmp;
            }
        }

        return null;
    }

    public inline function getTransform() :Transform {
        return getComponent(Transform);
    }

    public function getSystem() :EntitySystem {
        return _system;
    }
}
