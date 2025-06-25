//
//  CMPGoogleLocationManager.h
//  M3
//
//  Created by MacBook on 2020/2/20.
//

#import <UIKit/UIKit.h>

#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>


UIKIT_EXTERN NSString * _Nullable const CMPLocationManagerMapsTypeGoogle;
UIKIT_EXTERN NSString * _Nullable const CMPLocationManagerMapsTypeAmap;


typedef void(^getPoisCompetedBlock)(NSString *  _Nullable provider,NSArray * _Nullable  pois,AMapLocationReGeocode * _Nullable bestPoi,AMapGeoPoint *  _Nullable geoPoint, AMapReGeocode *  _Nullable regeocode, NSError * _Nullable locationError, NSError * _Nullable searchError ,  NSError * _Nullable locationResultError);

NS_ASSUME_NONNULL_BEGIN

@interface CMPGoogleLocationManager : NSObject

+ (instancetype)sharedManager;

+ (void)initGoogleMapsWirhMapKey:(NSString *)googleMapKey;

- (void)reGeocoderLocation:(CLLocation *)location pois:(getPoisCompetedBlock)getPoisCompeted;

+ (NSString *)googleMapKey;

@end

NS_ASSUME_NONNULL_END
