//
//  SettingViewBuilder.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHPickView.h"

@interface SettingViewBuilder : NSObject

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZHPickView *resolutionRatioPickview;

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
