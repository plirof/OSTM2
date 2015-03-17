package ostm;

import js.*;
import jengine.*;

import ostm.map.MapGenerator;

class TownManager extends Component {
    public static var instance(default, null) :TownManager;

    public override function init() :Void {
        instance = this;
    }

    public override function update() :Void {
        var inTown = MapGenerator.instance.isInTown();
        Browser.document.getElementById('town-screen').style.display = inTown ? '' : 'none';
    }    
}
