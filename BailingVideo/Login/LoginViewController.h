//
//  LoginViewController.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Blink/BlinkEngine.h>
#import "SettingViewController.h"
#import "LoginViewBuilder.h"
#import "LoginBlinkEngineDelegateImpl.h"
#import "LoginTextFieldDelegateImpl.h"
#import "MessageStatusBar.h"

/**
 *定义网络连接方式
 */
typedef NS_ENUM(NSInteger, BlinkConnectionMode)
{
    Blink_ConnectionMode_TCP = 0,
    Blink_ConnectionMode_QUIC = 1
};

@interface LoginViewController : UIViewController

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSArray *configListArray;
@property (nonatomic, strong) BlinkEngine *blinkEngine;
@property (nonatomic, strong) NSString *keyToken;
@property (nonatomic, strong) NSURL *tokenURL;
@property (nonatomic, strong) NSString *userDefinedToken, *userDefinedCMP, *userDefinedAppKey;
@property (nonatomic, strong) SettingViewController *settingViewController;
@property (nonatomic, strong) LoginViewBuilder *loginViewBuilder;
@property (nonatomic, strong) LoginBlinkEngineDelegateImpl *loginBlinkEngineDelegateImpl;
@property (nonatomic, strong) LoginTextFieldDelegateImpl *loginTextFieldDelegateImpl;
@property (nonatomic, assign) BOOL isUserDefinedTokenAndCMP, isRoomNumberInput;

+ (NSDictionary *)selectedConfigData;
+ (NSString *)getKeyToken;
+ (void)setConnectionState:(BlinkConnectionState)state;
- (void)roomNumberTextFieldDidChange:(UITextField *)textField;
- (void)userNameTextFieldDidChange:(UITextField *)textField;
- (void)joinRoomButtonPressed:(id)sender;
- (void)onRadioButtonValueChanged:(RadioButton *)sender;
- (void)loginSettingButtonPressed;
- (void)updateJoinRoomButtonSocket:(BlinkConnectionState)state;

@end
