package jengine;

interface Saveable {
    public var saveId(default, null) :String;
    public function serialize() :String;
    public function deserialize(data :String) :Void;
}

class SaveManager extends Component {
    public static var instance(default, null) :SaveManager;

    var _toSave = new Map<String, Saveable>();

    public override function init() :Void {
        instance = this;
    }

    public function addItem(item :Saveable) :Void {
        _toSave[item.saveId] = item;
    }
    public function addItems(items :Array<Saveable>) :Void {
        for (item in items) {
            addItem(item);
        }
    }

    static inline var kItemDelim = '$,';
    static inline var kKvDelim = '$:';
    public function saveString() :String {
        var str = '';
        for (item in _toSave) {
            if (str != '') {
                str += kItemDelim;
            }
            str += item.saveId + kKvDelim + item.serialize();
        }
        return str;
    }
    public function loadString(saveString :String) :Void {
        var kvs = saveString.split(kItemDelim);
        for (kv in kvs) {
            var pair = kv.split(kKvDelim);
            var k = pair[0];
            var v = pair[1];
            var item = _toSave.get(k);
            if (item != null) {
                item.deserialize(v);
            }
        }
    }
}
