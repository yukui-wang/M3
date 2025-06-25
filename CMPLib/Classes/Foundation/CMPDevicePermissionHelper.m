//
//  NSObject+CMPObject.m
//  CMPLib
//
//  Created by wujiansheng on 2016/10/28.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "CMPDevicePermissionHelper.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CMPConstant.h"
#import "CMPAlertView.h"
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>


@implementation CMPDevicePermissionHelper
//iOS 判断应用是否有使用相机的权限
+ (BOOL)hasPermissionsForCamera
{

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        NSLog(@"相机权限受限");
        NSString *app_Name = [[NSBundle mainBundle]
                              objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *alertTitle = [NSString stringWithFormat:SY_STRING(@"common_nocameraalert"),app_Name];
        [CMPDevicePermissionHelper showAlertWithTitle:SY_STRING(@"common_camera_unavailable") messsage:alertTitle];
        return NO;
    }
    return YES;
}

+ (BOOL)cheackPermissionsForCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}
//iOS 判断应用是否有使用相册的权限


+ (void)permissionsForPhotosTrueCompletion:(void (^)(void))trueCompletion
                           falseCompletion:(void (^)(void))falseCompletion
                                 showAlert:(BOOL)showAlert
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusNotDetermined: {
                    
                }
                    break;
                case PHAuthorizationStatusRestricted:
                case PHAuthorizationStatusDenied: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        falseCompletion();
                        if (showAlert) {
                            NSString *app_Name = [[NSBundle mainBundle]
                                                  objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                            
                            NSString *alertTitle = [NSString stringWithFormat:SY_STRING(@"common_nophotos"),app_Name];
                            [CMPDevicePermissionHelper showAlertWithTitle:SY_STRING(@"common_nophotostitle") messsage:alertTitle];
                        }
                    });
                }
                    break;
                case PHAuthorizationStatusAuthorized:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        trueCompletion();
                    });
                    break;
                default:
                    break;
            }
        }];
    }
    else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        falseCompletion();
        if (showAlert) {
            NSString *app_Name = [[NSBundle mainBundle]
                                  objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            
            NSString *alertTitle = [NSString stringWithFormat:SY_STRING(@"common_nophotos"),app_Name];
            [CMPDevicePermissionHelper showAlertWithTitle:SY_STRING(@"common_nophotostitle") messsage:alertTitle];
        }
    }
    else if (status == PHAuthorizationStatusAuthorized) {
        trueCompletion();
    }
}



+ (void)showAlertWithTitle:(NSString *)title messsage:(NSString *)msg {
    CMPAlertView *alertView = [[CMPAlertView alloc] initWithTitle:title
                                                          message:msg
                                                cancelButtonTitle:nil
                                                otherButtonTitles:[NSArray arrayWithObjects:SY_STRING(@"commom_ok"),SY_STRING(@"commom_setting"), nil]
                                                         callback:^(NSInteger buttonIndex) {
                                                             if (buttonIndex == 1) {
                                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                 
                                                             }
                                                             
                                                         }];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
    [alertView release];
    alertView = nil;

}

//麦克风权限
+ (void)microphonePermissionTrueCompletion:(void (^)(void))trueCompletion falseCompletion:(void (^)(void))falseCompletion
{
    AVAudioSession *sharedSession = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission permission = [sharedSession recordPermission];
    if (permission == AVAudioSessionRecordPermissionGranted) {
        if (trueCompletion) {
            trueCompletion();
        }
        return;
    }
    else if (permission == AVAudioSessionRecordPermissionDenied) {
        if (falseCompletion) {
            falseCompletion();
        }
        return;
    }
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            // 用户同意获取麦克风
            if (trueCompletion) {
                trueCompletion();
            }
        } else {
            // 用户不同意获取麦克风
            if (falseCompletion) {
                falseCompletion();
            }
        }
    }];
}

+ (void)cameraPermissionTrueCompletion:(void (^)(void))trueCompletion falseCompletion:(void (^)(void))falseCompletion
{
   
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
         if (falseCompletion) {
             falseCompletion();
         }
         return;
    }
    //获取访问相机权限时，弹窗的点击事件获取
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            // 用户同意获取麦克风
            if (trueCompletion) {
                trueCompletion();
            }
        } else {
            // 用户不同意获取麦克风
            if (falseCompletion) {
                falseCompletion();
            }
        }
    }];
}

//位置权限
+ (BOOL)isHasLocationPermission
{
    if (![CLLocationManager locationServicesEnabled]) {
        return NO;
    }
    
     CLAuthorizationStatus  status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined ||status == kCLAuthorizationStatusAuthorizedAlways ||status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return YES;
    }
    return NO;
}



@end
