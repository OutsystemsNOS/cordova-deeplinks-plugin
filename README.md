# cordova-plugin-intent-filter

Cordova plugin to inject custom `<intent-filter>` rules into the `AndroidManifest.xml` file on Android builds.  
Useful for enabling **deep linking** and **auto-verification** of app links.

## 📦 Installation

Install the plugin via the Cordova CLI and provide the required variables:

```bash
cordova plugin add cordova-plugin-intent-filter \
  --variable APP_SCHEME=https \
  --variable APP_HOST=example.com \
  --variable APP_PATHPATTERN=/path.*
