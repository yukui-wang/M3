//
//  BaseMapViewController.h
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
//#import <AMapLocationKit/AMapLocationKit.h>

@interface BaseMapViewController : UIViewController<MAMapViewDelegate>//, AMapLocationManagerDelegate>

@property (nonatomic, retain) MAMapView *mapView;

//@property (nonatomic, strong) AMapLocationManager *locationManager;

- (void)returnAction;

@end
