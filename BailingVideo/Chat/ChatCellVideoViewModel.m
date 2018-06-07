//
//  ChatCellVideoViewModel.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/07.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "ChatCellVideoViewModel.h"
#import "UIColor+ColorChange.h"

@interface ChatCellVideoViewModel ()
 

@end


@implementation ChatCellVideoViewModel

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self)
    {
        self.cellVideoView = view;
        self.originalSize = CGSizeZero;
        self.userID = @"";
        self.frameRateRecv = 0;
        self.frameWidthRecv = 0;
        self.frameHeightRecv = 0;
        self.avType = 1;
        
        [self initLableView];
    }
    
    return self;
}

- (UIWebView *)audioLevelView
{
    if (!_audioLevelView) {
        _audioLevelView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"gif"];
        NSURL *url = [NSURL URLWithString:path];
        [_audioLevelView loadRequest:[NSURLRequest requestWithURL:url]];
        _audioLevelView.backgroundColor = [UIColor clearColor];
        _audioLevelView.opaque = NO;
        _audioLevelView.scalesPageToFit = YES;
     }
    return _audioLevelView;
}

- (ChatAvatarView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[ChatAvatarView alloc] init];
        _avatarView.backgroundColor = [UIColor randomColorForAvatarRBG];
    }
    return _avatarView;
}

- (void)initLableView
{
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.cellVideoView.frame.size.height-16, self.cellVideoView.frame.size.width, 16)];
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    self.infoLabel.font = [UIFont systemFontOfSize:12];
    self.infoLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
    self.infoLabel.textColor = [UIColor greenColor];
    
    [self addObserver:self forKeyPath:@"frameRateRecv" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"frameWidthRecv" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"frameHeightRecv" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"frameRate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)setCellVideoView:(UIView *)cellVideoView
{
    _cellVideoView = cellVideoView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    self.infoLabel.text = [NSString stringWithFormat:@"  %zd    %@", self.frameRateRecv, self.frameRate];
    self.infoLabel.frame = CGRectMake(0, self.cellVideoView.frame.size.height-16, self.cellVideoView.frame.size.width, 16);
    [self.cellVideoView bringSubviewToFront:self.infoLabel];
}

@end
