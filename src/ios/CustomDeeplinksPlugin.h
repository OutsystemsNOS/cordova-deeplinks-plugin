#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomDeeplinksPlugin : CDVPlugin

+ (void)setPendingURL:(NSString *)url;
- (void)getPendingDeeplink:(CDVInvokedUrlCommand *)command;
- (BOOL)handleUserActivity:(NSUserActivity *)userActivity;

@end
