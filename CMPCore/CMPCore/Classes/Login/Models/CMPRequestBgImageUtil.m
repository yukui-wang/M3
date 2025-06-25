//
//  CMPRequestBgImageUtil.m
//  M3
//
//  Created by MacBook on 2020/1/9.
//

#import "CMPRequestBgImageUtil.h"
#import "CMPLoginView.h"

#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/EGOCache.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/UIColor+Hex.h>


@interface CMPRequestBgImageUtil()<CMPDataProviderDelegate>
@property (copy, nonatomic) RequestStart startBlock;
@property (copy, nonatomic) RequestProgressUpdateWithExt progressUpdateWithExtBlock;
@property (copy, nonatomic) RequestSuccess successBlock;
@property (copy, nonatomic) RequestFail failBlock;

@end

@implementation CMPRequestBgImageUtil

- (void)requestBackgroundWithStart:(RequestStart)start
             progressUpdateWithExt:(RequestProgressUpdateWithExt)update
                           success:(RequestSuccess)success
                              fail:(RequestFail)fail
{
    self.startBlock = start;
    self.progressUpdateWithExtBlock = update;
    self.successBlock = success;
    self.failBlock = fail;
    [self requestBackground];
}

- (void)requestBackground {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/seeyon/m3/homeSkinController.do"];
    url = [url appendHtmlUrlParam:@"method" value:@"getSkinImageUrl"];
    url = [url appendHtmlUrlParam:@"imageType" value:@"bg"];
    url = [url appendHtmlUrlParam:@"phoneType" value:@"iphone"];
    url = [url appendHtmlUrlParam:@"companyId" value:[CMPCore sharedInstance].currentUser.accountID];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSDictionary *strDic = [aResponse.responseStr JSONValue];
    NSError *error = nil;
    if (!strDic ||
        ![strDic isKindOfClass:[NSDictionary class]]) {
        self.failBlock(error);
        return;
    }
    
    NSDictionary *userInfo = aRequest.userInfo;
    if (!userInfo) {
        NSString *imageRelatePath = nil;
        id data = strDic[@"data"];
        
        // 服务器返回数据不是标准数据
        if (!data || (![data isKindOfClass:[NSString class]] && ![data isKindOfClass:[NSDictionary class]])) {
            self.failBlock(error);
            return;
        }
        
        CMPLoginViewStyle *style = [CMPLoginViewStyle defaultStyle];
        BOOL isDefault = NO;
        
        if ([data isKindOfClass:[NSString class]]) {
            imageRelatePath = data;
            NSString *imageUrl = [CMPCore fullUrlForPath:imageRelatePath];
            if ([NSString isNull:imageRelatePath]) {
                style.backgroundImage = nil;
                style.backgroundLandscapeImage = nil;
            }else {
                style.backgroundImage = imageUrl;
                style.backgroundLandscapeImage = imageUrl;
            }
        } else if ([data isKindOfClass:[NSDictionary class]]) { // 1130版本修改接口，新增登录文字颜色
            isDefault = data[@"deft"] ? [data[@"deft"] boolValue] : NO;
            imageRelatePath = data[@"bgImage"];
            NSString *inputTextColorStr = data[@"inputText"];
            NSString *selectedTagColorStr = data[@"selectedTag"];
            NSString *unselectTagColorStr = data[@"selectTag"];
            NSString *scanColor = data[@"scanColor"];
            NSString *titleColor = data[@"titleColor"];
            NSString *toServerSiteColor = data[@"toServerSiteColor"];
            
            //老版本登录页颜色
            if ([NSString isNotNull:scanColor]) {
                  style.inputTextColor = [UIColor colorWithHexString:inputTextColorStr];
            }
            if ([NSString isNotNull:scanColor]) {
                 style.tagSelectColor = [UIColor colorWithHexString:selectedTagColorStr];
            }
            if ([NSString isNotNull:scanColor]) {
                 style.tagUnSelectColor = [UIColor colorWithHexString:unselectTagColorStr];
            }
            //v8.0 版本登录页颜色
            if ([NSString isNotNull:scanColor]) {
                 style.scanColor = [UIColor colorWithHexString:scanColor];
            }
            if ([NSString isNotNull:titleColor]) {
                style.titleColor = [UIColor colorWithHexString:titleColor];
            }
            if ([NSString isNotNull:toServerSiteColor]) {
                style.toServerSiteColor = [UIColor colorWithHexString:toServerSiteColor];
            }
            
            NSDictionary *bgStyle = data[@"bgStyle"];
            if (bgStyle && [bgStyle isKindOfClass:[NSDictionary class]]) {
                NSNumber *maskAlpha = bgStyle[@"transparency"];
                NSString *maskColorStr = bgStyle[@"color"];
                style.backgroundMaskColor = [UIColor colorWithHexString:maskColorStr];
                style.backgroundMaskAlpha = [maskAlpha doubleValue] / 100;
            }
            
            NSString *imageUrl = [CMPCore fullUrlForPath:imageRelatePath];
            if (isDefault) {
                style.backgroundImage = nil;
                style.backgroundLandscapeImage = nil;
            }else {
                style.backgroundImage = imageUrl;
                style.backgroundLandscapeImage = imageUrl;
            }
            
            NSDictionary * moreBgImage = data[@"moreBgImage"];
            if (moreBgImage && [moreBgImage isKindOfClass:[NSDictionary class]]) {
                NSDictionary *bgImageDic = nil;
                if (INTERFACE_IS_PAD) {
                    bgImageDic = moreBgImage[@"pad"];
                } else if (INTERFACE_IS_PHONE) {
                    bgImageDic = moreBgImage[@"phone"];
                }
                
                if ([bgImageDic count]) {
                    NSMutableDictionary *portraitCompareResultDic = [NSMutableDictionary dictionary];
                    NSMutableDictionary *landscapeCompareResultDic = [NSMutableDictionary dictionary];
                    CGFloat screenWidth = [UIScreen mainScreen].nativeBounds.size.width;
                    CGFloat screenheight = [UIScreen mainScreen].nativeBounds.size.height;
                    CGFloat portraitScale = screenWidth/screenheight;
                    CGFloat landscapeScale = screenheight/screenWidth;
                    
                    [bgImageDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([key isKindOfClass:NSString.class] && [key containsString:@"*"]) {
                            NSArray *sizeArr = [key componentsSeparatedByString:@"*"];
                            CGFloat width = [sizeArr[0] doubleValue];
                            CGFloat heght = [sizeArr[1] doubleValue];
                            CGFloat scale = width/heght;
                            CGFloat portraitCompare = fabs(scale - portraitScale);
                            CGFloat landscapeCompare = fabs(scale - landscapeScale);
                            [portraitCompareResultDic setObject:obj forKey:[NSNumber numberWithDouble:portraitCompare]];
                            [landscapeCompareResultDic setObject:obj forKey:[NSNumber numberWithDouble:landscapeCompare]];
                        }
                    }];
                    
                    NSArray *portraitCompareResultArr = [portraitCompareResultDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        return [obj1 compare:obj2];
                    }];
                    
                    NSArray *landscapeCompareResultArr = [landscapeCompareResultDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        return [obj1 compare:obj2];
                    }];
                    
                    NSString *portraitUrl = portraitCompareResultDic[portraitCompareResultArr.firstObject];
                    NSString *landscapeUrl = landscapeCompareResultDic[landscapeCompareResultArr.firstObject];
                    style.backgroundImage = [NSString stringWithFormat:@"%@%@", [CMPCore sharedInstance].serverurl, portraitUrl];
                    style.backgroundLandscapeImage = [NSString stringWithFormat:@"%@%@", [CMPCore sharedInstance].serverurl, landscapeUrl];
                    
                } else {
                    style.backgroundImage = nil;
                    style.backgroundLandscapeImage = nil;
                }
            }
        }
        [self saveLoginViewStyle:style];
        self.successBlock(style);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    self.failBlock(error);
}

- (void)saveLoginViewStyle:(CMPLoginViewStyle *)style {
    NSLog(@"zl---[login style]:缓存样式：%@", style);
    [[EGOCache globalCache] setObject:style forKey:[self _loginViewStyleKey]];
}

- (NSString*)_loginViewStyleKey {
    NSString *aServerVersion = @"";
    if ([CMPCore sharedInstance].serverIsLaterV8_0) {
        aServerVersion = @"3_5_0_";
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@loginViewStyle", [CMPCore sharedInstance].serverID, aServerVersion];
    NSLog(@"zl---[login style]:缓存key%@", key);
    return key;
}

- (CMPLoginViewStyle *)currentLoginViewStyle {
    CMPLoginViewStyle *style = (CMPLoginViewStyle *)[[EGOCache globalCache] objectForKey:[self _loginViewStyleKey]];
    if (!style) {
        NSLog(@"zl---[login style]:没有获取到缓存样式，使用默认样式");
        return [CMPLoginViewStyle defaultStyle];
    }
    NSLog(@"zl---[login style]:获取到缓存样式：%@", style);
    return style;
}

@end
