package com.cordova.deeplinks.plugin;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.apache.cordova.CordovaPlugin;

public class CustomDeeplinksPlugin extends CordovaPlugin {

    private static final String TAG = "[CustomDeeplinks]";
    private static String pendingURL = null;

    @Override
    protected void pluginInitialize() {
        Log.d(TAG, "Plugin initialized");

        Intent intent = cordova.getActivity().getIntent();
        if (intent != null && intent.getData() != null) {
            Uri data = intent.getData();
            pendingURL = data.toString();
            Log.d(TAG, "Detected cold start with URL: " + pendingURL);

            fireDeepLinkToJS(pendingURL);
            //pendingURL = null;
        }
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if ("getPendingDeeplink".equals(action)) {
            if (pendingURL != null) {
                Log.d(TAG, "Returning pending URL: " + pendingURL);
                callbackContext.success(pendingURL);
                pendingURL = null;
            } else {
                Log.d(TAG, "No pending URL");
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.NO_RESULT));
            }
            return true;
        }
    
        return false;
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (intent != null && intent.getData() != null) {
            String url = intent.getData().toString();
            Log.d(TAG, "Received deep link (warm): " + url);
            fireDeepLinkToJS(url);
        }
    }

    private void fireDeepLinkToJS(String url) {
        if (webView != null) {
            String escaped = url.replace("'", "\\'");
            String js = "window.CustomDeeplinksPlugin && window.CustomDeeplinks.onDeepLink && window.CustomDeeplinks.onDeepLink('" + escaped + "');";
            webView.getEngine().evaluateJavascript(js, null);
            Log.d(TAG, "Dispatched JS event with URL: " + url);
        } else {
            Log.w(TAG, "WebView is null, cannot dispatch deep link");
        }
    }
}
