//
//  ChatViewController.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Blink/BlinkEngine.h>
#import "ChatCell.h"
#import "ChatCollectionViewDataSourceDelegateImpl.h"
#import "ChatBlinkEngineDelegateImpl.h"
#import "ChatViewBuilder.h"
#import "MessageStatusBar.h"
#import "ChatCellVideoViewModel.h"
#import "WhiteBoardWebView.h"

#define TitleHeight 78
#define redButtonBackgroundColor [UIColor colorWithRed:243.0/255.0 green:57.0/255.0 blue:58.0/255.0 alpha:1.0]

@interface ChatViewController : UIViewController

@property (nonatomic, retain) NSString *roomName, *userName;
@property (nonatomic, assign) ChatType chatType;
@property (nonatomic, weak) IBOutlet UIButton *speakerControlButton;
@property (nonatomic, weak) IBOutlet UIButton *audioMuteControlButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraControlButton;
@property (nonatomic, weak) IBOutlet UIView *videoControlView;
@property (nonatomic, weak) IBOutlet UIView *videoMainView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *statusView;
@property (nonatomic, weak) IBOutlet UILabel *talkTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dataTrafficLabel;
@property (nonatomic, weak) IBOutlet UILabel *alertLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) WhiteBoardWebView *whiteBoardWebView;
@property (nonatomic, strong) UIImageView *homeImageView;
@property (nonatomic, strong) NSMutableArray *remoteViewArray, *observerArray;
@property (nonatomic, strong) UIView *localView;
@property (nonatomic,strong) UIAlertController *alertController;
@property (nonatomic, strong) BlinkEngine *blinkEngine;
@property (nonatomic, strong) NSMutableArray *userIDArray;
@property (nonatomic, strong) NSMutableArray *alertTypeArray;//alertTypeArray:   Blink_Device_Camera = 1,Blink_Device_Micphone = 2,Blink_Device_CameraMicphone = 3,upgrade:4
@property (nonatomic, strong) NSMutableDictionary *videoMuteForUids;
@property (nonatomic, assign) ChatType type;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) NSUInteger duration, chatResolutionRatioIndex;
@property (nonatomic, assign) BOOL isBackCamera, isCloseCamera, isSpeaker,isWhiteBoardExist, isNotMute, isSwitchCamera, isOpenWhiteBoard, isGPUFilter, isSRTPEncrypt, isHiddenStatusBar;
@property (nonatomic, assign) NSInteger orignalRow, observerIndex, closeCameraIndex;
@property (nonatomic, strong) ChatCell *selectedChatCell;
@property (nonatomic, assign) CGFloat videoHeight, blankHeight;
@property (nonatomic, strong) ChatCollectionViewDataSourceDelegateImpl *chatCollectionViewDataSourceDelegateImpl;
@property (nonatomic, strong) ChatBlinkEngineDelegateImpl *chatBlinkEngineDelegateImpl;
@property (nonatomic, strong) ChatViewBuilder *chatViewBuilder;
@property (nonatomic, strong) MessageStatusBar *messageStatusBar;
@property (nonatomic, strong) NSMutableDictionary *paraDic;
@property (nonatomic, strong) ChatCellVideoViewModel *localVideoViewModel;
@property (nonatomic, assign) BOOL isFinishLeave,isLandscapeLeft, isNotLeaveMeAlone;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientaionBefore;

- (void)hideAlertLabel:(BOOL)isHidden;
- (void)selectSpeakerButtons:(BOOL)selected;
- (void)updateTalkTimeLabel;
- (void)resumeLocalView:(NSIndexPath *)indexPath;
- (void)didClickHungUpButton;
- (void)menuItemButtonPressed:(UIButton *)sender;
- (void)resetAudioSpeakerButton;
- (void)didClickVideoMuteButton:(UIButton *)btn;
- (void)muteVideoButton:(UIButton *)btn;
- (void)didClickAudioMuteButton:(UIButton *)btn;
- (void)didClickRaiseHandButton:(UIButton *)btn;
- (void)didClickSwitchCameraButton:(UIButton *)btn;
- (void)didcClickRotateButton:(UIButton *)btn;
- (void)didClickDownVideoProfileButton:(UIButton *)btn;
- (void)didClickUpVideoProfileButton:(UIButton *)btn;
- (void)shouldChangeSwitchCameraButtonBG:(UIButton *)btn;

- (void)updateAudioVideoType:(BlinkAudioVideoType)type;
- (void)enableButton:(UIButton *)btn enable:(BOOL)flag;
- (void)turnMenuButtonToObserver;
- (void)turnMenuButtonToNormal;
- (void)showButtonsWithWhiteBoardExist:(BOOL)exist;
- (void)showButtons:(BOOL)flag;


- (void)modifyAudioVideoType:(UIButton *)btn;
- (void)showWhiteBoardWithURL:(NSString *)wbURL;
- (void)enableSpeakerButton:(BOOL)enable;
- (void)joinChannel;


@end
