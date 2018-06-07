//
//  UINavigationController+returnBack.h
//  BlinkTalk
//
//  Created by Vicky on 2018/1/30.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol BackButtonHandlerProtocol <NSObject>

@optional
- (BOOL)navigationShouldPopOnBackButton;

@end


@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end


@interface UINavigationController (returnBack)<BackButtonHandlerProtocol>




@end
