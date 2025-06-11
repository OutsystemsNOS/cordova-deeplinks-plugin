#import "AppDelegate+NOSLinksPlugin.h"
#import "NOSLinksPlugin.h"

static NSString *const PLUGIN_NAME = @"NOSLinks";

@implementation AppDelegate (NOSLinksPlugin)

// Universal Link handler
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
restorationHandler:(void (^)(NSArray *))restorationHandler {

    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[NOSLinks] Invalid URL");
        return NO;
    }

    NOSLinksPlugin *plugin = [self.viewController getCommandInstance:PLUGIN_NAME];
    if (plugin == nil) {
        NSLog(@"[NOSLinks] Plugin not found");
        return NO;
    }

    NSLog(@"[NOSLinks] URL: %@", userActivity.webpageURL.absoluteString);

    BOOL handled = [plugin handleUserActivity:userActivity];

    NSLog(@"[NOSLinks] handleUserActivity result: %@", handled ? @"YES" : @"NO");

    return handled;
}

// Deep link (URL scheme) handler
- (BOOL)application:(UIApplication *)app 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSLog(@"[NOSLinks] App opened via URL scheme: %@", url.absoluteString);

    return YES;
}

@end
