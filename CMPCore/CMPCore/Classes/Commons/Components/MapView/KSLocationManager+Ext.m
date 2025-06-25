//
//  KSLocationManager+Ext.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/3/7.
//

#import "KSLocationManager+Ext.h"

@implementation KSLocationManager (Ext)

+(AMapGeoPoint *)convertCLLocationToAMapGeoPoint:(CLLocation *)location
{
    AMapGeoPoint *geoPoint = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    return geoPoint;
}

+(AMapReGeocode *)convertCLPlacemarkToAMapReGeocode:(CLPlacemark *)placeMark
{
    AMapAddressComponent *addressComponent = [[AMapAddressComponent alloc] init];
    addressComponent.country = placeMark.country?:@"";
    addressComponent.province = placeMark.administrativeArea?:@"";
    addressComponent.city = placeMark.locality?:@"";
    addressComponent.district = placeMark.subLocality?:@"";
    addressComponent.township = placeMark.thoroughfare?:@"";
    addressComponent.neighborhood = placeMark.subThoroughfare?:@"";
    addressComponent.citycode = placeMark.postalCode;
    
    NSString *locationName;
    
    NSDictionary *dic = placeMark.addressDictionary;
    NSArray *arr = dic[@"FormattedAddressLines"];
    if (arr && [arr isKindOfClass:[NSArray class]] && arr.count) {
        locationName = arr.firstObject;
    }
    if (!locationName||locationName.length==0) {
        NSString *country = placeMark.country?:@"";
        NSString *city = placeMark.locality?:@"";
        NSString *subCity = placeMark.subLocality?:@"";
        NSString *street = placeMark.thoroughfare?:@"";
//            NSString *subStreet = placeMark.subThoroughfare?:@"";
        NSString *name = placeMark.name?:@"";
        
        locationName = [NSString stringWithFormat:@"%@%@%@%@%@",country,city,subCity,street,name];
    }
    
    AMapReGeocode *aRegeo = [[AMapReGeocode alloc] init];
    aRegeo.addressComponent = addressComponent;
    aRegeo.formattedAddress = locationName;
    
    return aRegeo;
}

@end
