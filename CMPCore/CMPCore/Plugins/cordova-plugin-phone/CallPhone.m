//
//  CallPhone.m
//  HelloCordova
//
//  Created by lin on 15/8/10.
//
//

#import "CallPhone.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SyMFMailComposeViewController.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIViewController+CMPViewController.h>

@interface CallPhone()<MFMessageComposeViewControllerDelegate>
{
}
@end

@implementation CallPhone

- (void)dealloc
{
    [super dealloc];
}

- (void) call:(CDVInvokedUrlCommand*)command
{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *phoneNumber = [parameter objectForKey:@"phonenumber"];
    if (phoneNumber.length > 0) {
        [self callPhone:phoneNumber];
    }
}

- (void)send:(CDVInvokedUrlCommand*)command
{
    NSDictionary *parameter = [command.arguments firstObject];
    NSString *phoneNumber = [parameter objectForKey:@"phonenumber"];
    if (phoneNumber.length > 0) {
        [self sendSMS:phoneNumber];
    }
}

- (void)callPhone:(NSString *)phoneNumber
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:whitespace];
    
    if ([phoneNumber isEqualToString:@""] == NO && phoneNumber != nil) {
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {/*[NSString stringWithFormat:@"tel:130-032-2837"]*/
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        [NSString stringWithFormat:@"tel://%@",phoneNumber]]];
        } else {
            [self alertWithTitle:nil msg:SY_STRING(@"device_not_telephone") tag:11];
        }
    }
}

- (void)sendSMS:(NSString *)phoneNumber
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    NSLog(@"can send SMS [%d]", [messageClass canSendText]);
    
    if (messageClass != nil) {
        if ([messageClass canSendText]) {
            [self displaySMSWithMessageBody:@"" phoneNumber:phoneNumber];// 默认内容
        }
        else {
            [self alertWithTitle:nil msg:SY_STRING(@"device_not_sms") tag:11];
        }
    }
    else {
        [self alertWithTitle:nil msg:SY_STRING(@"device_ios_low") tag:11];
    }
}

- (void)displaySMSWithMessageBody:(NSString *)messageBody phoneNumber:(NSString *)aNumberStr
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate= self;
    picker.body = messageBody; // 默认信息内容
    // 默认收件人(可多个)
    picker.recipients = [NSArray arrayWithObjects:aNumberStr, nil];
    //	[_viewControllerpresentViewController:picker animated:YES completion:nil];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        [self.viewController cmp_presentViewController:picker animated:YES completion:nil];
    }
    else {
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }
    [picker release];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_SMSViewWillShow object:nil];
}

- (void)alertWithTitle:(NSString *)aTitle msg:(NSString *)aMsg tag:(NSInteger)aTag
{
    UIAlertView *vAlertView = [[UIAlertView alloc] initWithTitle:nil message:aMsg delegate:nil cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil, nil];
    [vAlertView show];
    [vAlertView release];
    vAlertView = nil;
}


#pragma mark- MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    NSString  *msg;
    switch (result) {
        case MessageComposeResultCancelled:
            msg = SY_STRING(@"common_cancelSending");
            break;
            
        case MessageComposeResultSent:
            msg = SY_STRING(@"common_send_success");
            [self alertWithTitle:nil msg:msg tag:11];
            break;
        case MessageComposeResultFailed:
            msg = SY_STRING(@"common_send_fail");
            [self alertWithTitle:nil msg:msg tag:11];
            break;
        default:
            break;
    }
    NSLog(@"发送结果：%@", msg);
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_SMSViewWillHide object:nil];

}

@end
