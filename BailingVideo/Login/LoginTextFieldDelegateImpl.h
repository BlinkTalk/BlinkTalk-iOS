//
//  LoginTextFieldDelegateImpl.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KMaxInpuNumber 12

@interface LoginTextFieldDelegateImpl : NSObject <UITextFieldDelegate>

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
