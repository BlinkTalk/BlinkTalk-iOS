//
//  LoginViewBuilder.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadioButton.h"

#define JoinButtonEnableBackgroundColor [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0]
#define JoinButtonUnableBackgroundColor [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0]

@interface LoginViewBuilder : NSObject

@property (nonatomic, strong) UIImageView *loginIconImageView;
@property (nonatomic, strong) UIView *inputNumPasswordView;
@property (nonatomic, strong) UILabel *welcomeLabel, *titleLabel, *contentLabel, *versionLabel, *copyrightLabel, *userNameTitleLabel;
@property (nonatomic, strong) UITextField *roomNumberTextField, *roomPasswordTextField, *userNameTextField;
@property (nonatomic, strong) UIButton *joinRoomButton;
@property (nonatomic, strong) UIButton *loginSettingButton;
@property (nonatomic, strong) NSMutableArray *radioButtons;
@property (nonatomic, strong) CALayer *lineLayer;

- (instancetype)initWithViewController:(UIViewController *)vc;
- (void)reloadLoginView;

@end
