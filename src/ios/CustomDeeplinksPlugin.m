#import "CustomDeeplinksPlugin.h"

@implementation CustomDeeplinksPlugin

static NSString *pendingURL = nil;

// Static method to allow the AppDelegate to write the URL without needing the active instance.
+ (void)setPendingURL:(NSString *)url {
    pendingURL = url;
}

- (void)pluginInitialize {
    // The immediate clearing of the pendingURL has been removed here to allow JS to consume it via getPendingDeeplink if preferred.
    if (pendingURL != nil) {
        /*
        NSString *escapedURL = [pendingURL stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *js = [NSString stringWithFormat:@"window.CustomDeeplinks && window.CustomDeeplinks.onDeepLink && window.CustomDeeplinks.onDeepLink('%@');", escapedURL];
        [self.commandDelegate evalJs:js];
        NSLog(@"[CustomDeeplinks] Fire pending universal link: %@", pendingURL);
        // pendingURL = nil; // Commented out to avoid race conditions using JS's getPendingDeeplink.
        */
    }
}

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    if (userActivity.webpageURL == nil) return NO;

    NSString *urlString = userActivity.webpageURL.absoluteString;
    NSLog(@"[CustomDeeplinks] Handling universal link: %@", urlString);

    pendingURL = urlString;

    if (self.webViewEngine && self.webViewEngine.engineWebView) {
        NSString *escapedURL = [urlString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *js = [NSString stringWithFormat:@"window.CustomDeeplinks && window.CustomDeeplinks.onDeepLink && window.CustomDeeplinks.onDeepLink('%@');", escapedURL];
        [self.commandDelegate evalJs:js];
        NSLog(@"[CustomDeeplinks] Fire universal link immediately: %@", urlString);
        pendingURL = nil;
    }

    return YES;
}

- (void)getPendingDeeplink:(CDVInvokedUrlCommand *)command {
    if (pendingURL != nil) {
        NSLog(@"[CustomDeeplinks] Returning pending URL: %@", pendingURL);
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:pendingURL];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

        pendingURL = nil;
    } else {
        NSLog(@"[CustomDeeplinks] No pending URL");
        
        // Return OK with nil instead of NO_RESULT to make handling easier in JS.
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

@end
