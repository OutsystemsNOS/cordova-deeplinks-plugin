var PLUGIN_NAME = "NOSLinks";

window.NOSLinks = {
    onDeepLink: function (url) {
        const event = new CustomEvent("NOSLinks", { detail: { url } });
        window.dispatchEvent(event);
    }
};
