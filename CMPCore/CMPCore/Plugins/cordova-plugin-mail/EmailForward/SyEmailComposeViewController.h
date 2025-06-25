//
//  SyEmailComposeViewController.h
//  M1Core
//
//  Created by kaku_songu on 14-7-29.
//
//

#import <MessageUI/MessageUI.h>
#import "SyEmailForwardObject.h"

@interface SyEmailComposeViewController : MFMailComposeViewController<MFMailComposeViewControllerDelegate>

@property (nonatomic,retain) SyEmailForwardObject *emailObject;
@property (nonatomic,assign) UIViewController *presentViewController;

-(id)initWithEmailObject:(SyEmailForwardObject *)object;
-(void)sendEmail;

@end
