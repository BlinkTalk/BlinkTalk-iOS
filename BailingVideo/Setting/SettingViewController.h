//
//  SettingViewController.h
//  BlinkTalk
//
//  Created by LiuLinhong on 16/11/11.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingViewBuilder.h"
#import "SettingTableViewDelegateSourceImpl.h"
#import "SettingPickViewDelegateImpl.h"
#import "UINavigationController+returnBack.h"

#define Key_Min @"min"
#define Key_Max @"max"
#define Key_Default @"default"
#define Key_Step @"step"
@class LoginViewController;
@interface SettingViewController : UIViewController

@property (nonatomic, strong) LoginViewController *loginVC;
@property (nonatomic, strong) SettingViewBuilder *settingViewBuilder;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSUInteger sectionNumber;
@property (nonatomic, strong) NSArray *resolutionRatioArray, *frameRateArray, *codeRateArray, *codingStyleArray;
@property (nonatomic, assign) NSInteger resolutionRatioIndex, frameRateIndex, codeRateIndex, connectionStyleIndex, codingStyleIndex, minCodeRateIndex, observerIndex;
@property (nonatomic, strong) UISwitch *connectStyleSwitch, *gpuSwitch, *srtpSwitch, *quicSwitch;
@property (nonatomic, strong) SettingTableViewDelegateSourceImpl *settingTableViewDelegateSourceImpl;
@property (nonatomic, strong) SettingPickViewDelegateImpl *settingPickViewDelegateImpl;
@property (nonatomic, assign) BOOL isGPUFilter, isSRTPEncrypt, isQuicRequestMode;
@property (nonatomic, strong) UIAlertController *alertController;


+ (NSUserDefaults *)shareSettingUserDefaults;
- (void)connectStyleSwitchAction;
- (void)gpuSwitchAction;
- (void)quicSwitchAction;

@end
