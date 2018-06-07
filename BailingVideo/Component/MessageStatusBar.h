//
//  MessageStatusBar.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/11.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageStatusBar : UIWindow
 
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, assign) CGFloat animateWithDuration;
@property (nonatomic, assign) CGFloat messageDelaySeconds;

/**
 *  显示后自动隐藏,整个过程持续1.3秒,同时按自定义颜色显示背景色
 *
 *  @param message
 *  @param bgColor
 */
- (void)showMessageStatusBar:(NSString *)message withBackgroundColor:(UIColor *)bgColor;

/**
 *  显示后会一直显示,不会自动隐藏,需要使用下面的hideManual手动隐藏
 *  @param message
 */
- (void)showMessageStatusBar:(NSString *)message;

- (void)hideManual;

/**
 *  显示后自动隐藏,整个过程持续1.3秒
 *  @param message
 */
- (void)showMessageBarAndHideAuto:(NSString *)message;

/**
 *  显示后自动隐藏,整个过程持续1.3秒,并在隐藏后执行block
 *  @param message
 *  @param finishBlock
 */
- (void)showMessageBarAndHideAuto:(NSString *)message finish:(void (^)(void))finishBlock;

@end
