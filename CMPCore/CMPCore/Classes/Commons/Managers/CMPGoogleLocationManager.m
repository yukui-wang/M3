//
//  CMPGoogleLocationManager.m
//  M3
//
//  Created by MacBook on 2020/2/20.
//

#import "CMPGoogleLocationManager.h"

#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPConstant.h>
#import "CMPCommonManager.h"


NSString * const CMPLocationManagerMapsTypeGoogle = @"google";
NSString * const CMPLocationManagerMapsTypeAmap = @"gaode";


@interface CMPGoogleAddress:NSObject
@property (copy, nonatomic) NSString *district;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *country;
@property (copy, nonatomic) NSString *street;
@property (copy, nonatomic) NSString *postal_code;
@property (copy, nonatomic) NSString *formattedAddress;

@end
@implementation CMPGoogleAddress
@end

@interface CMPGoogleLocationManager()

@property (copy, nonatomic) NSString *googleMapKey;

@end

@implementation CMPGoogleLocationManager
#pragma mark - 初始化相关
+ (instancetype)sharedManager {
    static CMPGoogleLocationManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CMPGoogleLocationManager alloc] init];
//        _instance.googleMapKey = [CMPCommonManager lbsGoogleAPIKey];
    });
    return _instance;
}

+ (void)initGoogleMapsWirhMapKey:(NSString *)googleMapKey {
    NSLog(@"ks log --- CMPLocationManager -- initGoogleMapsWirhMapKey: %@",googleMapKey);
    [CMPGoogleLocationManager sharedManager].googleMapKey = googleMapKey;
}

- (void)setGoogleMapKey:(NSString *)googleMapKey {
    _googleMapKey = googleMapKey;
}

+ (NSString *)googleMapKey
{
    return [CMPGoogleLocationManager sharedManager].googleMapKey;
}

#pragma mark - 定位相关

- (void)reGeocoderLocation:(CLLocation *)location pois:(getPoisCompetedBlock)getPoisCompeted {
    if ([NSString isNull:self.googleMapKey]) {
        return;
    }
    CLLocationCoordinate2D addressCoordinates = location.coordinate;
    [self googleReGeoApi:addressCoordinates pois:getPoisCompeted];
}

- (void)googleReGeoApi:(CLLocationCoordinate2D)coordinate pois:(getPoisCompetedBlock)getPoisCompeted{
    // 替换为你的谷歌API密钥
    NSString *apiKey = self.googleMapKey;
    // 构建请求URL
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@",coordinate.latitude, coordinate.longitude, apiKey];

    NSURL *url = [NSURL URLWithString:urlString];
    // 发起网络请求
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // 解析JSON响应
            NSError *jsonError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                options:NSJSONReadingMutableContainers
                error:&jsonError];
              
            if (!jsonError && jsonResponse) {
                if ([jsonResponse[@"status"] isEqualToString: @"OK"]) {
                    NSArray *results = jsonResponse[@"results"];
                    
                    NSMutableArray *pois = NSMutableArray.array;
                    CMPGoogleAddress *firstAddress = nil;
                    
                    for (int i=0; i<results.count; i++) {
                        NSDictionary *result = results[i];
                        NSString *formattedAddress = result[@"formatted_address"];
                        
                        NSArray *addressComponents = result[@"address_components"];
                        CMPGoogleAddress *address = [CMPGoogleAddress new];
                        address.formattedAddress = formattedAddress;
                        if (i==0) {
                            firstAddress = address;
                        }
                        
                        for (NSDictionary *component in addressComponents) {
                            NSArray *types = component[@"types"];
                            NSString *longName = component[@"long_name"];
                            if ([types containsObject:@"sublocality"]) {
                                address.district = longName;
                            }else if ([types containsObject:@"locality"]) {
                                address.city = longName;
                            }else if ([types containsObject:@"administrative"]
                                      || [types containsObject:@"administrative_area_level_1"]){
                                address.province = longName;
                            }else if ([types containsObject:@"country"]){
                                address.country = longName;
                            }else if ([types containsObject:@"route"]){
                                address.street = longName;
                            }else if ([types containsObject:@"postal_code"]){
                                address.postal_code = longName;
                            }
                        }
                        
                        AMapLocationReGeocode *poi = [self getAGeoWithAddress:address];
                        [pois addObject:poi];
                    }
                    
                    AMapReGeocode *aRegeo = [self getAReGeocodeWithAddress:firstAddress];
                    AMapGeoPoint *geoPoint = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                    if (getPoisCompeted) {
                        getPoisCompeted(@"google",pois,pois.firstObject,geoPoint,aRegeo,nil,nil,nil);
                    }
                } else {
                    NSString *errStr = [NSString stringWithFormat:@"Geocoding failed with status: %@", jsonResponse[@"status"]];
                    NSError *err = [NSError errorWithDomain:errStr code:500 userInfo:nil];
                    if (getPoisCompeted) {
                        getPoisCompeted(@"google",nil,nil,nil,nil,error,error,err);
                    }
                }
            } else {
                NSString *errStr = [NSString stringWithFormat:@"Error parsing JSON: %@", jsonError];
                NSError *err = [NSError errorWithDomain:errStr code:500 userInfo:nil];
                if (getPoisCompeted) {
                    getPoisCompeted(@"google",nil,nil,nil,nil,error,error,err);
                }
            }
        } else {
            if (getPoisCompeted) {
                getPoisCompeted(@"google",nil,nil,nil,nil,error,error,error);
            }
        }
    }];
    [dataTask resume];
}

- (AMapLocationReGeocode *)getAGeoWithAddress:(CMPGoogleAddress *)address {
    AMapLocationReGeocode *aGeo = [[AMapLocationReGeocode alloc] init];
    aGeo.country = address.country;
    aGeo.province = address.province;
    aGeo.city = address.city;
    aGeo.district = address.district;
    aGeo.street = address.street;
    aGeo.citycode = address.postal_code;
    aGeo.formattedAddress = address.formattedAddress;
    return aGeo;
}

- (AMapReGeocode *)getAReGeocodeWithAddress:(CMPGoogleAddress *)address {
    AMapReGeocode *aRegeo = [[AMapReGeocode alloc] init];
    aRegeo.addressComponent = [[AMapAddressComponent alloc] init];
    aRegeo.addressComponent.country = address.country;
    aRegeo.addressComponent.province = address.province;
    aRegeo.addressComponent.city = address.city;
    aRegeo.addressComponent.district = address.district;
    aRegeo.addressComponent.citycode = address.postal_code;
    aRegeo.formattedAddress = address.formattedAddress;
    return aRegeo;
}



@end
