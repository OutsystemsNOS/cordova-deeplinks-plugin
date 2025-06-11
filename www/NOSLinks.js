window.nosLinks = {
    onDeepLink: function (url) {
        const event = new CustomEvent("noslink", { detail: { url } });
        window.dispatchEvent(event);
    }
};
