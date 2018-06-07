//
//  SettingViewController.m
//  BlinkTalk
//
//  Created by LiuLinhong on 16/11/11.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "SettingViewController.h"
#import "CommonUtility.h"
#import "SXAlertView.h"
#import "LoginViewController.h"

#define kCMP @"cmp"
#define kTOKEN @"token"
#define kTCP @"tcp"
#define kQUIC @"quic"

static NSUserDefaults *settingUserDefaults = nil;

@interface SettingViewController ()<UITextFieldDelegate>
{
    UITapGestureRecognizer *tapGestureRecognizer;
    UITapGestureRecognizer *tapGestureRecognizerOfThirdTouch;
}
@end


@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"setting_title", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.sectionNumber = 3;
    
    [self loadPlistData];
    
    self.settingTableViewDelegateSourceImpl = [[SettingTableViewDelegateSourceImpl alloc] initWithViewController:self];
    self.settingPickViewDelegateImpl = [[SettingPickViewDelegateImpl alloc] initWithViewController:self];
    self.settingViewBuilder = [[SettingViewBuilder alloc] initWithViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPlistData];
    self.sectionNumber = 3;
    [self.settingViewBuilder.tableView reloadData];
    
    if (!tapGestureRecognizerOfThirdTouch)
    {
        tapGestureRecognizerOfThirdTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerActionOfThirdTouch)];
        [tapGestureRecognizerOfThirdTouch setNumberOfTapsRequired:5];
    }
    [self.navigationController.view addGestureRecognizer:tapGestureRecognizerOfThirdTouch];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.settingViewBuilder.resolutionRatioPickview remove];
    self.navigationItem.rightBarButtonItem = nil;
    [self.navigationController.view removeGestureRecognizer:tapGestureRecognizerOfThirdTouch];
}

- (void)returnBack
{
    NSString *token = [settingUserDefaults objectForKey:KeyUserDefinedToken];
    NSString *cmp = [settingUserDefaults objectForKey:KeyUserDefinedCMP];
    NSString *appkey = [settingUserDefaults objectForKey:KeyUserDefinedAppKey];
    NSMutableArray *array;
    if (cmp && ![cmp isEqualToString:@""])
        array = [NSMutableArray arrayWithObjects:cmp,token,appkey, nil];
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *configListArray = [userDefaults valueForKey:@"BlinkServerPRODConfigList"];
        NSDictionary *configDic = (NSDictionary *)configListArray[0];
        NSString *token = configDic[kTOKEN];
        NSString *cmp = configDic[kCMP];
        
        if (!token)
        {
            if (!_isQuicRequestMode)
            {
                NSDictionary *tcp = configDic[kTCP];
                token = tcp[kTOKEN];
                cmp = [@"tcp://" stringByAppendingString:tcp[kCMP]];
            }
            else
            {
                NSDictionary *quic = configDic[kQUIC];
                token = quic[kTOKEN];
                cmp = [@"quic://" stringByAppendingString:quic[kCMP]];
            }
        }
        array = [NSMutableArray arrayWithObjects:cmp,token,@"", nil];
    }
    
    [SXAlertView showWithTitle:NSLocalizedString(@"setting_urlschema", nil) placeholder:array cancelButtonTitle:NSLocalizedString(@"chat_alert_btn_cancel", nil)  otherButtonTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) clickButtonBlock:^(SXAlertView * _Nonnull alertView, NSInteger buttonIndex, NSArray<NSString *> * _Nonnull texts) {
        DLog(@"%s %zd %@", __FUNCTION__, buttonIndex, texts);
        [self dealWithCMP:texts[0] withToken:texts[1] withAppKey:texts[2]];
    }];
}

- (BOOL)navigationShouldPopOnBackButton
{
    return YES;
}

#pragma mark - deal with default urlstr
- (void)dealWithCMP:(NSString *)cmp withToken:(NSString *)token withAppKey:(NSString *)appKey
{
    if ([cmp isEqualToString:@""] && [token isEqualToString:@""] && [appKey isEqualToString:@""]) {
        [settingUserDefaults setObject:nil forKey:KeyUserDefinedCMP];
        [settingUserDefaults setObject:nil forKey:KeyUserDefinedToken];
        [settingUserDefaults setObject:nil forKey:KeyUserDefinedAppKey];
        [settingUserDefaults synchronize];
        self.loginVC.tokenURL = nil;
        return;
    }
    
    if (([cmp isEqualToString:@""] || [token isEqualToString:@""] || [appKey isEqualToString:@""] )) {
        [self alertWith:nil withMessage:NSLocalizedString(@"setting_urlschema_null", nil) withOKAction:nil withCancleAction:nil];
        return ;
    }
    
    if (![cmp containsString:@":"]) {
        [self alertWith:nil withMessage:NSLocalizedString(@"setting_urlschema_cmp_error", nil) withOKAction:nil withCancleAction:nil];
        return ;
    }

    if (![token containsString:@"http://"] && ![token containsString:@"https://"] ) {
        [self alertWith:nil withMessage:NSLocalizedString(@"setting_urlschema_token_error", nil) withOKAction:nil withCancleAction:nil];
        return ;
    }
 
    if ([cmp containsString:@"quic://"])
        _isQuicRequestMode = YES;
    else
        _isQuicRequestMode = NO;
    
    [self.quicSwitch setOn:self.isQuicRequestMode];
    [settingUserDefaults setObject:@(self.quicSwitch.on) forKey:Key_ConnectionMode];
    [settingUserDefaults setObject:cmp forKey:KeyUserDefinedCMP];
    [settingUserDefaults setObject:token forKey:KeyUserDefinedToken];
    [settingUserDefaults setObject:appKey forKey:KeyUserDefinedAppKey];
    [settingUserDefaults synchronize];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *configListArray = [userDefaults valueForKey:@"BlinkServerPRODConfigList"];
    NSDictionary *configDic = (NSDictionary *)configListArray[0];
    NSArray *configDicKeys = [configDic allKeys];
    NSString *tokenD = @"";
    if ([configDicKeys containsObject:kTOKEN])
    {
        tokenD = configDic[kTOKEN];
    }
    NSString *cmpD = configDic[kCMP];
    
    if ([cmpD isEqualToString:cmp] && [tokenD isEqualToString:token]) {
        self.loginVC.configListArray = [userDefaults valueForKey:@"BlinkServerPRODConfigList"];
    }
}

#pragma mark - validate address
- (BOOL)validateAddress:(NSString *)ipStr withRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:ipStr];
}

#pragma mark - AlertController
- (void)alertWith:(NSString *)title withMessage:(NSString *)msg withOKAction:(nullable  UIAlertAction *)ok withCancleAction:(nullable UIAlertAction *)cancel
{
    self.alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    if (cancel)
        [self.alertController addAction:cancel];
    if (!ok)
    {
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self.alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.alertController addAction:ok];
    }
    else
        [self.alertController addAction:ok];
    
    [self presentViewController:self.alertController animated:YES completion:^{}];
}

#pragma mark - load default plist data
- (void)loadPlistData
{
    settingUserDefaults = [SettingViewController shareSettingUserDefaults];
    
    self.resolutionRatioIndex = [[settingUserDefaults valueForKey:Key_ResolutionRatio] integerValue];
    self.frameRateIndex = [[settingUserDefaults valueForKey:Key_FrameRate] integerValue];
    self.codeRateIndex = [[settingUserDefaults valueForKey:Key_CodeRate] integerValue];
    self.connectionStyleIndex = [[settingUserDefaults valueForKey:Key_ConnectionStyle] integerValue];
    self.codingStyleIndex = [[settingUserDefaults valueForKey:Key_CodingStyle] integerValue];
    self.minCodeRateIndex = [[settingUserDefaults valueForKey:Key_CodeRateMin] integerValue];
    self.observerIndex = [[settingUserDefaults valueForKey:Key_Observer] integerValue];
    self.isGPUFilter = [[settingUserDefaults valueForKey:Key_GPUFilter] boolValue];
    self.isSRTPEncrypt = [[settingUserDefaults valueForKey:Key_SRTPEncrypt] boolValue];
    self.isQuicRequestMode = [[settingUserDefaults valueForKey:Key_ConnectionMode]  boolValue];
    
    self.resolutionRatioArray = [CommonUtility getPlistArrayByplistName:Key_ResolutionRatio];
    self.frameRateArray = [CommonUtility getPlistArrayByplistName:Key_FrameRate];
    self.codeRateArray = [CommonUtility getPlistArrayByplistName:Key_CodeRate];
    self.codingStyleArray = [CommonUtility getPlistArrayByplistName:Key_CodingStyle];
    
    [self.quicSwitch setOn:self.isQuicRequestMode];
}

#pragma mark - connect style witch action
- (void)gpuSwitchAction
{
    [settingUserDefaults setObject:@(self.gpuSwitch.on) forKey:Key_GPUFilter];
    [settingUserDefaults synchronize];
}

- (void)quicSwitchAction
{
    _isQuicRequestMode = self.quicSwitch.on;
    [settingUserDefaults setObject:@(self.quicSwitch.on) forKey:Key_ConnectionMode];
    [settingUserDefaults synchronize];
}

#pragma mark - tap gesture action
- (void)tapGestureRecognizerActionOfThirdTouch
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_edit"] style:(UIBarButtonItemStyleDone) target:self action:@selector(returnBack)];
}

#pragma mark - share setting UserDefaults
+ (NSUserDefaults *)shareSettingUserDefaults
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"settingUserDefaults"];
    });
    return settingUserDefaults;
}

@end
