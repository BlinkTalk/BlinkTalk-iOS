//
//  LoginTextFieldDelegateImpl.m
//  BlinkTalk
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Bailing Cloud. All rights reserved.
//

#import "LoginTextFieldDelegateImpl.h"
#import "LoginViewController.h"
#import "NSString+length.h"


@interface LoginTextFieldDelegateImpl ()

@property (nonatomic, strong) LoginViewController *loginViewController;

@end


@implementation LoginTextFieldDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.loginViewController = (LoginViewController *) vc;
    }
    return self;
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.origin.x, 0, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(0, 186, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
 
- (BOOL)textFieldShouldReturn:(UITextField *)aTextfield
{
    if (self.loginViewController.isRoomNumberInput) {
        [self.loginViewController joinRoomButtonPressed:self.loginViewController.loginViewBuilder.joinRoomButton];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.loginViewController.loginViewBuilder.userNameTextField])
    {
        NSString *tobeString = textField.text;
        if ([tobeString getStringLengthOfBytes] > KMaxInpuNumber)
        {
        }
    }
    return YES;
}

#pragma mark - validate for username
- (BOOL)validateUserName:(NSString *)userName withRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:userName];
}

- (BOOL)isChineseOfLatticeInput:(NSString *)character
{
        NSString *other = @"➋➌➍➎➏➐➑➒";     //九宫格的输入值
        NSString * regex;
        regex = @"^[A-Za-z0-9\u4e00-\u9fa5()]*$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if([other rangeOfString:character].location != NSNotFound)
        {
            return YES;
        }
        BOOL isMatch = [pred evaluateWithObject:character];
        return isMatch;
}

@end
