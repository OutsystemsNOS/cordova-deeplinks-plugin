#import "AppDelegate+CULPlugin.h"
#import "CULPlugin.h"

static NSString *const PLUGIN_NAME = @"UniversalLinks";

@implementation AppDelegate (Deeplink)

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {

    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[UniversalLinks] invalid url");
        return NO;
    }
    
    CULPlugin *plugin = [self.viewController getCommandInstance:PLUGIN_NAME];
    if (plugin == nil) {
        NSLog(@"[UniversalLinks] Plugin not found");
        return NO;
    }

    // Show deeplink
    NSLog(@"[UniversalLinks] URL: %@", userActivity.webpageURL.absoluteString);
    
    BOOL handled = [plugin handleUserActivity:userActivity];

    // show if it is a valid universal link
    NSLog(@"[UniversalLinks] handleUserActivity result: %@", handled ? @"YES" : @"NO");

    return handled;
}
@end
