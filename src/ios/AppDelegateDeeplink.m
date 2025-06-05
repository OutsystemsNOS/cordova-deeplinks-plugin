#import "AppDelegate+CULPlugin.h"
#import "CULPlugin.h"

static NSString *const PLUGIN_NAME = @"UniversalLinks";

@implementation AppDelegate (Deeplink)

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {

    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[UniversalLinks] Ignorado: Tipo de atividade ou URL inválida");
        return NO;
    }
    
    CULPlugin *plugin = [self.viewController getCommandInstance:PLUGIN_NAME];
    if (plugin == nil) {
        NSLog(@"[UniversalLinks] Plugin não encontrado");
        return NO;
    }

    // Show deeplink
    NSLog(@"[UniversalLinks] Recebido URL: %@", userActivity.webpageURL.absoluteString);
    
    BOOL handled = [plugin handleUserActivity:userActivity];

    // show if it is a valid universal link
    NSLog(@"[UniversalLinks] Resultado do handleUserActivity: %@", handled ? @"YES" : @"NO");

    return handled;
}
@end
