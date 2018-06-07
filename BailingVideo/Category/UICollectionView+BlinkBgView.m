//
//  UIView+BlinkBgView.m
//  BlinkTalk
//
//  Created by Vicky on 2018/1/24.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "UICollectionView+BlinkBgView.h"
#import <objc/runtime.h>

static NSString *strKey = @"touchDelegate";

@implementation UICollectionView (BlinkBgView)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint point1 = [self convertPoint:point toView:self.chatVC.whiteBoardWebView];
    __weak ChatViewController *weakChatVC = self.chatVC;
    
    if (!weakChatVC) {
        return [super hitTest:point withEvent:event];
    }
    if (CGRectContainsPoint(self.frame, point) && (weakChatVC.userIDArray.count * 90 < ScreenWidth && point1.x > weakChatVC.userIDArray.count * 90)){
        return self.superview;
    }else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)setChatVC:(ChatViewController *)chatVC
{
    objc_setAssociatedObject(self, (__bridge const void *)(strKey), chatVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ChatViewController *)chatVC
{
    return objc_getAssociatedObject(self, (__bridge const void *)(strKey));
}

@end
