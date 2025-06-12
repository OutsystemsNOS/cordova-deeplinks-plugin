var PLUGIN_NAME = "Deeplinks";

window.Deeplinks = {
    onDeepLink: function (url) {
        const event = new CustomEvent("deeplinks", { detail: { url } });
        window.dispatchEvent(event);
    }
};
