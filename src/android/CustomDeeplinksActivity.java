package com.cordova.deeplinks.plugin;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.content.Context;

public class CustomDeeplinksActivity extends Activity {

    private static final String TAG = "[CustomDeeplinksActivity]";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try {
            Intent incomingIntent = getIntent();
            Uri data = incomingIntent.getData();

            if (data != null) {
                Log.d(TAG, "Received deep link: " + data.toString());
            } else {
                Log.w(TAG, "Received intent with no data");
            }

            Context context = this;
            String packageName = context.getPackageName();
            Class<?> mainActivityClass = Class.forName(packageName + ".MainActivity");

            // Send deeplink to MainActivity
            Intent launchIntent = new Intent(this, mainActivityClass);
            launchIntent.setAction(Intent.ACTION_MAIN);
            launchIntent.addCategory(Intent.CATEGORY_LAUNCHER);
            if (data != null) {
                launchIntent.putExtra("deeplink_url", data.toString());
            }
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

            startActivity(launchIntent);
        } catch (Exception e) {
            Log.e(TAG, "Error handling deep link intent", e);
        } finally {
            finish(); 
        }
    }
}
