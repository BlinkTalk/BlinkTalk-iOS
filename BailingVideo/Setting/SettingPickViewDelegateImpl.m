//
//  SettingPickViewDelegateImpl.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "SettingPickViewDelegateImpl.h"
#import "SettingViewController.h"

static NSUserDefaults *settingPickViewUserDefaults = nil;

@interface SettingPickViewDelegateImpl ()

@property (nonatomic, strong) SettingViewController *settingViewController;

@end


@implementation SettingPickViewDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
        settingPickViewUserDefaults = [SettingViewController shareSettingUserDefaults];
    }
    return self;
}

#pragma mark - ZhpickVIewDelegate
- (void)toolbarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString selectedRow:(NSInteger)selectedRow
{
    NSInteger section = self.settingViewController.indexPath.section;
    switch (section)
    {
        case 0:
        {
            [settingPickViewUserDefaults setObject:@(selectedRow) forKey:Key_ResolutionRatio];
            
            if (self.settingViewController.resolutionRatioIndex != selectedRow)
            {
                self.settingViewController.resolutionRatioIndex = selectedRow;
                
                //max code rate
                NSDictionary *codeRateDictionary = self.settingViewController.codeRateArray[self.settingViewController.resolutionRatioIndex];
                //NSInteger min = [codeRateDictionary[Key_Min] integerValue];
                NSInteger max = [codeRateDictionary[Key_Max] integerValue];
                NSInteger defaultValue = [codeRateDictionary[Key_Default] integerValue];
                NSInteger step = [codeRateDictionary[Key_Step] integerValue];
                
                NSMutableArray *muArray = [NSMutableArray array];
                for (NSInteger temp = 0; temp <= max; temp += step)
                    [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];
                
                NSInteger defaultIndex = [muArray indexOfObject:[NSString stringWithFormat:@"%zd", defaultValue]];
                self.settingViewController.codeRateIndex = defaultIndex;
                [settingPickViewUserDefaults setObject:@(self.settingViewController.codeRateIndex) forKey:Key_CodeRate];
                
                //min code rate
                NSMutableArray *minArray = [NSMutableArray array];
                for (NSInteger tmp = 0; tmp <= max; tmp += step)
                    [minArray addObject:[NSString stringWithFormat:@"%zd", tmp]];
                
                NSInteger minCodeRateDefaultValue = [codeRateDictionary[Key_Min] integerValue];
                self.settingViewController.minCodeRateIndex = [minArray indexOfObject:[NSString stringWithFormat:@"%zd", minCodeRateDefaultValue]];
                [settingPickViewUserDefaults setObject:@(self.settingViewController.minCodeRateIndex) forKey:Key_CodeRateMin];
                
                //frame rate
                self.settingViewController.frameRateIndex = 0;
                [settingPickViewUserDefaults setObject:@(self.settingViewController.frameRateIndex) forKey:Key_FrameRate];
            }
        }
            break;
        default:
            break;
    }
    [settingPickViewUserDefaults synchronize];
    [self.settingViewController.settingViewBuilder.tableView reloadData];
}

- (void)toolbarCancelBtnHaveClick:(ZHPickView *)pickView
{
    NSInteger section = self.settingViewController.indexPath.section;
    switch (section)
    {
        case 0:
            [self.settingViewController.settingViewBuilder.resolutionRatioPickview setSelectedPickerItem:self.settingViewController.resolutionRatioIndex];
            break;
        default:
            break;
    }
}

@end
