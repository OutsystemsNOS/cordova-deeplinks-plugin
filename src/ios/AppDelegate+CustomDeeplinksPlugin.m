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

    // MODIFICAÇÃO: Verificação segura da instância do plugin
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

    CustomDeeplinksPlugin *plugin = [self.viewController getCommandInstance:@"CustomDeeplinks"];
    if (plugin != nil) {
        // Criamos um NSUserActivity fake ou chamamos um método interno para processar a URL
        NSLog(@"[CustomDeeplinks] Notifying plugin of URL Scheme");
    }

    return YES;
}

@end// Deep link (URL scheme) handler
- (BOOL)application:(UIApplication *)app 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSLog(@"[CustomDeeplinks] App opened via URL scheme: %@", url.absoluteString);

    // Support for URL Schemes in Cold Start
    [CustomDeeplinksPlugin setPendingURL:url.absoluteString];

    return YES;
}

@end
