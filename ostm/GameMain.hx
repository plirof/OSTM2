package ostm;

import jengine.Entity;
import jengine.JEngineMain;
import jengine.SaveManager;

import ostm.battle.BattleManager;
import ostm.item.Inventory;
import ostm.map.MapGenerator;

class SaveTest implements Saveable {
    public var saveId(default, null) :String;
    var str :String;
    public function new(id, str) { this.saveId = id; this.str = str; }
    public function serialize() :String {
        return str;
    }
    public function deserialize(data :String) :Void {
        str = data;
    }
}

class GameMain extends JEngineMain {
	public static function main() {
		new GameMain();
	}

	public function new() {
		var entityList = [
            new Entity([ new MapGenerator() ]),
            new Entity([ new BattleManager() ]),
            new Entity([ new Inventory() ]),
            new Entity([ new SaveManager() ]),
        ];

        MouseManager.init();

		super(entityList);
	}
}
