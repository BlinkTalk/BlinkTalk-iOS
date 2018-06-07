//
//  CommonUtility.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtility : NSObject


/**
 check file existing at path of url
 */
+ (BOOL)isFileExistsAtPath:(NSString *)url;

/**
 get data from plist file
 */
+ (NSArray *)getPlistArrayByplistName:(NSString *)plistName;

/**
 get random room number
 */
+ (NSInteger)getRandomNumber:(int)fromValue to:(int)toValue;

/**
 set button image
 */
+ (void)setButtonImage:(UIButton *)button imageName:(NSString *)name;


+ (NSString *)getRandomString;

+ (BOOL)isDownloadFileExists:(NSString *)fileName atPath:(NSString *)folderPath;

+ (NSString *)formatTimeFromDate:(NSDate *)date withFormat:(NSString *)format;

+ (NSString *)strimCharacter:(NSString *)userName withRegex:(NSString *)regex;

+ (NSString *)getdeviceName;

@end
