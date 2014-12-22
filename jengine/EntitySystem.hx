package jengine;

import jengine.util.*;

class EntitySystem {
    var _entities: Array<Entity> = new Array<Entity>();

    public function new() { }
    public function addEntity(ent :Entity) :Void {
        _entities.push(ent);
        ent._system = this;
    }

    public function update() :Void {
        for (ent in _entities) {
            if (!ent._hasStarted) {
                ent.forAllComponents(function (cmp) {
                    cmp.start();
                });
                ent._hasStarted = true;
            }
            ent.forAllComponents(function (cmp) {
                cmp.update();
            });
        }

        for (ent in _entities) {
            ent.forAllComponents(function (cmp) {
                cmp.draw();
            });
        }
    }

    public function removeEntity(ent :Entity) :Void {
        for (e in _entities) {
            if (e == ent) {
                e.forAllComponents(function (cmp) {
                    cmp.deinit();
                });
                e._system = null;
                _entities.remove(e);
                return;
            }
        }
        Log.log("Failed to find entity " + ent);
    }

    public function removeAll() :Void {
        while (_entities.length > 0) {
            removeEntity(_entities[0]);
        }
    }
}
