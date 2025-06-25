//
//  CMPCookieTool.h
//  M3
//
//  Created by CRMO on 2018/2/27.
//

#import <CMPLib/CMPObject.h>

@interface CMPCookieTool : CMPObject

+ (NSString *)cookieStrFromat:(NSString *)cookie;
/**
 将离线登陆的cookie存到本地

 @param url 需要存储cookie的url
 @param responseHeaders 回复头
 */
+ (void)saveCookiesWithUrl:(NSString *)url responseHeaders:(NSDictionary *)responseHeaders;


/**
 判断本地存储的cookie是否过期
 */
+ (BOOL)isCookieExpired;

/**
 恢复本次存储的cookie设置到NSHTTPCookieStorage
 */
+ (BOOL)restoreCookies;

/**
 清理本地Cookie，webview的cache
 */
+ (void)clearCookiesAndCache;

/**
获取Cookie 里的 JSESSIONID
*/
+ (NSString *)JSESSIONIDForUrl:(NSString *)url;

@end
