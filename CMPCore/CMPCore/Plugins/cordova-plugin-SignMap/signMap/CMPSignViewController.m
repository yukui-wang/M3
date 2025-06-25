//
//  CMPSignViewController.m
//  CMPCore
//
//  Created by wujiansheng on 16/7/28.
//
//

#import "CMPSignViewController.h"
#import "SyLocationManager.h"
#import "SyReverseGeocoder.h"
#import "CMPSignView.h"
#import <MapKit/MapKit.h>
#import "SyAddressGeocoder.h"
#import "SySearchResult.h"
#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MAPointAnnotation.h>
#import "CMPLocationManager.h"
#import <CMPLib/CMPDevicePermissionHelper.h>

@interface CMPSignViewController ()<SyReverseGeocoderDelegate,MAMapViewDelegate,CMPCityPickerViewDelegate,SyAddressGeocoderDelegate,UITextFieldDelegate>

@property (nonatomic, strong)SyReverseGeocoder *geoCoder;
@property (nonatomic, strong)SyAddressGeocoder *seachGeoCoder;

@property (nonatomic, strong)CLLocation *currentLocation;
@property (nonatomic, strong)SyAddress *currentAddress;

@property (nonatomic, strong)CMPSignView *signView;
@property (nonatomic, strong)UIButton *rightButton;

@property (nonatomic, assign)BOOL isLocalLocationSuccessful;
@property (nonatomic, strong)NSError *localLocationError;

@end

@implementation CMPSignViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLocalLocationSuccessful = NO;
    
    [self setTitle:SY_STRING(@"Sign_markInMap")];
    self.backBarButtonItemHidden = NO;
    _rightButton = [UIButton transparentButtonWithFrame:CGRectMake(0, 0, 50, 35) title:SY_STRING(@"common_save")];
    [_rightButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _rightButton.enabled = NO;
    [_rightButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:_rightButton, nil]];

    _signView = (CMPSignView *)self.mainView;
    _signView.mapView.delegate = self;
    [_signView.floatView.cityButton addTarget:self action:@selector(cityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_signView setShowCenterPoint:YES];
    
    [self fetchAdress];
    
    _signView.cityPickerView.delegate = self;
    _signView.floatView.adressField.delegate = self;
    
}

- (void)sendAction:(id)sender {
    
    if (self.isLocalLocationSuccessful) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(signViewViewController:withAddress:currentLoaction:withWebViewCommandKey:)]) {
            [self.delegate signViewViewController:self withAddress:self.currentAddress currentLoaction:self.currentLocation withWebViewCommandKey:self.webCommandKey];
        }
    }else {
        if(self.delegate && [self.delegate respondsToSelector:@selector(signViewViewControllerDidFail:failError:)]) {
            [self.delegate signViewViewControllerDidFail:self failError:self.localLocationError];
        }
    }
   
}

- (void)backBarButtonAction:(id)sender {
    [super backBarButtonAction:sender];
    if(self.delegate && [self.delegate respondsToSelector:@selector(signViewViewControllerDidCancel:)]) {
        [self.delegate signViewViewControllerDidCancel:self];
    }
}


- (void)cityButtonAction:(id)sender {
    [_signView.floatView.adressField resignFirstResponder];
    [_signView.cityPickerView show];
}

//- (void)fetchAdress {
//    if(!_manager){
//        _manager = [[SyLocationManager alloc] init];
//        _manager.delegate = self;
//        _manager.gpsRefreshRate = 10;
//    }
//    if(!_manager.locationServiceEnable){
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:SY_STRING(@"Sign_location_servicesSet") delegate:nil cancelButtonTitle:nil otherButtonTitles:SY_STRING(@"common_ok"), nil];
//        [alertView show];
//        return;
//    }
//
//    [_manager checkThisAppLocationServiceEnable];
//}

- (void)fetchAdress {
    CMPLocationManager *locationManager = [CMPLocationManager shareLocationManager];
    __weak typeof(self) weakSelf = self;
    
    if(!locationManager.locationServiceEnable){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:SY_STRING(@"Sign_location_servicesSet") delegate:nil cancelButtonTitle:nil otherButtonTitles:SY_STRING(@"common_ok"), nil];
        [alertView show];
        return;
    }
    
    if(![CMPDevicePermissionHelper isHasLocationPermission]){
        NSString *app_Name = [[NSBundle mainBundle]
                              objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:SY_STRING(@"Sign_location_servicesSet_m3"),app_Name];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:SY_STRING(@"common_ok"), nil];
        [alertView show];
        return;
    }
    
    [locationManager getSingleLocationWithCompletionBlock:^(NSString *  _Nullable provider,AMapGeoPoint * _Nullable location, AMapReGeocode * _Nullable regeocode, NSError * _Nullable locationError, NSError * _Nullable searchError, NSError * _Nullable locationResultError) {
        
        weakSelf.rightButton.enabled = YES;
        
        if (locationError) {
            NSLog(@"locationError %@",locationError);
            self.localLocationError = locationError;
            return;
        }
        
        if (searchError) {
            NSLog(@"searchError %@",searchError);
            self.localLocationError = searchError;
            return;
        }
        
        if (locationResultError) {
            NSLog(@"locationResultError %@",locationResultError);
            self.localLocationError = locationResultError;
            return;
        }
        
        SyAddress *address = [[SyAddress alloc] init];
        address.provinceName =  regeocode.addressComponent.province;
        address.cityName = regeocode.addressComponent.city;
        address.districtName = regeocode.addressComponent.district;
        address.street = regeocode.formattedAddress;
        address.nearestPOI =  regeocode.formattedAddress;
        address.citycode = regeocode.addressComponent.citycode;
        address.latitude = location.latitude;
        address.longitude = location.longitude;
        weakSelf.currentLocation = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
        weakSelf.currentAddress = address;
        [self mapViewsSetRegionWithLocation:self.currentLocation clear:YES];
        
        NSArray *array = [NSArray arrayWithObjects:@"Beijing",@"tianjin",@"chongqing",@"shanghai",@"hongkong",@"macao",@"北京市",@"天津市",@"重庆市",@"上海市",@"香港",@"澳门", nil];
        NSString *provinceName = address.provinceName;
        if ([array containsObject:provinceName.lowercaseString]) {
            provinceName = @"";
        }
        [weakSelf.signView.floatView layoutProvince:provinceName city:address.cityName address:address.nearestPOI];
        weakSelf.isLocalLocationSuccessful = YES;
    }];
}

- (void)requestAdressWithCLLocation:(CLLocation *)aLocation tag:(NSInteger) tag {
    self.geoCoder.tag = tag;
    self.currentLocation = aLocation;
    self.geoCoder.geoLocation = aLocation;
}


- (void)mapViewsSetRegionWithLocation:(CLLocation *)location  clear:(BOOL)clear {
    if (clear) {
        [_signView.mapView removeAnnotations:_signView.mapView.annotations];
    }
    double zoomLevel = _signView.mapView.zoomLevel;

    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.008;
    span.longitudeDelta = 0.008;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span = span;
    
    MACoordinateRegion centerRegion;
    centerRegion.center.latitude =  location.coordinate.latitude;
    centerRegion.center.longitude = location.coordinate.longitude;
    centerRegion.span.latitudeDelta = 0.5;
    centerRegion.span.longitudeDelta = 0.5;
    
    [_signView.mapView setRegion:centerRegion animated:YES];
    [_signView.mapView setZoomLevel:zoomLevel animated:NO];
    self.geoCoder.tag = 101;
}

- (void)reverseGeocoderDidFinsh:(SyReverseGeocoder *)geocoder withSyAddress:(SyAddress *)aAddress {
    self.currentAddress = aAddress;
    NSArray *array = [NSArray arrayWithObjects:@"Beijing",@"tianjin",@"chongqing",@"shanghai",@"hongkong",@"macao",@"北京市",@"天津市",@"重庆市",@"上海市",@"香港",@"澳门", nil];
    NSString *provinceName = aAddress.provinceName;
    if ([array containsObject:provinceName.lowercaseString]) {
        provinceName = @"";
    }
    [_signView.floatView layoutProvince:provinceName city:aAddress.cityName address:aAddress.nearestPOI];
    if (geocoder.tag == 100) {
        [self mapViewsSetRegionWithLocation:self.currentLocation clear:YES];
    }
    _rightButton.enabled = YES;
}

- (void)checkIsMunicipalities:(SyGeoPOI *)poi {
    //不需要国际化
    if([poi.province isEqualToString:@"北京市"]){
        poi.city = @"北京市";
    }else if([poi.province isEqualToString:@"天津市"]){
        poi.city = @"天津市";
    }else if([poi.province isEqualToString:@"重庆市"]){
        poi.city = @"重庆市";
    }else if([poi.province isEqualToString:@"上海市"]){
        poi.city = @"上海市";
    }
    
}

#pragma mark - mapviewDelegate

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    //点击 标注
    CLLocation *aLocation  = [[CLLocation alloc] initWithLatitude: coordinate.latitude
                                                        longitude: coordinate.longitude];
    [self requestAdressWithCLLocation:aLocation tag:100];
}

-(MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.draggable = YES;
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState
   fromOldState:(MAAnnotationViewDragState)oldState {
    if(oldState == MAAnnotationViewDragStateEnding) {
        MAPointAnnotation *pointAnnotation = view.annotation;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:pointAnnotation.coordinate.latitude longitude:pointAnnotation.coordinate.longitude];
        [self requestAdressWithCLLocation:location tag:100];
    }
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    
    
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if (!self.isLocalLocationSuccessful) {
        return;
    }
    CLLocation *aLocation  = [[CLLocation alloc] initWithLatitude: mapView.region.center.latitude longitude: mapView.region.center.longitude];
    self.currentLocation = aLocation;
    self.geoCoder.geoLocation = aLocation;
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    
}

#pragma mark - CMPCityPickerViewDelegate

- (void)cityPickerViewDidCancel {
    
}

- (void)cityPickerViewDidSelectCityWithInfo:(NSDictionary *)infoDict {
    NSDictionary *dic = infoDict;
    NSString *provinceName = [dic objectForKey:@"province"];
    NSString *cityName =[CMPCore language_ZhCN] ?[dic objectForKey:@"city"] :[dic objectForKey:@"en"];
    
    [_signView.floatView layoutProvince:provinceName city:cityName address:@""];
    
    NSNumber *latNum = [dic objectForKey:@"lat"];
    NSNumber *lonNum = [dic objectForKey:@"lon"];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[latNum doubleValue] longitude:[lonNum doubleValue]];
    [self requestAdressWithCLLocation:location tag:100];
}

#pragma mark search adress

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchAddress];
    [textField resignFirstResponder];
    return NO;
}

- (void)searchAddress {
    if(_signView.floatView.adressField.text.length == 0)
        return;
    
    NSString *address = [_signView.floatView.adressField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(address.length == 0)
        return;
//    NSString *aFullAddress = [NSString stringWithFormat:@"%@%@%@", self.currentAddress.provinceName, self.currentAddress.cityName, address];
//    _seachGeoCoder.address = aFullAddress;
    
    [self.seachGeoCoder searchPOIKeywordsWithCityName:self.currentAddress.cityName keywords:address];
}

#pragma mark - SyAddressGeocoderDelegate

- (void)addressGeocoder:(SyAddressGeocoder *)geocoder finishedGeocoder:(SyGeoCodingSearchResult *)result {
    if(result.count == 0)
        return;
    SyGeoPOI *poi = [result.geoCodingArray firstObject];
    [self checkIsMunicipalities:poi];
    CLLocation *aLocation  = [[CLLocation alloc] initWithLatitude: poi.x longitude: poi.y];
    [self requestAdressWithCLLocation:aLocation tag:100];
}

-(void)addressGeocoder:(SyAddressGeocoder *)geocoder searchKeywordsLocation:(AMapGeoPoint *)location {
    CLLocation *aLocation  = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    [self requestAdressWithCLLocation:aLocation tag:100];
}

- (void)addressGeocoderFailed:(SyAddressGeocoder *)geocoder  {
    
}

#pragma mark - lazy

- (SyReverseGeocoder *)geoCoder {
    if(!_geoCoder){
        _geoCoder = [[SyReverseGeocoder alloc] init];
        _geoCoder.delegate = self;
    }
    return  _geoCoder;
}

- (SyAddressGeocoder *)seachGeoCoder {
    if (!_seachGeoCoder) {
        _seachGeoCoder = [[SyAddressGeocoder alloc] init];
        _seachGeoCoder.delegate = self;
        
    }
    return _seachGeoCoder;
}

@end
