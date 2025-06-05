#import "AppDelegate+CULPlugin.h"
#import "CULPlugin.h"

static NSString *const PLUGIN_NAME = @"UniversalLinks";

@implementation AppDelegate (Deeplink)

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    // Ignorar atividades que não sejam Universal Links
    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] || userActivity.webpageURL == nil) {
        NSLog(@"[UniversalLinks] Ignorado: Tipo de atividade ou URL inválida");
        return NO;
    }
    
    // Obter o plugin
    CULPlugin *plugin = [self.viewController getCommandInstance:PLUGIN_NAME];
    if (plugin == nil) {
        NSLog(@"[UniversalLinks] Plugin não encontrado");
        return NO;
    }

    // Mostrar o link recebido
    NSLog(@"[UniversalLinks] Recebido URL: %@", userActivity.webpageURL.absoluteString);
    
    // Tratar o link com o plugin e guardar o resultado
    BOOL handled = [plugin handleUserActivity:userActivity];

    // Mostrar se foi tratado com sucesso
    NSLog(@"[UniversalLinks] Resultado do handleUserActivity: %@", handled ? @"SIM" : @"NÃO");

    return handled;
}
