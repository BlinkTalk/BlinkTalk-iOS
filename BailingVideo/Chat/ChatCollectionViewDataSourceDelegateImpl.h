//
//  ChatCollectionViewDataSourceDelegateImpl.h
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatCellVideoViewModel.h"

@interface ChatCollectionViewDataSourceDelegateImpl : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) ChatCellVideoViewModel *originalSelectedViewModel;

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
