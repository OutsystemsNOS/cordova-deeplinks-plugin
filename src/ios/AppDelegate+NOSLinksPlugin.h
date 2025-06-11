#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NOSLinksPlugin : CDVPlugin

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity;

@end
