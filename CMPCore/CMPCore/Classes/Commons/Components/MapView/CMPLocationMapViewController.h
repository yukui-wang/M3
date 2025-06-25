//
//  CMPLocationMapViewController.h
//  M3
//
//  Created by Kaku Songu on 5/8/21.
//

#import <CMPLib/CMPBannerViewController.h>
#import <CoreLocation/CLLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLocationMapViewController : CMPBannerViewController

-(instancetype)initWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate locationName:(NSString *)locationName;

@end

NS_ASSUME_NONNULL_END
