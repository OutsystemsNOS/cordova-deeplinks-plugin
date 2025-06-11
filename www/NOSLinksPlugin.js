var PLUGIN_NAME = "NOSLinksPlugin";

window.NOSLinksPlugin = {
    onDeepLink: function (url) {
        const event = new CustomEvent("NOSLinksPlugin", { detail: { url } });
        window.dispatchEvent(event);
    }
};
