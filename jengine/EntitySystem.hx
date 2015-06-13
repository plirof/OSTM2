package jengine;

import jengine.util.*;

class EntitySystem {
    var _entities: Array<Entity> = [];
    var _entitiesToAdd :Array<Entity> = [];
    var _entitiesToRemove :Array<Entity> = [];

    public function new() { }
    public function addEntity(ent :Entity) :Void {
        _entitiesToAdd.push(ent);
        ent._system = this;
    }
    public function removeEntity(ent :Entity) :Void {
        _entitiesToRemove.push(ent);
    }

    public function update() :Void {
        for (ent in _entities) {
            if (!ent._hasStarted) {
                for (cmp in ent._components) {
                    cmp.start();
                }
            }
        }
        for (ent in _entities) {
            if (!ent._hasStarted) {
                for (cmp in ent._components) {
                    cmp.postStart();
                }
                ent._hasStarted = true;
            }
        }

        for (ent in _entities) {
            for (cmp in ent._components) {
                cmp.update();
            }
        }
        for (ent in _entities) {
            for (cmp in ent._components) {
                cmp.draw();
            }
        }

        for (ent in _entitiesToAdd) {
            _entities.push(ent);
        }
        for (ent in _entitiesToRemove) {
            var i = _entities.indexOf(ent);
            if (i >= 0) {
                for (cmp in ent._components) {
                    cmp.deinit();
                }
                ent._system = null;
                _entities.remove(ent);
            }
        }
        _entitiesToAdd = [];
        _entitiesToRemove = [];
    }
}
