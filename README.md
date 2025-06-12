
# cordova-custom-deeplinks-plugin

Cordova plugin to handle **universal links** and **deep links** on Android and iOS, with automatic event dispatch and support for retrieving pending links on app launch.

## 📦 Installation

Install the plugin via the Cordova CLI:

```bash
cordova plugin add https://github.com/MiguelRosaDev/cordova-custom-deeplinks-plugin.git \
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
- `APP_PATHPATTERN`: path pattern (e.g. `.*` for all paths)

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

The plugin injects an `<intent-filter>` into `AndroidManifest.xml`:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" />
  <data android:host="app host" />
  <data android:pathPattern=".*" />
</intent-filter>
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
