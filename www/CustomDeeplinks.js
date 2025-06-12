var PLUGIN_NAME = "CustomDeeplinks";

window.CustomDeeplinks = {
    onDeepLink: function (url) {
        const event = new CustomEvent("deeplinks", { detail: { url } });
        window.dispatchEvent(event);
    }
};

window.CustomDeeplinks.getPendingDeeplink = function (callback) {
    if (!window.cordova || !cordova.exec) {
        console.warn("Cordova not ready");
        callback(null);
        return;
    }
    cordova.exec(
        function (url) {
            if (typeof callback === 'function') {
                callback(url);
            }
        },
        function (err) {
            console.error("Cannot get pending deeplink:", err);
            callback(null);
        },
        "CustomDeeplinks",
        "getPendingDeeplink",
        []
    );
};
