var PLUGIN_NAME = "CustomDeeplinks";

window.CustomDeeplinksPlugin = {
    onDeepLink: function (url) {
        const event = new CustomEvent("deeplinks", { detail: { url } });
        window.dispatchEvent(event);
    }
};
