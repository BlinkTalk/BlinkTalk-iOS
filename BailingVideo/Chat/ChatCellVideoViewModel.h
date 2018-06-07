//
//  ChatCellVideoViewModel.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/07.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatAvatarView.h"

@interface ChatCellVideoViewModel : UIView

- (instancetype)initWithView:(UIView *)view;

@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, strong) UIView *cellVideoView;
@property (nonatomic, strong) ChatAvatarView *avatarView;
@property (nonatomic, strong) UIWebView *audioLevelView;
@property (nonatomic, strong) NSString *userID, *userName;
@property (nonatomic, assign) NSInteger frameRateRecv;
@property (nonatomic, assign) NSInteger frameWidthRecv;
@property (nonatomic, assign) NSInteger frameHeightRecv;
@property (nonatomic, assign) NSInteger audioLevel;
@property (nonatomic, assign) NSString *frameRate;
@property (nonatomic, assign) NSInteger avType, screenSharingStatus, everOnLocalView;
@property (nonatomic, strong) UIImageView *micImageView;
@property (nonatomic, strong) UILabel *infoLabel, *nameLabel;
@property (nonatomic, assign) BOOL isShowVideo;

@end
