#import "AppDelegate+DeeplinksPlugin.h"
#import "DeeplinksPlugin.h"

@implementation AppDelegate (DeeplinksPlugin)

// Universal Link handler
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
restorationHandler:(void (^)(NSArray *))restorationHandler {

    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[Deeplinks] Invalid URL");
        return NO;
    }

    [self.viewController getCommandInstance:@"Deeplinks"];

    NOSLinksPlugin *plugin = [self.viewController getCommandInstance:@"Deeplinks"];
    if (plugin == nil) {
        NSLog(@"[Deeplinks] Plugin not found");
    }

    NSLog(@"[Deeplinks] URL: %@", userActivity.webpageURL.absoluteString);

    BOOL handled = [plugin handleUserActivity:userActivity];

    NSLog(@"[Deeplinks] handleUserActivity result: %@", handled ? @"YES" : @"NO");

    return handled;
}

// Deep link (URL scheme) handler
- (BOOL)application:(UIApplication *)app 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSLog(@"[Deeplinks] App opened via URL scheme: %@", url.absoluteString);

    return YES;
}

@end
