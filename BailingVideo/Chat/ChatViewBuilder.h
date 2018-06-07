//
//  ChatViewBuilder.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/18.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatBubbleMenuViewDelegateImpl.h"
#import "BlinkExcelView.h"

#define kUnableButtonColor [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]

@class ChatViewController;

@interface ChatViewBuilder : NSObject

@property (nonatomic, strong) ChatViewController *chatViewController;
@property (nonatomic, strong) UILabel *infoLabel, *snifferLabel;
@property (nonatomic, strong) BlinkExcelView *excelView;
@property (nonatomic, strong) UIButton *hungUpButton, *openCameraButton, *speakerOnOffButton, *microphoneOnOffButton, *whiteBoardButton, *raiseHandButton, *switchCameraButton, *rotateButton;
@property (nonatomic, strong) DWBubbleMenuButton *upMenuView;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer, *rightSwipeGestureRecognizer;
- (instancetype)initWithViewController:(UIViewController *)vc;
- (void)reloadChatView;

@end
