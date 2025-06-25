//
//  EmailPlugin.m
//  CMPCore
//
//  Created by lin on 15/8/26.
//
//

#import "EmailPlugin.h"
#import "SyEmailComposeViewController.h"
#import "SyEmailForwardObject.h"
#import <CMPLib/NSData+Base64.h>
#import <CMPLib/CMPConstant.h>
@interface EmailPlugin()<MFMailComposeViewControllerDelegate>
{
    NSString *_callBackID;
}
@end

@implementation EmailPlugin

-(void)dealloc{
    [_callBackID release];
    _callBackID = nil;
    [super dealloc];
}

-(void)sendEmail:(CDVInvokedUrlCommand*)command{

    if ([SyEmailComposeViewController canSendMail] == NO) {
        NSDictionary *error= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:19002],@"code",SY_STRING(@"Email_NO_Config_Mailbox"),@"message",@"",@"detail", nil];
        CDVPluginResult *vresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error];
        [self.commandDelegate sendPluginResult:vresult callbackId:command.callbackId];
        return;
    }
    [_callBackID release];
    _callBackID = nil;
    _callBackID = [command.callbackId retain];
    NSDictionary *parameter = [command.arguments firstObject];
    if (parameter) {
        NSString *bodyStr = [parameter objectForKey:@"bodystr"];
        NSString *attaName = [parameter objectForKey:@"attaname"];
        NSString *attaDataStr = [parameter objectForKey:@"attadata"];
        NSData *attaData = [NSData base64Decode:attaDataStr];
        NSString *receiver = [parameter objectForKey:@"receiver"];

        SyEmailForwardObject *emailObject = [[SyEmailForwardObject alloc] init];
        emailObject.messageBodyString = bodyStr;
        emailObject.attachmentData = attaData;
        emailObject.attaName = attaName;
        emailObject.receiver = receiver;
        SyEmailComposeViewController *emailSendVC = [[SyEmailComposeViewController alloc] initWithEmailObject:emailObject];
        emailSendVC.presentViewController = self.viewController;
        [emailSendVC sendEmail];
        emailSendVC.mailComposeDelegate = self;
        [emailSendVC release];
        [emailObject release];
    }
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //    if (![[UIDevice currentDevice]networkAvailable]) {
    //        result = MFMailComposeResultFailed;
    //    }
    
    //应该判断网络是否可用
    NSString *msg;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"Email_Send_Cancel";
            CDVPluginResult *vresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
            [self.commandDelegate sendPluginResult:vresult callbackId:_callBackID];
            break;
        case MFMailComposeResultSaved:
            msg = @"Email_Save_Success";
            vresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
            [self.commandDelegate sendPluginResult:vresult callbackId:_callBackID];

            break;
        case MFMailComposeResultSent:
            msg = @"Email_Send_Success";
            vresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
            [self.commandDelegate sendPluginResult:vresult callbackId:_callBackID];

            break;
        case MFMailComposeResultFailed:
            msg = @"发送邮件失败";
             NSDictionary *error= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:19001],@"code",msg,@"message",@"",@"detail", nil];
            vresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error];
            [self.commandDelegate sendPluginResult:vresult callbackId:_callBackID];

            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
