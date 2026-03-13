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

// Este método é chamado pelo AppDelegate quando a app já está aberta
- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    if (userActivity.webpageURL == nil) return NO;

    NSString *urlString = userActivity.webpageURL.absoluteString;
    NSLog(@"[CustomDeeplinks] Handling active link: %@", urlString);

    // 1. Guardamos na mesma para o caso de o JS ainda não ter feito o check
    pendingURL = urlString;

    // 2. Disparamos o evento CustomEvent para o seu window.addEventListener("deeplinks")
    if (self.webViewEngine && self.webViewEngine.engineWebView) {
        // MODIFICAÇÃO: Dispara o evento "deeplinks" que o seu JS espera
        NSString *js = [NSString stringWithFormat:
            @"var evt = new CustomEvent('deeplinks', { detail: { url: '%@' } }); window.dispatchEvent(evt);", 
            urlString];
            
        [self.commandDelegate evalJs:js];
        NSLog(@"[CustomDeeplinks] Event 'deeplinks' dispatched to JS");
        
        // Limpamos o pendingURL porque o evento já o entregou em "tempo real"
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
