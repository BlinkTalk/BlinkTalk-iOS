//
//  ChatDataInfoModel.h
//  Blink Talk
//
//  Created by Vicky on 2018/2/8.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatDataInfoModel : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *tunnelName;
@property (nonatomic, strong) NSString *codec;
@property (nonatomic, strong) NSString *frame;
@property (nonatomic, strong) NSString *frameRate;
@property (nonatomic, strong) NSString *codeRate;
@property (nonatomic, strong) NSString *lossRate;


@end
