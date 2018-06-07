//
//  LoginBlinkEngineDelegateImpl.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/30.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "LoginBlinkEngineDelegateImpl.h"
#import "LoginViewController.h"

@interface LoginBlinkEngineDelegateImpl ()

@property (nonatomic, strong) LoginViewController *loginViewController;

@end

@implementation LoginBlinkEngineDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.loginViewController = (LoginViewController *) vc;
    }
    return self;
}

#pragma mark - BlinkEngineDelegate
- (void)blinkEngine:(BlinkEngine *)engine onConnectionStateChanged:(BlinkConnectionState)state
{
    [LoginViewController setConnectionState:state];
    self.connectionState = state;
    [self.loginViewController updateJoinRoomButtonSocket:self.connectionState];
}

- (void)blinkEngine:(BlinkEngine *)engine onAudioAuthority:(BOOL)enableAudio onVideoAuthority:(BOOL)enableVideo
{
    if (enableAudio && enableVideo)
        return;
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"WARNING" message:@"Please open the Authorization of Camera & Micphone" preferredStyle:UIAlertControllerStyleAlert];
    [alertViewController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }]];
    [alertViewController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self.loginViewController presentViewController:alertViewController animated:YES completion:^{}];
}

- (void)blinkEngine:(BlinkEngine *)engine onJoinComplete:(BOOL)success
{
}

- (void)blinkEngine:(BlinkEngine *)engine onLeaveComplete:(BOOL)success
{
    DLog(@"LLH......Login blinkEngine:onLeaveComplete: %zd", success);
    if (![self.loginViewController.navigationController.visibleViewController isEqual:self.loginViewController]) {
        [self.loginViewController.navigationController popToViewController:self.loginViewController animated:YES];
    }
}

- (void)blinkEngine:(BlinkEngine *)engine onUserJoined:(NSString *)userId userName:(NSString *)userName userType:(BlinkUserType)type audioVideoType:(BlinkAudioVideoType)avType screenSharingStatus:(BlinkScreenSharingState)screenSharingStatus
{
}

- (void)blinkEngine:(BlinkEngine *)engine onUserLeft:(NSString *)userId
{
}

- (void)blinkEngine:(BlinkEngine *)engine onUser:(NSString *)userId audioVideoType:(BlinkAudioVideoType)avType
{
}

- (void)blinkEngine:(BlinkEngine *)engine onWhiteBoardURL:(NSString *)url
{
}

- (void)blinkEngineOnAudioDeviceReady:(BlinkEngine *)engine
{
}

- (void)blinkEngine:(BlinkEngine *)engine onOutputAudioPortSpeaker:(BOOL)enable
{
}

- (void)blinkEngine:(BlinkEngine *)engine onRemoteVideoView:(UIView *)videoView vidoeSize:(CGSize)size remoteUserID:(NSString*)userID
{
}

- (void)blinkEngine:(BlinkEngine *)engine onNetworkSentLost:(NSInteger)lost
{
}

@end
