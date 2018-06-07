//
//  LoginBlinkEngineDelegateImpl.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/30.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Blink/BlinkEngine.h>

@interface LoginBlinkEngineDelegateImpl : NSObject <BlinkEngineDelegate>

@property (nonatomic, assign) BlinkConnectionState connectionState;

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
