#import "CustomDeeplinksPlugin.h"

@implementation CustomDeeplinksPlugin

static NSString *pendingURL = nil;

+ (void)setPendingURL:(NSString *)url {
    pendingURL = url;
    NSLog(@"[CustomDeeplinks] Static pendingURL set to: %@", pendingURL);
}

- (void)pluginInitialize {
    // MODIFICAÇÃO: Removemos TOTALMENTE a limpeza automática aqui.
    if (pendingURL != nil) {
        NSLog(@"[CustomDeeplinks] Plugin initialized. URL waiting: %@", pendingURL);
    }
}

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    if (userActivity.webpageURL == nil) return NO;

    NSString *urlString = userActivity.webpageURL.absoluteString;
    pendingURL = urlString;

    // MODIFICAÇÃO: Comentamos o evalJs e a limpeza imediata. 
    // Vamos confiar APENAS no getPendingDeeplink do seu JS para evitar conflitos.
    /*
    if (self.webViewEngine && self.webViewEngine.engineWebView) {
        NSString *escapedURL = [urlString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *js = [NSString stringWithFormat:@"window.CustomDeeplinks.onDeepLink('%@');", escapedURL];
        [self.commandDelegate evalJs:js];
        pendingURL = nil; 
    }
    */
    
    return YES;
}

- (void)getPendingDeeplink:(CDVInvokedUrlCommand *)command {
    // Debug para saber o que está na variável no momento da chamada JS
    NSLog(@"[CustomDeeplinks] JS called getPendingDeeplink. Current value: %@", pendingURL);

    CDVPluginResult *result;
    if (pendingURL != nil && ![pendingURL isEqualToString:@""]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:pendingURL];
        pendingURL = nil; // SÓ LIMPA AQUI após entregar ao JS
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
