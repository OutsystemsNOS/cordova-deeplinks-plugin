#import "NOSLinksPlugin.h"

@implementation NOSLinksPlugin

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    if (userActivity.webpageURL == nil) {
        NSLog(@"[NOSLinks] No URL to handle.");
        return NO;
    }

    NSString *urlString = userActivity.webpageURL.absoluteString;
    NSLog(@"[NOSLinks] Handling universal link: %@", urlString);

    NSString *js = [NSString stringWithFormat:@"window.nosLinks && window.nosLinks.onDeepLink && window.nosLinks.onDeepLink('%@');", urlString];
    [self.commandDelegate evalJs:js];

    return YES;
}

@end
