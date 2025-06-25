//
//  KSLocationManager.h
//  M3
//
//  Created by Kaku Songu on 5/8/21.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKPointAnnotation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KSLocateResultBlk)(NSArray<CLLocation *> * _Nullable locations,
                                 NSError * _Nullable error);
typedef void(^KSLocationReverseResultBlk)(NSArray<CLPlacemark *> * _Nullable placemarks,
                                          NSString *locationAddressName,
                                          NSError * _Nullable error);

@interface KSLocationManager : NSObject

@property (nonatomic, assign) float zoomVal;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *annotation;
@property (assign, nonatomic) CLLocationCoordinate2D targetLocationCoordinate;
@property (nonatomic,copy) NSString *targetLocationName;

-(void)requestOnceLocationWithLocateResult:(KSLocateResultBlk)locateResultBlk reverseResult:(KSLocationReverseResultBlk)reverseResultBlk;
-(void)requestUpdatingLocationWithLocateResult:(KSLocateResultBlk)locateResultBlk reverseResult:(KSLocationReverseResultBlk)reverseResultBlk;
-(void)stopUpdatingLocation;

@end

NS_ASSUME_NONNULL_END
