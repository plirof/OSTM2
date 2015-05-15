package ostm;

import jengine.Entity;
import jengine.JEngineMain;
import jengine.SaveManager;

import ostm.KeyboardManager;
import ostm.battle.BattleManager;
import ostm.item.Inventory;
import ostm.map.MapGenerator;
import ostm.skill.SkillTree;

class GameMain extends JEngineMain {
	public static function main() {
		new GameMain();
	}

	public function new() {
		var entityList = [
            new Entity([ new KeyboardManager() ]),
            new Entity([ new MapGenerator() ]),
            new Entity([ new BattleManager() ]),
            new Entity([ new Inventory() ]),
            new Entity([ new SaveManager() ]),
            new Entity([ new SkillTree() ]),
            new Entity([ new TownManager() ]),
        ];

        MouseManager.init();

		super(entityList);
	}
}
