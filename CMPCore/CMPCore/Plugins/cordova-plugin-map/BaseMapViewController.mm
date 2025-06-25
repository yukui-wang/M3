//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"

@interface BaseMapViewController()

@property (nonatomic, assign) BOOL isFirstAppear;

@end

@implementation BaseMapViewController
@synthesize mapView = _mapView;
//@synthesize locationManager = _locationManager;

- (void)dealloc
{
    [_mapView release];
    _mapView = nil;
    [super dealloc];
}

#pragma mark - Utility

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearLocationManager
{
//    [self.locationManager stopUpdatingLocation];
//    
//    //Restore Default Value
//    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
//    [self.locationManager setPausesLocationUpdatesAutomatically:YES];
//    [self.locationManager setAllowsBackgroundLocationUpdates:NO];
//    
//    self.locationManager.delegate = nil;
}

#pragma mark - Handle Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    [self clearLocationManager];
}

#pragma mark - AMapLocationManager Delegate

//- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
//{
//    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
//}
//
//- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
//{
//    NSLog(@"%s, didUpdateLocation = {lat:%f; lon:%f;}", __func__, location.coordinate.latitude, location.coordinate.longitude);
//}

#pragma mark - Initialization

- (void)initMapView
{
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)initLocationManager
{
//    if(_locationManager == nil){
//       _locationManager = [[AMapLocationManager alloc] init];
//    }
//    self.locationManager.delegate = self;
}

- (void)initBaseNavigationBar
{
    UIBarButtonItem *aItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(returnAction)];
    self.navigationItem.leftBarButtonItem = aItem;
    [aItem release];
}

- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
}

#pragma mark - Life Cycle

-(id)init{
    self = [super init];
    if (self) {
        [self initMapView];
        
        [self initLocationManager];
    }
    return  self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstAppear)
    {
        self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
        _isFirstAppear = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isFirstAppear = YES;
    
    [self initTitle:self.title];
    
    [self initBaseNavigationBar];
    

}

@end
