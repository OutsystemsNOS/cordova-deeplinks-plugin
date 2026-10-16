
# cordova-custom-deeplinks-plugin

Cordova plugin to handle **universal links** and **deep links** on Android and iOS, with automatic event dispatch and support for retrieving pending links on app launch.

---

## ⚠️ Important Requirements

To ensure deep links work properly with **App Links (Android)** and **Universal Links (iOS)**, your domain **must** be correctly configured with the following files:

- `https://<your-domain>/.well-known/assetlinks.json` (Android)
- `https://<your-domain>/.well-known/apple-app-site-association` (iOS)

> These files must be publicly accessible and contain the correct app association data.  
> See the [official Android documentation](https://developer.android.com/training/app-links/deep-linking) and [Apple documentation](https://developer.apple.com/documentation/xcode/supporting-associated-domains) for more details.

---

## 📦 Installation

Install the plugin via the Cordova CLI:

```bash
cordova plugin add https://github.com/MiguelRosaDev/cordova-deeplinks-plugin \
  --variable APP_SCHEME=https \
  --variable APP_HOST=your domain \
  --variable APP_PATHPATTERN=".*"
```

> Replace with your own repository URL and values if needed.

## 📱 Supported Platforms

- ✅ Android (Cordova Android >= 10)
- ✅ iOS (Cordova iOS >= 5)

## ⚙️ Preferences

These are the configurable plugin variables:

- `APP_SCHEME`: the URI scheme (e.g. `https`)
- `APP_HOST`: the host/domain (e.g. `your app host`)
- `APP_BRANDED`: optional branded host/domain (e.g. `your branded host`)
- `APP_PATHPATTERN`: path pattern (e.g. `.*` for all paths)
- `IOS_ATTRIBUTION_REPORT_ENDPOINT` *(iOS, optional, since 1.7)*: value of the `NSAdvertisingAttributionReportEndpoint` key (SKAdNetwork) in `Info.plist` (e.g. `https://appsflyer-skadnetwork.com/`)
- `IOS_ATTRIBUTION_COPY_ENDPOINT` *(iOS, optional, since 1.7)*: value of the `AttributionCopyEndpoint` key (AdAttributionKit, iOS 17.4+) in `Info.plist` (e.g. `https://appsflyer-skadnetwork.com/`)

### iOS attribution endpoints (optional)

When `IOS_ATTRIBUTION_REPORT_ENDPOINT` / `IOS_ATTRIBUTION_COPY_ENDPOINT` are set, the plugin adds the corresponding keys to the root of the app `Info.plist`:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://appsflyer-skadnetwork.com/</string>
<key>AttributionCopyEndpoint</key>
<string>https://appsflyer-skadnetwork.com/</string>
```

Each variable is independent. If a variable is omitted (or set to `none`, `undefined`, `null`, `false` or an empty value), its key is **not** added to `Info.plist`. This is handled by the `after_prepare` hook `hooks/iosAttributionEndpoints.js`, because `plugin.xml` cannot add `Info.plist` entries conditionally.

### OutSystems extensibility configuration

```json
{
  "plugin": {
    "url": "https://github.com/OutsystemsNOS/cordova-deeplinks-plugin/tree/V1.7",
    "variables": [
      { "name": "APP_SCHEME", "value": "https" },
      { "name": "APP_HOST", "value": "your app host" },
      { "name": "APP_BRANDED", "value": "your branded host" },
      { "name": "APP_PATHPATTERN", "value": "/" },
      { "name": "IOS_ATTRIBUTION_REPORT_ENDPOINT", "value": "https://appsflyer-skadnetwork.com/" },
      { "name": "IOS_ATTRIBUTION_COPY_ENDPOINT", "value": "https://appsflyer-skadnetwork.com/" }
    ]
  }
}
```

To keep the 1.6 behaviour (no attribution keys), remove the two `IOS_ATTRIBUTION_*` variables.

## 🚀 Usage

### Handle deep link events

When the app is open and receives a link:

```js
window.addEventListener('deeplinks', function (event) {
  const url = event.detail.url;
  console.log('Received deep link:', url);
  // Handle navigation here
});
```

### Get pending link on app launch

If the app was opened via a deep link, retrieve it after `deviceready`:

```js
document.addEventListener('deviceready', function () {
  window.CustomDeeplinks.getPendingDeeplink(function (url) {
    if (url) {
      console.log('Pending deep link:', url);
      // Handle navigation here
    }
  });
});
```

## 🛠 Android Configuration

The plugin injects an `<intent-filter>` into `AndroidManifest.xml` with a new activity CustomDeeplinksActivity:

```xml
 <config-file target="AndroidManifest.xml" parent="/manifest/application">
     <activity android:exported="true"
               android:name="com.cordova.deeplinks.plugin.CustomDeeplinksActivity"
               android:theme="@android:style/Theme.NoDisplay">
         <intent-filter android:autoVerify="true">
             <action android:name="android.intent.action.VIEW" />
             <category android:name="android.intent.category.DEFAULT" />
             <category android:name="android.intent.category.BROWSABLE" />
             <data android:scheme="https" android:host="$APP_HOST" android:pathPrefix="$APP_PATHPATTERN" />
             <data android:scheme="http" android:host="$APP_HOST" android:pathPrefix="$APP_PATHPATTERN" />
         </intent-filter>
     </activity>
 </config-file>
```

Make sure your domain is properly verified for **App Links** in your assetlinks.json.

## 🍏 iOS Configuration

The plugin sets up Universal Links by modifying the entitlements:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:your app host</string>
</array>
```

Also handles universal link routing inside the `AppDelegate`.

## 🧪 Example Test Link

```
https://<your app host>/some page
```

---

Developed and maintained by [MiguelRosaDev](https://github.com/MiguelRosaDev)
