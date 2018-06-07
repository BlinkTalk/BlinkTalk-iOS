//
//  ZHPickView.h
//  BlinkTalk
//
//  Created by LiuLinhong on 16/11/11.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHPickView;

@protocol ZHPickViewDelegate <NSObject>

@optional
- (void)toolbarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString selectedRow:(NSInteger)selectedRow;
- (void)toolbarCancelBtnHaveClick:(ZHPickView *)pickView;

@end


@interface ZHPickView : UIView

@property (nonatomic,weak) id<ZHPickViewDelegate> delegate;

/**
 *  通过plistName添加一个pickView
 *  @param plistName          plist文件的名字
 *  @param isHaveNavControler 是否在NavControler之内
 *  @return 带有toolbar的pickview
 */
- (instancetype)initPickviewWithPlistName:(NSString *)plistName isHaveNavControler:(BOOL)isHaveNavControler;

/**
 *  通过plistName添加一个pickView
 *  @param array              需要显示的数组
 *  @param isHaveNavControler 是否在NavControler之内
 *  @return 带有toolbar的pickview
 */
- (instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler;

/**
 *  通过时间创建一个DatePicker
 *  @param date               默认选中时间
 *  @param isHaveNavControler是否在NavControler之内
 *  @return 带有toolbar的datePicker
 */
- (instancetype)initDatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler;

/**
 通过给定值生成picker选项

 @param min 最小值
 @param max 最大值
 @param def 默认值
 @param step 步长
 @return 带有toolbar的pickview
 */
- (instancetype)initPickerWithMinValue:(NSInteger)min max:(NSInteger)max defaultValue:(NSInteger)defaultValue step:(NSInteger)step isHaveNavControler:(BOOL)isHaveNavControler;

/**
 *  移除本控件
 */
- (void)remove;

/**
 *  显示本控件
 */
- (void)show;

/**
 *  设置PickView的颜色
 */
- (void)setPickViewColer:(UIColor *)color;

/**
 *  设置toobar的文字颜色
 */
- (void)setTintColor:(UIColor *)color;

/**
 *  设置toobar的背景颜色
 */
- (void)setToolbarTintColor:(UIColor *)color;

/**
 *  设置当前选项
 */
- (void)setSelectedPickerItem:(NSInteger)index;

- (void)setMin:(NSInteger)min max:(NSInteger)max defaultValue:(NSInteger)defaultValue step:(NSInteger)step;

@end
