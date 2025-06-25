//
//  CDVBarcodeScanner.m
//  CMPCore
//
//  Created by lin on 15/8/28.
//
//

#import "CDVBarcodeScanner.h"
#import "SyScanViewController.h"
#import "AppDelegate.h"
#import <CMPLib/NSData+Base64.h>
#import <CMPLib/CMPConstant.h>
#import "CMPChatManager.h"
#import "CMPRCChatViewController.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPMessageManager.h"
#import "CMPScanWebViewController.h"
#import "SyQRCodeController.h"
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPStringConst.h>
#import "CMPFaceManager.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/SvUDIDTools.h>
@interface CDVBarcodeScanner()<SyScanViewControllerDelegate>

@property (retain, nonatomic) SyScanViewController *scanViewController;

@end

@implementation CDVBarcodeScanner

- (void)dealloc {
    SY_RELEASE_SAFELY(_scanViewController);
    [super dealloc];
}

- (void)scan:(CDVInvokedUrlCommand*)command{
    [self startScanWithCommand:command autoDismiss:YES];
}

- (void)encode:(CDVInvokedUrlCommand*)command
{
    NSString *encodeString = command.arguments[0][@"data"];
    UIImage *codeImage =[SyScanViewController encode:encodeString];
    if (codeImage != nil) {
        NSData *data = UIImagePNGRepresentation(codeImage);
        NSMutableDictionary* resultDict = [[[NSMutableDictionary alloc] init] autorelease];
        NSString *base64Str = [NSData base64Encode:data];
        [resultDict setObject:base64Str forKey:@"image"];
        
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   messageAsDictionary:resultDict
                                   ];
        [[self commandDelegate] sendPluginResult:result callbackId:command.callbackId];
    }else{
        
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   messageAsString:@"encode failed"
                                   ];
        [[self commandDelegate] sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)openScanPage:(CDVInvokedUrlCommand*)command {
    NSString *url =  @"http://commons.m3.cmp/v1.0.0/m3-scan-page.html";
    UIViewController *currentVC = [UIViewController currentViewController];
    [[CMPMessageManager sharedManager] showScanViewWithUrl:url viewController:currentVC];
}

- (void)holdScan:(CDVInvokedUrlCommand*)command {
    [self startScanWithCommand:command autoDismiss:NO];
}

- (void)holdScanSendResult:(CDVInvokedUrlCommand*)command
{
    NSDictionary *paraDict = [command.arguments lastObject];
    NSString *message = [paraDict objectForKey:@"callbackVal"];
    
    if ([NSString isNull:message]) {
        NSDictionary *errorDict = @{@"code" : @"0",
                                    @"message" : @"Message为空",
                                    @"detail" : @""};
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        __weak typeof(self) weakSelf = self;
        CMPAlertView *alertView =
        [[CMPAlertView alloc] initWithTitle:nil
                                    message:message
                          cancelButtonTitle:SY_STRING(@"common_ok")
                          otherButtonTitles:nil
                                   callback:^(NSInteger buttonIndex) {
       
            if ([weakSelf.viewController isKindOfClass:[CMPScanWebViewController class]]) {
                CMPScanWebViewController *aScanWebViewController = (CMPScanWebViewController *)self.viewController;
                if (aScanWebViewController.scanImage) {
                    //说明是直接识别的图片，界面直接关闭吧  OA-211884
                    [weakSelf.viewController dismissViewControllerAnimated:YES completion:nil];
                    return ;
                }
            }
            [_scanViewController continueScan];
                                   }];
        [alertView show];
        CDVPluginResult* result = [CDVPluginResult  resultWithStatus: CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)closeScanWebViewController
{
    NSMutableArray *arr = [[self.viewController.navigationController.viewControllers mutableCopy] autorelease];
    if (arr.count > 1) {
        [arr enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([vc isMemberOfClass:[CMPScanWebViewController class]]) {
                [arr removeObject:vc];
            }
        }];
        self.viewController.navigationController.viewControllers = arr;
        return ;
    }
    [self.viewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)holdScanClose:(CDVInvokedUrlCommand *)command
{
    if ([self.viewController isKindOfClass:[CMPScanWebViewController class]]) {
        if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [self closeScanWebViewController];
            });
            return;
        }
        __weak typeof(self) weakSelf = self;
        CMPBannerWebViewController *aWebViewController = (CMPBannerWebViewController *)self.viewController;
        aWebViewController.willClose = YES;
        aWebViewController.didShowViewControllerCallBack = ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf closeScanWebViewController];
            });
        };
        aWebViewController.navigationController.delegate = aWebViewController;
    }
    else {
         [self.viewController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)startScanWithCommand:(CDVInvokedUrlCommand *)command autoDismiss:(BOOL)autoDismiss {
    // 如果当前viewController为CMPScanWebViewController
    if ([self.viewController isKindOfClass:[CMPScanWebViewController class]]) {
        CMPScanWebViewController *aScanWebViewController = (CMPScanWebViewController *)self.viewController;
        self.scanViewController = aScanWebViewController.scanViewController;
    }
    else {
        self.scanViewController = [SyScanViewController scanViewController];
        [self.viewController presentViewController:self.scanViewController animated:YES completion:^{
            
        }];
    }
    self.scanViewController.callBackID = command.callbackId;
    self.scanViewController.autoDismiss = autoDismiss;
    self.scanViewController.delegate = self;
    BOOL nativeHandleSpecialResult = YES;
    NSDictionary *arg = command.arguments.firstObject;
    if ([arg.allKeys containsObject:@"nativeHandleSpecialResult"]) {
        //8.0新增参数，判断是否有值，如果没有默认true
        nativeHandleSpecialResult = [arg[@"nativeHandleSpecialResult"] boolValue];
    }
    self.scanViewController.nativeHandleSpecialResult = nativeHandleSpecialResult;
    [self.scanViewController continueScan];
}

- (void)handAddGroupFinish:(SyScanViewController *)scanViewController info:(id)json success:(BOOL)bSuccess
{
    [self cmp_hideProgressHUD];
    [scanViewController dismissViewControllerAnimated:NO completion:^{
        
    }];
    if ([self.viewController isKindOfClass:NSClassFromString(@"CMPScanWebViewController")]) {
        [self.viewController.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
    
    if (!bSuccess) {
        [self cmp_showHUDWithText:json];
        return;
    }
    NSInteger aCode = [[json objectForKey:@"code"] integerValue];
    if (aCode== 200 || aCode == 6031) {
        [NSNotificationCenter.defaultCenter postNotificationName:CMPCloseCurrentViewAfterScanFinishedNoti object:nil];
        //延时解决退出CMPCloseCurrentViewAfterScanFinishedNoti这个view时遗留bug
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CMPTabBarViewController *tabBarViewController = [AppDelegate shareAppDelegate].tabBarViewController;
            CMPRCTargetObject *obj = [[[CMPRCTargetObject alloc]init] autorelease];
            obj.type  = ConversationType_GROUP;
            NSString *groupName = [[json objectForKey:@"groupName"] description];
            obj.title = groupName;
            obj.targetId = [json objectForKey:@"groupId"];
            obj.tabbar = tabBarViewController;
            UIViewController *selectedViewController = tabBarViewController.selectedViewController;
            if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)selectedViewController;
                obj.navigationController = nav;
                if ([nav.viewControllers.lastObject isKindOfClass:CMPRCChatViewController.class]) {
                    NSMutableArray *vcs = [NSMutableArray arrayWithArray:nav.viewControllers];
                    [vcs removeLastObject];
                    nav.viewControllers = vcs;
                }
            } else {
                UINavigationController *nav = (UINavigationController *)((CMPSplitViewController *)selectedViewController).detailNavigation;
                obj.navigationController = nav;
                if ([nav.viewControllers.lastObject isKindOfClass:CMPRCChatViewController.class]) {
                    NSMutableArray *vcs = [NSMutableArray arrayWithArray:nav.viewControllers];
                    [vcs removeLastObject];
                    nav.viewControllers = vcs;
                }
            }
            
            [[CMPChatManager sharedManager] showChatView:obj];
            obj = nil;
        });
    }
    else {
        NSString *message = [json objectForKey:@"message"];
        if ([NSString isNull:message]) {
            message = SY_STRING(@"scan_joingroup_error");
        }
        [self cmp_showHUDWithText:message];
    }
}

- (void)handAddGroup:(SyScanViewController *)scanViewController group:(NSString*)groupId {
    if (groupId) {
        [[CMPChatManager sharedManager] requestAddGroup:groupId start:^{
            [self cmp_showProgressHUD];
        } success:^(id json) {
            [self handAddGroupFinish:scanViewController info:json success:YES];
        } fail:^(id info) {
            [self handAddGroupFinish:scanViewController info:info success:NO];
        }];
    }
}

/**
 获取当前小时的时间戳，或者nextHour的时间戳，精确到小时
 nextHour = 0 当前小时，1表示下一个小时
 */
- (NSTimeInterval)getCurHourTS:(NSInteger)nextHour{
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour) fromDate:currentDate];
    [components setMinute:0];
    [components setSecond:0];
    if (nextHour>0) {
        [components setHour:components.hour + nextHour]; //增加几个小时
    }
    NSDate *hourDate = [calendar dateFromComponents:components];
    NSTimeInterval timestamp = [hourDate timeIntervalSince1970];
    return timestamp;
}

- (void)scanViewController:(SyScanViewController *)scanViewController didScanFinishedWithResult:(ZXParsedResult *)aResult
{
    NSString *str = [aResult description];
    
    //扫码命中调试模式
    if([NSString isNotNull:str] && [str hasPrefix:@"cmp-ios-action"]){
        //cmp-ios-action::reset-udid::md5加密字符串（当前小时时间戳）
        NSArray *arr = [str componentsSeparatedByString:@"::"];
        NSString *action = @"";
        if (arr.count>1) {
            action = arr[1];
        }
        if ([action isEqualToString:@"reset-udid"]) {//重置设备号
            NSString * curHour = [NSString stringWithFormat:@"%f",[self getCurHourTS:0]];
            NSString * nextHour = [NSString stringWithFormat:@"%f",[self getCurHourTS:1]];
            curHour = [curHour md5String];
            nextHour = [nextHour md5String];
            NSString *validHour = arr.lastObject;
            if ([curHour isEqualToString:validHour]
                ||[nextHour isEqualToString:validHour]) {//时间有效
                //弹框确认是否重置udid
                CMPAlertView *alertView =
                [[CMPAlertView alloc] initWithTitle:nil
                                            message:@"重置设备号不可恢复！\n重置后需要重启APP\n确定要重置设备号吗？"
                                  cancelButtonTitle:SY_STRING(@"common_cancel")
                                  otherButtonTitles:@[SY_STRING(@"common_confirm")]
                                           callback:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {//确认
                        NSString *oldUDID = [SvUDIDTools UDID];
                        BOOL remove = [SvUDIDTools removeUDIDFromKeyChain];
                        if (remove) {
                            NSString *newUDID = [SvUDIDTools UDID];
                            NSString *alertMsg = [NSString stringWithFormat:@"旧设备号:%@\n新设备号:%@\n(如果两次设备号相同，则无需再次重置设备号)",oldUDID,newUDID];
                            __weak typeof(self) weakSelf = self;
                            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:alertMsg preferredStyle:(UIAlertControllerStyleAlert)];
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定并重启APP" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                                exit(0);
                            }];
                            [alertVC addAction:action];
                            [self.viewController presentViewController:alertVC animated:NO completion:nil];
                        }else{
                            [[[CMPAlertView alloc] initWithTitle:nil message:@"重置失败，请重试" cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                                [scanViewController continueScan];//继续扫码
                            }] show];
                        }
                    }else{
                        [scanViewController continueScan];//继续扫码
                    }
                }];
                [alertView show];
                
            }else{
                [self cmp_showHUDWithText:@"二维码过期"];
                [scanViewController continueScan];
            }
        }
        return;
    }
    
    
    //先判断是否符合人脸二维码
    if ([[CMPFaceManager sharedInstance] isFaceEEQrCode:str]) {
        [self cmp_showProgressHUD];
        __weak typeof(self) weakSelf = self;
        [[CMPFaceManager sharedInstance] verifyQrCode:str inVC:scanViewController completion:^(BOOL success, CMPFaceErrorModel *errModel) {
            [self cmp_hideProgressHUD];
            if (errModel) {
//                if (errModel.errCode == 1001 && [errModel.errEnum isEqualToString:@"CLIENT_UNAUTHORIZED"]) {
//                    //faceManager中已做弹框处理，这里不toast提示
//                }else{
//                    [scanViewController cmp_showHUDWithText:errModel.errMsg];
//                }
                //延迟一秒后恢复重新扫描
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [scanViewController continueScan];
//                });
            }else{
                [weakSelf.viewController dismissViewControllerAnimated:NO completion:nil];
            }
        }];
        return;
    }
    
    if ([str length] > 0 && scanViewController.nativeHandleSpecialResult) {
        NSDictionary *json = [str JSONValue];
        if ([[[json objectForKey:@"type"] description] isEqualToString:@"zhixin"]) {
            [self handAddGroup:scanViewController group:[json objectForKey:@"targetid"]];
            return;
        }
    }
    
    NSMutableDictionary *resultDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSString *displayResultJsonStr = [[aResult.displayResult JSONValue] JSONRepresentation];
    if ([NSString isNotNull:displayResultJsonStr]) {
        [resultDict setObject:displayResultJsonStr forKey:@"text"];
    } else {
        [resultDict setObject:aResult.displayResult ?: @""  forKey:@"text"];
    }
    
    NSString *type = @"1";
    
    switch (aResult.type) {
        case kParsedResultTypeAddressBook:
            type = @"1";
            break;
        case kParsedResultTypeEmailAddress:
            type = @"2";
            break;
        case kParsedResultTypeProduct:
            type = @"3";
            break;
        case kParsedResultTypeURI:
            type = @"4";
            break;
        case kParsedResultTypeText:
            type = @"5";
            break;
        case kParsedResultTypeAndroidIntent:
            type = @"6";
            break;
        case kParsedResultTypeGeo:
            type = @"7";
            break;
        case kParsedResultTypeTel:
            type = @"8";
            break;
        case kParsedResultTypeSMS:
            type = @"9";
            break;
        case kParsedResultTypeCalendar:
            type = @"10";
            break;
        case kParsedResultTypeWifi:
            type = @"11";
            break;
        case kParsedResultTypeNDEFSMartPoster:
            type = @"12";
            break;
        case kParsedResultTypeMobiletagRichWeb:
            type = @"13";
            break;
        case kParsedResultTypeISBN:
            type = @"14";
            break;
        case kParsedResultTypeVIN:
            type = @"15";
            break;

        default:
            break;
    }
    [resultDict setObject:type forKey:@"type"];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    if (!scanViewController.autoDismiss) {
        [result setKeepCallbackAsBool:YES];
    }
    [self.commandDelegate sendPluginResult:result callbackId:scanViewController.callBackID];
    if (scanViewController.autoDismiss) {
        [self.viewController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)scanViewControllerScanFailed:(SyScanViewController *)scanViewController
{
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:18004],@"code",@"Scan failed",@"message",@"",@"detail", nil];
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsDictionary:errorDict
                               ];
    [self.commandDelegate sendPluginResult:result callbackId:scanViewController.callBackID];
//    [scanViewController.navigationController dismissViewControllerAnimated:NO completion:^{
//        if ([self.viewController isKindOfClass:NSClassFromString(@"CMPScanWebViewController")]) {
//            [self.viewController.navigationController popViewControllerAnimated:NO];
//        }
//    }];
}

- (void)scanViewControllerDidCanceled:(SyScanViewController *)scanViewController
{
    NSDictionary *errorDict= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:18005],@"code",@"Scan cancelled",@"message",@"",@"detail", nil];
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsDictionary: errorDict
                               ];
    [self.commandDelegate sendPluginResult:result callbackId:scanViewController.callBackID];
//    if ([self.viewController isKindOfClass:NSClassFromString(@"CMPScanWebViewController")]) {
////        [self.viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
//        self
//    }
}

@end
