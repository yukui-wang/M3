//
//  SYGeocoder.m
//  M1Core
//
//  Created by Aries on 14-3-7.
//
//

#import "SyReverseGeocoder.h"
#import <MapKit/MapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPCore.h>
@interface SyReverseGeocoder ()<AMapSearchDelegate>
{
    AMapSearchAPI *_search;
}
@end

@implementation SyReverseGeocoder

- (void)dealloc
{
    _search.delegate = nil;
    [_search release];
    _search = nil;
    [_geoLocation release];
    _geoLocation = nil;
    [super dealloc];
}

//设置经纬度，根据经纬度进行地理逆解析
- (void)setGeoLocation:(CLLocation *)geoLocation
{
    if(geoLocation == _geoLocation)
        return;
    if(geoLocation == nil)
        return;
    _geoLocation = nil;
    _geoLocation = [geoLocation retain];
    
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [AMapServices sharedServices].apiKey = [CMPCommonManager lbsAPIKey];

    if(!_search){
        [AMapSearchAPI updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
        [AMapSearchAPI updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
        //构造 AMapReGeocodeSearchRequest 对象,location 为必选项,radius 为可选项
        _search.language = [CMPCore language_ZhCN]?AMapSearchLanguageZhCN:AMapSearchLanguageEn;
    }
    [_search cancelAllRequests];
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:_geoLocation.coordinate.latitude longitude:_geoLocation.coordinate.longitude];
    request.location = [AMapGeoPoint locationWithLatitude:13.778106 longitude:100.4863015];
    //<-122.031219, 37.332331>
    //request.location = [AMapGeoPoint locationWithLatitude:37.32415135481359 longitude:-122.03014662489296];
    //request.keywords = @"";
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
//    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施I|Arts & Entertainment|College & University|Event|Food|Nightlife Spot|Outdoors & Recreation|Professional & Other Places|Residence|Shop & Service|Travel & Transport";
//    request.types = @"Arts & Entertainment|College & University|Event|Food|Nightlife Spot|Outdoors & Recreation|Professional & Other Places|Residence|Shop & Service|Travel & Transport";
    request.types = @"Arts & Entertainment|College & University|Event|Food|Nightlife Spot|Outdoors & Recreation|Professional & Other Places|Residence|Shop & Service|Travel & Transport";
    //request.types = @"Food";
    request.sortrule = 0;
    //request.requireExtension = YES;
   // request.city = @"Cupertino";
    //request.offset = 50;
    //发起周边搜索
    //[_search AMapPOIAroundSearch: request];
    [request release];
    request = nil;
    
    //海外POI关键字搜索 OK
    AMapPOIKeywordsSearchRequest *keywordsRequest = [[[AMapPOIKeywordsSearchRequest alloc] init] autorelease];
    keywordsRequest.keywords = @"park";
    keywordsRequest.city = @"Woodland";
    keywordsRequest.types = @"";
    keywordsRequest.sortrule = 0;
    //request.offset = 50;
    //[_search AMapPOIKeywordsSearch:keywordsRequest];
    
    AMapReGeocodeSearchRequest *regeo = [[[AMapReGeocodeSearchRequest alloc] init] autorelease];

    regeo.location                    = [AMapGeoPoint locationWithLatitude:_geoLocation.coordinate.latitude longitude:_geoLocation.coordinate.longitude];
    regeo.requireExtension            = YES;
    regeo.poitype = @"Event";
    [_search AMapReGoecodeSearch:regeo];
    
/*
    AMapPlaceSearchRequest *request = [[[AMapPlaceSearchRequest alloc] init] autorelease];
    
    request.searchType = AMapSearchType_PlaceAround;
    request.location = [AMapGeoPoint locationWithLatitude:_geoLocation.coordinate.latitude
                                                longitude:_geoLocation.coordinate.longitude];
    request.offset = 10;
    request.requireExtension = YES;
    request.page = 1;
    request.sortrule = 1;

    //发起逆地理编码
    [_search AMapPlaceSearch: request];
    
*/
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if (response.regeocode != nil) {
        if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderDidFinsh:withSyAddress:)]) {
            AMapReGeocode *regeocode = response.regeocode;
            SyAddress *address = [[SyAddress alloc] init];
            address.provinceName =  regeocode.addressComponent.province;
            address.cityName = regeocode.addressComponent.city;
            address.districtName = regeocode.addressComponent.district;
            address.street = regeocode.formattedAddress;
            address.nearestPOI =  regeocode.formattedAddress;
            address.citycode = regeocode.addressComponent.citycode;
            address.latitude = request.location.latitude;
            address.longitude = request.location.longitude;
            [_delegate reverseGeocoderDidFinsh:self withSyAddress:address];
        }
    }
}


//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    NSLog(@"respons.count: %ld", (long)response.count);
    
    if(response.pois.count == 0) {
        //没有结果，解析失败
        if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderFail:)]){
            
            [_delegate reverseGeocoderFail:self];
        }
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    //处理搜索结果
    
    NSArray *pois = response.pois;
    
    if(pois.count == 0){
        if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderFail:)]){
            [_delegate reverseGeocoderFail:self];
        }
        return;
    }
    
    BOOL la = [CMPCore language_ZhCN];
    if (la) {
        [self handleResponse:response province:@"" city:@""];
    }
    else {
        AMapPOI *poi = [pois firstObject];
        CLGeocoder *reverseGeocoder=[[[CLGeocoder alloc]  init] autorelease];
        CLLocation *aLocation  = [[[CLLocation alloc] initWithLatitude: poi.location.latitude
                                                             longitude: poi.location.longitude] autorelease];
        __weak SyReverseGeocoder* weakSelf = self;
        
        [reverseGeocoder reverseGeocodeLocation:aLocation completionHandler:^(NSArray *array, NSError *error)
         {
             CLPlacemark *placeMark = [array lastObject];
             NSString *cityName = @"";
             NSString *province = @"";
             if (placeMark != nil){
                 cityName = [placeMark.addressDictionary objectForKey:@"City"];
                 province = [placeMark.addressDictionary objectForKey:@"State"];
             }
             [weakSelf handleResponse:response province:province city:cityName];
             
         }];
    }
}

- (void)handleResponse:(AMapPOISearchResponse *)response province:(NSString *)province city:(NSString *)city
{
    NSMutableArray *addressArr = [NSMutableArray array];
    NSArray *pois = response.pois;
    BOOL la = [CMPCore language_ZhCN];
    for (AMapPOI *poi in pois) {
        SyAddress *addressOne = [[SyAddress alloc] init];
        
        addressOne.provinceName = la ? poi.province :province;
        addressOne.cityName = la ? poi.city:city;
        addressOne.districtName = poi.district;
        addressOne.street = poi.address;
        addressOne.nearestPOI = poi.name;
        addressOne.nearestPOI = poi.name;
        addressOne.citycode = poi.citycode;
        addressOne.latitude = poi.location.latitude;
        addressOne.longitude = poi.location.longitude;
        [addressArr addObject:addressOne];
        [addressOne release];
        
    }
    SyAddress *addressOne = [addressArr firstObject];
    if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderDidFinsh:withSyAddress:)]){
        [_delegate reverseGeocoderDidFinsh:self withSyAddress:addressOne];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderDidFinsh:withSyAddressList:)]){
        [_delegate reverseGeocoderDidFinsh:self withSyAddressList:addressArr];
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    
}
/*
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request
                 response:(AMapPlaceSearchResponse *)respons
{
    NSLog(@"respons.count: %ld", (long)respons.count);
    
    if(respons.pois != nil) {
        //处理搜索结果

        NSArray *pois = respons.pois;
        
        NSMutableArray *addressArr = [NSMutableArray array];
        
        for (AMapPOI *poi in pois) {
            SyAddress *addressOne = [[SyAddress alloc] init];
          
            addressOne.provinceName = poi.province;
            addressOne.cityName = poi.city;
            addressOne.districtName = poi.district;
            addressOne.street = poi.address;
            addressOne.nearestPOI = poi.name;
            addressOne.nearestPOI = poi.name;
            addressOne.citycode = poi.citycode;
            [addressArr addObject:addressOne];
            [addressOne release];
        }
        SyAddress *addressOne = [addressArr firstObject];
        if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderDidFinsh:withSyAddress:)]){
            [_delegate reverseGeocoderDidFinsh:self withSyAddress:addressOne];
        }
        if(addressArr.count == 0){
            if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderFail:)]){
                
                [_delegate reverseGeocoderFail:self];
            }
            return;
        }
        
        if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderDidFinsh:withSyAddressList:)]){
            [_delegate reverseGeocoderDidFinsh:self withSyAddressList:addressArr];
        }
        
    }else {
        //没有结果，解析失败
        if(_delegate && [_delegate respondsToSelector:@selector(reverseGeocoderFail:)]){
            
            [_delegate reverseGeocoderFail:self];
        }
    }


}

*/
@end


@implementation SyAddress

- (void)dealloc
{
    [_provinceName release];
    [_cityName release];
    [_districtName release];
    [_nearestPOI release];
    [_street release];
    [_citycode release];
    [_country release];
    [super dealloc];
}
- (NSString *)longName
{
    NSMutableString *retString = [[[NSMutableString alloc] init] autorelease];
    
    if(_provinceName && _provinceName.length > 0){
        [retString appendString:_provinceName];
    }
    if(  _cityName && _cityName.length > 0 && ![_cityName isEqualToString:_provinceName]){
        [retString appendString:_cityName];
    }
    if(_districtName && _districtName.length > 0){
        [retString appendString:_districtName];
    }
  
    if(_nearestPOI && _nearestPOI.length > 0){
        [retString appendFormat:@"%@",_nearestPOI];
    }
    if(retString.length == 0)
        return nil;
    return retString;
}
- (NSString *)roadName
{
    NSMutableString *retString = [[[NSMutableString alloc] init] autorelease];
    
    if(_provinceName && _provinceName.length > 0){
        [retString appendString:_provinceName];
    }
    if(_cityName && _cityName.length > 0 && ![_cityName isEqualToString:_provinceName]){
        [retString appendString:_cityName];
    }
    if(_districtName && _districtName.length > 0){
        [retString appendString:_districtName];
    }
    if(_street && _street.length > 0){
        [retString appendString:_street];
    }
    if(retString.length == 0)
        return nil;
    return retString;

}



- (NSString *)imageName
{
    NSMutableString *retString = [[[NSMutableString alloc] init] autorelease];
    
    

    if(_districtName && _districtName.length > 0){
        [retString appendString:_districtName];
    }
    
    if(_nearestPOI && _nearestPOI.length > 0){
        [retString appendFormat:@"%@",_nearestPOI];
    }
    if(_cityName && _cityName.length > 0 && ![_cityName isEqualToString:_provinceName]){
        [retString appendString:@"-"];
        [retString appendString:_cityName];
    }
    if(retString.length == 0)
        return nil;
    return retString;
}

- (NSDictionary *)deaultAddressDictionary
{
    NSString *longitude = [[NSNumber numberWithDouble:self.longitude] stringValue];
    NSString *latitude = [[NSNumber numberWithDouble:self.latitude] stringValue];
//    NSString *address = [self longName];
    NSString *address = self.nearestPOI;
    
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
    addressDictionary[@"category"] = @"2";
    addressDictionary[@"lbsLongitude"] = longitude ?: NSNull.null;
    addressDictionary[@"lbsLatitude"] = latitude ?: NSNull.null;
    addressDictionary[@"lbsComment"] = NSNull.null;
    
    if(address && address.length > 0){
        [addressDictionary setValue:address forKey:@"lbsAddr"];
    }else{
        [addressDictionary setValue:[NSNull null] forKey:@"lbsAddr"];
    }
    if(self.provinceName && self.provinceName.length > 0){
        [addressDictionary setValue:self.provinceName forKey:@"lbsProvince"];
    }else{
        [addressDictionary setValue:[NSNull null] forKey:@"lbsProvince"];
    }
    if(self.cityName && self.cityName.length > 0){
        [addressDictionary setValue: self.cityName forKey:@"lbsCity"];
    }else{
        [addressDictionary setValue: [NSNull null] forKey:@"lbsCity"];
    }
    if(self.street && self.street.length > 0){
        [addressDictionary setValue:self.street forKey:@"lbsStreet"];
    }else{
        [addressDictionary setValue:[NSNull null] forKey:@"lbsStreet"];
    }
    [addressDictionary setValue:[NSNull null] forKey:@"lbsContinent"];
    [addressDictionary setValue:self.country forKey:@"lbsCountry"];
    [addressDictionary setValue:self.districtName forKey:@"lbsTown"];
    addressDictionary[@"createDate"] = NSNull.null;
    addressDictionary[@"provider"] = self.provider;
    return addressDictionary;
}

@end
