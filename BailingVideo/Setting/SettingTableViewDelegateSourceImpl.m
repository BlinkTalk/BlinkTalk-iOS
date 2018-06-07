//
//  SettingTableViewDelegateSourceImpl.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "SettingTableViewDelegateSourceImpl.h"
#import "SettingViewController.h"

@interface SettingTableViewDelegateSourceImpl ()

@property (nonatomic, strong) SettingViewController *settingViewController;

@end


@implementation SettingTableViewDelegateSourceImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.settingViewController.indexPath = indexPath;
    NSInteger section = [indexPath section];
    [self.settingViewController.settingViewBuilder.resolutionRatioPickview remove];
    ZHPickView *pickView;
    switch (section)
    {
        case 0:
            pickView = self.settingViewController.settingViewBuilder.resolutionRatioPickview;
            [pickView show];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingViewController.sectionNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *identifer = [NSString stringWithFormat:@"Cell%zd%zd", section, row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    switch (section)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.settingViewController.resolutionRatioArray[self.settingViewController.resolutionRatioIndex]];
        }
            break;
        case 1:
        {
            [cell.contentView addSubview:self.settingViewController.gpuSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_gpu_filter", nil);
        }
            break;
        case 2:
        {
            [cell.contentView addSubview:self.settingViewController.quicSwitch];
            cell.textLabel.text = @"QUIC";
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return NSLocalizedString(@"setting_resolution_ratio", nil);
        case 1:
            return NSLocalizedString(@"setting_local_video", nil);
        case 2:
            return NSLocalizedString(@"setting_media_connectiontype", nil);
        default:
            break;
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

@end
