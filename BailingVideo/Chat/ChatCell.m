//
//  ChatCell.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "ChatCell.h"

@interface ChatCell ()
@property (weak, nonatomic) IBOutlet UIView *audioView;
@end

@implementation ChatCell
 
- (void)setType:(ChatType)type
{
    _type = type;
    
    if (type == ChatTypeAudio) {
        self.videoView.hidden = YES;
        self.audioView.hidden = NO;
    } else if (type == ChatTypeVideo) {
        self.videoView.hidden = NO;
        self.audioView.hidden = YES;
    } else {
        DLog(@"error: control type not correct");
    }
}

@end
