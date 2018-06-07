//
//  ChatViewBuilder.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/18.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "ChatViewBuilder.h"
#import "ChatViewController.h"
#import "CommonUtility.h"

@interface ChatViewBuilder ()
{
    UIView *infoView;
    ChatBubbleMenuViewDelegateImpl *chatBubbleMenuViewDelegateImpl;
    BOOL isLeftDisplay, isRightDisplay;
}

@end

@implementation ChatViewBuilder
@synthesize upMenuView = upMenuView;


- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
        
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.hungUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hungUpButton.frame = CGRectMake(0, 0, 44, 44);
    
    NSString *deviceModel = [UIDevice currentDevice].model;
    if ([deviceModel containsString:@"iPad"])
        self.hungUpButton.center = CGPointMake(ScreenWidth/2, ScreenHeight - 44);
    else
        self.hungUpButton.center = CGPointMake(ScreenWidth/2, (ScreenHeight - (TitleHeight + self.chatViewController.videoHeight))/2 + (TitleHeight + self.chatViewController.videoHeight));
    
    [CommonUtility setButtonImage:self.hungUpButton imageName:@"chat_hung_up"];
    [self.hungUpButton addTarget:self.chatViewController action:@selector(didClickHungUpButton) forControlEvents:UIControlEventTouchUpInside];
    self.hungUpButton.backgroundColor = redButtonBackgroundColor;
    self.hungUpButton.layer.masksToBounds = YES;
    self.hungUpButton.layer.cornerRadius = 22.f;
    [self.chatViewController.view addSubview:self.hungUpButton];
    
    self.rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rotateButton.frame = CGRectMake(0, 0, 36, 36);
    if ([deviceModel containsString:@"iPad"])
        self.rotateButton.center = CGPointMake(16.f+18.f, ScreenHeight - 44);
    else
        self.rotateButton.center = CGPointMake(16.f+18.f, (ScreenHeight - (TitleHeight + self.chatViewController.videoHeight))/2 + (TitleHeight + self.chatViewController.videoHeight));
    
    self.rotateButton.hidden = YES;
    [self.rotateButton addTarget:self.chatViewController action:@selector(didcClickRotateButton:) forControlEvents:UIControlEventTouchUpInside];
    self.rotateButton.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
    self.rotateButton.tintColor = [UIColor blackColor];
    
    [CommonUtility setButtonImage:self.rotateButton imageName:@"chat_rotate_off"];
    self.rotateButton.layer.masksToBounds = YES;
    self.rotateButton.layer.cornerRadius = 18.f;
    [self.chatViewController.view addSubview:self.rotateButton];
    
    [self initMenuButton];
}

- (void)reloadChatView
{
    self.hungUpButton.center = CGPointMake(ScreenHeight/2, ScreenWidth - 44);
    upMenuView.frame = CGRectMake(self.chatViewController.view.frame.size.height - self.chatViewController.homeImageView.frame.size.height - 16.f, ScreenWidth - 60, self.chatViewController.homeImageView.frame.size.height, self.chatViewController.homeImageView.frame.size.width);
}

#pragma mark - init menu button
- (void)initMenuButton
{
    chatBubbleMenuViewDelegateImpl = [[ChatBubbleMenuViewDelegateImpl alloc] initWithViewController:self.chatViewController];
    
    self.chatViewController.homeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 36.f, 36.f)];
    self.chatViewController.homeImageView.userInteractionEnabled = YES;
    self.chatViewController.homeImageView.image = [UIImage imageNamed:@"chat_menu"];
    self.chatViewController.homeImageView.backgroundColor = [UIColor whiteColor];
    self.chatViewController.homeImageView.layer.masksToBounds = YES;
    self.chatViewController.homeImageView.layer.cornerRadius = self.chatViewController.homeImageView.frame.size.width / 2.f;
    
    CGRect BubbleMenuButtonRect;
    NSString *deviceModel = [UIDevice currentDevice].model;
    if ([deviceModel containsString:@"iPad"])
    {
        BubbleMenuButtonRect = CGRectMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width - 16.f, ScreenHeight - 60, self.chatViewController.homeImageView.frame.size.width, self.chatViewController.homeImageView.frame.size.height);
    }
    else
    {
        BubbleMenuButtonRect = CGRectMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width - 16.f, (ScreenHeight - (TitleHeight + self.chatViewController.videoHeight) - 36)/2 + (TitleHeight + self.chatViewController.videoHeight), self.chatViewController.homeImageView.frame.size.width, self.chatViewController.homeImageView.frame.size.height);
    }
    upMenuView = [[DWBubbleMenuButton alloc] initWithFrame:BubbleMenuButtonRect expansionDirection:DirectionUp];
    upMenuView.center = CGPointMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width/2 - 16.f, ScreenHeight/2+(7*36+6*10)/2);
    upMenuView.homeButtonView = self.chatViewController.homeImageView;
    upMenuView.delegate = chatBubbleMenuViewDelegateImpl;
    [upMenuView addButtons:[self createDemoButtonArray]];
    [self.chatViewController.view addSubview:upMenuView];
    [upMenuView showButtons];
    upMenuView.homeButtonView.hidden = YES;
 }

- (NSArray *)createDemoButtonArray
{
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 6; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0.f, 0.f, 36.f, 36.f);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
        button.clipsToBounds = YES;
        button.tag = i;
        [button addTarget:self.chatViewController action:@selector(menuItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsMutable addObject:button];
        [button setTintColor:[UIColor blackColor]];
        
        switch (button.tag)
        {
            case 0:
            {
                self.raiseHandButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_handup_off"];
            }
                break;
            case 1:
            {
                self.whiteBoardButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_white_board_off"];
            }
                break;
            case 2:
                self.switchCameraButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_switch_camera"];
                break;
            case 3:
            {
                self.openCameraButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_open_camera"];
            }
                break;
            case 4:
            {
                self.speakerOnOffButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_speaker_on"];
            }
                break;
            case 5:
            {
                self.microphoneOnOffButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_microphone_on"];
            }
                break;
            default:
                break;
        }
    }
    
    return [buttonsMutable copy];
}

#pragma mark - bitrate display label
- (void)initInfoLabel
{
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(-ScreenWidth, ScreenHeight/2, ScreenWidth, 200)];
    self.infoLabel.font = [UIFont systemFontOfSize:14];
    self.infoLabel.textColor = [UIColor greenColor];
    self.infoLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    self.infoLabel.numberOfLines = 0; // 不可少Label属性之一
    self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping; // 不可少Label属性之一
    self.infoLabel.hidden = YES;
    [self.chatViewController.view addSubview:self.infoLabel];
    
    self.snifferLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth, ScreenHeight/2, ScreenWidth, 200)];
    self.snifferLabel.font = [UIFont systemFontOfSize:14];
    self.snifferLabel.textColor = [UIColor greenColor];
    self.snifferLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
    self.snifferLabel.textAlignment = NSTextAlignmentCenter;
    self.snifferLabel.numberOfLines = 0; // 不可少Label属性之一
    self.snifferLabel.lineBreakMode = NSLineBreakByWordWrapping; // 不可少Label属性之一
    self.snifferLabel.hidden = YES;
    [self.chatViewController.view addSubview:self.snifferLabel];
}

- (void)initSwipeGesture
{
    _leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerAction:)];
    _leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.chatViewController.view addGestureRecognizer:_leftSwipeGestureRecognizer];
    
    _rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerAction:)];
    _rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.chatViewController.view addGestureRecognizer:_rightSwipeGestureRecognizer];
}

- (void)swipeGestureRecognizerAction:(UISwipeGestureRecognizer *)recognize
{
    switch (recognize.direction)
    {
        case UISwipeGestureRecognizerDirectionRight:
        {
            if (isRightDisplay)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.snifferLabel.frame = CGRectMake(ScreenWidth, self.snifferLabel.frame.origin.y, self.snifferLabel.frame.size.width, self.snifferLabel.frame.size.height);
                } completion:^(BOOL finished) {
                    self.snifferLabel.hidden = YES;
                }];
                isRightDisplay = NO;
            }
            else if (!isLeftDisplay)
            {
                self.excelView.hidden = NO;
                [self.chatViewController showButtons:YES];
                [UIView animateWithDuration:0.3 animations:^{
                    self.excelView.frame =  CGRectMake(0, self.excelView.frame.origin.y, self.excelView.frame.size.width, self.excelView.frame.size.height);
                } completion:^(BOOL finished) {
                }];
                isLeftDisplay = YES;
            }
        }
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
        {
            if (isLeftDisplay)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    [self.chatViewController showButtons:NO];
                    self.excelView.frame =  CGRectMake(-ScreenWidth, self.excelView.frame.origin.y, self.excelView.frame.size.width, self.excelView.frame.size.height);
                } completion:^(BOOL finished) {
                    self.excelView.hidden = YES;
                }];
                isLeftDisplay = NO;
            }
            else if (!isRightDisplay)
            {
                self.snifferLabel.hidden = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    self.snifferLabel.frame = CGRectMake(0, self.snifferLabel.frame.origin.y, self.snifferLabel.frame.size.width, self.snifferLabel.frame.size.height);
                } completion:^(BOOL finished) {
                }];
                isRightDisplay = YES;
            }
        }
            break;
        default:
            break;
    }
}


@end
