package com.cordova.deeplinks.plugin;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

public class CustomDeeplinksPlugin extends CordovaPlugin {

    private static final String TAG = "[CustomDeeplinks]";
    private static String pendingURL = null;

    @Override
    protected void pluginInitialize() {
        Log.d(TAG, "Plugin initialized");

        if (pendingURL != null) {
            String escaped = pendingURL.replace("'", "\\'");
            String js = "window.CustomDeeplinks && window.CustomDeeplinks.onDeepLink && window.CustomDeeplinks.onDeepLink('" + escaped + "');";
            webView.getEngine().evaluateJavascript(js, null);
            Log.d(TAG, "Fired pending URL: " + pendingURL);
            pendingURL = null;
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        Uri data = intent.getData();
        if (data != null) {
            String url = data.toString();
            Log.d(TAG, "Received deep link: " + url);
            pendingURL = url;

            if (webView != null) {
                String escaped = url.replace("'", "\\'");
                String js = "window.CustomDeeplinks && window.CustomDeeplinks.onDeepLink && window.CustomDeeplinks.onDeepLink('" + escaped + "');";
                webView.getEngine().evaluateJavascript(js, null);
                Log.d(TAG, "Fired deep link immediately: " + url);
            }
        }
    }
}
