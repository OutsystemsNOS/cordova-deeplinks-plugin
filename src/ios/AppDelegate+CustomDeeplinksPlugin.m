#import "AppDelegate+CustomDeeplinksPlugin.h"
#import "CustomDeeplinksPlugin.h"

@implementation AppDelegate (CustomDeeplinksPlugin)

- (BOOL)isAppsFlyerEnabled {
    NSLog(@"[CustomDeeplinks] Starting isAppsFlyerEnabled check...");

    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"xml"];
    if (!configPath) {
        NSLog(@"[CustomDeeplinks] ERROR: config.xml path not found in mainBundle!");
        return NO;
    }
    NSLog(@"[CustomDeeplinks] config.xml found at path: %@", configPath);

    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    if (!configData) {
        NSLog(@"[CustomDeeplinks] ERROR: Could not read data from config.xml!");
        return NO;
    }

    NSString *configString = [[NSString alloc] initWithData:configData encoding:NSUTF8StringEncoding];
    if (!configString) {
        NSLog(@"[CustomDeeplinks] ERROR: Could not convert config.xml data to String!");
        return NO;
    }
    
    NSString *targetPattern = @"ENABLE_APPSFLYER_DEEEPLINKS";
    NSRange range = [configString rangeOfString:targetPattern options:NSCaseInsensitiveSearch];
    
    if (range.location == NSNotFound) {
        NSLog(@"[CustomDeeplinks] ERROR: Preference ENABLE_APPSFLYER_DEEEPLINKS completely missing from config.xml text!");
        return NO;
    }
    
    NSLog(@"[CustomDeeplinks] Preference key found in config.xml! Checking value...");

    NSUInteger searchStart = range.location;
    NSUInteger lengthToSearch = MIN(100, configString.length - searchStart);
    NSString *subSegment = [configString substringWithRange:NSMakeRange(searchStart, lengthToSearch)];
    
    if ([subSegment rangeOfString:@"value=\"true\"" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSLog(@"[CustomDeeplinks] SUCCESS: isAppsFlyerEnabled is true");
        return YES;
    }

    NSLog(@"[CustomDeeplinks] SUCCESS: isAppsFlyerEnabled is false (value is not true)");
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
