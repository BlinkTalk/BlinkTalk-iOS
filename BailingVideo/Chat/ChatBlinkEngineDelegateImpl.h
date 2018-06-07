//
//  ChatBlinkEngineDelegateImpl.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Blink/BlinkEngine.h>
#import "ChatCellVideoViewModel.h"

@interface ChatBlinkEngineDelegateImpl : NSObject <BlinkEngineDelegate>

@property (nonatomic, strong) UIImageView *remoteMicImageView;
@property (nonatomic, strong) ChatCellVideoViewModel *degradeCellVideoViewModel;
@property (nonatomic, strong) NSMutableArray *bitrateArray;

- (instancetype)initWithViewController:(UIViewController *)vc;

- (void)adaptUserType:(Blink_Device_Type)dType withDataModel:(ChatCellVideoViewModel *)model open:(BOOL)isOpen;


@end
