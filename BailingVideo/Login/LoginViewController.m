//
//  LoginViewController.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "LoginViewController.h"
#import "BlinkTalkAppDelegate.h"
#import "ChatViewController.h"
#import "CommonUtility.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+length.h"
#import <Blink/BlinkQuicHttp.h>

#define kEverLaunched @"everLaunched"
#define kDefaultRoomNumber @"defaultRoomNumber"
#define kCustomUserName @"kCustomUserName"
#define kRoomNumberMin 100000
#define kRoomNumberMax 999999
#define kTempCache [NSTemporaryDirectory() stringByAppendingPathComponent:@"Cache"]

#define kNAME @"name"
#define kCMP @"cmp"
#define kCMPTLS @"cmptls"
#define kSNIFFER @"sniffer"
#define kSNIFFERTLS @"sniffertls"
#define kTOKEN @"token"
#define kDER @"der"
#define kTCP @"tcp"
#define kQUIC @"quic"

typedef enum : NSUInteger {
    TextFieldInputErrorNil,
    TextFieldInputErrorLength,
    TextFieldInputErrorIllegal,
    TextFieldInputErrorNone,
} TextFieldInputError;


static NSString * const SegueIdentifierChat = @"Chat";
static NSString *staticKeyToken;
static NSDictionary *selectedServer;
static BlinkConnectionState connectionState = -1;

@interface LoginViewController ()
{
    NSUserDefaults *settingUserDefaults;
    NSInteger pressedRadioTag;
    TextFieldInputError inputError;
}

@property (nonatomic, assign) BlinkConnectionMode connectionType;

@end

@implementation LoginViewController
@synthesize isRoomNumberInput = isRoomNumberInput;
@synthesize connectionType = connectionType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    isRoomNumberInput = NO;
    __weak typeof(self) weakSelf = self;
    
    [self initUserDefaults];
    self.loginBlinkEngineDelegateImpl = [[LoginBlinkEngineDelegateImpl alloc] initWithViewController:self];
    self.loginTextFieldDelegateImpl = [[LoginTextFieldDelegateImpl alloc] initWithViewController:self];

    self.settingViewController = [[SettingViewController alloc] init];
    self.settingViewController.loginVC = self;
    self.loginViewBuilder = [[LoginViewBuilder alloc] initWithViewController:self];
    inputError = TextFieldInputErrorNone;
    
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.view.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        weakSelf.loginViewBuilder.loginIconImageView.frame = CGRectMake(weakSelf.loginViewBuilder.loginIconImageView.frame.origin.x, 50, weakSelf.loginViewBuilder.loginIconImageView.frame.size.width, weakSelf.loginViewBuilder.loginIconImageView.frame.size.height);
        weakSelf.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(weakSelf.loginViewBuilder.inputNumPasswordView.frame.origin.x, 186, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    //create random room number, save to userDefaults for later on
    NSString *enterRoomNumber,*customUserName;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL everLaunched = [userDefaults boolForKey:kEverLaunched];
    if (everLaunched)
    {
        enterRoomNumber = [userDefaults valueForKey:kDefaultRoomNumber];
        customUserName = [userDefaults valueForKey:kCustomUserName];
    }
    else
    {
        [userDefaults setBool:YES forKey:kEverLaunched];
        NSInteger randomRoomNumber = [CommonUtility getRandomNumber:kRoomNumberMin to:kRoomNumberMax];
        enterRoomNumber = [NSString stringWithFormat:@"%zd", randomRoomNumber];
        [userDefaults setObject:enterRoomNumber forKey:kDefaultRoomNumber];
        [userDefaults synchronize];
    }

    self.loginViewBuilder.roomNumberTextField.text = enterRoomNumber;
    self.loginViewBuilder.roomPasswordTextField.text = @"123456";
    if (customUserName)
        self.loginViewBuilder.userNameTextField.text = customUserName;
    
    connectionState = Blink_ConnectionState_Disconnected;

    [self userNameTextFieldDidChange:self.loginViewBuilder.userNameTextField];
    isRoomNumberInput = YES;
    [self updateJoinRoomButtonSocket:NO textFieldInput:isRoomNumberInput];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = YES;
    
    BlinkTalkAppDelegate *appDelegate = (BlinkTalkAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isForcePortrait = YES;
    [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
    self.userDefinedToken = [settingUserDefaults objectForKey:KeyUserDefinedToken];
    self.userDefinedCMP = [settingUserDefaults objectForKey:KeyUserDefinedCMP];
    self.userDefinedAppKey =  [settingUserDefaults objectForKey:KeyUserDefinedAppKey];

    if (self.userDefinedCMP && self.userDefinedToken && self.userDefinedAppKey)
    {
        connectionType =  [[settingUserDefaults valueForKey:Key_ConnectionMode] integerValue];
        if ([self.userDefinedCMP containsString:@"quic://"] && connectionType != Blink_ConnectionMode_QUIC)
        {
            connectionType = Blink_ConnectionMode_QUIC;
            [settingUserDefaults setInteger: connectionType forKey:Key_ConnectionMode];
            [settingUserDefaults synchronize];
        }
        else if (![self.userDefinedCMP containsString:@"quic://"] && connectionType == Blink_ConnectionMode_QUIC)
        {
            connectionType = Blink_ConnectionMode_TCP;
            [settingUserDefaults setInteger: connectionType forKey:Key_ConnectionMode];
            [settingUserDefaults synchronize];
        }
        
        [self updateJoinRoomButtonSocket:NO textFieldInput:self.isRoomNumberInput];
        _isUserDefinedTokenAndCMP = YES;
        self.tokenURL = [NSURL URLWithString:self.userDefinedToken];
        [self getKeyTokenFromServer:@""];
    }
    else
    {
        _isUserDefinedTokenAndCMP = NO;
        BlinkConnectionMode currentMode =  [[settingUserDefaults valueForKey:Key_ConnectionMode] integerValue];
        if (kIsCustomVersion)
        {
            DLog(@"LLH...... kIsCustomVersion YES");
            self.tokenURL = [NSURL URLWithString:kURLTokenCustom];
            [self getKeyTokenFromServer:@""];
        }
        else
        {
            
            if (currentMode != connectionType && self.tokenURL) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:nil forKey:@"BlinkServerConfigList"];
                [userDefaults synchronize];
                connectionType = currentMode;
                [self getKeyTokenFromServer:@""];
            }
            connectionType = currentMode;
            if (!self.tokenURL || (currentMode != connectionType)){
                [self requestPRODConfigList];
            }
        }
    }
    
    [self userNameTextFieldDidChange:self.loginViewBuilder.userNameTextField];
    if (self.blinkEngine.delegate && self.blinkEngine.delegate != self.loginBlinkEngineDelegateImpl)
        self.blinkEngine.delegate = self.loginBlinkEngineDelegateImpl;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - validate for username
- (BOOL)validateUserName:(NSString *)userName withRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:userName];
}

- (BOOL)isContainedIllegalChar:(NSString *)userName
{
    for (NSUInteger i = 0 ; i < userName.length; i++) {
        NSString *c = [NSString stringWithFormat:@"%C",[userName characterAtIndex:i]];
        if ([IllegelCharSet containsString:c]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)strimCharacter:(NSString *)userName
{
    NSString *nickName = userName;
    if ([self validateUserName:userName withRegex:RegexIsChinese]) {
        if (userName.length > 4) {
            nickName = [userName substringWithRange:NSMakeRange(userName.length-4, 4)];
        }
    }else{
        //
        NSArray *subNames = [userName componentsSeparatedByString:@" "];
        if (subNames.count > 1) {
            nickName = subNames.lastObject;
        }else{
            if (userName.length > 5) {
                nickName = [userName substringWithRange:NSMakeRange(userName.length-5, 5)];
            }else
               nickName = userName;
        }
    }
    return nickName;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - setter
+ (NSDictionary *)selectedConfigData
{
    return selectedServer;
}

- (void)requestPRODConfigList
{
    __weak typeof(self) weakSelf = self;
    switch (connectionType) {
        case Blink_ConnectionMode_TCP:
        {
            NSURLSession *session = [NSURLSession sharedSession];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kURLConfigListProd]
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                               timeoutInterval:30.0];
            request.HTTPMethod = @"Get";
            
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                DLog(@"LLH...... PROD ConfigList response");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!data)
                    {
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        weakSelf.configListArray = [userDefaults valueForKey:@"BlinkServerPRODConfigList"];
                        DLog(@"LLH...... PROD ConfigList response data is nil, use cache data! PROD configList: %@", weakSelf.configListArray);
                        if (weakSelf.configListArray && [weakSelf.configListArray count] > 0)
                        {
                            NSDictionary *configDic = (NSDictionary *)weakSelf.configListArray[0];
                            NSArray *configDicKeys = [configDic allKeys];
                            if ([configDicKeys containsObject:kTOKEN])
                            {
                                weakSelf.tokenURL = [NSURL URLWithString:configDic[kTOKEN]];
                                [weakSelf getKeyTokenFromServer:@""];
                            }else if ([configDicKeys containsObject:kTCP])
                            {
                                NSDictionary *tcp = configDic[kTCP];
                                weakSelf.tokenURL = [NSURL URLWithString:tcp[kTOKEN]];
                                [weakSelf getKeyTokenFromServer:@""];
                            }
                            else
                                [weakSelf requestPRODConfigList];
                        }
                        return;
                    }
                    
                    NSError *err;
                    weakSelf.configListArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                    DLog(@"LLH...... queried PROD configList: %@", weakSelf.configListArray);
                    if (weakSelf.configListArray && [weakSelf.configListArray count] > 0)
                    {
                        NSDictionary *configDic = (NSDictionary *)weakSelf.configListArray[0];
                        NSArray *configDicKeys = [configDic allKeys];
                        if ([configDicKeys containsObject:kTOKEN])
                        {
                            weakSelf.tokenURL = [NSURL URLWithString:configDic[kTOKEN]];
                            
                            [weakSelf getKeyTokenFromServer:@""];
                        }else if ([configDicKeys containsObject:kTCP])
                        {
                            NSDictionary *tcp = configDic[kTCP];
                            weakSelf.tokenURL = [NSURL URLWithString:tcp[kTOKEN]];
                            [weakSelf getKeyTokenFromServer:@""];
                        }
                        else
                            [weakSelf requestPRODConfigList];
                    }
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:weakSelf.configListArray forKey:@"BlinkServerPRODConfigList"];
                    [userDefaults synchronize];
                });
            }];
            
            [task resume];
            DLog(@"LLH...... request ConfigList");
        }
            break;
            
        default:
        {
            BlinkQuicHttp* http = [[BlinkQuicHttp alloc] init];
            [http getRequestWithUrl:kURLConfigListProdQUIC Callback:^(NSData *data, NSError * error) {
                
                DLog(@"LLH...... PROD ConfigList response");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (!data)
                    {
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        weakSelf.configListArray = [userDefaults valueForKey:@"BlinkServerPRODConfigList"];
                        DLog(@"LLH...... PROD ConfigList response data is nil, use cache data! PROD configList: %@", weakSelf.configListArray);
                        if (weakSelf.configListArray && [weakSelf.configListArray count] > 0)
                        {
                            NSDictionary *configDic = (NSDictionary *)weakSelf.configListArray[0];
                            NSArray *configDicKeys = [configDic allKeys];
                            NSString *token = configDic[kTOKEN];
                            if (token)
                            {
                                weakSelf.tokenURL = [NSURL URLWithString:configDic[kTOKEN]];
                                weakSelf.connectionType = Blink_ConnectionMode_TCP;
                                
                                [settingUserDefaults setInteger:weakSelf.connectionType forKey:Key_ConnectionMode];
                                [settingUserDefaults synchronize];
                                [weakSelf getKeyTokenFromServer:@""];
                            }else if ([configDicKeys containsObject:kQUIC])
                            {
                                NSDictionary *quic = configDic[kQUIC];
                                weakSelf.tokenURL = [NSURL URLWithString:quic[kTOKEN]];
                                [weakSelf getKeyTokenFromServer:@""];
                            }
                            else
                                [weakSelf requestPRODConfigList];
                        }
                        return;
                    }
                    
                    NSError *err;
                    weakSelf.configListArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                    DLog(@"LLH...... queried PROD configList: %@", weakSelf.configListArray);
                    if (weakSelf.configListArray && [weakSelf.configListArray count] > 0)
                    {
                        NSDictionary *configDic = (NSDictionary *)weakSelf.configListArray[0];
                        NSArray *configDicKeys = [configDic allKeys];
                        NSString *token = configDic[kTOKEN];
                        if (token)
                        {
                            weakSelf.tokenURL = [NSURL URLWithString:configDic[kTOKEN]];
                            weakSelf.connectionType = Blink_ConnectionMode_TCP;
                            
                            [settingUserDefaults setInteger:weakSelf.connectionType forKey:Key_ConnectionMode];
                            [settingUserDefaults synchronize];
                            [weakSelf getKeyTokenFromServer:@""];
                        }else if ([configDicKeys containsObject:kQUIC])
                        {
                            NSDictionary *quic = configDic[kQUIC];
                            weakSelf.tokenURL = [NSURL URLWithString:quic[kTOKEN]];
                            [weakSelf getKeyTokenFromServer:@""];
                        }
                        else
                            [weakSelf requestPRODConfigList];
                    }
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:weakSelf.configListArray forKey:@"BlinkServerPRODConfigList"];
                    [userDefaults synchronize];
                });
            }];
        }
            break;
    }
}

- (void)getKeyTokenFromServer:(NSString *)selectedServer
{
    __weak typeof(self) weakSelf = self;
    NSString *postBody = [NSString stringWithFormat:@"uid=%@&appid=%@", kDeviceUUID, kAPPKey];
    if ([kAPPKey isEqualToString:@""])
    {
        DLog(@"此APPKey在加入房间时需要用到, 请到百灵官网获取, 否则无法加入房间");
    }
    
    if (_isUserDefinedTokenAndCMP)
        postBody = [NSString stringWithFormat:@"uid=%@&appid=%@", kDeviceUUID, self.userDefinedAppKey];
    
    switch (connectionType)
    {
        case Blink_ConnectionMode_TCP:
        {
            NSURLSession *session = [NSURLSession sharedSession];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.tokenURL
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                               timeoutInterval:30.0];
            
            request.HTTPMethod = @"POST";
            request.HTTPBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
            
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                DLog(@"LLH...... token response");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (!data)
                    {
                        DLog(@"LLH...... Token Response data is nil, ERROR!");
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [weakSelf updateJoinRoomButtonSocket:NO textFieldInput:weakSelf.isRoomNumberInput];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [weakSelf getKeyTokenFromServer:selectedServer];
                        });
                        
                        return;
                    }
                    
                    weakSelf.keyToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    staticKeyToken = weakSelf.keyToken;
                    DLog(@"LLH...... keyToken: %@", weakSelf.keyToken);
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSArray *configListArray = [userDefaults valueForKey:@"BlinkServerConfigList"];
                    NSDictionary *configDic = (NSDictionary *)configListArray[0];
                    
                    NSString *cmpD = configDic[kCMP];
                    NSString *tokenD = configDic[kTOKEN];
                    if (!tokenD)
                    {
                        if (weakSelf.connectionType == Blink_ConnectionMode_TCP)
                        {
                            NSDictionary *tcp = configDic[kTCP];
                            tokenD = tcp[kTOKEN];
                            cmpD = tcp[kCMP];
                        }
                        else
                        {
                            NSDictionary *quic = configDic[kQUIC];
                            tokenD = quic[kTOKEN];
                            cmpD = quic[kCMP];
                        }
                    }
                    
                    weakSelf.blinkEngine = nil;
                    if (weakSelf.isUserDefinedTokenAndCMP && ![weakSelf.userDefinedCMP isEqualToString:cmpD]&& ![weakSelf.userDefinedToken isEqualToString:tokenD])
                    {
                        weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:weakSelf.userDefinedCMP];
                        weakSelf.blinkEngine.engineTLSCertificateData = nil;
                        [weakSelf.blinkEngine setDelegate:weakSelf.loginBlinkEngineDelegateImpl];
                        return;
                    }
                    
                    if (kIsCustomVersion)
                    {
                        DLog(@"LLH...... kIsCustomVersion 1234 YES");
                        weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:kURLCMPCustom];
                        weakSelf.blinkEngine.engineTLSCertificateData = nil;
                    }
                    else
                    {
                        DLog(@"LLH...... kIsCustomVersion 1234 NO");
                        NSDictionary *configDic = (NSDictionary *)self.configListArray[0];
                        NSString *cmp = configDic[kCMP];
                        NSString *certURL = configDic[kDER];
                        NSDictionary *quic = configDic[kQUIC];
                        if (quic)
                        {
                            switch (weakSelf.connectionType)
                            {
                                case Blink_ConnectionMode_TCP:
                                {
                                    NSDictionary *tcp = configDic[kTCP];
                                    cmp = tcp[kCMP];
                                    certURL = tcp[kDER];
                                }
                                    break;
                                    
                                default:
                                {
                                    cmp = quic[kCMP];
                                    certURL = quic[kDER];
                                }
                                    break;
                            }
                        }
                        
                        if (certURL)
                        {
                            NSString *fileName = [NSString stringWithFormat:@"PROD%@", [certURL lastPathComponent]];
                            NSString *certFilePath = [kTempCache stringByAppendingPathComponent:fileName];
                            
                            BOOL fileExist = [CommonUtility isDownloadFileExists:fileName atPath:kTempCache];
                            if (!fileExist)
                            {
                                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:certURL]];
                                [data writeToFile:certFilePath atomically:NO];
                            }
                            
                            NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
                            weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:cmp];
                            weakSelf.blinkEngine.engineTLSCertificateData = certData;
                        }
                        else
                        {
                            weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:cmp];
                            weakSelf.blinkEngine.engineTLSCertificateData = nil;
                        }
                    }
                    [weakSelf.blinkEngine setDelegate:weakSelf.loginBlinkEngineDelegateImpl];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [weakSelf userNameTextFieldDidChange:weakSelf.loginViewBuilder.userNameTextField];
                    });
                });
            }];
            
            [task resume];
            DLog(@"LLH...... token send request");
        }
            break;
            
        default:
        {
            BlinkQuicHttp* http = [[BlinkQuicHttp alloc] init];
            [http getRequestWithUrl:[NSString stringWithFormat:@"%@?%@",self.tokenURL, postBody] Callback:^(NSData *data, NSError * error) {
                DLog(@"LLH...... token response");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    if (!data)
                    {
                        DLog(@"LLH...... Token Response data is nil, ERROR!");
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [weakSelf updateJoinRoomButtonSocket:NO textFieldInput:weakSelf.isRoomNumberInput];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [weakSelf getKeyTokenFromServer:selectedServer];
                        });
                        
                        return;
                    }
                    
                    weakSelf.keyToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    staticKeyToken = weakSelf.keyToken;
                    DLog(@"LLH...... keyToken: %@", weakSelf.keyToken);
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSArray *configListArray = [userDefaults valueForKey:@"BlinkServerPRODConfigList"];
                    NSDictionary *configDic = (NSDictionary *)configListArray[0];
                    NSString *cmpD = configDic[kCMP];
                    NSString *tokenD = configDic[kTOKEN];
                    if (!tokenD)
                    {
                        if (weakSelf.connectionType == Blink_ConnectionMode_TCP)
                        {
                            NSDictionary *tcp = configDic[kTCP];
                            tokenD = tcp[kTOKEN];
                            cmpD = tcp[kCMP];
                        }
                        else
                        {
                            NSDictionary *quic = configDic[kQUIC];
                            tokenD = quic[kTOKEN];
                            cmpD = quic[kCMP];
                        }
                    }
                    
                    weakSelf.blinkEngine = nil;
                    if (weakSelf.isUserDefinedTokenAndCMP && ![weakSelf.userDefinedCMP isEqualToString:cmpD]&& ![weakSelf.userDefinedToken isEqualToString:tokenD])
                    {
                        weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:weakSelf.userDefinedCMP];
                        weakSelf.blinkEngine.engineTLSCertificateData = nil;
                        [weakSelf.blinkEngine setDelegate:weakSelf.loginBlinkEngineDelegateImpl];
                        return;
                    }
                    
                    if (kIsCustomVersion)
                    {
                        DLog(@"LLH...... kIsCustomVersion 1234 YES");
                        weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:kURLCMPCustom];
                        weakSelf.blinkEngine.engineTLSCertificateData = nil;
                    }
                    else
                    {
                        DLog(@"LLH...... kIsCustomVersion 1234 NO");
                        NSDictionary *configDic = (NSDictionary *)self.configListArray[0];
                        NSString *cmp = configDic[kCMP];
                        NSString *certURL = configDic[kDER];
                        NSDictionary *quic = configDic[kQUIC];
                        if (quic)
                        {
                            switch (weakSelf.connectionType)
                            {
                                case Blink_ConnectionMode_TCP:
                                {
                                    NSDictionary *tcp = configDic[kTCP];
                                    cmp = tcp[kCMP];
                                    certURL = tcp[kDER];
                                    if (![cmp containsString:@"quic://"])
                                        cmp = [@"quic://" stringByAppendingString:cmp];
                                }
                                    break;
                                    
                                default:
                                {
                                    cmp = quic[kCMP];
                                    certURL = quic[kDER];
                                    if (![cmp containsString:@"quic://"])
                                        cmp = [@"quic://" stringByAppendingString:cmp];
                                }
                                    break;
                            }
                        }
                        
                        if (certURL)
                        {
                            NSString *fileName = [NSString stringWithFormat:@"PROD%@", [certURL lastPathComponent]];
                            NSString *certFilePath = [kTempCache stringByAppendingPathComponent:fileName];
                            
                            BOOL fileExist = [CommonUtility isDownloadFileExists:fileName atPath:kTempCache];
                            if (!fileExist)
                            {
                                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:certURL]];
                                [data writeToFile:certFilePath atomically:NO];
                            }
                            
                            NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
                            weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:cmp];
                            weakSelf.blinkEngine.engineTLSCertificateData = certData;
                        }
                        else
                        {
                            weakSelf.blinkEngine = [[BlinkEngine alloc] initEngine:cmp];
                            weakSelf.blinkEngine.engineTLSCertificateData = nil;
                        }
                    }
                    [weakSelf.blinkEngine setDelegate:weakSelf.loginBlinkEngineDelegateImpl];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [weakSelf userNameTextFieldDidChange:weakSelf.loginViewBuilder.userNameTextField];
                    });
                });
            }];
        }
            break;
    }
}

#pragma mark - init UserDefaults
- (void)initUserDefaults
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences"];
    NSString *settingUserDefaultPath = [docDir stringByAppendingPathComponent:File_SettingUserDefaults_Plist];
    BOOL isPlistExist = [CommonUtility isFileExistsAtPath:settingUserDefaultPath];
    settingUserDefaults = [SettingViewController shareSettingUserDefaults];
    
    if (!isPlistExist)
    {
        [settingUserDefaults setObject:@(Value_Default_ResolutionRatio) forKey:Key_ResolutionRatio];
        [settingUserDefaults setObject:@(Value_Default_FrameRate) forKey:Key_FrameRate];
        [settingUserDefaults setObject:@(Value_Default_CodeRate) forKey:Key_CodeRate];
        [settingUserDefaults setObject:@(Value_Default_Connection_Style) forKey:Key_ConnectionStyle];
        [settingUserDefaults setObject:@(Value_Default_Coding_Style) forKey:Key_CodingStyle];
        [settingUserDefaults setObject:@(Value_Default_MinCodeRate) forKey:Key_CodeRateMin];
        [settingUserDefaults setObject:@(Value_Default_Observer) forKey:Key_Observer];
        [settingUserDefaults setObject:@(Value_Default_GPUFilter) forKey:Key_GPUFilter];
        [settingUserDefaults setObject:@(Value_Default_SRTPEncrypt) forKey:Key_SRTPEncrypt];
        [settingUserDefaults setObject:@(Value_Default_ConnectionMode) forKey:Key_ConnectionMode];
    }
    
    connectionType = [[settingUserDefaults valueForKey:Key_ConnectionMode] integerValue];
    [settingUserDefaults setObject:@(Value_Default_CloseVideo) forKey:Key_CloseVideo];
    [settingUserDefaults synchronize];
}

#pragma mark - room number text change
- (void)roomNumberTextFieldDidChange:(UITextField *)textField
{
    if ([self.loginViewBuilder.userNameTextField.text isEqualToString:@""] || ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""] || [self.loginViewBuilder.roomPasswordTextField.text isEqualToString:@""]))
    {
        isRoomNumberInput = NO;
    }
    else
    {
        if ([self validateUserName:self.loginViewBuilder.userNameTextField.text withRegex:RegexUserName])
            isRoomNumberInput = YES;
        else
            isRoomNumberInput = NO;
    }
    
    NSString *userName = self.loginViewBuilder.userNameTextField.text ;
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (userName.length == 0)
        isRoomNumberInput = NO;
    
    BOOL success;
    switch (connectionState)
    {
        case Blink_ConnectionState_Connected:
            success = YES;
            break;
        case Blink_ConnectionState_Disconnected:
            success = NO;
            break;
        default:
            success = YES;
            break;
    }
    
    [self updateJoinRoomButtonSocket:success textFieldInput:isRoomNumberInput];
}

- (void)userNameTextFieldDidChange:(UITextField *)textField
{
    isRoomNumberInput = YES;
    if ([self.loginViewBuilder.userNameTextField.text isEqualToString:@""] || ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""] || [self.loginViewBuilder.roomPasswordTextField.text isEqualToString:@""]))
    {
        isRoomNumberInput = NO;
    }
    
    NSString *userName = self.loginViewBuilder.userNameTextField.text ;
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (userName.length == 0)
    {
        isRoomNumberInput = NO;
        inputError = TextFieldInputErrorNil;
    }
    
    if ([self validateUserName:userName withRegex:RegexUserName] && ![self isContainedIllegalChar:userName]){
        NSString *lang = [[textField textInputMode] primaryLanguage];
        if ([lang isEqualToString:@"zh-Hans"])
        {
            UITextRange *selectedRange = [textField markedTextRange];
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            if (!position)
            {
                if ([userName getStringLengthOfBytes] > KMaxInpuNumber)
                {
                    inputError = TextFieldInputErrorLength;
                    isRoomNumberInput = NO;
                }
                else
                    inputError = TextFieldInputErrorNone;
            }else
                inputError = TextFieldInputErrorNone;
        }
        else
        {
            if ([userName getStringLengthOfBytes] > KMaxInpuNumber)
            {
                inputError = TextFieldInputErrorLength;
                isRoomNumberInput = NO;
            }
            else
                inputError = TextFieldInputErrorNone;
        }
    }
    else if ([userName getStringLengthOfBytes] > KMaxInpuNumber)
    {
        isRoomNumberInput = NO;
        inputError = TextFieldInputErrorLength;
    }
    else
    {
        isRoomNumberInput = NO;
        inputError = TextFieldInputErrorIllegal;
    }

    BOOL success;
    switch (connectionState)
    {
        case Blink_ConnectionState_Connected:
            success = YES;
            break;
        case Blink_ConnectionState_Disconnected:
            success = NO;
            break;
        default:
            success = YES;
            break;
    }
    
    [self updateJoinRoomButtonSocket:success textFieldInput:isRoomNumberInput];
}

- (void)updateJoinRoomButtonSocket:(BlinkConnectionState)state
{
    connectionState = state;
    switch (state)
    {
        case Blink_ConnectionState_Connected:
            [self updateJoinRoomButtonSocket:YES textFieldInput:isRoomNumberInput];
            break;
        case Blink_ConnectionState_Disconnected:
            [self updateJoinRoomButtonSocket:NO textFieldInput:isRoomNumberInput];
            break;
        default:
            break;
    }
}

#pragma mark - change join button enable/unenable
- (void)updateJoinRoomButtonSocket:(BOOL)success textFieldInput:(BOOL)input
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success && input)
        {
            self.loginViewBuilder.joinRoomButton.enabled = YES;
            self.loginViewBuilder.joinRoomButton.backgroundColor = JoinButtonEnableBackgroundColor;
            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_enter_meeting_room", nil) forState:UIControlStateNormal];
            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_enter_meeting_room", nil) forState:UIControlStateHighlighted];
        }
        else
        {
            self.loginViewBuilder.joinRoomButton.enabled = NO;
            self.loginViewBuilder.joinRoomButton.backgroundColor = JoinButtonUnableBackgroundColor;
            
            if (input)
            {
                switch (inputError){
                    case TextFieldInputErrorIllegal:
                    {
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_illegal", nil) forState:UIControlStateNormal];
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_illegal", nil) forState:UIControlStateHighlighted];
                    }
                        break;
                    case TextFieldInputErrorNil:
                    {
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_nil", nil) forState:UIControlStateNormal];
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_nil", nil) forState:UIControlStateHighlighted];
                    }
                        break;
                    case TextFieldInputErrorLength:
                    {
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_length", nil) forState:UIControlStateNormal];
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_length", nil) forState:UIControlStateHighlighted];
                    }
                        break;
                    default:
                    {
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_meeting_room", nil) forState:UIControlStateNormal];
                        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_meeting_room", nil) forState:UIControlStateHighlighted];
                    }
                        break;
                }
            }
            else
            {
                if ([self.loginViewBuilder.userNameTextField.text isEqualToString:@""] && [self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""])
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_input", nil) forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_input", nil) forState:UIControlStateHighlighted];
                }
                else if ([self.loginViewBuilder.userNameTextField.text isEqualToString:@""])
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_user_name", nil) forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_user_name", nil) forState:UIControlStateHighlighted];
                }
                else if ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""])
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_room_number", nil) forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_room_number", nil) forState:UIControlStateHighlighted];
                }
                else
                {
                    switch (inputError)
                    {
                        case TextFieldInputErrorIllegal:
                        {
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_illegal", nil) forState:UIControlStateNormal];
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_illegal", nil) forState:UIControlStateHighlighted];
                        }
                            break;
                        case TextFieldInputErrorNil:
                        {
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_nil", nil) forState:UIControlStateNormal];
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_nil", nil) forState:UIControlStateHighlighted];
                        }
                            break;
                        case TextFieldInputErrorLength:
                        {
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_length", nil) forState:UIControlStateNormal];
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_error_length", nil) forState:UIControlStateHighlighted];
                        }
                            break;
                        default:
                        {
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_meeting_room", nil) forState:UIControlStateNormal];
                            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_meeting_room", nil) forState:UIControlStateHighlighted];
                        }
                            break;
                    }
                }
            }
        }
    });
}

#pragma mark - prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.identifier isEqualToString:SegueIdentifierChat])
        return;
    
    ChatViewController *chatViewController = segue.destinationViewController;
    chatViewController.roomName = self.loginViewBuilder.roomNumberTextField.text;
    chatViewController.chatType = ChatTypeVideo;
    chatViewController.userName = self.loginViewBuilder.userNameTextField.text;
}

#pragma mark - click join Button
- (void)joinRoomButtonPressed:(id)sender
{
    if ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""] || connectionState == Blink_ConnectionState_Disconnected)
        return;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.loginViewBuilder.roomNumberTextField.text forKey:kDefaultRoomNumber];
    [userDefaults setObject:self.loginViewBuilder.userNameTextField.text forKey:kCustomUserName];
    [userDefaults synchronize];
    [self.loginViewBuilder.roomNumberTextField resignFirstResponder];
    [self.loginViewBuilder.roomPasswordTextField resignFirstResponder];
    [self.loginViewBuilder.userNameTextField resignFirstResponder];

    if (![self.navigationController.topViewController isKindOfClass:[ChatViewController class]])
        [self performSegueWithIdentifier:SegueIdentifierChat sender:sender];
}

#pragma mark - click setting button
- (void)loginSettingButtonPressed
{
    if (![self.navigationController.topViewController isKindOfClass:[SettingViewController class]])
        [self.navigationController pushViewController:self.settingViewController animated:YES];
}

#pragma mark - click redio button
- (void)onRadioButtonValueChanged:(RadioButton *)radioButton
{
    //0:default  1:close video  2:observer
    settingUserDefaults = [SettingViewController shareSettingUserDefaults];
    if (radioButton.selected)
    {
        pressedRadioTag = radioButton.tag+1;
        [settingUserDefaults setObject:@(pressedRadioTag) forKey:Key_CloseVideo];
        DLog(@"LLH...... RadioButton Selected: %@", radioButton.titleLabel.text);
    }
    else if (pressedRadioTag == radioButton.tag+1)
    {
        [settingUserDefaults setObject:@(Value_Default_CloseVideo) forKey:Key_CloseVideo];
        DLog(@"LLH...... RadioButton Selected: 音频 + 视频");
    }
    
    [settingUserDefaults synchronize];
    [self.loginViewBuilder.roomNumberTextField resignFirstResponder];
    [self.loginViewBuilder.roomPasswordTextField resignFirstResponder];
}

#pragma mark - gesture selector method
- (IBAction)didTapHideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

+ (NSString *)getKeyToken
{
    return staticKeyToken;
}

+ (void)setConnectionState:(BlinkConnectionState)state
{
    connectionState = state;
}

- (void)onLoginDeviceOrientationChange
{
    [self.loginViewBuilder reloadLoginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
