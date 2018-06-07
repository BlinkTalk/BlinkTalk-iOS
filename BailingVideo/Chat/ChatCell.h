//
//  ChatCell.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChatType) {
    ChatTypeVideo,
    ChatTypeAudio,
    ChatTypeDefault = ChatTypeVideo
};

@interface ChatCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (assign, nonatomic) ChatType type;
@end
