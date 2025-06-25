//
//  CMPSignView.m
//  CMPCore
//
//  Created by wujiansheng on 16/7/28.
//
//

#import "CMPSignView.h"
#import "CMPCommonManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

@implementation CMPSignView {
    
    UIImageView *centerPoint;
}

- (void)dealloc
{
    SY_RELEASE_SAFELY(_mapView);
    SY_RELEASE_SAFELY(_floatView);
    SY_RELEASE_SAFELY(_cityPickerView);
    SY_RELEASE_SAFELY(centerPoint);
    [super dealloc];
}

- (void)setup
{
    _showCenterPoint = NO;
    
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [AMapServices sharedServices].apiKey = [CMPCommonManager lbsAPIKey];
    if(!_mapView){
        
        [MAMapView updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
        [MAMapView updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
        
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.width, 151)];
        _mapView.mapLanguage = [CMPCore language_ZhCN]?@0:@1;
        //开启海外地图
        [self.mapView performSelector:NSSelectorFromString(@"setShowsWorldMap:") withObject:@YES];
        //关闭海外地图
        //[self.mapView performSelector:@selector(setShowsWorldMap:) withObject:@NO];
        [self addSubview:_mapView];
        
    }
    
    if (!_floatView) {
        _floatView = [[CMPSignFloatView alloc] init];
        [self addSubview:_floatView];
    }
    if (!_cityPickerView) {
        _cityPickerView = [[CMPCityPickerView alloc] init];
        [self addSubview:_cityPickerView];
    }
}

- (void)customLayoutSubviews
{
    _floatView.frame = CGRectMake(0, 0, self.width, 97);
    CGFloat y = _floatView.height;
    _mapView.frame = CGRectMake(0, y, self.width,self.height- y);
    [_cityPickerView setFrame:CGRectMake(0, self.height, self.width, self.height)];
    
    if (centerPoint) {
        centerPoint.frame = CGRectMake((self.width - 50)/2, y + (_mapView.height - 50)/2, 50, 50);
    }
}

- (void)setShowCenterPoint:(BOOL)showCenterPoint {
    
    _showCenterPoint = showCenterPoint;
    
    if (_showCenterPoint) {
        if (!centerPoint) {
            UIImage *image = [UIImage imageNamed:@"AMap.bundle/images/greenPin.png"];
            centerPoint = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - image.size.width)/2, _mapView.originY + _mapView.height/2 - image.size.height, image.size.width, image.size.height)];
            centerPoint.image = image;
            [self addSubview:centerPoint];
        }
        centerPoint.hidden = NO;
    }
    else {
        centerPoint.hidden = YES;
    }
}

@end
