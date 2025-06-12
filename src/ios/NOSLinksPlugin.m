#import "NOSLinksPlugin.h"

@implementation NOSLinksPlugin

static NSString *pendingURL = nil;

- (void)pluginInitialize {
    if (pendingURL != nil) {
        NSString *js = [NSString stringWithFormat:@"window.NOSLinks && window.NOSLinks.onDeepLink && window.NOSLinks.onDeepLink('%@');", pendingURL];
        [self.commandDelegate evalJs:js];
        NSLog(@"[NOSLinks] Fire pending universal link: %@", pendingURL);
        pendingURL = nil;
    }
}

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    if (userActivity.webpageURL == nil) return NO;

    NSString *urlString = userActivity.webpageURL.absoluteString;
    NSLog(@"[NOSLinks] Handling universal link: %@", urlString);

    pendingURL = urlString;

    if (self.webViewEngine && self.webViewEngine.engineWebView) {NSString *js = [NSString stringWithFormat:@"window.NOSLinks && window.NOSLinks.onDeepLink && window.NOSLinks.onDeepLink('%@');", urlString];
        [self.commandDelegate evalJs:js];
        NSLog(@"[NOSLinks] Fire universal link: %@", urlString);
    }

    return YES;
}

@end
