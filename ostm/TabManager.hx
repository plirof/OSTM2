package ostm;

import js.*;
import js.html.*;

import jengine.Component;
import jengine.SaveManager;

class TabManager extends Component
        implements Saveable {

    public var saveId(default, null) = 'tab-manager';

    var _tabs = [
        {
            id: 'stat-screen',
            buttonName: 'Stats',
            column: 1,
        }, {
            id: 'main-screen',
            buttonName: null,
            column: 2,
        }, {
            id: 'inventory-screen',
            buttonName: 'Inventory',
            column: 2,
        }, {
            id: 'map-screen',
            buttonName: 'Map',
            column: 3,
        }, {
            id: 'skill-screen',
            buttonName: 'Skills',
            column: 3,
        }
    ];

    static inline var kNumColumns = 3;

    var _enabled = ['main-screen', 'map-screen'];
    var _shouldRefresh = true;

    public override function start() :Void {
        SaveManager.instance.addItem(this);

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

            var columns = new Map<Int, Array<Element>>();
            for (tab in _tabs) {
                var elem = Browser.document.getElementById(tab.id);
                if (_enabled.indexOf(tab.id) == -1) {
                    elem.style.display = 'none';
                }
                else {
                    elem.style.display = '';

                    if (columns.get(tab.column) == null) {
                        columns[tab.column] = [];
                    }
                    columns[tab.column].push(elem);
                }
            }

            var numVisibleColumns = 0;
            for (x in columns) {
                numVisibleColumns++;
            }
            var columnWidth = 100.0 / numVisibleColumns;
            var columnLeft = 0.0;
            for (i in 1...(kNumColumns+1)) {
                var columnElem = Browser.document.getElementById('column-' + i);
                if (columns.get(i) == null) {
                    columnElem.style.display = 'none';
                }
                else {
                    columnElem.style.display = '';
                    columnElem.style.width = columnWidth + '%';
                    columnElem.style.left = columnLeft + '%';
                    columnLeft += columnWidth;
                }
            }


            for (tabElems in columns) {
                var numVisibleRows = tabElems.length;
                var rowHeight = 100.0 / numVisibleRows;
                var rowTop = 0.0;
                for (elem in tabElems) {
                    elem.style.height = rowHeight + '%';
                    elem.style.top = rowTop + '%';
                    rowTop += rowHeight;
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
        if (_enabled.indexOf(tabId) == -1) {
            _enabled.push(tabId);
        }
        else {
            _enabled.remove(tabId);
        }

        _shouldRefresh = true;
    }

    public function serialize() :Dynamic {
        return {
            enabled: _enabled,
        };
    }
    public function deserialize(data :Dynamic) :Void {
        _enabled = data.enabled;
        _shouldRefresh = true;
    }
}
