//
//  CMPLocationMapView.m
//  M3
//
//  Created by Kaku Songu on 5/8/21.
//

#import "CMPLocationMapView.h"
#import <CMPLib/Masonry.h>

@interface CMPLocationMapView()
{
    
}
@end

@implementation CMPLocationMapView

-(void)setup
{
    [super setup];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    _mapView.mapType = MKMapTypeStandard;
    if([UIDevice currentDevice].systemVersion.floatValue >= 9.0){
        _mapView.zoomEnabled = YES;
        _mapView.showsCompass = YES;
    }
    _mapView.showsUserLocation = YES;
    [self addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    UIView *botV = [[UIView alloc] init];
    botV.backgroundColor = [UIColor whiteColor];
    [self addSubview:botV];
    [botV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.height.equalTo(@68);
    }];
    
    _directBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_directBtn setBackgroundImage:IMAGE(@"map_direct") forState:UIControlStateNormal];
    _directBtn.layer.cornerRadius = 20;
    [botV addSubview:_directBtn];
    [_directBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-14);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    _locationNameLb = [[KSLabel alloc] init];
    _locationNameLb.font = [UIFont systemFontOfSize:16];
    _locationNameLb.textColor = [UIColor blackColor];
    [botV addSubview:_locationNameLb];
    [_locationNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(12);
        make.top.offset(11);
        make.right.equalTo(_directBtn.mas_left).offset(-20);
    }];
    
    _locationDesLb = [[KSLabel alloc] init];
    _locationDesLb.font = [UIFont systemFontOfSize:14];
    _locationDesLb.textColor = [UIColor grayColor];
    [botV addSubview:_locationDesLb];
    [_locationDesLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(12);
        make.bottom.offset(-11);
        make.right.equalTo(_directBtn.mas_left).offset(-20);
    }];
}

@end
