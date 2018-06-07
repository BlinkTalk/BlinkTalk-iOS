//
//  ChatBubbleMenuViewDelegateImpl.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWBubbleMenuButton.h"

@interface ChatBubbleMenuViewDelegateImpl : NSObject <DWBubbleMenuViewDelegate>

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
