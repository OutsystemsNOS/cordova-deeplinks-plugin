var PLUGIN_NAME = "CustomDeeplinks";

window.Deeplinks = {
    onDeepLink: function (url) {
        const event = new CustomEvent("deeplinks", { detail: { url } });
        window.dispatchEvent(event);
    }
};
