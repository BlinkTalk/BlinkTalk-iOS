//
//  UIView+BlinkBgView.h
//  BlinkTalk
//
//  Created by Vicky on 2018/1/24.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@protocol CollectionViewTouchesDelegate <NSObject>

- (void)didTouchedBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event withBlock:(void  (^)(void))block;

@end

@interface UICollectionView (BlinkBgView)

@property (nonatomic, strong) ChatViewController  *chatVC;

@end
