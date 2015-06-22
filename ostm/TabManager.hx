package ostm;

import js.*;
import js.html.*;

import jengine.Component;
import jengine.SaveManager;

class TabManager extends Component {
    var _tabs = [
        {
            id: 'main-screen',
            buttonName: 'Main',
        }, {
            id: 'stat-screen',
            buttonName: 'Stats',
        }, {
            id: 'equip-screen',
            buttonName: 'Equipment',
        }, {
            id: 'inventory-screen',
            buttonName: 'Inventory',
        }, {
            id: 'map-screen',
            buttonName: 'Map',
        }, {
            id: 'skill-screen',
            buttonName: 'Skills',
        }
    ];

    var _shouldRefresh = true;
    var _selected = 'main-screen';

    public override function start() :Void {
        var header = Browser.document.getElementById('header-tab-container');
        for (tab in _tabs) {
            if (tab.buttonName != null) {
                var button = Browser.document.createButtonElement();
                button.innerText = tab.buttonName;
                button.onclick = function(event) {
                    toggleTabEnabled(tab.id);
                };
                header.appendChild(button);
            }
        }
    }

    public override function update() :Void {
        if (_shouldRefresh) {
            _shouldRefresh = false;

            for (tab in _tabs) {
                var elem = Browser.document.getElementById(tab.id);
                if (tab.id != _selected) {
                    elem.style.display = 'none';
                }
                else {
                    elem.style.display = '';
                }
            }
        }
    }

    function getTabData(id :String) {
        for (tab in _tabs) {
            if (tab.id == id) {
                return tab;
            }
        }
        return null;
    }

    function toggleTabEnabled(tabId :String) :Void {
        _selected = tabId;
        _shouldRefresh = true;
    }
}
