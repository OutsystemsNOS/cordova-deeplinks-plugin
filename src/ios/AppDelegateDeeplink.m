#import "AppDelegate+CULPlugin.h"
#import "CULPlugin.h"

static NSString *const PLUGIN_NAME = @"NOSLinks";

@implementation AppDelegate (Deeplink)

// Universal Link handler
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
restorationHandler:(void (^)(NSArray *))restorationHandler {

    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[UniversalLinks] invalid url");
        return NO;
    }
    
    CULPlugin *plugin = [self.viewController getCommandInstance:PLUGIN_NAME];
    if (plugin == nil) {
        NSLog(@"[UniversalLinks] Plugin not found");
        return NO;
    }

    NSLog(@"[UniversalLinks] URL: %@", userActivity.webpageURL.absoluteString);
    
    BOOL handled = [plugin handleUserActivity:userActivity];

    NSLog(@"[UniversalLinks] handleUserActivity result: %@", handled ? @"YES" : @"NO");

    return handled;
}

// Deep link (URL scheme) handler
- (BOOL)application:(UIApplication *)app 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSLog(@"[DeepLink] App opened via URL scheme: %@", url.absoluteString);
    
    return YES;
}

@end
