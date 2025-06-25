//
//  SYGeocoder.h
//  M1Core
//
//  Created by Aries on 14-3-7.
//
//

#import <Foundation/Foundation.h>
#import  <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchKit.h>

@protocol SyReverseGeocoderDelegate;

@interface SyReverseGeocoder : NSObject
{

}
@property (nonatomic,assign) id<SyReverseGeocoderDelegate>delegate;
@property (nonatomic,retain) CLLocation *geoLocation;
@property (nonatomic, assign) NSInteger tag;

@end

@interface SyAddress :NSObject
/* provider用于告知H5当前用的是高德还是Google进行地位  :  gaode  google */
@property (copy, nonatomic) NSString *provider;
@property (nonatomic, copy) NSString * country;
@property (nonatomic, copy) NSString * provinceName;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *districtName;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *nearestPOI;
@property (nonatomic,readonly) NSString *longName;
@property (nonatomic, readonly) NSString *roadName;
@property (nonatomic, assign) BOOL isPoi;
@property (nonatomic, copy) NSString *citycode;
@property (nonatomic, readonly) NSString *imageName;


@property (nonatomic, assign) CGFloat latitude; //!< 纬度（垂直方向）
@property (nonatomic, assign) CGFloat longitude; //!< 经度（水平方向）
- (NSDictionary *)deaultAddressDictionary;
@end

@protocol SyReverseGeocoderDelegate <NSObject>
@optional
- (void)reverseGeocoderDidFinsh:(SyReverseGeocoder *)geocoder withSyAddress:(SyAddress *)aAddress;
- (void)reverseGeocoderDidFinsh:(SyReverseGeocoder *)geocoder withSyAddressList:(NSArray *)addressList;
- (void)reverseGeocoderFail:(SyReverseGeocoder *)geocoder;
@end
