module.exports = {
    onDeepLink: function (url) {
        console.log("[NOSLinks] Received URL: ", url);
        // Aqui podes dispatchar eventos, etc.
        const event = new CustomEvent("noslink", { detail: { url } });
        window.dispatchEvent(event);
    }
};
