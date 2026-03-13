#import "AppDelegate+CustomDeeplinksPlugin.h"
#import "CustomDeeplinksPlugin.h"

@implementation AppDelegate (CustomDeeplinksPlugin)

// Universal Link handler
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
restorationHandler:(void (^)(NSArray *))restorationHandler {

    NSLog(@"[CustomDeeplinks] First click");
    
    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[CustomDeeplinks] Invalid URL");
        return NO;
    }

    // MODIFICAÇÃO: Guarda a URL na variável estática antes de tentar obter a instância (Fix Cold Start)
    [CustomDeeplinksPlugin setPendingURL:userActivity.webpageURL.absoluteString];

    CustomDeeplinksPlugin *plugin = [self.viewController getCommandInstance:@"CustomDeeplinks"];
    if (plugin == nil) {
        NSLog(@"[Deeplinks] Plugin not found");
        // MODIFICAÇÃO: Retornamos YES aqui porque a URL já foi guardada em setPendingURL para uso posterior
        return YES;
    }

    NSLog(@"[CustomDeeplinks] URL: %@", userActivity.webpageURL.absoluteString);

    BOOL handled = [plugin handleUserActivity:userActivity];

    NSLog(@"[CustomDeeplinks] handleUserActivity result: %@", handled ? @"YES" : @"NO");

    return handled;
}

// Deep link (URL scheme) handler
- (BOOL)application:(UIApplication *)app 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSLog(@"[CustomDeeplinks] App opened via URL scheme: %@", url.absoluteString);

    // MODIFICAÇÃO: Suporte para URL Schemes no Cold Start
    [CustomDeeplinksPlugin setPendingURL:url.absoluteString];

    return YES;
}

@end
