//
//  CMPURLUtils.m
//  M3
//
//  Created by youlin on 2020/3/3.
//

#import "CMPURLUtils.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPServerVersionUtils.h>
@implementation CMPURLUtils

static NSDictionary *_urlPathDict;
+ (NSString *)urlPathMatch:(NSString *)path serverVersion:(NSString *)version {
    return [CMPURLUtils urlPathMatch:path serverVersion:version contextPath:KURLPath_Seeyon];
}
+ (NSString *)urlPathMatch:(NSString *)path serverVersion:(NSString *)version contextPath:(NSString *)contextPath {
    if (![CMPServerVersionUtils serverIsLaterV8_0WithServerVersion:version]) {
        return path;
    }
    if (!_urlPathDict) {
        _urlPathDict = @{
            @"/api/pns/device/register":@"/rest/pns/device/register",
            @"/api/verification/logout":@"/rest/m3/login/logout",
            @"/api/verification/login":@"/rest/m3/login/verification",
            @"/api/mobile/app/list":@"/rest/m3/appManager/getCurrentUserAppList",
            @"/api/mobile/app/download/":@"/rest/m3/appManager/download/",
            @"/api/message/classification":@"/rest/m3/message/classification",
            @"/api/message/delete/":@"/rest/m3/message/remove/",
            @"/api/message/update/":@"/rest/m3/message/update/",
            @"/api/bind/apply":@"/rest/m3/security/device/apply",
            @"/api/contacts2/frequentContacts/":@"/rest/contacts2/frequentContacts/",
            @"/api/pns/message/setOfflineMsgCount/":@"/rest/m3/message/setOfflineMsgCount/",
            @"/seeyon/m3/homeSkinController.do":@"/rest/m3/theme/homeSkin",
            @"/seeyon/fileUpload.do":@"/rest/commonImage/showImage",
            @"/seeyon/m3/offlineDownload.do":@"/rest/m3/contacts/offline/download/"
        };
    }
    
    NSString *mapUrlPath = _urlPathDict[path];
    return [contextPath?:KURLPath_Seeyon stringByAppendingString:mapUrlPath?:path];

}

+ (NSString *)requestURLWithHost:(NSString *)aHost path:(NSString *)aPath 
{
    NSString *aUrl = [aHost stringByAppendingString:aPath];
    return aUrl;
}

+ (NSString *)ignoreDefaultPort:(NSString *)url{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:url];
    if (urlComponents) {
        BOOL http_flag = [urlComponents.scheme.lowercaseString containsString:@"http"] &&  urlComponents.port.integerValue == 80;
        BOOL http_s_flag = [urlComponents.scheme.lowercaseString containsString:@"https"] && urlComponents.port.integerValue == 443;
        if (http_flag || http_s_flag) {
            urlComponents.port = nil;
            return urlComponents.URL.absoluteString;
        }
    }
    return url;
}

@end
