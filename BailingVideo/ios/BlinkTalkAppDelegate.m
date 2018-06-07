//
//  BlinkTalkAppDelegate.m
//  BlinkTalk
//
//  Created by Bailing Cloud on 2016/11/11.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "BlinkTalkAppDelegate.h"

@implementation BlinkTalkAppDelegate {
    UIWindow *_window;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (self.isForceLandscape) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else if (self.isForcePortrait){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:task];
        task = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
