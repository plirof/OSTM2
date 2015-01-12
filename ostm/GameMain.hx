package ostm;

import jengine.Entity;
import jengine.JEngineMain;

import ostm.battle.BattleManager;
import ostm.item.Inventory;
import ostm.map.MapGenerator;

class GameMain extends JEngineMain {
	public static function main() {
		new GameMain();
	}

	public function new() {
		var entityList = [
            new Entity([ new MapGenerator() ]),
            new Entity([ new BattleManager() ]),
            new Entity([ new Inventory() ]),
        ];

        MouseManager.init();

		super(entityList);
	}
}
