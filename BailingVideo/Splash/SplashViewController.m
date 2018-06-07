//
//  SplashViewController.m
//  BlinkTalk
//
//  Created by LiuLinhong on 16/11/11.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "SplashViewController.h"
#import "BlinkTalkAppDelegate.h"

@interface SplashViewController ()

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadingLabel.text = NSLocalizedString(@"splash_loading", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BlinkTalkAppDelegate *appDelegate = (BlinkTalkAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isForcePortrait = YES;
    [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"Splash" sender:self];
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
 
 
@end
