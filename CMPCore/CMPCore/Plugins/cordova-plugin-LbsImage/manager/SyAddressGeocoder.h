//
//  SyAddressGeocoder.h
//  M1Core
//
//  Created by Aries on 14-3-25.
//
//

#import <Foundation/Foundation.h>
#import  <CoreLocation/CoreLocation.h>
#import <CMPLib/CMPObject.h>
#import <AMapSearchKit/AMapSearchKit.h>

@class SyGeoCodingSearchResult;

@protocol SyAddressGeocoderDelegate;

@interface SyAddressGeocoder : CMPObject

@property (nonatomic, copy) NSString *address;
@property (nonatomic, weak) id<SyAddressGeocoderDelegate> delegate;

- (void)searchPOIKeywordsWithCityName:(NSString *)city keywords:(NSString *)keywords;

@end

@protocol SyAddressGeocoderDelegate <NSObject>

- (void)addressGeocoder:(SyAddressGeocoder *)geocoder finishedGeocoder:(SyGeoCodingSearchResult *)result;
- (void)addressGeocoder:(SyAddressGeocoder *)geocoder searchKeywordsLocation:(AMapGeoPoint *)location;
- (void)addressGeocoderFailed:(SyAddressGeocoder *)geocoder;

@end
