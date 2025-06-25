//
//  SYLocationManager.m
//  M1Core
//
//  Created by Aries on 14-3-7.
//
//

#import "SyLocationManager.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPCore.h>

@interface SyLocationManager ()<MAMapViewDelegate,CLLocationManagerDelegate>

@end

@implementation SyLocationManager
{
    MAMapView *_mapView;
    CLLocationManager *_manager;
}

- (id)init
{
    self = [super init];
    if(self){
        [[AMapServices sharedServices] setEnableHTTPS:YES];
        [AMapServices sharedServices].apiKey = [CMPCommonManager lbsAPIKey];
        
        [MAMapView updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
        [MAMapView updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
        
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _mapView.mapLanguage = [CMPCore language_ZhCN]?@0:@1;
        _mapView.delegate = self;
    }
    return  self;
}

- (void)dealloc
{
    _mapView.delegate = nil;
    [_mapView release];
    _mapView = nil;
    
    _manager.delegate = nil;
    [_manager release];
    _manager = nil;
    
    [super dealloc];
}

//本地总定位服务是否开启
- (BOOL)locationServiceEnable
{
    return [CLLocationManager locationServicesEnabled];
}

//检查本应用程序的定位是否被打开
- (void)checkThisAppLocationServiceEnable
{
    if(!_manager){
        _manager = [[CLLocationManager alloc] init];
    }
    if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_manager requestWhenInUseAuthorization];
    }
    _manager.delegate = self;
    [_manager startUpdatingLocation];
}

- (void)startUpdatingLocation
{
    [self checkThisAppLocationServiceEnable];
}

- (void)stopUpdatingLocation
{
    [_manager stopUpdatingLocation];
    _manager.delegate = nil;
    if(_mapView && _mapView.showsUserLocation){
        _mapView.showsUserLocation = NO;
    }
}

- (void)cancelUpdatingLocation
{
    [_manager stopUpdatingLocation];
    _manager.delegate = nil;
    [_manager release];
    _manager = nil;
}

- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView
{
    
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if(_delegate && [_delegate respondsToSelector:@selector(locationManager:didUpdateLocation:)]){
        [_delegate locationManager:self didUpdateLocation:userLocation.location];
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    if(_delegate && [_delegate respondsToSelector:@selector(locationManager:didUpdateLocation:)]){
        [_delegate locationManager:self didUpdateLocation:userLocation.location];
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if(_delegate && [_delegate respondsToSelector:@selector(locationManager:didFailWithError:)]){
        [_delegate locationManager:self didFailWithError:error];
    }
}
/*
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_manager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusAuthorized:{
            [self startUpdatingLocation];
            break;
        }
//        case kCLAuthorizationStatusAuthorizedAlways:{
//            [self startUpdatingLocation];
//            break;
//        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            [self startUpdatingLocation];
            break;
        }
        default:
            break;   
    }
}
*/
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    [_manager stopUpdatingLocation];
    
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            if (_delegate  && [_delegate respondsToSelector:@selector(locationManager:thisAppLocationServiceEnable:errorCode:)]) {
                [_delegate  locationManager:self thisAppLocationServiceEnable:NO errorCode:kCLErrorDenied];
                return;
            }
            errorString = @"Access to Location Services denied by user";
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
             errorString = @"Location data unavailable";
            if (_delegate  && [_delegate respondsToSelector:@selector(locationManager:thisAppLocationServiceEnable:errorCode:)]) {
                [_delegate  locationManager:self thisAppLocationServiceEnable:NO errorCode:kCLErrorLocationUnknown];
                return;
            }
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            if (_delegate  && [_delegate respondsToSelector:@selector(locationManager:thisAppLocationServiceEnable:errorCode:)]) {
                [_delegate  locationManager:self thisAppLocationServiceEnable:NO errorCode:kCLErrorLocationUnknown];
                return;
            }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_manager stopUpdatingLocation];
/*    if (_delegate  && [_delegate respondsToSelector:@selector(locationManager:thisAppLocationServiceEnable:errorCode:)]) {
        [_delegate  locationManager:self thisAppLocationServiceEnable:YES errorCode:-1];
    }*/
    if(_mapView && !_mapView.showsUserLocation) {
        _mapView.showsUserLocation = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    [_manager stopUpdatingLocation];
    if (_delegate  && [_delegate respondsToSelector:@selector(locationManager:thisAppLocationServiceEnable:errorCode:)]) {
        [_delegate  locationManager:self thisAppLocationServiceEnable:YES errorCode:-1];
    }
}

@end
