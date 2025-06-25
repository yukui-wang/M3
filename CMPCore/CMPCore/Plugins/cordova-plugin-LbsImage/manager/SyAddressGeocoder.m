//
//  SyAddressGeocoder.m
//  M1Core
//
//  Created by Aries on 14-3-25.
//
//

#import "SyAddressGeocoder.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "SySearchResult.h"
#import "CMPCommonManager.h"

@interface SyAddressGeocoder ()<AMapSearchDelegate>

@property (nonatomic,strong)AMapSearchAPI *search;

@property (nonatomic,copy)NSString *lastSearchCity;
@property (nonatomic,copy)NSString *lastSearchKeywords;

@end

@implementation SyAddressGeocoder

- (void)setAddress:(NSString *)address {
    
    if([address  isEqualToString: _address]) {
        return;
    }
    _address = [address copy];
    if(self.address.length == 0 || !self.address) {
         return;
    }
    
    [AMapServices sharedServices].apiKey = [CMPCommonManager lbsAPIKey];
    
    [self searchGeocodeWithKey:address adcode:@""];
    
}

- (void)searchPOIKeywordsWithCityName:(NSString *)city keywords:(NSString *)keywords {
    
    if ([NSString isNull:city] || [NSString isNull:keywords]) {
        return;
    }
    
    if ([self.lastSearchCity isEqualToString:city] && [self.lastSearchKeywords isEqualToString:keywords]) {
        return;
    }
    
    self.lastSearchCity = city;
    self.lastSearchKeywords = keywords;
   
    AMapPOIKeywordsSearchRequest *keywordsRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
    keywordsRequest.keywords = keywords;
    keywordsRequest.city = city;
    keywordsRequest.types = @"";
    keywordsRequest.sortrule = 0;
    //request.offset = 50;
    [self.search AMapPOIKeywordsSearch:keywordsRequest];
    
}

//地理编码 搜索
- (void)searchGeocodeWithKey:(NSString *)key adcode:(NSString *)adcode {
    
    if (key.length == 0) {
        return;
    }
    
    AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
    geoRequest.address = key;
    
    if (adcode.length > 0){
        geoRequest.city = adcode;
    }
    [self.search AMapGeocodeSearch:geoRequest];
}

#pragma mark - AMapSearchDelegate

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if (response.pois.count == 0) {
        if(_delegate && [_delegate respondsToSelector:@selector(addressGeocoderFailed:)]){
            [_delegate addressGeocoderFailed:self];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressGeocoder:searchKeywordsLocation:)]) {
        [self.delegate addressGeocoder:self searchKeywordsLocation:response.pois.firstObject.location];
    }
    
    //解析response获取POI信息，具体解析见 Demo
}


// 地理编码回调
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    if (response.geocodes.count == 0)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(addressGeocoderFailed:)]){
            [_delegate addressGeocoderFailed:self];
        }
        return;
    }
    SyGeoCodingSearchResult *aResult = [[SyGeoCodingSearchResult alloc] init];
    aResult.count = response.geocodes.count;
  
    for (AMapGeocode *coder in response.geocodes) {
        
        SyGeoPOI *aNewPoi = [[SyGeoPOI alloc] init];
        aNewPoi.x = coder.location.latitude;
        aNewPoi.y = coder.location.longitude;
        
        aNewPoi.address = coder.formattedAddress;
        aNewPoi.province = coder.province;
        aNewPoi.city = coder.city;
        aNewPoi.district = coder.district;
        [aResult.geoCodingArray addObject:aNewPoi];
        
    }
    if(_delegate && [_delegate respondsToSelector:@selector(addressGeocoder:finishedGeocoder:)] ){
        [_delegate addressGeocoder:self finishedGeocoder:aResult];
        return;
    }

}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error {
    if(_delegate && [_delegate respondsToSelector:@selector(addressGeocoderFailed:)]){
        [_delegate addressGeocoderFailed:self];
    }
}

#pragma mark - lazy

- (AMapSearchAPI *)search {
    if(!_search){
        [AMapSearchAPI updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
        [AMapSearchAPI updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
        _search = [[AMapSearchAPI alloc] init];
        _search.language = [CMPCore language_ZhCN]?AMapSearchLanguageZhCN:AMapSearchLanguageEn;
        _search.delegate = self;
    }
    return _search;
}

@end
