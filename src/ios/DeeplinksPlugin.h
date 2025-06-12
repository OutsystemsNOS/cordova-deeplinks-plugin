#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeeplinksPlugin : CDVPlugin

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity;

@end
