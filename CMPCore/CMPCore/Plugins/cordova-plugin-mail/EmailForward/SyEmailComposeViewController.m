//
//  SyEmailComposeViewController.m
//  M1Core
//
//  Created by kaku_songu on 14-7-29.
//
//

#import "SyEmailComposeViewController.h"
#import "AppDelegate.h"

@implementation SyEmailComposeViewController

- (void)dealloc
{
    self.presentViewController = nil;
    self.mailComposeDelegate = nil;
    [_emailObject release];
    [super dealloc];
}


-(id)initWithEmailObject:(SyEmailForwardObject *)object
{
    self = [super init];
    if (self) {
        self.emailObject = object;
        [self loadEmailObject];
    }
    return self;
}


-(void)loadEmailObject
{
    self.subject = _emailObject.subjectString;
    self.toRecipients = nil;
//    self.mailComposeDelegate = self;
    if (_emailObject.attachmentData && _emailObject.attachmentType) {
        [self addAttachmentData:_emailObject.attachmentData
                       mimeType:@""
                       fileName:_emailObject.attaName];
    }
    
    if (_emailObject.messageBodyString.length > 0) {
        [self setMessageBody:_emailObject.messageBodyString isHTML:YES];
    }
    if (![NSString isNull:_emailObject.receiver]) {
        [self setToRecipients:[NSArray arrayWithObject:_emailObject.receiver]];
    }
}



-(void)sendEmail
{
    Class mailClass = (NSClassFromString(@"SyEmailComposeViewController"));
    
    if (mailClass != nil) {
        
        if ([mailClass canSendMail]) {
            
            [self displayComposerSheet];
        }
        else {
            
            [self launchMailAppOnDevice];
        }
    }
    else {
        
        [self launchMailAppOnDevice];
    }
}



-(void)dismissComposerSheet
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




-(void)displayComposerSheet
{
    //OA-128847 M3-IOS端：语音小致查找人员，人员信息卡片点击发邮件，未成功进入发邮件界面，点击后未有反应
//    AppDelegate *delegate =  (AppDelegate *) [UIApplication sharedApplication].delegate;
//    [delegate.window.rootViewController presentViewController:self animated:YES completion:nil];
    [self.presentViewController presentViewController:self animated:YES completion:nil];
}


-(void)launchMailAppOnDevice
{
    NSString *email = [NSString stringWithFormat:@"mailto:subject=%@&body=%@", _emailObject.subjectString,_emailObject.messageBodyString];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
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
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSaved:
            msg = @"Email_Save_Success";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSent:
            msg = @"Email_Send_Success";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultFailed:
            msg = @"Email_Send_Fail";
            [self alertWithTitle:nil msg:msg];
            break;
        default:
            break;
    }
    
    [self dismissComposerSheet];
}



- (void)alertWithTitle:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:SY_STRING(@"common_ok")
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}






- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}



@end
