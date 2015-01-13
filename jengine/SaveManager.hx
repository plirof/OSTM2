package jengine;

import haxe.Json;
import js.Browser;

interface Saveable {
    public var saveId(default, null) :String;
    public function serialize() :Dynamic;
    public function deserialize(data :Dynamic) :Void;
}

class SaveManager extends Component {
    public static var instance(default, null) :SaveManager;

    var _toSave = new Map<String, Saveable>();
    var _saveTimer :Float = 0;
    var _savingEnabled :Bool = true;
    static inline var kSaveTime = 15;
    static inline var kSaveKey = 'ostm2';

    public override function init() :Void {
        instance = this;

        Browser.document.getElementById('save-button').onclick = function (event) { save(); };
        Browser.document.getElementById('save-clear-button').onclick = function (event) { clearSave(); };
    }

    public override function postStart() :Void {
        var storage = Browser.getLocalStorage();
        var save = storage.getItem(kSaveKey);
        if (save != null) {
            loadString(save);
        }
    }

    public override function update() :Void {
        _saveTimer += Time.dt;
        if (_saveTimer > kSaveTime && _savingEnabled) {
            save();
        }
    }

    public function save() :Void {
        Browser.getLocalStorage().setItem(kSaveKey, saveString());
        _saveTimer = 0;
        _savingEnabled = true;
    }
    public function clearSave() :Void {
        Browser.getLocalStorage().removeItem(kSaveKey);
        _savingEnabled = false;
    }

    public function addItem(item :Saveable) :Void {
        if (item.saveId != null) {
            _toSave[item.saveId] = item;
        }
    }
    public function addItems(items :Array<Saveable>) :Void {
        for (item in items) {
            addItem(item);
        }
    }

    public function saveString() :String {
        var save :Dynamic = {};

        for (item in _toSave) {
            Reflect.setField(save, item.saveId, item.serialize());
        }
        return Json.stringify(save);
    }
    public function loadString(saveString :String) :Void {
        var save :Dynamic = Json.parse(saveString);
        var keys = _toSave.keys();
        for (k in keys) {
            var data = Reflect.getProperty(save, k);
            var item = _toSave.get(k);
            if (data != null) {
                item.deserialize(data);
            }
        }
    }
}
