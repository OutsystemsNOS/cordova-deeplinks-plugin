var PLUGIN_NAME = "NOSLinks";

window.NOSLinks = {
    onDeepLink: function (url) {
        const event = new CustomEvent("noslink", { detail: { url } });
        window.dispatchEvent(event);
    }
};
