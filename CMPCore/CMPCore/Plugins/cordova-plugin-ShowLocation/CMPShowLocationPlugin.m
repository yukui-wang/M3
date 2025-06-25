//
//  CMPShowLocationPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/26.
//
//

#import "CMPShowLocationPlugin.h"
#import "CMPSingleLocationViewController.h"
#import "AppDelegate.h"
@interface CMPShowLocationPlugin ()<CMPSingleLocationViewControllerDelegate>
@property (nonatomic, copy)NSString *callbackId;

@end

@implementation CMPShowLocationPlugin
- (void)dealloc
{
    self.callbackId = nil;
    [super dealloc];
}
- (void)showLocation:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    NSDictionary *paramDict = [[command arguments] firstObject];
    CMPSingleLocationViewController *controller = [[CMPSingleLocationViewController alloc] init];
    controller.delegate = self;
    controller.lbsUrl = [paramDict objectForKey:@"lbsUrl"];
    controller.memberIconUrl = [paramDict objectForKey:@"memberIconUrl"];
//    controller.lbsUrl = @"http://10.5.6.240:88/seeyon/rest/cmplbs/1814357976477972035";
    AppDelegate *appDelegate =(AppDelegate *) self.appDelegate;
    [appDelegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
    [controller release];
    controller = nil;
}



#pragma mark CMPSingleLocationViewControllerDelegate
- (void)singleLocationViewControllerDisimss:(CMPSingleLocationViewController *)aViewController
{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    [aViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
