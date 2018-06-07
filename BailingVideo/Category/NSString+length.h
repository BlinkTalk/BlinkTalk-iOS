//
//  NSString+length.h
//  Blink Talk
//
//  Created by Vicky on 2018/2/24.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (length)

- (NSInteger)getStringLengthOfBytes;
- (NSString *)subBytesOfstringToIndex:(NSInteger)index;
- (NSString *)subBytesOfstringFromIndex:(NSInteger)index;
- (NSString *)subStringWithString:(NSString *)string withLength:(NSInteger )count;

@end
