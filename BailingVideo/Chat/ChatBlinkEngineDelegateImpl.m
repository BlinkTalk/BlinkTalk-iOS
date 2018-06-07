
//
//  ChatBlinkEngineDelegateImpl.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "ChatBlinkEngineDelegateImpl.h"
#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ChatCellVideoViewModel.h"
#import "LoginViewController.h"
#import "BlinkTalkAppDelegate.h"
#import "UIColor+ColorChange.h"
#import "ChatDataInfoModel.h"
#import "ChatLocalDataInfoModel.h"
#import "CommonUtility.h"

@interface ChatBlinkEngineDelegateImpl ()
{
    dispatch_semaphore_t sem;
}
@property (nonatomic, strong) ChatViewController *chatViewController;

@end

@implementation ChatBlinkEngineDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
        sem = dispatch_semaphore_create(1);
        _bitrateArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - BlinkEngineDelegate
- (void)blinkEngine:(BlinkEngine *)engine onConnectionStateChanged:(BlinkConnectionState)state
{
    [LoginViewController setConnectionState:state];
    
    if (state == Blink_ConnectionState_Disconnected)
        [self.chatViewController joinChannel];
}

- (void)blinkEngine:(BlinkEngine *)engine onJoinComplete:(BOOL)success
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (success)
    {
        if (weakChatVC.type == ChatTypeAudio) {
            //    [self.blinkEngine disableVideo];
        }
        NSInteger avType = [weakChatVC.paraDic[kCloseCamera] integerValue];
        if (avType == Blink_User_Only_Audio && weakChatVC.isFinishLeave && !(weakChatVC.observerIndex == Blink_User_Observer))
        {
            [weakChatVC modifyAudioVideoType:weakChatVC.chatViewBuilder.openCameraButton];
            weakChatVC.isFinishLeave = NO;
        }

        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [engine requestWhiteBoardExist];
    }
    else
        [self blinkEngine:engine onLeaveComplete:YES];
}

- (void)blinkEngine:(BlinkEngine *)engine onLeaveComplete:(BOOL)success
{
    DLog(@"LLH......blinkEngine:onLeaveComplete: %zd", success);

    __weak ChatViewController *weakChatVC = self.chatViewController;
    weakChatVC.isFinishLeave = YES;
    [weakChatVC.durationTimer invalidate];
    weakChatVC.talkTimeLabel.text = @"";
    weakChatVC.localView.hidden = NO;
    [weakChatVC.localView removeFromSuperview];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    BlinkTalkAppDelegate *appDelegate = (BlinkTalkAppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.isForceLandscape = NO;
     
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];

    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];

    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
    weakChatVC.localVideoViewModel = nil;
    
    for (ChatCellVideoViewModel *model in weakChatVC.remoteViewArray)
    {
        [model removeObserver:model forKeyPath:@"frameRateRecv"];
        [model removeObserver:model forKeyPath:@"frameWidthRecv"];
        [model removeObserver:model forKeyPath:@"frameHeightRecv"];
        [model removeObserver:model forKeyPath:@"frameRate"];
    }
    [weakChatVC.remoteViewArray removeAllObjects];
    [weakChatVC.navigationController popViewControllerAnimated:YES];
    [weakChatVC resetAudioSpeakerButton];
}

- (void)blinkEngine:(BlinkEngine *)engine OnNotifyUserVideoCreated:(NSString *)userId;
{
    
    
    __weak ChatViewController *weakChatVC = self.chatViewController;
    
    if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId]) {
        weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.blinkEngine createRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) forUser:userId withDisplayType:Blink_VideoViewDisplay_CompleteView];
        [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
        weakChatVC.localVideoViewModel.isShowVideo = YES;
        [weakChatVC.localVideoViewModel.avatarView.indicatorView stopAnimating];
        
        if (weakChatVC.localVideoViewModel.avType == Blink_User_Audio_Video_None ||
            weakChatVC.localVideoViewModel.avType == Blink_User_Only_Audio) {
            [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];
            weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
            weakChatVC.localVideoViewModel.avatarView.center = weakChatVC.localVideoViewModel.cellVideoView.center;
            weakChatVC.localVideoViewModel.isShowVideo = NO;
        }else
            [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
    }
    
    [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.userID isEqualToString:userId]) {
            model.cellVideoView = [weakChatVC.blinkEngine createRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120.0) forUser:userId withDisplayType:Blink_VideoViewDisplay_FullScreen];
            if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]) {
                model.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:weakChatVC.videoMainView.frame withUserID:userId withDisplayType:Blink_VideoViewDisplay_CompleteView];
                model.avatarView.frame = BigVideoFrame;
            }else
                model.avatarView.frame = SmallVideoFrame;

            model.isShowVideo = YES;
            [model.avatarView.indicatorView stopAnimating];
            
            if (model.avType == Blink_User_Audio_Video_None || model.avType == Blink_User_Only_Audio)
            {
                [model.cellVideoView addSubview:model.avatarView];
                model.avatarView.center = model.cellVideoView.center;
                model.isShowVideo = NO;
            }
            else
                [model.avatarView removeFromSuperview];
            
            [weakChatVC.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
        }
    }];
}

- (void)blinkEngine:(BlinkEngine *)engine onUserJoined:(NSString *)userId userName:(NSString *)userName userType:(BlinkUserType)type audioVideoType:(BlinkAudioVideoType)avType screenSharingStatus:(BlinkScreenSharingState)screenSharingStatus
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (type == Blink_User_Observer)
    {
        UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
        ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
        chatCellVideoViewModel.userID = userId;
        chatCellVideoViewModel.userName = userName;
        chatCellVideoViewModel.avType = avType;
        chatCellVideoViewModel.screenSharingStatus = screenSharingStatus ;
        chatCellVideoViewModel.everOnLocalView = 0;
        
        [weakChatVC.observerArray addObject:chatCellVideoViewModel];
        
         return;
    }
    
    self.chatViewController.isNotLeaveMeAlone = YES;
    [weakChatVC hideAlertLabel:YES];
 
    // Update talk time
    if (weakChatVC.duration == 0 && !weakChatVC.durationTimer)
    {
        weakChatVC.talkTimeLabel.text = @"00:00";
        weakChatVC.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakChatVC selector:@selector(updateTalkTimeLabel) userInfo:nil repeats:YES];
    }
    
    if (weakChatVC.observerIndex == Blink_User_Observer && (!weakChatVC.localVideoViewModel || [weakChatVC.localVideoViewModel.userID isEqualToString:@""]))
    {
        UIView *videoView = [[UIView alloc] initWithFrame:weakChatVC.videoMainView.bounds];
        weakChatVC.localVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
        [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];

        weakChatVC.localVideoViewModel.userID = userId;
        weakChatVC.localVideoViewModel.avType = avType;
        weakChatVC.localVideoViewModel.userName = userName;
        weakChatVC.localVideoViewModel.screenSharingStatus = screenSharingStatus;
        weakChatVC.localVideoViewModel.everOnLocalView = 0;

        weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
        weakChatVC.localVideoViewModel.avatarView.center = weakChatVC.localVideoViewModel.cellVideoView.center;
        weakChatVC.localVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:userName userID:userId];
        [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];

        if (avType == Blink_User_Only_Audio || avType == Blink_User_Audio_Video_None)
            [weakChatVC.localVideoViewModel.avatarView.indicatorView stopAnimating];
        
        if (weakChatVC.localVideoViewModel.screenSharingStatus == 1 && weakChatVC.localVideoViewModel.everOnLocalView == 0)
        {
            [weakChatVC.messageStatusBar showMessageBarAndHideAuto: NSLocalizedString(@"chat_Suggested_horizontal_screen_viewing", nil)];
            weakChatVC.localVideoViewModel.everOnLocalView = 1;
        }
    }
    else
    {
        [weakChatVC.userIDArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:userId])
            {
                [weakChatVC.userIDArray removeObject:userId];
                if (weakChatVC.remoteViewArray.count > idx)
                {
                    ChatCellVideoViewModel *model = weakChatVC.remoteViewArray[idx];
                    [model removeObserver:model forKeyPath:@"frameRateRecv"];
                    [model removeObserver:model forKeyPath:@"frameWidthRecv"];
                    [model removeObserver:model forKeyPath:@"frameHeightRecv"];
                    [model removeObserver:model forKeyPath:@"frameRate"];
                    
                    if ([weakChatVC.collectionView numberOfItemsInSection:0] > idx)
                    {
                        [weakChatVC.collectionView performBatchUpdates:^{
                            [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                            [weakChatVC.remoteViewArray removeObjectAtIndex:idx];
                        } completion:^(BOOL finished) {
                        }];
                    }
                }
            }
        }];
        
        [weakChatVC.userIDArray addObject:userId];
        
        UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
        ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
        chatCellVideoViewModel.userID = userId;
        chatCellVideoViewModel.userName = userName;
        chatCellVideoViewModel.avType = avType;
        chatCellVideoViewModel.screenSharingStatus = screenSharingStatus ;
        chatCellVideoViewModel.everOnLocalView = 0;
        chatCellVideoViewModel.isShowVideo = NO;
        DLog(@"User named %@ joined channel", userName);
        [chatCellVideoViewModel.cellVideoView addSubview:chatCellVideoViewModel.avatarView];
        chatCellVideoViewModel.avatarView.frame = SmallVideoFrame;
        chatCellVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:userName userID:userId];
        if (avType == Blink_User_Only_Audio || avType == Blink_User_Audio_Video_None)
            [chatCellVideoViewModel.avatarView.indicatorView stopAnimating];
        
        [weakChatVC.remoteViewArray addObject:chatCellVideoViewModel];
        [weakChatVC.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]]];
        
    }
}

- (void)blinkEngine:(BlinkEngine *)engine onUser:(NSString *)userId audioVideoType:(BlinkAudioVideoType)avType
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (weakChatVC.observerIndex == Blink_User_Observer && [weakChatVC.localVideoViewModel.userID isEqualToString:userId])
    {
        weakChatVC.localVideoViewModel.avType = avType;
        BlinkVideoViewDisplayType type;
        if (weakChatVC.localVideoViewModel.cellVideoView.frame.size.width == ScreenWidth && weakChatVC.localVideoViewModel.cellVideoView.frame.size.height == ScreenHeight)
            type = Blink_VideoViewDisplay_CompleteView;
        else
            type = Blink_VideoViewDisplay_FullScreen;
        
        UIView *videoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, weakChatVC.localVideoViewModel.cellVideoView.frame.size.width, weakChatVC.localVideoViewModel.cellVideoView.frame.size.height) withUserID:userId withDisplayType:type];
        weakChatVC.localVideoViewModel.cellVideoView = videoView;
        
        if (avType == Blink_User_Only_Audio || avType == Blink_User_Audio_Video_None)
        {
            if (videoView.frame.size.width == ScreenWidth && videoView.frame.size.height == ScreenHeight)
                weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
            else
                weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
            
            [videoView addSubview:weakChatVC.localVideoViewModel.avatarView];
            weakChatVC.localVideoViewModel.avatarView.center = weakChatVC.localVideoViewModel.cellVideoView.center;
            [weakChatVC.localVideoViewModel.avatarView.indicatorView stopAnimating];
        }
        else
        {
            if (weakChatVC.localVideoViewModel.avatarView)
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
        }
        return;
    }
    
    for (NSInteger i = 0; i < [weakChatVC.remoteViewArray count]; i++)
    {
        ChatCellVideoViewModel *tempModel = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[i];
        if ([tempModel.userID isEqualToString:userId])
        {
            BlinkVideoViewDisplayType type;
            if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId])
                type = Blink_VideoViewDisplay_CompleteView;
            else
            {
                if (tempModel.cellVideoView.frame.size.width == ScreenWidth && tempModel.cellVideoView.frame.size.height == ScreenHeight)
                    type = Blink_VideoViewDisplay_CompleteView;
                else
                    type = Blink_VideoViewDisplay_FullScreen;
            }
            
            tempModel.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, tempModel.cellVideoView.frame.size.width, tempModel.cellVideoView.frame.size.height) withUserID:userId withDisplayType:type];
            
            if (avType == Blink_User_Only_Audio || avType == Blink_User_Audio_Video_None)
            {
                if (weakChatVC.isSwitchCamera)
                {
                    if ([weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId])
                        tempModel.avatarView.frame = BigVideoFrame;
                    else
                        tempModel.avatarView.frame = SmallVideoFrame;
                }
                else
                {
                    if (tempModel.cellVideoView.frame.size.width == ScreenWidth && tempModel.cellVideoView.frame.size.height == ScreenHeight)
                        tempModel.avatarView.frame = SmallVideoFrame;
                    else
                        tempModel.avatarView.frame = SmallVideoFrame;
                }
                
                [tempModel.cellVideoView.superview addSubview:tempModel.avatarView];
                tempModel.avatarView.center = tempModel.cellVideoView.center;
                [tempModel.avatarView.indicatorView stopAnimating];
            }
            else
            {
                if (tempModel.avatarView)
                    [tempModel.avatarView removeFromSuperview];
            }
            
            tempModel.avType = avType;
        }
    }
}

- (void)blinkEngine:(BlinkEngine *)engine onUserLeft:(NSString *)userId
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"userLeft begin:%@",userId);
        if ([weakChatVC.userIDArray indexOfObject:userId] != NSNotFound)
        {
            NSInteger index = [weakChatVC.userIDArray indexOfObject:userId];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]) {
                [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
            }
            
            [weakChatVC.userIDArray removeObjectAtIndex:index];
            
            ChatCellVideoViewModel *chatCellVideoViewModel = weakChatVC.remoteViewArray[indexPath.row];
            [chatCellVideoViewModel removeObserver:chatCellVideoViewModel forKeyPath:@"frameRateRecv"];
            [chatCellVideoViewModel removeObserver:chatCellVideoViewModel forKeyPath:@"frameWidthRecv"];
            [chatCellVideoViewModel removeObserver:chatCellVideoViewModel forKeyPath:@"frameHeightRecv"];
            [chatCellVideoViewModel removeObserver:chatCellVideoViewModel forKeyPath:@"frameRate"];
            
            if (weakChatVC.remoteViewArray.count > indexPath.row) {
                [weakChatVC.remoteViewArray removeObjectAtIndex:indexPath.row];
            }
            
            [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            NSLog(@"userLeft end:%@",userId);
            
            if (weakChatVC.orignalRow > 0)
                weakChatVC.orignalRow--;
            
            if ([weakChatVC.userIDArray count] == 0)
            {
                if (weakChatVC.durationTimer)
                {
                    [weakChatVC.durationTimer invalidate];
                    weakChatVC.duration = 0;
                    weakChatVC.durationTimer = nil;
                }
                
                weakChatVC.dataTrafficLabel.hidden = YES;
                weakChatVC.talkTimeLabel.text = @"00:00";
                if (![weakChatVC.localVideoViewModel.userID isEqual:userId] && ![weakChatVC.localVideoViewModel.userID isEqualToString:kDeviceUUID])
                    [weakChatVC hideAlertLabel:YES];
                else
                    [weakChatVC hideAlertLabel:NO];
            }
        }
        
        if (weakChatVC.observerIndex == Blink_User_Observer)
        {
            if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId])
            {
                if ([weakChatVC.remoteViewArray count] > 0)
                {
                    ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];
                    model.infoLabel.text = @"";
                    
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                    
                    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                    [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                    weakChatVC.localVideoViewModel = model;
                    
                    [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                    [weakChatVC.userIDArray removeObjectAtIndex:0];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    
                    weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
                    
                    [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                    
                    if (weakChatVC.localVideoViewModel.avType == Blink_User_Only_Audio || weakChatVC.localVideoViewModel.avType == Blink_User_Audio_Video_None)
                    {
                        weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                        [weakChatVC.localVideoViewModel.cellVideoView.superview addSubview:weakChatVC.localVideoViewModel.avatarView];
                        weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                    }
                }
                else
                {
                    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                    weakChatVC.localVideoViewModel.cellVideoView = nil;
                    [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                    
                    [weakChatVC.localView removeFromSuperview];
                    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                    weakChatVC.localVideoViewModel = nil;
                    
                    if (weakChatVC.durationTimer)
                    {
                        [weakChatVC.durationTimer invalidate];
                        weakChatVC.duration = 0;
                        weakChatVC.durationTimer = nil;
                    }
                    [weakChatVC hideAlertLabel:NO];
                    weakChatVC.talkTimeLabel.text = @"00:00";
                }
            }
        }
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onWhiteBoardURL:(NSString *)url
{
    if ([url isEqualToString:@""] || url == NULL)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.chatViewController.isOpenWhiteBoard)
            [self.chatViewController showWhiteBoardWithURL:url];
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onWhiteBoardExist:(BOOL)isExist
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatViewController.isWhiteBoardExist = isExist;
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyWhiteBoardCreateBy:(NSString *)userId
{
    //其他人创建白板的回调
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatViewController.isWhiteBoardExist = YES;
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onControlAudioVideoDevice:(NSInteger)code
{
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyControlAudioVideoDevice:(Blink_Device_Type)type withUserID:(NSString *)userId open:(BOOL)isOpen
{
    //刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUser:userId deviceType:type open:isOpen];
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onRemoteVideoView:(UIView *)videoView vidoeSize:(CGSize)size remoteUserID:(NSString*)userID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < [self.chatViewController.remoteViewArray count]; i++)
        {
            ChatCellVideoViewModel *tempView = (ChatCellVideoViewModel *)self.chatViewController.remoteViewArray[i];
            if ([tempView.userID isEqualToString:userID])
                tempView.originalSize = size;
        }
        
        if ([self.chatViewController.localVideoViewModel.userID isEqualToString:userID])
            self.chatViewController.localVideoViewModel.originalSize = size;
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onOutputAudioPortSpeaker:(BOOL)enable
{
    [self.chatViewController selectSpeakerButtons:enable];
    [self.chatViewController.blinkEngine switchSpeaker:enable];
    [self.chatViewController enableSpeakerButton:enable];
}

- (void)blinkEngineOnAudioDeviceReady:(BlinkEngine *)engine
{
    [self.chatViewController.speakerControlButton setEnabled:YES];
    NSString *deviceModel = [UIDevice currentDevice].model;
    if ([deviceModel isEqualToString:@"iPod touch"] || [deviceModel containsString:@"iPad"])
    {
        [self.chatViewController.speakerControlButton setEnabled:NO];
        [self.chatViewController selectSpeakerButtons:NO];
        [self.chatViewController.blinkEngine switchSpeaker:NO];
    }
}

- (void)blinkEngine:(BlinkEngine *)engine onNetworkSentLost:(NSInteger)lost
{
    DLog(@"LLH...... onNetworkSentLost: %zd", lost);
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyScreenSharing:(NSString *)userId open:(BOOL)isOpen
{
        __weak ChatViewController *weakChatVC = self.chatViewController;
        for (ChatCellVideoViewModel *model in weakChatVC.remoteViewArray)
        {
            if ([model.userID isEqualToString:userId])
            {
                model.screenSharingStatus = isOpen ? 1:0;
                if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId])
                {
                    if (isOpen)
                    {
                        [weakChatVC.messageStatusBar showMessageBarAndHideAuto: NSLocalizedString(@"chat_Suggested_horizontal_screen_viewing", nil)];
                        model.everOnLocalView = 1;
                    }
                    else
                        model.everOnLocalView = 0;
                }
                else
                    model.everOnLocalView = 0;
            }
        }
}

#pragma mark - Meeting
- (void)blinkEngine:(BlinkEngine *)engine onNotifyDegradeNormalUserToObserver:(NSString *)userId
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    NSLog(@"userId:%@,localUID:%@",userId,self.chatViewController.localVideoViewModel.userID);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([kDeviceUUID isEqualToString: userId] && weakChatVC.observerIndex != Blink_User_Observer)
        {
            if (weakChatVC.alertController)
                [weakChatVC.alertController dismissViewControllerAnimated:YES completion:nil];
            
            if (weakChatVC.isCloseCamera)
                [weakChatVC didClickVideoMuteButton:weakChatVC.chatViewBuilder.openCameraButton];
            
            if (weakChatVC.isNotMute)
                [weakChatVC didClickAudioMuteButton:weakChatVC.chatViewBuilder.microphoneOnOffButton];
            
            [weakChatVC.blinkEngine answerDegradeNormalUserToObserver:userId status:YES];
            
            
            [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userID isEqualToString:userId]) {
                    UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
                    ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                    chatCellVideoViewModel.userID = userId;
                    chatCellVideoViewModel.userName = obj.userName;
                    chatCellVideoViewModel.avType = Blink_User_Audio_Video;
                    chatCellVideoViewModel.screenSharingStatus = 0 ;
                    chatCellVideoViewModel.everOnLocalView = 0;
                    
                    
                    [weakChatVC.observerArray addObject:chatCellVideoViewModel];
                }
            }];
            
            if (weakChatVC.isSwitchCamera)
            {
                ChatCellVideoViewModel *sourceMode = weakChatVC.remoteViewArray[weakChatVC.orignalRow];
                ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.orignalRow inSection:0]];
                ChatCellVideoViewModel *tempMode = weakChatVC.localVideoViewModel;
                
                tempMode.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                weakChatVC.remoteViewArray[weakChatVC.orignalRow] = tempMode;
                
                weakChatVC.localVideoViewModel = sourceMode;
                weakChatVC.observerIndex = Blink_User_Observer;
                [self.chatViewController turnMenuButtonToObserver];
                [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger i, BOOL * _Nonnull stop) {
                    if ([model.userID isEqualToString:userId])
                    {
                        [model removeObserver:model forKeyPath:@"frameRateRecv"];
                        [model removeObserver:model forKeyPath:@"frameWidthRecv"];
                        [model removeObserver:model forKeyPath:@"frameHeightRecv"];
                        [model removeObserver:model forKeyPath:@"frameRate"];
                        
                        [model.avatarView removeFromSuperview];
                        [weakChatVC.remoteViewArray removeObjectAtIndex:i];
                        [weakChatVC.userIDArray removeObjectAtIndex:i];
                        [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                    }
                }];
                
            }
            else
            {
                if ([weakChatVC.remoteViewArray count] > 0)
                {
                    ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];
                    model.infoLabel.text = @"";
                    
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                    
                    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                    [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                    self.degradeCellVideoViewModel = model;
                    weakChatVC.localVideoViewModel = model;
                    
                    [weakChatVC.userIDArray removeObjectAtIndex:0];
                    [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                    [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
                    
                    UIView *videoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
                    weakChatVC.localVideoViewModel.cellVideoView = videoView;
                    
                    [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                    
                    if (weakChatVC.localVideoViewModel.avType == Blink_User_Only_Audio || weakChatVC.localVideoViewModel.avType == Blink_User_Audio_Video_None)
                    {
                        weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                        [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];
                        weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                    }
                    
                    if (weakChatVC.isOpenWhiteBoard)
                        [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                    
                    [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.localVideoViewModel.cellVideoView];
                    
                }
                weakChatVC.observerIndex = Blink_User_Observer;
                [self.chatViewController turnMenuButtonToObserver];
            }
        }
        else
        {
            if ([weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId] && weakChatVC.isCloseCamera)
            {
                NSInteger index = [weakChatVC.userIDArray indexOfObject:weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID];
                if (index != NSNotFound)
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    if (weakChatVC.isSwitchCamera)
                        [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
                }
                
                weakChatVC.localView = [weakChatVC.blinkEngine createLocalVideoViewFrame:weakChatVC.videoMainView.frame withDisplayType:Blink_VideoViewDisplay_FullScreen];
                [weakChatVC.videoMainView addSubview:weakChatVC.localView];
            }
            
            [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger i, BOOL * _Nonnull stop) {
                if ([model.userID isEqualToString:userId])
                {
                    [model removeObserver:model forKeyPath:@"frameRateRecv"];
                    [model removeObserver:model forKeyPath:@"frameWidthRecv"];
                    [model removeObserver:model forKeyPath:@"frameHeightRecv"];
                    [model removeObserver:model forKeyPath:@"frameRate"];
                    
                    [weakChatVC.remoteViewArray removeObjectAtIndex:i];
                    [weakChatVC.userIDArray removeObjectAtIndex:i];
                    [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                }
            }];
            
            if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId])
            {
                if ([weakChatVC.remoteViewArray count] > 0)
                {
                    ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];
                    model.infoLabel.text = @"";
                    
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                    
                    [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                    self.degradeCellVideoViewModel = model;
                    weakChatVC.localVideoViewModel = model;
                    
                    [weakChatVC.userIDArray removeObjectAtIndex:0];
                    [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                    [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
                    
                    weakChatVC.localView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
                    
                    [weakChatVC.videoMainView addSubview:weakChatVC.localView];
                    
                    
                    if (weakChatVC.localVideoViewModel.avType == Blink_User_Only_Audio || weakChatVC.localVideoViewModel.avType == Blink_User_Audio_Video_None)
                    {
                        weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                        if (!weakChatVC.isOpenWhiteBoard)
                            [weakChatVC.localView.superview addSubview:weakChatVC.localVideoViewModel.avatarView];
                        
                        weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                    }
                    
                    if (weakChatVC.isOpenWhiteBoard)
                        [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                    else
                        [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.localView];
                }
            }
        }
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyUpgradeObserverToNormalUser:(NSString *)userId 
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([userId isEqualToString:kDeviceUUID])
        {
            if (weakChatVC.observerIndex != Blink_User_Observer)
                return ;
            
            __weak ChatViewController *weakChatVC = self.chatViewController;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([weakChatVC.alertTypeArray containsObject:[NSNumber numberWithInteger:4]])
                    return ;
                
                [weakChatVC.alertTypeArray addObject:[NSNumber numberWithInteger:4]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakChatVC.alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_invite_upgrade", nil) preferredStyle:UIAlertControllerStyleAlert];
                    [weakChatVC.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [weakChatVC.alertTypeArray removeObject:[NSNumber numberWithInteger:4]];
                        dispatch_semaphore_signal(sem);
                        [weakChatVC.localView removeFromSuperview];
                        weakChatVC.localView = nil;
                        if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationPortrait) {
                            weakChatVC.localView = [weakChatVC.blinkEngine createLocalVideoViewFrame:CGRectMake(0, 0, 90, 120) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                        }else{
                            weakChatVC.localView = [weakChatVC.blinkEngine createLocalVideoViewFrame:CGRectMake(0, 0, 120, 120) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                            if (weakChatVC.observerIndex == Blink_User_Observer) {
                                weakChatVC.localView.transform = CGAffineTransformIdentity;
                                if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationLandscapeLeft) {
                                    weakChatVC.localView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                                }else{
                                    weakChatVC.localView.transform = CGAffineTransformMakeRotation(M_PI_2);
                                }
                            }
                        }
                        
                        weakChatVC.observerIndex = Blink_User_Normal;
                        
                        
                        if (weakChatVC.isSwitchCamera && weakChatVC.remoteViewArray.count > weakChatVC.orignalRow) {
                            ChatCellVideoViewModel *sourceMode = weakChatVC.remoteViewArray[weakChatVC.orignalRow];
                            ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.orignalRow inSection:0]];
                            [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                            ChatCellVideoViewModel *tempMode = weakChatVC.localVideoViewModel;
                            
                            tempMode.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                            weakChatVC.remoteViewArray[weakChatVC.orignalRow] = tempMode;
                            if ([weakChatVC.userIDArray containsObject:tempMode.userID]) {
                                [weakChatVC.userIDArray removeObject:tempMode.userID ];
                            }
                            [weakChatVC.userIDArray addObject:tempMode.userID];
                            [cell.videoView addSubview:tempMode.cellVideoView];
                            if (tempMode.avType == Blink_User_Only_Audio || tempMode.avType == Blink_User_Audio_Video_None)
                            {
                                tempMode.avatarView.frame = SmallVideoFrame;
                                [cell.videoView addSubview:tempMode.avatarView];
                                tempMode.avatarView.center = tempMode.cellVideoView.center;
                            }
                            weakChatVC.localVideoViewModel = sourceMode;
                        }
                        
                        if (self.chatViewController.localVideoViewModel && ![self.chatViewController.localVideoViewModel.userID isEqualToString:@""]) {
                            UIView *videoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
                            
                            ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                            chatCellVideoViewModel.avatarView = weakChatVC.localVideoViewModel.avatarView;
                            if ([weakChatVC.userIDArray containsObject:self.chatViewController.localVideoViewModel.userID]) {
                                [weakChatVC.userIDArray removeObject:self.chatViewController.localVideoViewModel.userID ];
                            }
                            [weakChatVC.userIDArray addObject:self.chatViewController.localVideoViewModel.userID];
                            if (self.degradeCellVideoViewModel) {
                                chatCellVideoViewModel.avType = self.degradeCellVideoViewModel.avType;
                                chatCellVideoViewModel.originalSize = self.degradeCellVideoViewModel.originalSize;
                            }else{
                                chatCellVideoViewModel.avType = self.chatViewController.localVideoViewModel.avType;
                            }
                            
                            if (chatCellVideoViewModel.avType == Blink_User_Audio_Video_None || chatCellVideoViewModel.avType == Blink_User_Only_Audio) {
                                
                                chatCellVideoViewModel.avatarView.frame = BigVideoFrame;
                                
                                [weakChatVC.localVideoViewModel.cellVideoView addSubview:chatCellVideoViewModel.avatarView];
                                chatCellVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                            }
                            chatCellVideoViewModel.userID = weakChatVC.localVideoViewModel.userID;
                            [weakChatVC.remoteViewArray addObject:chatCellVideoViewModel];
                            [weakChatVC.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]]];
                        }
                        [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                        //weakChatVC.localview 旋转后
                        [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                        [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                        [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                        [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                        
                        weakChatVC.localVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:weakChatVC.localView];
                        weakChatVC.localVideoViewModel.userID = kDeviceUUID;
                        weakChatVC.localVideoViewModel.avType = Blink_User_Audio_Video;
                        weakChatVC.localVideoViewModel.userName = weakChatVC.userName;
                        weakChatVC.localVideoViewModel.screenSharingStatus = 0;
                        weakChatVC.localVideoViewModel.everOnLocalView = 0;
                        weakChatVC.localVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:weakChatVC.userName userID:kDeviceUUID];
                        
                        if (weakChatVC.userIDArray.count >= 1)
                        {
                            ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]];
                            ChatCellVideoViewModel *tmpModel = weakChatVC.remoteViewArray[weakChatVC.userIDArray.count-1];
                            [weakChatVC.videoMainView addSubview:tmpModel.cellVideoView];
                            
                            weakChatVC.isSwitchCamera = YES;
                            weakChatVC.orignalRow = weakChatVC.userIDArray.count-1;
                            weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel = tmpModel;
                            weakChatVC.selectedChatCell = cell;
                            weakChatVC.localVideoViewModel.avType = Blink_User_Audio_Video;
                            
                            if (weakChatVC.isOpenWhiteBoard)
                            {
                                [weakChatVC.localView removeFromSuperview];
                                weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.blinkEngine createLocalVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withDisplayType:Blink_VideoViewDisplay_CompleteView ];
                                tmpModel.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame: CGRectMake(0, 0, 90, 120) withUserID:tmpModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                                [cell.videoView addSubview:tmpModel.cellVideoView];
                                [cell.videoView bringSubviewToFront:tmpModel.cellVideoView];
                                
                                if (tmpModel.avType == Blink_User_Only_Audio || tmpModel.avType == Blink_User_Audio_Video_None)
                                {
                                    tmpModel.avatarView.frame = SmallVideoFrame;
                                    [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                                    tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                                }
                                
                                weakChatVC.isSwitchCamera = NO;
                                [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                            }
                            else
                            {
                                dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 2 *NSEC_PER_SEC);
                                dispatch_after(time
                                               , dispatch_get_main_queue(), ^{
                                                   [cell.videoView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                                                   if (tmpModel.avType == Blink_User_Only_Audio || tmpModel.avType == Blink_User_Audio_Video_None)
                                                   {
                                                       tmpModel.avatarView.frame = BigVideoFrame;
                                                       
                                                       [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                                                       tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                                                   }
                                                   
                                               });
                            }
                        }
                        
                        
                        if (weakChatVC.isNotMute)
                            [weakChatVC didClickAudioMuteButton:weakChatVC.chatViewBuilder.microphoneOnOffButton];
                        
                        if (weakChatVC.isCloseCamera)
                            [weakChatVC didClickVideoMuteButton:weakChatVC.chatViewBuilder.openCameraButton];
                        
                        if (weakChatVC.isBackCamera)
                            [weakChatVC shouldChangeSwitchCameraButtonBG:weakChatVC.chatViewBuilder.switchCameraButton];
                        
                        [weakChatVC turnMenuButtonToNormal];
                        weakChatVC.observerIndex = Blink_User_Normal;
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [weakChatVC.blinkEngine answerUpgradeObserverToNormalUser:userId status:YES];
                        });
                    }]];
                    [weakChatVC.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_no", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        [weakChatVC.blinkEngine answerUpgradeObserverToNormalUser:userId status:NO];
                        [weakChatVC.alertTypeArray removeObject:[NSNumber numberWithInteger:4]];
                        dispatch_semaphore_signal(sem);
                    }]];
                    [weakChatVC presentViewController:weakChatVC.alertController animated:YES completion:^{}];
                });
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            });
        }
        else
        {
            [weakChatVC.observerArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userID isEqualToString:userId])
                {
                    [obj removeObserver:obj forKeyPath:@"frameRateRecv"];
                    [obj removeObserver:obj forKeyPath:@"frameWidthRecv"];
                    [obj removeObserver:obj forKeyPath:@"frameHeightRecv"];
                    [obj removeObserver:obj forKeyPath:@"frameRate"];
                    
                    [weakChatVC.observerArray removeObject:obj];
                    [self blinkEngine:engine onUserJoined:userId userName:obj.userName userType:Blink_User_Normal audioVideoType:Blink_User_Audio_Video screenSharingStatus:Blink_ScreenSharing_Off];
                }
            }];
        }
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyNormalUserRequestHostAuthority:(NSString *)userId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([userId isEqualToString: kDeviceUUID])
        {
            self.chatViewController.alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_already_host", nil) preferredStyle:(UIAlertControllerStyleAlert)];
            [self.chatViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self.chatViewController presentViewController:self.chatViewController.alertController animated:YES completion:nil];
        }
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyRemoveUser:(NSString *)userId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([userId  isEqual: kDeviceUUID])
        {
            if (self.chatViewController.alertController)
                [self.chatViewController.alertController dismissViewControllerAnimated:YES completion:nil];
            
            self.chatViewController.alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_removed_by_host", nil) preferredStyle:UIAlertControllerStyleAlert];
            [self.chatViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.chatViewController didClickHungUpButton];
             }]];
            [self.chatViewController presentViewController:self.chatViewController.alertController animated:YES completion:^{}];
        }
    });
}

//所有与会人员收到的
- (void)blinkEngine:(BlinkEngine *)engine onNotifyHostControlUserDevice:(NSString *)userId host:(NSString *)hostId deviceType:(Blink_Device_Type)dType open:(BOOL)isOpen
{
    NSLog(@"userid:%@",userId);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([userId isEqualToString: kDeviceUUID])
        {
            ChatCellVideoViewModel *newModel = [[ChatCellVideoViewModel alloc] init];
            newModel.avType = self.chatViewController.localVideoViewModel.avType;
            [self adaptUserType:dType withDataModel:newModel open:isOpen];
            if (newModel.avType == self.chatViewController.localVideoViewModel.avType)
                return ;
            
            if (isOpen)
            {
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_yes", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    [self.chatViewController.alertTypeArray removeObject:[NSNumber numberWithInteger:dType]];
                    dispatch_semaphore_signal(sem);
                    
                    if (self.chatViewController.observerIndex != Blink_User_Observer)
                    {
                        [self updateUser:userId deviceType:dType open:isOpen];
                        [engine answerHostControlUserDevice:userId withDeviceType:dType open:isOpen status:YES];
                    }
                    
                }];
                UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_no", nil) style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                    [self.chatViewController.alertTypeArray removeObject:[NSNumber numberWithInteger:dType]];
                    dispatch_semaphore_signal(sem);
                    
                    if (self.chatViewController.observerIndex != Blink_User_Observer)
                        [engine answerHostControlUserDevice:userId withDeviceType:dType open:isOpen status:NO];
                }];
                
                __weak ChatViewController *weakChatVC = self.chatViewController;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if ([weakChatVC.alertTypeArray containsObject:[NSNumber numberWithInteger:dType]])
                        return ;
                    
                    [weakChatVC.alertTypeArray addObject:[NSNumber numberWithInteger:dType]];
                    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch (dType)
                        {
                            case Blink_Device_CameraMicphone:
                                [self alertWith:@"" withMessage:NSLocalizedString(@"chat_open_cameramic_by_host", nil) withOKAction:ok withCancleAction:cancle];
                                break;
                            case Blink_Device_Micphone:
                                [self alertWith:@"" withMessage:NSLocalizedString(@"chat_open_mic_by_host", nil) withOKAction:ok withCancleAction:cancle];
                                break;
                            case Blink_Device_Camera:
                                [self alertWith:@"" withMessage:NSLocalizedString(@"chat_open_camera_by_host", nil) withOKAction:ok withCancleAction:cancle];
                                break;
                            default:
                                break;
                        }
                    });
                });
            }
            else
            {
                if (self.chatViewController.observerIndex != Blink_User_Observer)
                {
                    [self updateUser:userId deviceType:dType open:isOpen];
                    [engine answerHostControlUserDevice:userId withDeviceType:dType open:isOpen status:YES];
                }
            }
        }
        else
        {
            [self updateUser:userId deviceType:dType open:isOpen];
        }
        
    });
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerHostControlUserDevice:(NSString *)userId withAnswerType:(Blink_Answer_Type)type withDeviceType:(Blink_Device_Type)dType status:(BOOL)isAccept
{
    if (isAccept)
    {
        BOOL isOpen = NO;
        if (type == Blink_Answer_InviteOpen)
            isOpen = YES;
        else if (type == Blink_Answer_InviteClose)
            isOpen = NO;
        
        [self updateUser:userId deviceType:dType open:isOpen];
    }
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerUpgradeObserverToNormalUser:(NSString *)userId status:(BOOL)isAccept
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    [weakChatVC.observerArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userID isEqualToString:userId])
        {
            [obj removeObserver:obj forKeyPath:@"frameRateRecv"];
            [obj removeObserver:obj forKeyPath:@"frameWidthRecv"];
            [obj removeObserver:obj forKeyPath:@"frameHeightRecv"];
            [obj removeObserver:obj forKeyPath:@"frameRate"];

            [weakChatVC.observerArray removeObject:obj];
            [self blinkEngine:engine onUserJoined:userId userName:obj.userName userType:Blink_User_Normal audioVideoType:Blink_User_Audio_Video screenSharingStatus:Blink_ScreenSharing_Off];
        }
    }];
}

- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerDegradeNormalUserToObserver:(NSString *)userId status:(BOOL)isAccept
{
    
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (isAccept)
    {
        if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId])
        {
            NSInteger index = [weakChatVC.userIDArray indexOfObject:weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID];
            if (index != NSNotFound)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                if (weakChatVC.isSwitchCamera)
                    [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
            }
        }
        __block NSInteger row;
        [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger i, BOOL * _Nonnull stop) {
            if ([model.userID isEqualToString:userId])
            {
                UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
                ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                chatCellVideoViewModel.userID = userId;
                chatCellVideoViewModel.userName = model.userName;
                chatCellVideoViewModel.avType = Blink_User_Audio_Video;
                chatCellVideoViewModel.screenSharingStatus = 0 ;
                chatCellVideoViewModel.everOnLocalView = 0;
                
                [weakChatVC.observerArray addObject:chatCellVideoViewModel];
                
                [model removeObserver:model forKeyPath:@"frameRateRecv"];
                [model removeObserver:model forKeyPath:@"frameWidthRecv"];
                [model removeObserver:model forKeyPath:@"frameHeightRecv"];
                [model removeObserver:model forKeyPath:@"frameRate"];
                
                row = i;
                [weakChatVC.remoteViewArray removeObjectAtIndex:i];
                [weakChatVC.userIDArray removeObjectAtIndex:i];
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }
        }];
        if (row <= weakChatVC.orignalRow)
            weakChatVC.orignalRow -= 1;
        
        if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId])
        {
            if ([weakChatVC.remoteViewArray count] > 0)
            {
                ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];
                model.infoLabel.text = @"";
                
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                
                //                    weakChatVC.localVideoViewModel = nil;
                //                    ChatCellVideoViewModel *tempModel = weakChatVC.localVideoViewModel;
                [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                self.degradeCellVideoViewModel = model;
                weakChatVC.localVideoViewModel = model;
                
                [weakChatVC.userIDArray removeObjectAtIndex:0];
                [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
                
                UIView *videoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
                weakChatVC.localVideoViewModel.cellVideoView = videoView;
                
                [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                
                
                if (weakChatVC.localVideoViewModel.avType == Blink_User_Only_Audio || weakChatVC.localVideoViewModel.avType == Blink_User_Audio_Video_None) {
                    
                    weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                    //                    if (!weakChatVC.isOpenWhiteBoard) {
                    [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];
                    //                    }
                    
                    weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                }
                
                //                    weakChatVC.localVideoViewModel.avType = tempModel.avType;
                if (weakChatVC.isOpenWhiteBoard) {
                    [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                }
                [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.localVideoViewModel.cellVideoView];
                
            }
        }
    }
}

//观察者收到的主持人回应回调
- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerObserverRequestBecomeNormalUser:(NSString *)userId status:(Blink_Accept_Type)acceptType;
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (acceptType == Blink_Accept_YES)
        {
            if ([userId isEqualToString:kDeviceUUID] && weakChatVC.observerIndex == Blink_User_Observer)
            {
                [weakChatVC.localView removeFromSuperview];
                weakChatVC.localView = nil;
                if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationPortrait)
                    weakChatVC.localView = [weakChatVC.blinkEngine createLocalVideoViewFrame:CGRectMake(0, 0, 90, 120) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                else
                {
                    weakChatVC.localView = [weakChatVC.blinkEngine createLocalVideoViewFrame:CGRectMake(0, 0, 120, 120) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                    if (weakChatVC.observerIndex == Blink_User_Observer)
                    {
                        weakChatVC.localView.transform = CGAffineTransformIdentity;
                        if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationLandscapeLeft)
                            weakChatVC.localView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                        else
                            weakChatVC.localView.transform = CGAffineTransformMakeRotation(M_PI_2);
                    }
                }
                
                if (weakChatVC.isSwitchCamera && weakChatVC.remoteViewArray.count > weakChatVC.orignalRow)
                {
                    ChatCellVideoViewModel *sourceMode = weakChatVC.remoteViewArray[weakChatVC.orignalRow];
                    ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.orignalRow inSection:0]];
                    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                    ChatCellVideoViewModel *tempMode = weakChatVC.localVideoViewModel;
                    
                    tempMode.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120) withUserID:tempMode.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                    weakChatVC.remoteViewArray[weakChatVC.orignalRow] = tempMode;
                    if ([weakChatVC.userIDArray containsObject:tempMode.userID])
                        [weakChatVC.userIDArray removeObject:tempMode.userID ];
                    
                    [weakChatVC.userIDArray addObject:tempMode.userID];
                    [cell.videoView addSubview:tempMode.cellVideoView];
                    if (tempMode.avType == Blink_User_Only_Audio || tempMode.avType == Blink_User_Audio_Video_None)
                    {
                        tempMode.avatarView.frame = SmallVideoFrame;
                        [cell.videoView addSubview:tempMode.avatarView];
                        tempMode.avatarView.center = tempMode.cellVideoView.center;
                    }
                    weakChatVC.localVideoViewModel = sourceMode;
                }
                
                if (weakChatVC.localVideoViewModel && ![weakChatVC.localVideoViewModel.userID isEqualToString:@""])
                {
                    UIView *videoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
                    
                    ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                    chatCellVideoViewModel.avatarView = weakChatVC.localVideoViewModel.avatarView;
                    if ([weakChatVC.userIDArray containsObject:weakChatVC.localVideoViewModel.userID])
                        [weakChatVC.userIDArray removeObject:weakChatVC.localVideoViewModel.userID ];
                    
                    [weakChatVC.userIDArray addObject:weakChatVC.localVideoViewModel.userID];
                    if (self.degradeCellVideoViewModel) {
                        chatCellVideoViewModel.avType = self.degradeCellVideoViewModel.avType;
                        chatCellVideoViewModel.originalSize = self.degradeCellVideoViewModel.originalSize;
                    }else{
                        chatCellVideoViewModel.avType = self.chatViewController.localVideoViewModel.avType;
                    }
                    
                    if (chatCellVideoViewModel.avType == Blink_User_Audio_Video_None || chatCellVideoViewModel.avType == Blink_User_Only_Audio) {
                        
                        chatCellVideoViewModel.avatarView.frame = BigVideoFrame;
                        
                        [weakChatVC.localVideoViewModel.cellVideoView addSubview:chatCellVideoViewModel.avatarView];
                        chatCellVideoViewModel.avatarView.center = CGPointMake(weakChatVC.videoMainView.frame.size.width / 2, weakChatVC.videoMainView.frame.size.height / 2);
                    }
                    
                    chatCellVideoViewModel.userID = weakChatVC.localVideoViewModel.userID;
                    [weakChatVC.remoteViewArray addObject:chatCellVideoViewModel];
                    [weakChatVC.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]]];
                }
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                //weakChatVC.localview 旋转后
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                
                weakChatVC.localVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:weakChatVC.localView];
                weakChatVC.localVideoViewModel.userID = kDeviceUUID;
                weakChatVC.localVideoViewModel.avType = Blink_User_Audio_Video;
                weakChatVC.localVideoViewModel.userName = weakChatVC.userName;
                weakChatVC.localVideoViewModel.screenSharingStatus = 0;
                weakChatVC.localVideoViewModel.everOnLocalView = 0;
                weakChatVC.localVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:weakChatVC.userName userID:kDeviceUUID];
                
                if (weakChatVC.userIDArray.count >= 1)
                {
                    ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]];
                    ChatCellVideoViewModel *tmpModel = weakChatVC.remoteViewArray[weakChatVC.userIDArray.count-1];
                    [weakChatVC.videoMainView addSubview:tmpModel.cellVideoView];
                    
                    weakChatVC.isSwitchCamera = YES;
                    weakChatVC.orignalRow = weakChatVC.userIDArray.count-1;
                    weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel = tmpModel;
                    weakChatVC.selectedChatCell = cell;
                    weakChatVC.localVideoViewModel.avType = Blink_User_Audio_Video;
                    
                    if (weakChatVC.isOpenWhiteBoard)
                    {
                        [weakChatVC.localView removeFromSuperview];
                        weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.blinkEngine createLocalVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withDisplayType:Blink_VideoViewDisplay_CompleteView ];
                        tmpModel.cellVideoView = [weakChatVC.blinkEngine changeRemoteVideoViewFrame: CGRectMake(0, 0, 90, 120) withUserID:tmpModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                        [cell.videoView addSubview:tmpModel.cellVideoView];
                        [cell.videoView bringSubviewToFront:tmpModel.cellVideoView];
                        
                        if (tmpModel.avType == Blink_User_Only_Audio || tmpModel.avType == Blink_User_Audio_Video_None)
                        {
                            tmpModel.avatarView.frame = SmallVideoFrame;
                            
                            [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                            tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                        }
                        
                        weakChatVC.isSwitchCamera = NO;
                        [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                    }
                    else
                    {
                        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2 *NSEC_PER_SEC);
                        dispatch_after(time
                                       , dispatch_get_main_queue(), ^{
                                           [cell.videoView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                                           if (tmpModel.avType == Blink_User_Only_Audio || tmpModel.avType == Blink_User_Audio_Video_None)
                                           {
                                               tmpModel.avatarView.frame = BigVideoFrame;
                                               
                                               [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                                               tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                                           }
                                           
                                       });
                    }
                }
                
                if (weakChatVC.isCloseCamera)
                    [weakChatVC didClickVideoMuteButton:weakChatVC.chatViewBuilder.openCameraButton];
                
                if (weakChatVC.isNotMute)
                    [weakChatVC didClickAudioMuteButton:weakChatVC.chatViewBuilder.microphoneOnOffButton];
                
                if (weakChatVC.isBackCamera)
                    [weakChatVC shouldChangeSwitchCameraButtonBG:weakChatVC.chatViewBuilder.switchCameraButton];
                
                weakChatVC.observerIndex = Blink_User_Normal;
                [weakChatVC turnMenuButtonToNormal];
                
            }
            else
            {
                [weakChatVC.observerArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.userID isEqualToString:userId])
                    {
                        [obj removeObserver:obj forKeyPath:@"frameRateRecv"];
                        [obj removeObserver:obj forKeyPath:@"frameWidthRecv"];
                        [obj removeObserver:obj forKeyPath:@"frameHeightRecv"];
                        [obj removeObserver:obj forKeyPath:@"frameRate"];

                        [weakChatVC.observerArray removeObject:obj];
                        [self blinkEngine:engine onUserJoined:userId userName:obj.userName userType:Blink_User_Normal audioVideoType:Blink_User_Audio_Video screenSharingStatus:Blink_ScreenSharing_Off];
                    }
                }];
            }
        }
        else if (acceptType == Blink_Accept_NO)
        {
            [weakChatVC turnMenuButtonToObserver];
        }
        else
        {
            //Busy
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [self alertWith:@"" withMessage:NSLocalizedString(@"chat_alert_raisehand_busy", nil) withOKAction:ok withCancleAction:nil];
        }
    });
}

//观察者请求成为正常用户后,主持人收到的回调
- (void)blinkEngine:(BlinkEngine *)engine onNotifyObserverRequestBecomeNormalUser:(NSString *)userId authorityType:(Blink_Authority_Type)type
{
}

//正常用户请求成为主持人信令是否发送成功的回调
- (void)blinkEngine:(BlinkEngine *)engine onNormalUserRequestHostAuthority:(NSInteger)code
{
}

- (void)blinkEngine:(BlinkEngine *)engine onRemoveUser:(NSInteger)code
{
}

- (void)blinkEngine:(BlinkEngine *)engine onGetInviteURL:(NSString *)url responseCode:(NSInteger)code
{
}

//主持人降低用户级别信令发送状态回调
- (void)blinkEngine:(BlinkEngine *)engine onDegradeNormalUserToObserver:(NSInteger)code
{
}

//主持人提升用户级别信令发送状态回调
- (void)blinkEngine:(BlinkEngine *)engine onUpgradeObserverToNormalUser:(NSInteger)code
{
}

//观察者请求成为正常用户信令是否发送成功的回调
- (void)blinkEngine:(BlinkEngine *)engine onObserverRequestBecomeNormalUser:(NSInteger)code
{
}

//主持人操作某正常用户设备开启关闭,信令发送是否成功的回调
- (void)blinkEngine:(BlinkEngine *)engine onHostControlUserDevice:(NSString *)userId withDeviceType:(Blink_Device_Type)dType responseCode:(NSInteger)code
{
}

#pragma mark - audioLevel
- (void)blinkEngine:(BlinkEngine *)engine onNotifyUserAudioLevel:(NSArray *)levelArray
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    for (NSDictionary *dict in levelArray) {
        NSInteger  audioleval = [dict[@"audioleval"] integerValue];
        NSString *userid = dict[@"userid"];
        if ([userid isEqualToString:kDeviceUUID])
        {
            if ([weakChatVC.localVideoViewModel.userID isEqualToString:userid])
            {
                weakChatVC.localVideoViewModel.audioLevel = audioleval;
                if (weakChatVC.localVideoViewModel.audioLevel <= 0)
                {
                    [weakChatVC.localVideoViewModel.audioLevelView removeFromSuperview];
                }
                else
                {
                    [weakChatVC.localVideoViewModel.cellVideoView.superview addSubview:weakChatVC.localVideoViewModel.audioLevelView];
                    [weakChatVC.localVideoViewModel.cellVideoView.superview bringSubviewToFront:weakChatVC.localVideoViewModel.audioLevelView];
                    weakChatVC.localVideoViewModel.audioLevelView.center = CGPointMake(weakChatVC.localVideoViewModel.cellVideoView.frame.size.width-20, weakChatVC.localVideoViewModel.cellVideoView.frame.size.height-20);
                }
            }
            
            continue;
        }
        [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.userID isEqualToString:userid]) {
                model.audioLevel = audioleval;
                if (model.audioLevel <= 0) {
                    [model.audioLevelView removeFromSuperview];
                }else{
                    [model.cellVideoView.superview addSubview:model.audioLevelView];
                    [model.cellVideoView.superview bringSubviewToFront:model.audioLevelView];
                    model.audioLevelView.center = CGPointMake(model.cellVideoView.frame.size.width-20, model.cellVideoView.frame.size.height-20);
                }
            }
        }];
    }
}

- (NSString *)trafficString:(NSString *)recvBitrate sendBitrate:(NSString *)sendBitrate
{
    return [NSString stringWithFormat:@"%@: %@   %@: %@", NSLocalizedString(@"chat_receive", nil), recvBitrate, NSLocalizedString(@"chat_send", nil), sendBitrate];
}

#pragma mark - private
- (void)updateUser:(NSString *)userId deviceType:(Blink_Device_Type)dType open:(BOOL)isOpen
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (weakChatVC.observerIndex == Blink_User_Observer){
        if ([self.chatViewController.localVideoViewModel.userID isEqualToString:userId]) {
            [self adaptUserType:dType withDataModel:self.chatViewController.localVideoViewModel open:isOpen];
            [self blinkEngine:weakChatVC.blinkEngine onUser:userId audioVideoType:self.chatViewController.localVideoViewModel.avType];
        }else{
            for (ChatCellVideoViewModel *model in weakChatVC.remoteViewArray) {
                if ([model.userID isEqualToString:userId]) {
                    [self adaptUserType:dType withDataModel:model open:isOpen];
                    [self blinkEngine:weakChatVC.blinkEngine onUser:userId audioVideoType:model.avType];
                }
            }
        }
    }if ([userId isEqualToString:kDeviceUUID]) {
        [self adaptUserType:dType withDataModel:weakChatVC.localVideoViewModel open:isOpen];
        NSLog(@"avType: %ld", (long)weakChatVC.localVideoViewModel.avType);
        [weakChatVC updateAudioVideoType:weakChatVC.localVideoViewModel.avType];
    }else{
        for (ChatCellVideoViewModel *model in weakChatVC.remoteViewArray) {
            if ([model.userID isEqualToString:userId]) {
                [self adaptUserType:dType withDataModel:model open:isOpen];
                [self blinkEngine:weakChatVC.blinkEngine onUser:userId audioVideoType:model.avType];
            }
        }
    }
}

#pragma mark - AlertController
- (void)alertWith:(NSString *)title withMessage:(NSString *)msg withOKAction:(UIAlertAction *)ok withCancleAction:(UIAlertAction *)cancel
{
    self.chatViewController.alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self.chatViewController.alertController addAction:ok];
    if (cancel)
        [self.chatViewController.alertController addAction:cancel];
    
    [self.chatViewController presentViewController:self.chatViewController.alertController animated:YES completion:^{}];
    
}

- (void)adaptUserType:(Blink_Device_Type)dType withDataModel:(ChatCellVideoViewModel *)model open:(BOOL)isOpen
{
    switch (model.avType) {
        case Blink_User_Only_Audio:
            switch (dType) {
                case Blink_Device_Camera:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Only_Audio;
                    break;
                case Blink_Device_Micphone:
                    model.avType = isOpen ? Blink_User_Only_Audio : Blink_User_Audio_Video_None;
                    break;
                case Blink_Device_CameraMicphone:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        case Blink_User_Audio_Video:
            switch (dType) {
                case Blink_Device_Camera:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Only_Audio;
                    break;
                case Blink_Device_Micphone:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Only_Video;
                    break;
                case Blink_Device_CameraMicphone:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        case Blink_User_Only_Video:
            switch (dType) {
                case Blink_Device_Camera:
                    model.avType = isOpen ? Blink_User_Only_Video : Blink_User_Audio_Video_None;
                    break;
                case Blink_Device_Micphone:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Only_Video;
                    break;
                case Blink_Device_CameraMicphone:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        case Blink_User_Audio_Video_None:
            switch (dType) {
                case Blink_Device_Camera:
                    model.avType = isOpen ? Blink_User_Only_Video : Blink_User_Audio_Video_None;
                    break;
                case Blink_Device_Micphone:
                    model.avType = isOpen ? Blink_User_Only_Audio : Blink_User_Audio_Video_None;
                    break;
                case Blink_Device_CameraMicphone:
                    model.avType = isOpen ? Blink_User_Audio_Video : Blink_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}
@end








