//
//  CMPCookieTool.m
//  M3
//
//  Created by CRMO on 2018/2/27.
//

#import "CMPCookieTool.h"

static NSString * const kM3CookieUserDefaultsKey = @"m3cookie";
static NSString * const kM3CookieExpireUserDefaultsKey = @"m3cookie_expire";
static NSString * const kM3CookieCookiePathDefaultsKey = @"m3cookie_cookiePath";


@implementation CMPCookieTool
// "Set-Cookie" = "route=b8c209f1ee5d712250e31164ddc1bf93; Path=/, JSESSIONID=4AF7A2B7E051CC993FB3C6AE1E3E6BDC.SY20; Path=/seeyon; HttpOnly";
+ (NSString *)cookieStrFromat:(NSString *)cookie{
    NSString *cookieNewStr = cookie;
    if ([NSString isNotNull:cookie]) {
        NSArray *cookieArray = [cookie componentsSeparatedByString:@","];
        NSString *tmp = @"";
        for (NSString *cookieStr in cookieArray) {
            NSArray *array = [cookieStr componentsSeparatedByString:@";"];
            for (NSString *str in array) {
                NSArray *components = [str componentsSeparatedByString:@"="];
                if (components.count > 1) {
                    NSString *key = [components objectAtIndex:0];
                    NSString *value = [components objectAtIndex:1];
                    key = [key replaceCharacter:@" " withString:@""];
                    if (![key.lowercaseString isEqualToString:@"path"]) {
                        tmp = [tmp stringByAppendingFormat:@"%@=%@;",key,value];
                    }
                }
            }
        }
        cookieNewStr = tmp;
    }
    return cookieNewStr;
}

+ (void)saveCookiesWithUrl:(NSString *)url responseHeaders:(NSDictionary *)responseHeaders {
    NSString *cookiePath = @"";//获取cookie的路径
    NSString *setCookie = [responseHeaders objectForKey:@"Set-Cookie"];
    // "Set-Cookie" = "route=b8c209f1ee5d712250e31164ddc1bf93; Path=/, JSESSIONID=4AF7A2B7E051CC993FB3C6AE1E3E6BDC.SY20; Path=/seeyon; HttpOnly";
    if ([NSString isNotNull:setCookie]) {
        NSArray *cookieArray = [setCookie componentsSeparatedByString:@","];
        for (NSString *cookieStr in cookieArray) {
            if ([cookieStr rangeOfString:@"JSESSIONID"].location == NSNotFound) {
                continue;//不包含JSESSIONID，不处理
            }
            NSArray *array = [cookieStr componentsSeparatedByString:@";"];
            for (NSString *str in array) {
                NSArray *subArray = [str componentsSeparatedByString:@"="];
                if (subArray.count > 1) {
                    NSString *name = subArray[0];
                    name = [name replaceCharacter:@" " withString:@""];
                    if ([name.lowercaseString isEqualToString:@"path"]) {
                        cookiePath = subArray[1];
                        break;
                    }
                }
            }
        }
    }
    
    NSString *aUrl = [NSString stringWithFormat:@"%@%@",url,cookiePath];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:aUrl]];
    NSString *expireTime = [responseHeaders objectForKey:@"Accessed-Timeout"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger aExpireTime = [expireTime integerValue] * 0.9; // 将过期时间提前一点，防止临近过期时间cookie失效问题
    NSDate *expireDate = [NSDate dateWithTimeIntervalSinceNow:aExpireTime];
    [userDefaults setObject:data forKey:kM3CookieUserDefaultsKey];
    [userDefaults setObject:expireDate forKey:kM3CookieExpireUserDefaultsKey];
    [userDefaults setObject:cookiePath forKey:kM3CookieCookiePathDefaultsKey];
    [userDefaults synchronize];
}

+ (BOOL)isCookieExpired {
    NSDate *expireDate = [[NSUserDefaults standardUserDefaults] objectForKey:kM3CookieExpireUserDefaultsKey];
    if (!expireDate ||
        ![expireDate isKindOfClass:[NSDate class]]) {
        return YES;
    }
    
    NSDate *currentDate = [NSDate date];
    NSComparisonResult result = [currentDate compare:expireDate];
    
    if (result == NSOrderedAscending) {
        return NO;
    }

    return YES;
}

+ (BOOL)restoreCookies {
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:kM3CookieUserDefaultsKey];
    
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
        return YES;
    }
    
    return NO;
}

+ (void)clearCookiesAndCache {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:kM3CookieCookiePathDefaultsKey];
    [userDefaults synchronize];

}

+ (NSString *)JSESSIONIDForUrl:(NSString *)url {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cookiePath = [userDefaults objectForKey:kM3CookieCookiePathDefaultsKey];//获取cookie的路径
    if ([NSString isNull:cookiePath]) {
        cookiePath = @"";
    }
    NSString *aUrl = [NSString stringWithFormat:@"%@%@",url,cookiePath];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:aUrl]];

    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"JSESSIONID"]) {
            return cookie.value;
        }
    }
    return nil;
}

@end
