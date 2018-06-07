//
//  UINavigationController+returnBack.m
//  BlinkTalk
//
//  Created by Vicky on 2018/1/30.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "UINavigationController+returnBack.h"


@implementation UIViewController (BackButtonHandler)

@end

@interface UINavigationController() <UINavigationBarDelegate>

@end

@implementation UINavigationController (returnBack)


- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if ([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController *vc = [self topViewController];
    if ([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        shouldPop = [vc navigationShouldPopOnBackButton];
    }
    
    if (shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }else{
        for (UIView *subView in [navigationBar subviews]) {
            if (0. < subView.alpha && subView.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subView.alpha = 1.;
                }];
            }
        }
    }
    
    return NO;
}

@end
