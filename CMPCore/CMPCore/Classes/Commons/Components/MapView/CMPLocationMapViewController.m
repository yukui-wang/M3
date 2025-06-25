//
//  CMPLocationMapViewController.m
//  M3
//
//  Created by Kaku Songu on 5/8/21.
//

#import "CMPLocationMapViewController.h"
#import "CMPLocationMapView.h"
#import "CMPLocationMapViewModel.h"
#import "KSLocationManager.h"
#import <CMPLib/KSActionSheetView.h>
#import <CMPLib/UIViewController+KSSafeArea.h>
#import <CMPLib/Masonry.h>

@interface CMPLocationMapViewController ()<MKMapViewDelegate>
{
    KSLocationManager *_locationManager;
}
@property (nonatomic, strong) CMPLocationMapViewModel *viewModel;
@property (nonatomic, strong) KSLocationManager *ksLocManager;
@end

@implementation CMPLocationMapViewController

-(CMPLocationMapViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPLocationMapViewModel alloc] init];
    }
    return _viewModel;
}

-(KSLocationManager *)ksLocManager
{
    if (!_ksLocManager) {
        _ksLocManager = [[KSLocationManager alloc] init];
    }
    return _ksLocManager;
}

-(CMPLocationMapView *)_mainView
{
    return ((CMPLocationMapView *)self.mainView);
}

-(instancetype)initWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate locationName:(NSString *)locationName
{
    if (self = [super init]) {
        self.ksLocManager.targetLocationCoordinate = locationCoordinate;
        self.ksLocManager.targetLocationName = locationName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地图";
    
    CMPLocationMapView *mainView = [self _mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.baseSafeView).offset(0);
    }];
    
    mainView.mapView.delegate = self;
    mainView.locationNameLb.text = self.ksLocManager.targetLocationName;
    
    [_locationManager.locationManager startUpdatingLocation];
    [self _updateMapLocation];
    
    
    [mainView.directBtn addTarget:self action:@selector(_directAct) forControlEvents:UIControlEventTouchUpInside];
}


-(void)_updateMapLocation
{
    CMPLocationMapView *mainView = [self _mainView];
    
    MKCoordinateRegion centerRegion = MKCoordinateRegionMake(self.ksLocManager.targetLocationCoordinate, MKCoordinateSpanMake(self.ksLocManager.zoomVal, self.ksLocManager.zoomVal));
    [mainView.mapView setRegion:[[self _mainView].mapView regionThatFits:centerRegion] animated:YES];
    mainView.mapView.showsUserLocation = NO;
    mainView.mapView.showsUserLocation = YES;
    
    [mainView.mapView removeAnnotation:self.ksLocManager.annotation];
    [mainView.mapView addAnnotation:self.ksLocManager.annotation];
    
    [mainView.mapView selectAnnotation:self.ksLocManager.annotation animated:YES];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.ksLocManager.targetLocationCoordinate.latitude longitude:self.ksLocManager.targetLocationCoordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            NSString *country = placemark.country;
            NSString *city = placemark.locality;
            NSString *subCity = placemark.subLocality;
            NSString *street = placemark.thoroughfare;
            NSString *name = placemark.name;
            
            NSString *locationName = [NSString stringWithFormat:@"%@%@",country,city];
            
            if(subCity){
                locationName = [NSString stringWithFormat:@"%@%@",locationName,subCity];
            }
            
            if(name){
                locationName = [NSString stringWithFormat:@"%@%@",locationName,name];
            }else {
                locationName = [NSString stringWithFormat:@"%@%@",locationName,street];
            }
            
            mainView.locationDesLb.text = locationName;
        }
    }];
}


-(void)_directAct
{
    NSArray *maps = [self _maps];
    __weak typeof(self) wSelf = self;
    KSActionSheetView *actionSheet = [KSActionSheetView showActionSheetWithTitle:nil cancelButtonTitle:SY_STRING(@"common_cancel") destructiveButtonTitle:nil otherButtonTitleItems:maps handler:^(KSActionSheetView *actionSheetView, KSActionSheetViewItem *actionItem, id ext) {
        
        CLLocationCoordinate2D endLocation = wSelf.ksLocManager.targetLocationCoordinate;
        NSString *endName = wSelf.ksLocManager.targetLocationName;
        NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        
        switch (actionItem.key) {
            case 100:
                [wSelf navAppleMap];
                break;
            case 101:
            {
                //iosamap://path?sourceApplication=applicationName&sid=&slat=39.92848272&slon=116.39560823&sname=A&did=&dlat=39.98848272&dlon=116.47560823&dname=B&dev=0&t=0
                NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&dlat=%f&dlon=%f&dname=%@&dev=1&t=0",@"导航",endLocation.latitude,endLocation.longitude,endName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                        NSLog(@"scheme调用结束");
                        
                    }];
                    
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
                break;
            case 102:
            {
                NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02",endLocation.latitude,endLocation.longitude,endName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                        NSLog(@"scheme调用结束");
                        
                    }];
                    
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
                break;
            case 103:
            {
                NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",endLocation.latitude, endLocation.longitude,endName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                        NSLog(@"scheme调用结束");
                        
                    }];
                    
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
                break;
            case 104:
            {
                NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&daddr=%f,%f&directionsmode=driving",@"导航",@"nav123456",endLocation.latitude, endLocation.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                        NSLog(@"scheme调用结束");
                        
                    }];
                    
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
                break;
                
            default:
                break;
        }
    }];
    [actionSheet show];

}


- (void)navAppleMap
{
    CLLocationCoordinate2D gps = self.ksLocManager.targetLocationCoordinate;
    
    MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:gps addressDictionary:nil]];
    toLocation.name = self.ksLocManager.targetLocationName;
    NSArray *items = @[currentLoc,toLocation];
    NSDictionary *dic = @{
                          MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                          MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                          MKLaunchOptionsShowsTrafficKey : @(YES)
                          };
    
    [MKMapItem openMapsWithItems:items launchOptions:dic];
}


-(NSArray *)_maps
{
    NSMutableArray *maps = [NSMutableArray array];
    
    KSActionSheetViewItem *item1 = [[KSActionSheetViewItem alloc] init];
    [item1 setTitle:@"苹果地图"];
    [item1 setKey:100];
    [maps addObject:item1];
    
    //高德地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        
        KSActionSheetViewItem *item = [[KSActionSheetViewItem alloc] init];
        [item setTitle:@"高德地图"];
        [item setKey:101];
        [maps addObject:item];

    }
    
    //百度地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        
        KSActionSheetViewItem *item = [[KSActionSheetViewItem alloc] init];
        [item setTitle:@"百度地图"];
        [item setKey:102];
        [maps addObject:item];

    }
    
    //腾讯地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        
        KSActionSheetViewItem *item = [[KSActionSheetViewItem alloc] init];
        [item setTitle:@"腾讯地图"];
        [item setKey:103];
        [maps addObject:item];

    }
    
    //谷歌地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        
        KSActionSheetViewItem *item = [[KSActionSheetViewItem alloc] init];
        [item setTitle:@"谷歌地图"];
        [item setKey:104];
        [maps addObject:item];

    }
    
    return maps;
}



//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    static NSString *pinAnnotationIdentifier = @"PinAnnotationIdentifier";
//    MKPinAnnotationView *pinAnnotationView =
//        (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinAnnotationIdentifier];
//    if (!pinAnnotationView) {
//        pinAnnotationView =
//            [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinAnnotationIdentifier];
//        pinAnnotationView.canShowCallout = YES;
//    }
//    return pinAnnotationView;
//}



@end
