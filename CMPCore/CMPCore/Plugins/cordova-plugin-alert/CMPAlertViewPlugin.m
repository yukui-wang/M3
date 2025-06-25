//
//  CMPAlertViewPlugin.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/25.
//
//

#import "CMPAlertViewPlugin.h"
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/NSObject+CMPHUDView.h>
@interface CMPAlertViewPlugin()
{
    NSString *_callbackId;
}
@end

@implementation CMPAlertViewPlugin

- (void)dealloc
{
    _callbackId = nil;
    [super dealloc];
}
//>4.5.7才有
- (void)showToast:(CDVInvokedUrlCommand *)command
{
    id obj = [command.arguments lastObject];
    if ([obj isKindOfClass:NSString.class]) {
        NSString *msg = obj;
        [self.class showTopToast:msg];//确保最顶层弹出
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }else{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
        
}
- (void)showAlertView:(CDVInvokedUrlCommand *)command
{
    _callbackId = command.callbackId;
    NSDictionary *aDict = [command.arguments lastObject];
    NSString *title = SY_STRING(@"common_prompt"),*message = @"";
    NSMutableArray *otherButtonTitles = [NSMutableArray arrayWithCapacity:2];
    if (aDict) {
        NSString *titleStr = [aDict objectForKey:@"title"];
        if (![NSString isNull:titleStr ]) {
            title = titleStr;
        }
        NSString *msg = [aDict objectForKey:@"message"];
        if (![NSString isNull:msg ]) {
            message = msg;
        }
        [otherButtonTitles removeAllObjects];
        [otherButtonTitles addObjectsFromArray:[aDict objectForKey:@"buttonTitles"]];
    }
    if ([message containsString:@"<br/>"]) {
        message = [message stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    }
    CMPAlertView *alertView = [[CMPAlertView alloc]initWithTitle:title message:message cancelButtonTitle:NULL otherButtonTitles:otherButtonTitles callback:^(NSInteger buttonIndex) {
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:buttonIndex];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
    [alertView show];
    [alertView release];
}

+ (void)showTopToast:(NSString *)message {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window cmp_showHUDWithText:message];
    return;
    /*
    UILabel *toastLabel = [[UILabel alloc] init];
    toastLabel.backgroundColor = [UIColor blackColor];
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.font = [UIFont systemFontOfSize:14.0];
    toastLabel.text = message;
    toastLabel.alpha = 0.9;
    toastLabel.layer.cornerRadius = 15;
    toastLabel.clipsToBounds = true;
    
    [window addSubview:toastLabel];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
    CGSize stringSize = [message sizeWithAttributes:attributes];
    CGFloat stringWidth = stringSize.width;
    
    [toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(window);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(stringWidth + 30);
    }];
    
    [UIView animateWithDuration:2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toastLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [toastLabel removeFromSuperview];
    }];
     */
}

@end
