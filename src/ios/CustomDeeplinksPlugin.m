#import "CustomDeeplinksPlugin.h"

@implementation CustomDeeplinksPlugin

static NSString *pendingURL = nil;

+ (void)setPendingURL:(NSString *)url {
    pendingURL = url;
    NSLog(@"[CustomDeeplinks] Static pendingURL set to: %@", pendingURL);
}

- (void)pluginInitialize {
    if (pendingURL != nil) {
        NSLog(@"[CustomDeeplinks] Plugin initialized. URL waiting for JS: %@", pendingURL);
    }
}

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    if (userActivity.webpageURL == nil) return NO;

    NSString *urlString = userActivity.webpageURL.absoluteString;
    NSLog(@"[CustomDeeplinks] Handling active link: %@", urlString);

    pendingURL = urlString;

    if (self.webViewEngine && self.webViewEngine.engineWebView) {

        NSString *js = [NSString stringWithFormat:
            @"var evt = new CustomEvent('deeplinks', { detail: { url: '%@' } }); window.dispatchEvent(evt);", 
            urlString];
            
        [self.commandDelegate evalJs:js];
        NSLog(@"[CustomDeeplinks] Event 'deeplinks' dispatched to JS");
        
        pendingURL = nil;
    }

    return YES;
}

- (void)getPendingDeeplink:(CDVInvokedUrlCommand *)command {
    NSLog(@"[CustomDeeplinks] JS called getPendingDeeplink. Current value: %@", pendingURL);

    CDVPluginResult *result;
    if (pendingURL != nil && ![pendingURL isEqualToString:@""]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:pendingURL];
        pendingURL = nil; 
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
