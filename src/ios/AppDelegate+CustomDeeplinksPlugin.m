#import "AppDelegate+CustomDeeplinksPlugin.h"
#import "CustomDeeplinksPlugin.h"

@implementation AppDelegate (CustomDeeplinksPlugin)

- (BOOL)isAppsFlyerEnabled {
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"xml"];
    if (!configPath) return NO;

    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    if (!configData) return NO;

    NSString *configString = [[NSString alloc] initWithData:configData encoding:NSUTF8StringEncoding];
    
    // Find preference: name="ENABLE_APPSFLYER_DEEEPLINKS" value="true"
    NSString *targetPattern = @"name=\"ENABLE_APPSFLYER_DEEEPLINKS\"";
    
    if ([configString rangeOfString:targetPattern options:NSCaseInsensitiveSearch].location != NSNotFound) {
        if ([configString rangeOfString:@"value=\"true\"" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    
    return NO; 
}

- (void)notifyAppsFlyerWithUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    if (![self isAppsFlyerEnabled]) {
        NSLog(@"[CustomDeeplinks] Forwarding blocked: ENABLE_APPSFLYER_DEEEPLINKS is false");
        return;
    }
    
    Class appsFlyerClass = NSClassFromString(@"AppsFlyerLib");
    CDVViewController* vc = (CDVViewController*)self.viewController; 

    if (!appsFlyerClass) return;

    SEL sharedSelector = NSSelectorFromString(@"shared");
    if (![appsFlyerClass respondsToSelector:sharedSelector]) return;
    
    id sharedLib = [appsFlyerClass performSelector:sharedSelector];
    if (!sharedLib) return;

    SEL devKeySelector = NSSelectorFromString(@"appsFlyerDevKey");
    SEL continueSelector = NSSelectorFromString(@"continueUserActivity:restorationHandler:");
    if (![sharedLib respondsToSelector:continueSelector]) return;

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *devKey = [sharedLib respondsToSelector:devKeySelector] ? [sharedLib performSelector:devKeySelector] : nil;
    #pragma clang diagnostic pop

    if (devKey && devKey.length > 0) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [sharedLib performSelector:continueSelector withObject:userActivity withObject:restorationHandler];
        #pragma clang diagnostic pop
        NSLog(@"[CustomDeeplinks] Warm Start: Universal Link forwarded to AppsFlyer immediately");
    } else {
        NSLog(@"[CustomDeeplinks] Cold Start: Waiting 2.5s for AppsFlyer JS initialization...");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [sharedLib performSelector:continueSelector withObject:userActivity withObject:restorationHandler];
            #pragma clang diagnostic pop
            NSLog(@"[CustomDeeplinks] Cold Start: Delayed Universal Link forwarded to AppsFlyer");
        });
    }
}

- (void)notifyAppsFlyerWithURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if (![self isAppsFlyerEnabled]) {
        NSLog(@"[CustomDeeplinks] Forwarding blocked: ENABLE_APPSFLYER_DEEEPLINKS is false");
        return;
    }
    
    Class appsFlyerClass = NSClassFromString(@"AppsFlyerLib");
    CDVViewController* vc = (CDVViewController*)self.viewController;
    
    if (!appsFlyerClass) return;

    SEL sharedSelector = NSSelectorFromString(@"shared");
    if (![appsFlyerClass respondsToSelector:sharedSelector]) return;
    
    id sharedLib = [appsFlyerClass performSelector:sharedSelector];
    if (!sharedLib) return;

    SEL devKeySelector = NSSelectorFromString(@"appsFlyerDevKey");
    SEL openURLSelector = NSSelectorFromString(@"handleOpenURL:options:");
    if (![sharedLib respondsToSelector:openURLSelector]) return;

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *devKey = [sharedLib respondsToSelector:devKeySelector] ? [sharedLib performSelector:devKeySelector] : nil;
    #pragma clang diagnostic pop

    if (devKey && devKey.length > 0) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [sharedLib performSelector:openURLSelector withObject:url withObject:options];
        #pragma clang diagnostic pop
        NSLog(@"[CustomDeeplinks] Warm Start: URL Scheme forwarded to AppsFlyer immediately");
    } else {
        NSLog(@"[CustomDeeplinks] Cold Start: Waiting 2.5s for AppsFlyer JS initialization...");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [sharedLib performSelector:openURLSelector withObject:url withObject:options];
            #pragma clang diagnostic pop
            NSLog(@"[CustomDeeplinks] Cold Start: Delayed URL Scheme forwarded to AppsFlyer");
        });
    }
}

// Universal Link handler
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
restorationHandler:(void (^)(NSArray *))restorationHandler {

    NSLog(@"[CustomDeeplinks] First click");
    
    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[CustomDeeplinks] Invalid URL");
        return NO;
    }

    [self notifyAppsFlyerWithUserActivity:userActivity restorationHandler:restorationHandler];

    CustomDeeplinksPlugin *plugin = [self.viewController getCommandInstance:@"CustomDeeplinks"];
    if (plugin == nil) {
        NSLog(@"[Deeplinks] Plugin not found");
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
    [self notifyAppsFlyerWithURL:url options:options];

    return YES;
}

@end
