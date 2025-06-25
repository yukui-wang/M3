//
//  CMPSignView.h
//  CMPCore
//
//  Created by wujiansheng on 16/7/28.
//
//

#import <CMPLib/CMPBaseView.h>
#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import "CMPSignFloatView.h"
#import "CMPCityPickerView.h"

@interface CMPSignView : CMPBaseView
@property (nonatomic, retain) MAMapView *mapView;
@property (nonatomic, retain) CMPSignFloatView *floatView;//悬浮视图
@property (nonatomic, retain) CMPCityPickerView *cityPickerView;//悬浮视图

//显示中心拖动点，默认不显示
@property (nonatomic, assign) BOOL showCenterPoint;

@end
