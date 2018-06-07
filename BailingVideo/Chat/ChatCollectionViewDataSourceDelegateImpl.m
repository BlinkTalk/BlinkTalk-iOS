//
//  ChatCollectionViewDataSourceDelegateImpl.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "ChatCollectionViewDataSourceDelegateImpl.h"
#import "ChatViewController.h"
#import "CommonUtility.h"

@interface ChatCollectionViewDataSourceDelegateImpl ()
{
    NSString *originalRemoteUserID;
}

@property (nonatomic, strong) ChatViewController *chatViewController;

@end

@implementation ChatCollectionViewDataSourceDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
    }
    
    return self;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.chatViewController.userIDArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.type = self.chatViewController.type;
    
    // Get info
    if ([self.chatViewController.userIDArray count] <= indexPath.row)
        return cell;
    
    NSString *streamId = [self.chatViewController.userIDArray objectAtIndex:indexPath.row];
    NSNumber *videoMute = [self.chatViewController.videoMuteForUids objectForKey:streamId];
    ChatCellVideoViewModel *model = [self.chatViewController.remoteViewArray objectAtIndex:indexPath.row];
    
    if (self.chatViewController.type == ChatTypeVideo)
    {
        if (videoMute.boolValue)
            cell.type = ChatTypeAudio;
        else
        {
            cell.type = ChatTypeVideo;
            if ([self.chatViewController.remoteViewArray count] <= indexPath.row)
                return cell;
            if (self.chatViewController.isSwitchCamera && indexPath.row == self.chatViewController.orignalRow)
                [cell.videoView addSubview:self.chatViewController.localVideoViewModel.cellVideoView];
            else
                [cell.videoView addSubview:model.cellVideoView];
        }
    }
    else
    {
        cell.type = ChatTypeAudio;
    }
    
    cell.nameLabel.text = model.userID;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.chatViewController.isOpenWhiteBoard)
        return;
    
    @synchronized (self)
    {
        NSInteger selectedRow = indexPath.row;
        ChatCellVideoViewModel *selectedViewModel = (ChatCellVideoViewModel *)self.chatViewController.remoteViewArray[selectedRow];
        ChatCell *cell = (ChatCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSString *bigStreamUseID = selectedViewModel.userID;
        if (self.chatViewController.isSwitchCamera)
        {
            if (selectedRow == self.chatViewController.orignalRow)
                bigStreamUseID = self.chatViewController.localVideoViewModel.userID;
        }
        
        if (self.chatViewController.isSwitchCamera)
        {
            if (selectedRow == self.chatViewController.orignalRow)
            {
                //本地: 恢复在大屏上显示
                BlinkVideoViewDisplayType type = [self.chatViewController.localVideoViewModel.userID isEqualToString:kDeviceUUID] ? Blink_VideoViewDisplay_CompleteView : Blink_VideoViewDisplay_CompleteView;
                
                if (self.chatViewController.observerIndex == Blink_User_Observer)
                    self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeRemoteVideoViewFrame:self.chatViewController.videoMainView.frame withUserID:self.chatViewController.localVideoViewModel.userID withDisplayType:type];
                else
                    self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeLocalVideoViewFrame:self.chatViewController.videoMainView.frame withDisplayType:type];
                
                DLog(@"LocalFrame:%@", NSStringFromCGRect(self.chatViewController.videoMainView.frame));
                [self.chatViewController.videoMainView addSubview:self.chatViewController.localVideoViewModel.cellVideoView];
                
                if (self.chatViewController.localVideoViewModel.avType == Blink_User_Only_Audio || self.chatViewController.localVideoViewModel.avType == Blink_User_Audio_Video_None)
                {
                    
                    self.chatViewController.localVideoViewModel.avatarView.frame = BigVideoFrame;
                    [self.chatViewController.videoMainView addSubview:self.chatViewController.localVideoViewModel.avatarView];
                    
                    self.chatViewController.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                }
                else
                    [self.chatViewController.localVideoViewModel.avatarView removeFromSuperview];
                
                //远端: 恢复显示在collection cell中
                selectedViewModel.cellVideoView = [self.chatViewController.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) withUserID:selectedViewModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                [cell.videoView addSubview:selectedViewModel.cellVideoView];
                
                
                if (selectedViewModel.avType == Blink_User_Only_Audio || selectedViewModel.avType == Blink_User_Audio_Video_None)
                {
                    selectedViewModel.avatarView.frame = SmallVideoFrame;
                    [selectedViewModel.cellVideoView addSubview:selectedViewModel.avatarView];
                    selectedViewModel.avatarView.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
                }
                else
                    [selectedViewModel.avatarView removeFromSuperview];
                
                self.chatViewController.isSwitchCamera = !self.chatViewController.isSwitchCamera;
            }
            else
            {
                //远端: 之前切换到大屏上的远端,先切换回原collection cell上
                UIView *formerRemoteVideoView = [self.chatViewController.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) withUserID:self.originalSelectedViewModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                [self.chatViewController.selectedChatCell.videoView addSubview:formerRemoteVideoView];
                
                if (self.originalSelectedViewModel.avType == Blink_User_Only_Audio || self.originalSelectedViewModel.avType == Blink_User_Audio_Video_None)
                {
                    self.originalSelectedViewModel.avatarView.frame = SmallVideoFrame;
                    [formerRemoteVideoView addSubview:self.originalSelectedViewModel.avatarView];
                    self.originalSelectedViewModel.avatarView.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
                }
                
                //远端: 当前点击的远端,切换到大屏
                self.originalSelectedViewModel = selectedViewModel;
                originalRemoteUserID = selectedViewModel.userID;
                selectedViewModel.cellVideoView = [self.chatViewController.blinkEngine changeRemoteVideoViewFrame:self.chatViewController.videoMainView.frame withUserID:selectedViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
                [self.chatViewController.videoMainView addSubview:selectedViewModel.cellVideoView];
                
                if (selectedViewModel.avType == Blink_User_Only_Audio || selectedViewModel.avType == Blink_User_Audio_Video_None)
                {
                    selectedViewModel.avatarView.frame = BigVideoFrame;
                    [selectedViewModel.cellVideoView addSubview:selectedViewModel.avatarView];
                    selectedViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                }
                else
                    [selectedViewModel.avatarView removeFromSuperview];
                
                //本地: 为在cell上铺满屏,根据所选本地分辨率判断宽高比例,切换到collection cell上
                if ([self.chatViewController.localVideoViewModel.userID isEqualToString:kDeviceUUID])
                {
                    if (self.chatViewController.deviceOrientaionBefore == UIDeviceOrientationPortrait) {
                        self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeLocalVideoViewFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                    }else{
                        self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeLocalVideoViewFrame:CGRectMake(0, 0, 120, 120) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                    }
                }
                else
                {
                    self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) withUserID:self.chatViewController.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
                }
                [cell.videoView addSubview:self.chatViewController.localVideoViewModel.cellVideoView];
                
                if (self.chatViewController.localVideoViewModel.avType == Blink_User_Only_Audio || self.chatViewController.localVideoViewModel.avType == Blink_User_Audio_Video_None)
                {
                    self.chatViewController.localVideoViewModel.avatarView.frame = SmallVideoFrame;
                    [cell.videoView.superview  addSubview:self.chatViewController.localVideoViewModel.avatarView];
                }
                else
                    [self.chatViewController.localVideoViewModel.avatarView removeFromSuperview];
            }
        }
        else
        {
            //远端: 根据远端设置的分辨率比例显示在大屏上
            self.originalSelectedViewModel = selectedViewModel;
            originalRemoteUserID = selectedViewModel.userID;
            
            selectedViewModel.cellVideoView = [self.chatViewController.blinkEngine changeRemoteVideoViewFrame:self.chatViewController.videoMainView.frame withUserID:selectedViewModel.userID withDisplayType:Blink_VideoViewDisplay_CompleteView];
            [self.chatViewController.videoMainView addSubview:selectedViewModel.cellVideoView];
            
            if (selectedViewModel.avType == Blink_User_Only_Audio || selectedViewModel.avType == Blink_User_Audio_Video_None)
            {
                selectedViewModel.avatarView.frame = BigVideoFrame;
                [selectedViewModel.cellVideoView addSubview:selectedViewModel.avatarView];
                selectedViewModel.avatarView.center = CGPointMake(selectedViewModel.cellVideoView.frame.size.width / 2, selectedViewModel.cellVideoView.frame.size.height / 2);
            }
            else
                [selectedViewModel.avatarView removeFromSuperview];
            
            //本地: 为了在cell上铺满屏,根据所选本地分辨率判断宽高比例,切换到collection cell上
            if ([self.chatViewController.localVideoViewModel.userID isEqualToString:kDeviceUUID])
            {
                if (self.chatViewController.deviceOrientaionBefore == UIDeviceOrientationPortrait) {
                    self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeLocalVideoViewFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                }else{
                    self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeLocalVideoViewFrame:CGRectMake(0, 0, 120, 120) withDisplayType:Blink_VideoViewDisplay_FullScreen];
                }
            }
            else
            {
                self.chatViewController.localVideoViewModel.cellVideoView = [self.chatViewController.blinkEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) withUserID:self.chatViewController.localVideoViewModel.userID withDisplayType:Blink_VideoViewDisplay_FullScreen];
            }
            [self.chatViewController.localVideoViewModel.avatarView removeFromSuperview];
            [cell.videoView addSubview:self.chatViewController.localVideoViewModel.cellVideoView];
            
            if (self.chatViewController.localVideoViewModel.avType == Blink_User_Only_Audio || self.chatViewController.localVideoViewModel.avType == Blink_User_Audio_Video_None)
            {
                self.chatViewController.localVideoViewModel.avatarView.frame =SmallVideoFrame;
                [cell.videoView.superview  addSubview:self.chatViewController.localVideoViewModel.avatarView];
                self.chatViewController.localVideoViewModel.avatarView.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
            }else
                [self.chatViewController.localVideoViewModel.avatarView removeFromSuperview];
            
            if (selectedViewModel.screenSharingStatus == 1 && selectedViewModel.everOnLocalView == 0) {
                [self.chatViewController.messageStatusBar showMessageBarAndHideAuto: NSLocalizedString(@"chat_Suggested_horizontal_screen_viewing", nil)];
                selectedViewModel.everOnLocalView = 1;
            }
            
            self.chatViewController.isSwitchCamera = !self.chatViewController.isSwitchCamera;
        }
        self.chatViewController.selectedChatCell = cell;
        self.chatViewController.orignalRow = selectedRow;
    }
}

@end
