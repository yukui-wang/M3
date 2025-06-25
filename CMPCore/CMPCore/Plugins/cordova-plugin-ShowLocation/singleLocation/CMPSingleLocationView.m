//
//  CMPSingleLocationView.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/24.
//
//


#import "CMPSingleLocationView.h"
#import <MapKit/MapKit.h>

#define  kMapViewHeight (self.height*0.25)

@interface CMPSingleLocationView ()<MKMapViewDelegate>
{
    UIView *_verticalLine;//竖线
    UIView *_topView;
    CMPFaceView *_faceView;
    UILabel   *_nameLabel;
    UILabel   *_dateLabel;
    UIImageView *_mapTopLine;
    UIImageView *_mapBottomLine;

}
@end

@implementation CMPSingleLocationView
- (void)dealloc
{
    SY_RELEASE_SAFELY(_verticalLine);
    SY_RELEASE_SAFELY(_topView);
    SY_RELEASE_SAFELY(_nameLabel);
    SY_RELEASE_SAFELY(_dateLabel);

    SY_RELEASE_SAFELY(_mapView);
    SY_RELEASE_SAFELY(_mapTopLine);
    SY_RELEASE_SAFELY(_mapBottomLine);
    
    SY_RELEASE_SAFELY(_currrentUserName);
    SY_RELEASE_SAFELY(_currentMemberMemberIcon);
    SY_RELEASE_SAFELY(_tableView);
    [super dealloc];
}


- (void)setup
{
    self.backgroundColor = UIColorFromRGB(0xf2f2f2);
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = UIColorFromRGB(0xd7dce2);
        _verticalLine.frame = CGRectMake(36, 0, 1, self.height);
        [self addSubview:_verticalLine];
    }
   
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColorFromRGB(0xd7dce2);
        _topView.frame = CGRectMake(0, 0, self.width, 64);
        [self addSubview:_topView];

    }
    if (!_faceView) {
        _faceView = [[CMPFaceView alloc] init];
        _faceView.frame = CGRectMake(20, 9, 46, 46);
        [_topView addSubview:_faceView];
    }
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(CGRectGetMaxX(_faceView.frame) + 8, 16, self.width - CGRectGetMaxX(_faceView.frame) -10, 15);
        _nameLabel.font = FONTSYS(15);
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [_topView addSubview:_nameLabel];
    }
    
    
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = FONTSYS(10);
        _dateLabel.textColor = UIColorFromRGB(0x9e9e9e);
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.frame =CGRectMake(CGRectGetMaxX(_faceView.frame) + 8, CGRectGetMaxY(_nameLabel.frame) + 8, 120, 10);
        [_topView addSubview:_dateLabel];
    }
//    [MAMapServices sharedServices].apiKey = (NSString *)APIKey;
//    [AMapLocationServices sharedServices].apiKey = (NSString *)APIKey;

    if(!_mapView){
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, self.width, kMapViewHeight)];
        _mapView.delegate = self;
        [self addSubview:_mapView];
    }
    if (!_mapTopLine) {
        UIImage *image1 = [UIImage imageNamed:@"lbsShow.bundle/shadow_up.png"];
        _mapTopLine = [[UIImageView alloc] initWithImage:image1];
        _mapTopLine.frame = CGRectMake(0, _mapView.frame.origin.y, self.width, 10);
        [self addSubview:_mapTopLine];
    }
    if (!_mapBottomLine) {
        UIImage *image2 = [UIImage imageNamed:@"lbsShow.bundle/shadow_down.png"];
        _mapBottomLine = [[UIImageView alloc] initWithImage:image2];
        _mapBottomLine.frame = CGRectMake(0, CGRectGetMaxY(_mapView.frame)-10, self.width, 10);
        [self addSubview:_mapBottomLine];
    }
    
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.frame = CGRectMake(0, CGRectGetMaxY(_mapView.frame), self.width, self.height - 64 - kMapViewHeight);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:_tableView];
    }
    
    
}

#pragma mark --MkMapDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *placemarkIdentifier = @"my annotation identifier";
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView
                                            dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifier];
        if (annotationView == nil) {
            annotationView =
            [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                          reuseIdentifier:placemarkIdentifier] autorelease];
            annotationView.image = [UIImage imageNamed:@"lbsShow.bundle/point_circle.png"];
        }
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    return nil;
}


- (void)setCurrentMemberMemberIcon:(SyFaceDownloadObj *)currentMemberMemberIcon
{
    SY_RELEASE_SAFELY(_currentMemberMemberIcon);
    _currentMemberMemberIcon = [currentMemberMemberIcon retain];
    _faceView.memberIcon = currentMemberMemberIcon;
    
}
- (void)setCurrrentUserName:(NSString *)currrentUserName
{
    SY_RELEASE_SAFELY(_currrentUserName);
    _currrentUserName = [currrentUserName copy];
    _nameLabel.text = _currrentUserName;
}

- (void)showDateTime:(NSString *)time
{
    _dateLabel.text = time;
}

- (void)setTableViewMaxHeight:(CGFloat)tableViewMaxHeight
{
    _tableViewMaxHeight = tableViewMaxHeight;
    [self customLayoutSubviews];
}
- (void)customLayoutSubviews
{
    _verticalLine.frame = CGRectMake(36, 0, 1, self.height);
    _topView.frame = CGRectMake(0, 0, self.width, 64);
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_faceView.frame) + 8, 16, self.width - CGRectGetMaxX(_faceView.frame) -10, 15);
    _dateLabel.frame =CGRectMake(CGRectGetMaxX(_faceView.frame) + 8, CGRectGetMaxY(_nameLabel.frame) + 8, 120, 10);
    
    CGFloat tabH = MIN(_tableViewMaxHeight, (self.height - 64)/2);
    _mapView.frame = CGRectMake(0, 64, self.width, self.height-64-tabH);
    _tableView.frame = CGRectMake(0, CGRectGetMaxY(_mapView.frame), self.width, tabH);

    _mapTopLine.frame = CGRectMake(0, _mapView.frame.origin.y, self.width, 10);
    _mapBottomLine.frame = CGRectMake(0, CGRectGetMaxY(_mapView.frame)-10, self.width, 10);

    
}
@end
