package ostm;

import jengine.Component;

enum NotificationType {
    MapUpdate;
    StatUpdate;
}

interface NotificationReceiver {
    public function receivedNotification(notif :NotificationType) :Void;
}

class NotificationManager extends Component {
    var _registeredObjects = new
        Map<NotificationType, Array<NotificationReceiver>>();
    var _pendingNotifications :Array<NotificationType> = [];

    public static var instance(default, null) :NotificationManager;

    public override function init() {
        instance = this;
    }

    public override function update() {
        for (notif in _pendingNotifications) {
            var toFire = _registeredObjects.get(notif);
            if (toFire != null) {
                for (obj in _registeredObjects[notif]) {
                    obj.receivedNotification(notif);
                }
            }
        }
        _pendingNotifications = [];
    }

    public function register(receiver :NotificationReceiver,
            notif :NotificationType) :Void {
        if (_registeredObjects.get(notif) == null) {
            _registeredObjects[notif] = [];
        }
        _registeredObjects[notif].push(receiver);
    }

    public function queueNotification(notif :NotificationType) {
        if (_pendingNotifications.indexOf(notif) == -1) {
            _pendingNotifications.push(notif);
        }
    }
}