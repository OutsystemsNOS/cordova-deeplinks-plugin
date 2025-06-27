#import "CustomDeeplinksPlugin.h"

@implementation CustomDeeplinksPlugin

static NSString *pendingURL = nil;

- (void)pluginInitialize {
    if (pendingURL != nil) {
        NSString *escapedURL = [pendingURL stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *js = [NSString stringWithFormat:@"window.CustomDeeplinks && window.CustomDeeplinks.onDeepLink && window.CustomDeeplinks.onDeepLink('%@');", escapedURL];
        [self.commandDelegate evalJs:js];
        NSLog(@"[CustomDeeplinks] Fire pending universal link: %@", pendingURL);
        pendingURL = nil;
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
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

@end
