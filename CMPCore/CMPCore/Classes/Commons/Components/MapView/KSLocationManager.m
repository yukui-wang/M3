//
//  KSLocationManager.m
//  M3
//
//  Created by Kaku Songu on 5/8/21.
//

#import "KSLocationManager.h"

@interface KSLocationManager()<CLLocationManagerDelegate>
{
    KSLocateResultBlk _onceLocateResultBlk;
    KSLocateResultBlk _updateLocateResultBlk;
    
    KSLocationReverseResultBlk _onceLocationReverseResultBlk;
    KSLocationReverseResultBlk _updateLocationReverseResultBlk;
}
@end

@implementation KSLocationManager

+ (void)showLocateNotOpenAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NULL message:@"No Locate Permission" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:NULL, nil];
    [alertView show];
}

static KSLocationManager *_instance;

+(KSLocationManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[KSLocationManager alloc] init];
    });
    return _instance;
}


-(instancetype)init
{
    if (self = [super init]) {
        _zoomVal = 0.01;
        _targetLocationCoordinate = CLLocationCoordinate2DMake(39.905575843455949, 39.905575843455949);
        _targetLocationName = @"当前位置";
    }
    return self;
}


-(MKPointAnnotation *)annotation
{
    if (!_annotation) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    _annotation.coordinate = _targetLocationCoordinate;
    _annotation.title = _targetLocationName;
    return _annotation;
}

-(CLLocationManager *)locationManager
{
    if (!_locationManager) {
        if([CLLocationManager locationServicesEnabled]){
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            _locationManager.distanceFilter=10;
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }else {
            [KSLocationManager showLocateNotOpenAlertView];
        }
    }
    return _locationManager;
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            if (_onceLocateResultBlk || _onceLocationReverseResultBlk) {
                [_locationManager requestLocation];
            }
            if (_updateLocateResultBlk || _updateLocationReverseResultBlk) {
                [_locationManager startUpdatingLocation];
            }
        }
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
            
        case kCLAuthorizationStatusDenied:
        {
            [KSLocationManager showLocateNotOpenAlertView];
        }
            break;
            
        default:
            break;
    }
}


-(void)requestOnceLocationWithLocateResult:(KSLocateResultBlk)locateResultBlk reverseResult:(KSLocationReverseResultBlk)reverseResultBlk
{
    NSLog(@"ks log --- %s",__func__);
    if (!locateResultBlk && !reverseResultBlk) {
        return;
    }
    
    _onceLocateResultBlk = locateResultBlk;
    _onceLocationReverseResultBlk = reverseResultBlk;
    
    if (!_updateLocateResultBlk && !_updateLocationReverseResultBlk) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self.locationManager requestLocation];
//        });
        
    }
}

-(void)requestUpdatingLocationWithLocateResult:(KSLocateResultBlk)locateResultBlk reverseResult:(KSLocationReverseResultBlk)reverseResultBlk
{
    NSLog(@"ks log --- %s",__func__);
    if (!locateResultBlk && !reverseResultBlk) {
        return;
    }
    [self stopUpdatingLocation];
    _updateLocateResultBlk = locateResultBlk;
    _updateLocationReverseResultBlk = reverseResultBlk;
    [self.locationManager startUpdatingLocation];
}

-(void)stopUpdatingLocation
{
    NSLog(@"ks log --- %s",__func__);
    _updateLocateResultBlk = nil;
    _updateLocationReverseResultBlk = nil;
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"ks log --- %s",__func__);
    if (_onceLocateResultBlk) {
        _onceLocateResultBlk(locations,nil);
        _onceLocateResultBlk = nil;
    }
    if (_updateLocateResultBlk) {
        _updateLocateResultBlk(locations,nil);
    }

    CLLocation *currentLocation = locations.lastObject;
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    NSLog(@"ks log --- 获取到经纬度%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    
    [geoCoder reverseGeocodeLocation: currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        NSLog(@"ks log --- reverseGeocodeLocation -- placemarks : %@ ,error: %@",placemarks,error);
        
        if(placemarks.count > 0){
            
            CLPlacemark *placeMark = placemarks[0];
            
            NSString *locationName;
            
            NSDictionary *dic = placeMark.addressDictionary;
            NSArray *arr = dic[@"FormattedAddressLines"];
            if (arr && [arr isKindOfClass:[NSArray class]] && arr.count) {
                locationName = arr.firstObject;
            }
            if (!locationName||locationName.length==0) {
                NSString *country = placeMark.country?:@"";
                NSString *city = placeMark.locality?:@"";
                NSString *subCity = placeMark.subLocality?:@"";
                NSString *street = placeMark.thoroughfare?:@"";
    //            NSString *subStreet = placeMark.subThoroughfare?:@"";
                NSString *name = placeMark.name?:@"";
                
                locationName = [NSString stringWithFormat:@"%@%@%@%@%@",country,city,subCity,street,name];
            }
            NSLog(@"ks log --- locationAddressName: %@",locationName);
            
            if (self->_onceLocationReverseResultBlk) {
                self->_onceLocationReverseResultBlk(placemarks,locationName,error);
                self->_onceLocationReverseResultBlk = nil;
            }
            if (self->_updateLocationReverseResultBlk) {
                self->_updateLocationReverseResultBlk(placemarks,locationName,error);
            }
            
        }
        else if(error == nil && placemarks.count == 0){
            
            NSString *domain = @"com.seeyon.errorDomain";
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"KSAddressReverseError" };
            error = [NSError errorWithDomain:domain
                                                 code:-101
                                             userInfo:userInfo];
            if (self->_onceLocationReverseResultBlk) {
                self->_onceLocationReverseResultBlk(placemarks,@"",error);
                self->_onceLocationReverseResultBlk = nil;
            }
            if (self->_updateLocationReverseResultBlk) {
                self->_updateLocationReverseResultBlk(placemarks,@"",error);
            }
            
        }else if(error){

            if (self->_onceLocationReverseResultBlk) {
                self->_onceLocationReverseResultBlk(placemarks,@"",error);
                self->_onceLocationReverseResultBlk = nil;
            }
            if (self->_updateLocationReverseResultBlk) {
                self->_updateLocationReverseResultBlk(placemarks,@"",error);
            }
        }
        
    }];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"ks log --- %s",__func__);
    NSLog(@"ks log --- %@",error);
    if (_onceLocateResultBlk) {
        _onceLocateResultBlk(nil,error);
        _onceLocateResultBlk = nil;
    }
    if (_updateLocateResultBlk) {
        _updateLocateResultBlk(nil,error);
    }
}
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"ks log --- %s",__func__);
}

@end
