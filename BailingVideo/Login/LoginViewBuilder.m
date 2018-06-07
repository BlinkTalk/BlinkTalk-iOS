//
//  LoginViewBuilder.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "LoginViewBuilder.h"
#import "LoginViewController.h"
#import "NSString+length.h"
#define kMaxInputNum 12

@interface LoginViewBuilder ()

@property (nonatomic, strong) LoginViewController *loginViewController;

@end

@implementation LoginViewBuilder

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.loginViewController = (LoginViewController *) vc;
        [self initNewView];
    }
    return self;
}

- (void)initNewView
{
    //设置按钮
    self.loginSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginSettingButton.frame = CGRectMake(ScreenWidth - 36 - 16, 36, 36, 36);
    [self.loginSettingButton setImage:[UIImage imageNamed:@"login_setting"] forState:UIControlStateNormal];
    [self.loginSettingButton setImage:[UIImage imageNamed:@"login_setting"] forState:UIControlStateHighlighted];
    [self.loginSettingButton addTarget:self.loginViewController action:@selector(loginSettingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.loginSettingButton.backgroundColor = [UIColor clearColor];
    [self.loginViewController.view addSubview:self.loginSettingButton];
    
    //logo
    self.loginIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 75) / 2, 150, 75, 75)];
    self.loginIconImageView.image = [UIImage imageNamed:@"splash_logo"];
    [self.loginViewController.view addSubview:self.loginIconImageView];
    
    //下方输入view
    self.inputNumPasswordView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - 186)];
    self.inputNumPasswordView.backgroundColor = [UIColor whiteColor];
    [self.loginViewController.view addSubview:self.inputNumPasswordView];
    
    //分隔线
    self.lineLayer = [CALayer layer];
    self.lineLayer.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    self.lineLayer.frame = CGRectMake(0, 0, self.inputNumPasswordView.frame.size.width, 0.5);
    [self.inputNumPasswordView.layer addSublayer:self.lineLayer];
    
    //欢迎体验实时高质量的音视频会议
    self.welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 26)];
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel.font = [UIFont systemFontOfSize:18];
    self.welcomeLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:214.0/255.0 blue:251.0/255.0 alpha:1.0];
    self.welcomeLabel.text = NSLocalizedString(@"login_input_meeting_welcome", nil);
    [self.inputNumPasswordView addSubview:self.welcomeLabel];
    
    //BailingVideo V1.0.0
    self.versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 46, ScreenWidth, 26)];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.font = [UIFont systemFontOfSize:14];
    self.versionLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:214.0/255.0 blue:251.0/255.0 alpha:1.0];
    self.versionLabel.text = APP_Version;
    [self.inputNumPasswordView addSubview:self.versionLabel];
    
    //请输入会议室名称
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.versionLabel.frame.origin.y + self.versionLabel.frame.size.height + 10, ScreenWidth - 60, 26)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = JoinButtonEnableBackgroundColor;
    self.titleLabel.text = NSLocalizedString(@"login_input_meeting_room_name", nil);
    [self.inputNumPasswordView addSubview:self.titleLabel];
    
    //房间号
    self.roomNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10, ScreenWidth - 60, 44)];
    self.roomNumberTextField.font = [UIFont systemFontOfSize:18];
    self.roomNumberTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.roomNumberTextField.textAlignment = NSTextAlignmentCenter;
    self.roomNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.roomNumberTextField.returnKeyType = UIReturnKeyJoin;
    self.roomNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.roomNumberTextField.placeholder = NSLocalizedString(@"login_input_meeting_room_NO", nil);
    self.roomNumberTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.roomNumberTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [self.roomNumberTextField addTarget:self.loginViewController action:@selector(roomNumberTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.inputNumPasswordView addSubview:self.roomNumberTextField];
 
    //请输入用户名称
    self.userNameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.roomNumberTextField.frame.origin.y + self.roomNumberTextField.frame.size.height + 10, ScreenWidth - 60, 26)];
    self.userNameTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.userNameTitleLabel.font = [UIFont systemFontOfSize:18];
    //    self.titleLabel.textColor = [UIColor  colorWithRed:64.0/255.0 green:135.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.userNameTitleLabel.textColor = JoinButtonEnableBackgroundColor;
    self.userNameTitleLabel.text = NSLocalizedString(@"login_input_meeting_user_name", nil);
    [self.inputNumPasswordView addSubview:self.userNameTitleLabel];
    
    //用户名称
    self.userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.userNameTitleLabel.frame.origin.y + self.userNameTitleLabel.frame.size.height + 10, ScreenWidth - 60, 44)];
    self.userNameTextField.font = [UIFont systemFontOfSize:18];
    self.userNameTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.userNameTextField.textAlignment = NSTextAlignmentCenter;
    self.userNameTextField.keyboardType = UIKeyboardTypeDefault;
    self.userNameTextField.returnKeyType = UIReturnKeyJoin;
    self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNameTextField.placeholder = NSLocalizedString(@"login_input_need_room_username", nil);
    self.userNameTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.userNameTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [self.userNameTextField addTarget:self.loginViewController action:@selector(userNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.inputNumPasswordView addSubview:self.userNameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
 
    //RadioButton
    UIView *rbView = [[UIView alloc] initWithFrame:CGRectMake(0, self.userNameTextField.frame.origin.y + self.userNameTextField.frame.size.height + 5, ScreenWidth, 75)];
 
    self.radioButtons = [NSMutableArray arrayWithCapacity:3];
    CGRect btnRect = CGRectMake(30, 10, ScreenWidth - 60, 24);
    NSArray *optionTitles = @[NSLocalizedString(@"login_input_radio_close_camera", nil), NSLocalizedString(@"login_input_radio_observer", nil)];
    
    for (NSInteger i = 0; i < [optionTitles count]; i++)
    {
        RadioButton *btn = [[RadioButton alloc] initWithFrame:btnRect];
        btn.tag = i;
        [btn addTarget:self.loginViewController action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
        btnRect.origin.y += 30;
        [btn setTitle:optionTitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setImage:[UIImage imageNamed:@"login_radio_uncheck.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"login_radio_check.png"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [rbView addSubview:btn];
        [btn setSelected:NO];
        [self.radioButtons addObject:btn];
    }
    
    [self.radioButtons[0] setGroupButtons:self.radioButtons]; // Setting buttons into the group
    [self.inputNumPasswordView addSubview:rbView];
    
    //加入会议室按钮
    self.joinRoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 
    self.joinRoomButton.frame = CGRectMake(30, self.userNameTextField.frame.origin.y + self.userNameTextField.frame.size.height + 85, ScreenWidth - 60, 44);
 
    [self.joinRoomButton setTintColor:[UIColor whiteColor]];
    self.joinRoomButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.joinRoomButton.enabled = NO;
    self.joinRoomButton.backgroundColor = JoinButtonUnableBackgroundColor;
    [self.joinRoomButton.layer setMasksToBounds:YES];
    [self.joinRoomButton.layer setCornerRadius:4.0];
    [self.joinRoomButton addTarget:self.loginViewController action:@selector(joinRoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputNumPasswordView addSubview:self.joinRoomButton];
}

- (void)reloadLoginView
{
    self.loginSettingButton.frame = CGRectMake(ScreenHeight - 36 - 16, 36, 36, 36);
    self.loginIconImageView.frame = CGRectMake((ScreenHeight - 120) / 2, 50, self.loginIconImageView.frame.size.width, self.loginIconImageView.frame.size.height);
    self.inputNumPasswordView.frame = CGRectMake(0, 186, ScreenHeight, ScreenWidth - 186);
    self.lineLayer.frame = CGRectMake(0, 0, self.inputNumPasswordView.frame.size.width, 0.5);
    self.welcomeLabel.frame = CGRectMake(0, 20, ScreenHeight, 26);
    self.versionLabel.frame = CGRectMake(0, 46, ScreenHeight, 26);
    self.titleLabel.frame = CGRectMake(30, self.versionLabel.frame.origin.y + self.versionLabel.frame.size.height + 30, ScreenHeight - 60, 26);
    self.roomNumberTextField.frame = CGRectMake(30, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10, ScreenHeight - 60, 44);
    self.joinRoomButton.frame = CGRectMake(30, self.roomNumberTextField.frame.origin.y + self.roomNumberTextField.frame.size.height + 85, ScreenHeight - 60, 44);
    self.copyrightLabel.frame = CGRectMake(0, self.inputNumPasswordView.frame.size.height - 40, ScreenHeight, 40);
}

- (void)initView
{
    //设置按钮
    self.loginSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginSettingButton.frame = CGRectMake(ScreenWidth - 36 - 16, 36, 36, 36);
    [self.loginSettingButton setImage:[UIImage imageNamed:@"login_setting"] forState:UIControlStateNormal];
    [self.loginSettingButton setImage:[UIImage imageNamed:@"login_setting"] forState:UIControlStateHighlighted];
    [self.loginSettingButton addTarget:self.loginViewController action:@selector(loginSettingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.loginSettingButton.backgroundColor = [UIColor clearColor];
    [self.loginViewController.view addSubview:self.loginSettingButton];
    
    //logo
    self.loginIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 120) / 2, 162, 120, 120)];
    self.loginIconImageView.image = [UIImage imageNamed:@"login_icon"];
    [self.loginViewController.view addSubview:self.loginIconImageView];
    
    //下方输入view
    self.inputNumPasswordView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - 186)];
    self.inputNumPasswordView.backgroundColor = [UIColor whiteColor];
    [self.loginViewController.view addSubview:self.inputNumPasswordView];
    
    //分隔线
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    lineLayer.frame = CGRectMake(0, 0, self.inputNumPasswordView.frame.size.width, 0.5);
    [self.inputNumPasswordView.layer addSublayer:lineLayer];
    
    //输入会议室名称
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, ScreenWidth - 60, 26)];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = NSLocalizedString(@"login_input_meeting_room_name", nil);
    [self.inputNumPasswordView addSubview:self.titleLabel];
    
    //如果会议室名称不存在...
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 50, ScreenWidth - 60, 64)];
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.font = [UIFont systemFontOfSize:16];
    self.contentLabel.textColor = [UIColor grayColor];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.text = NSLocalizedString(@"login_input_tip_content", nil);
    [self.inputNumPasswordView addSubview:self.contentLabel];
    
    //房间号
    self.roomNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 10, ScreenWidth - 60, 44)];
    self.roomNumberTextField.font = [UIFont systemFontOfSize:18];
    self.roomNumberTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.roomNumberTextField.textAlignment = NSTextAlignmentCenter;
    self.roomNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.roomNumberTextField.returnKeyType = UIReturnKeyJoin;
    self.roomNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.roomNumberTextField.placeholder = NSLocalizedString(@"login_input_meeting_room_NO", nil);
    self.roomNumberTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.roomNumberTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [self.roomNumberTextField addTarget:self.loginViewController action:@selector(roomNumberTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.inputNumPasswordView addSubview:self.roomNumberTextField];
    
    //密码
    self.roomPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.roomNumberTextField.frame.origin.y + self.roomNumberTextField.frame.size.height + 10, ScreenWidth - 60, 44)];
    self.roomPasswordTextField.font = [UIFont systemFontOfSize:18];
    self.roomPasswordTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.roomPasswordTextField.textAlignment = NSTextAlignmentCenter;
    self.roomPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.roomPasswordTextField.placeholder = NSLocalizedString(@"login_input_encryption_key", nil);
    self.roomPasswordTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    [self.roomPasswordTextField addTarget:self.loginViewController action:@selector(roomNumberTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    //    [self.inputNumPasswordView addSubview:self.roomPasswordTextField]; //waiting for password function to open
    
    //加入会议室按钮
    self.joinRoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.joinRoomButton.frame = CGRectMake(30, self.roomPasswordTextField.frame.origin.y + self.roomPasswordTextField.frame.size.height + 10, ScreenWidth - 60, 44);
    [self.joinRoomButton setTintColor:[UIColor whiteColor]];
    self.joinRoomButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.joinRoomButton.enabled = NO;
    self.joinRoomButton.backgroundColor = JoinButtonUnableBackgroundColor;
    [self.joinRoomButton.layer setMasksToBounds:YES];
    [self.joinRoomButton.layer setCornerRadius:4.0];
    [self.joinRoomButton addTarget:self.loginViewController action:@selector(joinRoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputNumPasswordView addSubview:self.joinRoomButton];
    
    //版本号
    self.versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.inputNumPasswordView.frame.size.height-60, ScreenWidth, 40)];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.font = [UIFont systemFontOfSize:12];
    self.versionLabel.textColor = [UIColor grayColor];
    self.versionLabel.text = APP_Version;
    [self.inputNumPasswordView addSubview:self.versionLabel];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
}

- (BOOL)validateUserName:(NSString *)userName withRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:userName];
}

@end
