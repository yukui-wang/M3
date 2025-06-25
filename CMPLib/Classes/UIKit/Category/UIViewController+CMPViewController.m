//
//  UIViewController+SyViewController.m
//  M1Core
//
//  Created by admin on 12-10-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "UIViewController+CMPViewController.h"
#import <objc/runtime.h>
#import "MBProgressHUD.h"
#import "CMPConstant.h"
#import "CMPAlertView.h"
#import "SOSwizzle.h"
#import "CMPDevicePermissionHelper.h"
#import <Photos/Photos.h>
#import "Masonry.h"
#import <AVFoundation/AVCaptureDevice.h>

@class CMPTabBarViewController;

static const void *CmpCtrlIsRootKey = &CmpCtrlIsRootKey;

@implementation UIViewController (CMPViewController)

//- (UIApplication *)appDelegate {
//    return (id)[UIApplication sharedApplication].delegate;
//}

- (UIInterfaceOrientation)statusBarOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)setIsInPopoverController:(BOOL)isInPopoverController
{
    objc_setAssociatedObject(self,
                             @selector(isInPopoverController),
                             [NSNumber numberWithBool:isInPopoverController],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isInPopoverController
{
    NSNumber *wrappedBool = objc_getAssociatedObject(self, @selector(isInPopoverController));
    BOOL userValue = [wrappedBool boolValue];
    return userValue ?: [[self parentViewController] isInPopoverController] ?: [self.navigationController isInPopoverController];
}

-(void)setIsRoot:(BOOL)isRoot
{
    objc_setAssociatedObject(self,
                             CmpCtrlIsRootKey,
                             [NSNumber numberWithBool:isRoot],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isRoot
{
    NSNumber *wrappedBool = objc_getAssociatedObject(self, CmpCtrlIsRootKey);
    BOOL userValue = [wrappedBool boolValue];
    return userValue;
}

- (BOOL)isVisible {
    return (self.isViewLoaded && self.view.window);
}

+ (UIViewController*)currentViewController {
    UIViewController* viewController = [self keyWindow].rootViewController;
    return [UIViewController findBestViewController:viewController];
}

+ (UIViewController*) findBestViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        return [UIViewController findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController findBestViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[CMPTabBarViewController class]]) {
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController findBestViewController:svc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}

+ (UIWindow *)keyWindow {
    
    id delegate =  [UIApplication sharedApplication].delegate;
    if ([delegate respondsToSelector:@selector(window)]) {
        UIWindow *window = [delegate performSelector:@selector(window)];
        return window;
    }
    return nil;
}

- (void)showAlertMessage:(NSString *)message {
    [self showAlertWithTitle:nil message:message cancelTitle:SY_STRING(@"common_ok")];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cacelTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString *formatMessage = [[[NSAttributedString alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil] autorelease];
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:[formatMessage string] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cacel = [UIAlertAction actionWithTitle:cacelTitle style:UIAlertActionStyleCancel handler:nil];
//        [alert addAction:cacel];
//        [self presentViewController:alert animated:YES completion:nil];
        //修改 bug OA-172943
        UIAlertView *aAlertView = [[[CMPAlertView alloc] initWithTitle:title message:[formatMessage string] cancelButtonTitle:cacelTitle otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
        }] autorelease];
        [aAlertView show];
    });
}

- (BOOL)isViewControllerVisable {
    return (self.isViewLoaded && self.view.window);
}


+ (void)load {
    SOSwizzleInstanceMethod([self class], @selector(presentViewController:animated:completion:), @selector(p_cmp_presentViewController:animated:completion:));
    SOSwizzleInstanceMethod([self class], @selector(viewWillAppear:), @selector(cmp_viewWillAppear:));
    SOSwizzleInstanceMethod([self class], @selector(viewDidAppear:), @selector(cmp_viewDidAppear:));
}

- (void)p_cmp_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    //解决xcode11编译后在iOS13里modal不是全屏的问题
    if (viewControllerToPresent.modalPresentationStyle == UIModalPresentationPageSheet) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    if ([viewControllerToPresent isKindOfClass:[UIImagePickerController class]]) {
        UIImagePickerController *ctrl = (UIImagePickerController *)viewControllerToPresent;
        switch (ctrl.sourceType) {
            case 0://照片图库                                                          
            {
                BOOL needToAuth = NO;
                PHAuthorizationStatus status;
                if (@available(iOS 14, *)) {
                    status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
                    if (status != PHAuthorizationStatusAuthorized && status != PHAuthorizationStatusLimited) {
                        needToAuth = YES;
                    }
                } else {
                    status = [PHPhotoLibrary authorizationStatus];
                    if (status != PHAuthorizationStatusAuthorized) {
                        needToAuth = YES;
                    }
                }
                if (needToAuth) {
                    UIView *aview = [[UIView alloc] init];
                    aview.backgroundColor = [UIColor whiteColor];
                    [viewControllerToPresent.view addSubview:aview];
                    CGFloat _topSp = 44 + [UIApplication sharedApplication].statusBarFrame.size.height;
                    [aview mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.bottom.right.offset(0);
                        make.top.offset(_topSp);
                    }];
                    [self dispatchAsyncToMain:^{
                        NSString *boundName = [[NSBundle mainBundle]
                                               objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                        NSString *message = [NSString stringWithFormat:SY_STRING(@"common_nophotos"),boundName];
                        CMPAlertView *alertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"common_nophotostitle") message:message cancelButtonTitle:nil
                                                                   otherButtonTitles:[NSArray arrayWithObjects:SY_STRING(@"commom_ok"),SY_STRING(@"commom_setting"), nil] callback:^(NSInteger buttonIndex) {
                                                                       if (buttonIndex == 1) {
                                                                           NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                           if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                                               [[UIApplication sharedApplication] openURL:url];
                                                                           }
                                                                       }
                                                                       else {
                                                                       }
                                                                   }];
                        
                        [alertView show];
                        alertView = nil;
                    }];
                }
            }
                break;
            case 1://拍照录像
            {
                BOOL needToAuth = NO;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
                {
                    needToAuth = YES;
                }
                if (needToAuth) {
                    [self dispatchAsyncToMain:^{
                        NSString *boundName = [[NSBundle mainBundle]
                                               objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                        NSString *message = [NSString stringWithFormat:SY_STRING(@"common_nocameraalert"),boundName];
                        CMPAlertView *alertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"common_camera_unavailable") message:message cancelButtonTitle:nil
                                                                   otherButtonTitles:[NSArray arrayWithObjects:SY_STRING(@"commom_ok"),SY_STRING(@"commom_setting"), nil] callback:^(NSInteger buttonIndex) {
                                                                       if (buttonIndex == 1) {
                                                                           NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                           if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                                               [[UIApplication sharedApplication] openURL:url];
                                                                           }
                                                                       }
                                                                       else {
                                                                       }
                                                                   }];
                        
                        [alertView show];
                        alertView = nil;
                    }];
                }
            }
                break;

            default:
                break;
        }
    }
    [self p_cmp_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

/// 原来的present方法。因为我们交换了原始的present方法，将原始的方法默认present的模式设为了全屏的，如果想使用原始的并且可以自定义模式的就用这个方法
- (void)cmp_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    //
    [self p_cmp_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

-(void)cmp_viewWillAppear:(BOOL)animated
{
    [self cmp_viewWillAppear:animated];
    
    //ks fix -- V5-43431 为了关闭快捷入口
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_viewWillAppear" object:self];
    //end
}

-(void)cmp_viewDidAppear:(BOOL)animated
{
    [self cmp_viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_viewDidAppear" object:self];
}

@end
