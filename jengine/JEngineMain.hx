package jengine;

import js.*;

class JEngineMain {
    var _entitySystem :EntitySystem = new EntitySystem();
    var _updateInterval :Int = 16;

    public function new(entityList :Array<Entity>) {
        for (ent in entityList) {
            _entitySystem.addEntity(ent);
        }

        Time.init();

        Browser.window.setInterval(update, _updateInterval);
    }

    public function update() :Void {
        Time.update();

        _entitySystem.update();
    }
}
