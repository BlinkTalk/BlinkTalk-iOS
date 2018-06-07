//
//  UIColor+ColorChange.h
//  Blink Talk
//
//  Created by Vicky on 2018/2/8.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorChange)


+ (UIColor *)colorWithHexString: (NSString *)color;
+ (UIColor *)randomColorForAvatarRBG;
+ (UIColor *)observerColor;

@end
