//
//  ChatAvatarView.m
//  Blink Talk
//
//  Created by Vicky on 2018/3/1.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "ChatAvatarView.h"
#import "UIColor+ColorChange.h"
#import "CommonUtility.h"

@implementation ChatAvatarModel

- (instancetype)initWithShowVoice:(BOOL)isShowVoice showIndicator:(BOOL)isShowIndicator userName:(NSString *)userName userID:(NSString *)userId;
{
    self = [super init];
    if (self) {
        _isShowVoice = isShowVoice;
        _isShowIndicator = isShowIndicator;
        _userID = userId;
        _userName = userName;
    }
    return self;
}

@end


@implementation ChatAvatarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self configUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self configUI];
}

- (UILabel *)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 20)/2, self.frame.size.width, 20.0)];
    }
    return _nickNameLabel;
}

- (UIImageView *)voiceImgView
{
    if (!_voiceImgView) {
        _voiceImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20.0, self.frame.size.width, 20.0)];
    }
    return _voiceImgView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width-90)/2,  (self.frame.size.height-90)/2, 90.0, 90.0)];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        _indicatorView.transform = transform;
    }
    return _indicatorView;
}

- (void)configUI
{
    self.nickNameLabel.frame = CGRectMake(0, (self.frame.size.height - 20)/2, self.frame.size.width, 20.0);
    _nickNameLabel.textAlignment = NSTextAlignmentCenter;
    _nickNameLabel.textColor = [UIColor whiteColor];
    [self addSubview:_nickNameLabel];
    
    self.voiceImgView.frame = CGRectMake(0, self.frame.size.height-20.0, self.frame.size.width, 20.0);
    [self addSubview:_voiceImgView];
    
    self.indicatorView.frame = CGRectMake((self.frame.size.width-90)/2,  (self.frame.size.height-90)/2, 90, 90);
    [self addSubview:_indicatorView];
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView stopAnimating];
}

- (void)setModel:(ChatAvatarModel *)model
{
    _voiceImgView.hidden = !model.isShowVoice;
    _indicatorView.hidden = !model.isShowIndicator;

    if (model.isShowIndicator) {
        [_indicatorView startAnimating];
    }else
        [_indicatorView stopAnimating];
    
    _nickNameLabel.text = [CommonUtility strimCharacter:model.userName withRegex:RegexIsChinese];
    
}


@end
