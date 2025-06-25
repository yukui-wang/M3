//
//  KSLocationManager+Ext.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/3/7.
//

#import "KSLocationManager.h"
#import <AMapSearchKit/AMapCommonObj.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSLocationManager (Ext)

+(AMapGeoPoint *)convertCLLocationToAMapGeoPoint:(CLLocation *)location;
+(AMapReGeocode *)convertCLPlacemarkToAMapReGeocode:(CLPlacemark *)placeMark;

@end

NS_ASSUME_NONNULL_END
