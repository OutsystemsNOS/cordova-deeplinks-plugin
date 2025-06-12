#import "DeeplinksPlugin.h"

@implementation DeeplinksPlugin

static NSString *pendingURL = nil;

- (void)pluginInitialize {
    if (pendingURL != nil) {
        NSString *escapedURL = [pendingURL stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *js = [NSString stringWithFormat:@"window.Deeplinks && window.Deeplinks.onDeepLink && window.Deeplinks.onDeepLink('%@');", escapedURL];
        [self.commandDelegate evalJs:js];
        NSLog(@"[Deeplinks] Fire pending universal link: %@", pendingURL);
        pendingURL = nil;
    }
}

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    if (userActivity.webpageURL == nil) return NO;

    NSString *urlString = userActivity.webpageURL.absoluteString;
    NSLog(@"[Deeplinks] Handling universal link: %@", urlString);

    pendingURL = urlString;

    if (self.webViewEngine && self.webViewEngine.engineWebView) {
        NSString *escapedURL = [urlString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *js = [NSString stringWithFormat:@"window.Deeplinks && window.Deeplinks.onDeepLink && window.Deeplinks.onDeepLink('%@');", escapedURL];
        [self.commandDelegate evalJs:js];
        NSLog(@"[Deeplinks] Fire universal link immediately: %@", urlString);
    }

    return YES;
}

@end
