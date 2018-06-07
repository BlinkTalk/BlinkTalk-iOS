//
//  SettingTableViewDelegateSourceImpl.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingTableViewDelegateSourceImpl : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
