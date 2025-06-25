//
//  AMapLocationPlugin.m
//  CMPCore
//
//  Created by lin on 16/1/8.
//
//

#import "AMapLocationPlugin.h"
#import <CoreLocation/CoreLocation.h>
#import "SyLocationManager.h"
#import <CMPLib/JSON.h>
#import "SyReverseGeocoder.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import "CMPLocationManager.h"
#import <CMPLib/KVOController.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPDevicePermissionHelper.h>


@interface AMapLocationPlugin()

@property (nonatomic,copy)NSString *callBackID;
@property (nonatomic,copy)NSString *mode;
@property (nonatomic,assign)BOOL isNeedInfo;
@property (nonatomic,assign)BOOL showSettingDialog;
@property (nonatomic,strong)CMPLocationManager *locationManager;
@property (nonatomic,strong)CMPLocationManager *singleLocationManager;

@property (nonatomic, weak) CMPNavigationController *navc;
@property (nonatomic,assign) BOOL isCanceled;

@end

@implementation AMapLocationPlugin

- (void)dealloc {
    [self.locationManager stopAndCleanUpdatingLocation];
    [self.singleLocationManager stopAndCleanUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.navc.willShowViewControllerAlwaysCallBackArr.count > 0) {
        [self.navc.willShowViewControllerAlwaysCallBackArr removeLastObject];
        if (self.navc.willShowViewControllerAlwaysCallBackArr.count == 0) {
            self.navc.willShowViewControllerAlwaysCallBackArr = nil;
        }
    }
}

- (void)getLocation:(CDVInvokedUrlCommand*)command {
   [self getLocation:command isNeedInfo:NO];
    
}

- (void)getLocationInfo:(CDVInvokedUrlCommand*)command {
    [self getLocation:command isNeedInfo:YES];
}

- (void)getLocation:(CDVInvokedUrlCommand *)command isNeedInfo:(BOOL)isNeedInfo {
    _isCanceled = NO;
    self.isNeedInfo = isNeedInfo;
    NSString *callbackId = command.callbackId;
    self.callBackID = callbackId;
    // mode : 1-单次定位,2-连续定位
    NSDictionary *dictionary = [command.arguments lastObject];
    NSLog(@"ks log --- %s -- params : %@",__func__,dictionary);
    NSString *aMode = dictionary[@"mode"];
    NSString *locationType = dictionary[@"locationType"];
    self.mode = @"1"; // 设置默认值
    CMPLocationManagerType aLocationType = CMPLocationManagerTypeAuto;
    if (![NSString isNull:aMode]) {
        self.mode = aMode;
    }
    if ([NSString isNotNull:locationType]) {
        aLocationType = locationType.intValue;
    }
    BOOL showSettingDialog = YES;
    if ([dictionary.allKeys containsObject:@"showSettingDialog"]) {
        showSettingDialog = [dictionary[@"showSettingDialog"]  boolValue];
    }
    self.showSettingDialog = showSettingDialog;
    if ([self.mode isEqualToString:@"1"]) {
        if (!self.singleLocationManager) {
            self.singleLocationManager = [CMPLocationManager locationManager];
        }
        self.singleLocationManager.locationManagerType = aLocationType;
        [self.singleLocationManager getSingleLocationWithCompletionBlock:[self handleLocationWithInfo:isNeedInfo callbackId:callbackId showAlert:showSettingDialog]];
    } else {
        if (!self.locationManager) {
            self.locationManager = [CMPLocationManager locationManager];
        }
        [self.locationManager  stopAndCleanUpdatingLocation];
        self.locationManager.locationManagerType = aLocationType;
        [self.locationManager getUpdatingLocationWithCompletionBlock:[self handleLocationWithInfo:isNeedInfo callbackId:callbackId showAlert:showSettingDialog]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        __weak typeof(self) weakSelf = self;
        __weak CMPBannerWebViewController *viewController = (CMPBannerWebViewController *)self.viewController;
       __weak  CMPNavigationController *navc = (CMPNavigationController *)viewController.navigationController;
        self.navc = navc;
        if ([navc isKindOfClass:[CMPNavigationController class]]) {
            CMPNavigationCallBack willShowViewControllerAlwaysCallBack = ^{
                if (navc.topViewController != viewController) {
                    [weakSelf.locationManager stopAndCleanUpdatingLocation];
                } else {
                    [weakSelf.locationManager getUpdatingLocationWithCompletionBlock:[weakSelf handleLocationWithInfo:isNeedInfo callbackId:callbackId showAlert:showSettingDialog]];
                }
            };
            [navc.willShowViewControllerAlwaysCallBackArr addObject:willShowViewControllerAlwaysCallBack];
        }
    }
    
}

-(void)stopLocation:(CDVInvokedUrlCommand*)command{
    _isCanceled = YES;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"code":@200,@"message":@"已停止定位"}];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)showPermissionGuide{
//    NSString *app_Name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//    NSString *message = [NSString stringWithFormat:SY_STRING(@"Sign_location_servicesSet_m3"), app_Name];
//    UIAlertView *alertView = [[CMPAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_goto_setting")] callback:^(NSInteger buttonIndex) {
//        if (buttonIndex == 1) { // 去设置
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        }
//    }];
//    [alertView show];
}

- (CMPLocationCompletionBlock)handleLocationWithInfo:(BOOL)isNeedInfo callbackId:(NSString *)callbackId showAlert:(BOOL)showAlert {
    __weak typeof(self) weakSelf = self;
    
    CMPLocationCompletionBlock completionBlock = ^(NSString *  _Nullable provider,AMapGeoPoint * _Nullable location, AMapReGeocode * _Nullable regeocode, NSError * _Nullable locationError, NSError * _Nullable searchError, NSError * _Nullable locationResultError) {
        if (weakSelf.isCanceled) return;
        if (locationError) {
            CLError errCode = locationError.code;
            if (showAlert &&errCode == kCLErrorDenied) {
                [weakSelf showPermissionGuide];
            }
            
            NSDictionary *errorDict = @{@"code":[NSNumber numberWithInt:errCode],@"message":SY_STRING(@"common_turnOnLocation")};
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
            [result setKeepCallbackAsBool:YES];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:callbackId];
            [weakSelf.locationManager stopUpdatingLocation];
            return;
        }
        
        if (searchError) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:28001], @"code",SY_STRING(@"common_failToFormatLocation"), @"message",@"",@"detail", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
            [result setKeepCallbackAsBool:YES];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:callbackId];
            return;
        }
        
        if (locationResultError) {
            if (![CMPDevicePermissionHelper isHasLocationPermission]) {
                [weakSelf showPermissionGuide];
            }
            NSDictionary *errorDict = @{@"code":[NSNumber numberWithInt:locationResultError.code],@"message":locationResultError.localizedDescription};
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
            [result setKeepCallbackAsBool:YES];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:callbackId];
            return;
        }
        
        NSDictionary *resultDict = nil;
        if (isNeedInfo) {
            SyAddress *address = [[SyAddress alloc] init];
            address.country = regeocode.addressComponent.country;
            address.provinceName =  regeocode.addressComponent.province;
            address.cityName = regeocode.addressComponent.city;
            address.districtName = regeocode.addressComponent.district;
            address.street = regeocode.addressComponent.township;///////
            address.nearestPOI =  regeocode.formattedAddress;
            address.citycode = regeocode.addressComponent.citycode;
            address.latitude = location.latitude;
            address.longitude = location.longitude;
            address.provider = provider;
            //    SyAddress *addressOne = [[SyAddress alloc] init];
            //
            //    addressOne.provinceName = la ? poi.province :province;
            //    addressOne.cityName = la ? poi.city:city;
            //    addressOne.districtName = poi.district;
            //    addressOne.street = poi.address;
            //    addressOne.nearestPOI = poi.name;
            //    addressOne.nearestPOI = poi.name;
            //    addressOne.citycode = poi.citycode;
            //    addressOne.latitude = poi.location.latitude;
            //    addressOne.longitude = poi.location.longitude;
            
            resultDict = [address deaultAddressDictionary];
        } else {
            NSString *longitude = [[NSNumber numberWithDouble:location.longitude] stringValue];
            NSString *latitude = [[NSNumber numberWithDouble:location.latitude] stringValue];
            NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:longitude, @"longitude", latitude, @"latitude", nil];
            resultDict = [NSDictionary dictionaryWithObjectsAndKeys:aDict, @"coordinate", provider,@"provider",nil];
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [result setKeepCallbackAsBool:YES];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:callbackId];
    };
    
    return completionBlock;
}

- (void)applicationWillEnterForeground {
    if ([self.mode isEqualToString:@"2"] && [self.viewController isViewControllerVisable]) {
        [self.locationManager getUpdatingLocationWithCompletionBlock:[self handleLocationWithInfo:self.isNeedInfo callbackId:self.callBackID showAlert:self.showSettingDialog]];
    }
}

- (void)applicationDidEnterBackground {
    if ([self.mode isEqualToString:@"2"]) {
        [self.locationManager stopAndCleanUpdatingLocation];
    }
}

@end
