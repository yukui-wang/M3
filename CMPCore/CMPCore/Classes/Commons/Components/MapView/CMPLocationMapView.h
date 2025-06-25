//
//  CMPLocationMapView.h
//  M3
//
//  Created by Kaku Songu on 5/8/21.
//

#import <CMPLib/CMPBaseView.h>
#import <MapKit/MapKit.h>
#import <CMPLib/KSLabel.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLocationMapView : CMPBaseView

@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic,strong) KSLabel *locationNameLb;
@property (nonatomic,strong) KSLabel *locationDesLb;
@property (nonatomic,strong) UIButton *directBtn;

@end

NS_ASSUME_NONNULL_END
