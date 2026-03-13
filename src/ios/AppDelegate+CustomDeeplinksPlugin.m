#import "AppDelegate+CustomDeeplinksPlugin.h"
#import "CustomDeeplinksPlugin.h"

@implementation AppDelegate (CustomDeeplinksPlugin)

// Universal Link handler (HTTPS links)
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
restorationHandler:(void (^)(NSArray *))restorationHandler {

    NSLog(@"[CustomDeeplinks] continueUserActivity triggered");
    
    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        return NO;
    }

    NSString *urlString = userActivity.webpageURL.absoluteString;
    NSLog(@"[CustomDeeplinks] URL detected: %@", urlString);

    [CustomDeeplinksPlugin setPendingURL:urlString];

    if (self.viewController != nil) {
        CustomDeeplinksPlugin *plugin = [self.viewController getCommandInstance:@"CustomDeeplinks"];
        if (plugin != nil) {
            NSLog(@"[CustomDeeplinks] Plugin found, handling activity immediately.");
            [plugin handleUserActivity:userActivity];
        } else {
            NSLog(@"[CustomDeeplinks] Plugin not initialized yet. URL cached in static variable.");
        }
    }

    return YES;
}

// Deep link handler (Custom URL Schemes: myapp://)
- (BOOL)application:(UIApplication *)app 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSLog(@"[CustomDeeplinks] openURL triggered: %@", url.absoluteString);

    [CustomDeeplinksPlugin setPendingURL:url.absoluteString];

    if (self.viewController != nil) {
        CustomDeeplinksPlugin *plugin = [self.viewController getCommandInstance:@"CustomDeeplinks"];
        if (plugin != nil) {
            NSLog(@"[CustomDeeplinks] Notifying plugin of URL Scheme");
            // Se tiveres lógica específica para schemes no plugin, podes chamar aqui
        }
    }

    return YES;
}

@end
