//
//  UIColor+ColorChange.m
//  Blink Talk
//
//  Created by Vicky on 2018/2/8.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "UIColor+ColorChange.h"

static NSInteger randomRGBIndex = -1;

@implementation UIColor (ColorChange)

+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *)randomColorForAvatarRBG
{
    NSArray *hexColors = @[@"#0066CC",@"#009900",@"#CC3333",@"#CC9966",@"#FF9900",@"#CC33CC"];
    NSInteger random;
    do
    {
        //detail implementation
        //arc4random() % 78 will return a number between 0 and 77, for example.
        //    CGFloat hue = arc4random() % 100 / 100.0; //色调：0.0 ~ 1.0
        //    CGFloat saturation = (arc4random() % 50 / 100) + 0.5; //饱和度：0.5 ~ 1.0
        //    CGFloat brightness = (arc4random() % 50 / 100) + 0.5; //亮度：0.5 ~ 1.0
        random = arc4random() % 6 ; //色调：0.0 ~ 1.0
    }
    while (randomRGBIndex == random);
    randomRGBIndex = random;
    return [UIColor colorWithHexString:hexColors[random]];
}

+ (UIColor *)observerColor
{
    return [UIColor colorWithHexString:@"#CCCCCC"];
}

@end
