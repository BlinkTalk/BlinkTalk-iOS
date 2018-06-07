//
//  NSString+length.m
//  Blink Talk
//
//  Created by Vicky on 2018/2/24.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "NSString+length.h"

@implementation NSString (length)

- (NSInteger)getStringLengthOfBytes
{
    NSInteger length = 0;
    for (int i = 0; i < [self length]; i++) {
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        if ([self validateChineseChar:s]) {
            length += 2;
        }else{
            length += 1;
        }
    }
    return length;
}

-(NSString *)subStringWithString:(NSString *)string withLength:(NSInteger )count
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data = [string dataUsingEncoding:enc];
    NSData * subData;
    if (data.length%2 == 0) {
        subData = [data subdataWithRange:NSMakeRange(data.length-5, count)];
    }else{
        subData = [data subdataWithRange:NSMakeRange(data.length-5, count)];
    }
    return [[NSString alloc] initWithData:subData encoding:enc];
}

- (NSString *)subBytesOfstringToIndex:(NSInteger)index
{
    NSInteger length = 0;
    NSInteger chineseNum = 0;
    NSInteger zifuNum = 0;
    
    for (int i = 0; i < [self length]; i++) {
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        if ([self validateChineseChar:s]) {
            if (length + 2 > index + 1) {
                return [self substringToIndex:chineseNum+zifuNum];
            }
            length += 2;
            chineseNum += 1;
        }else{
            if (length + 1 > index) {
                return [self substringToIndex:chineseNum+zifuNum];
            }
            length += 1;
            zifuNum += 1;
        }
    }
    return  [self substringToIndex:index];
}

- (NSString *)subBytesOfstringFromIndex:(NSInteger)index
{    
    NSInteger length = 0;
    NSInteger chineseNum = 0;
    NSInteger zifuNum = 0;
    for (NSInteger i = 0; i < [self length]; i++) {
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        if ([self validateChineseChar:s]) {
            if (length + 1 == index) {
                return [self substringFromIndex:chineseNum+zifuNum+1];
            }if (length + 2 > index) {
                return [self substringFromIndex:chineseNum+zifuNum];
            }
            length += 2;
            chineseNum += 1;
        }else{
            if (length + 1 > index) {
                return [self substringFromIndex:chineseNum+zifuNum];
            }
            length += 1;
            zifuNum += 1;
        }
    }
    return  [self substringFromIndex:index];
    
}

//检测中文或中文符号
- (BOOL)validateChineseChar:(NSString *)string
{
    NSString *nameRegEx = @"[\\u0391-\\uFFE5]";
    if (![string isMatchesRegularExp:nameRegEx]) {
        return NO;
    }
    return YES;
}
//检测中文
- (BOOL)validateChinese:(NSString *)string
{
    NSString *nameRegEx = @"[\u4e00-\u9fa5]";
    if (![string isMatchesRegularExp:nameRegEx]) {
        return NO;
    }
    return YES;
}

- (BOOL)isMatchesRegularExp:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return  [predicate evaluateWithObject:self];
}


@end
