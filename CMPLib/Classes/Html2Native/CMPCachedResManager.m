//
//  CMPCachedResManager.m
//  CMPCore
//
//  Created by youlin on 16/5/17.
//
//

#import "CMPCachedResManager.h"
#import "CMPAppManager.h"

@implementation CMPCachedResManager

+ (BOOL)checkCachedResWithHost:(NSString *)aHost
{
    if (!aHost) {
        return NO;
    }
    NSDictionary *aDict = [[CMPAppManager appInfoMap] objectForKey:aHost];
    if (aDict) {
        return YES;
    }
    return NO;
}

+ (NSString *)rootPathWithHost:(NSString *)aHost version:(NSString *)aVersion
{
//    if ([aHost isEqualToString:@"collaboration.v5.cmp"]) {
//         return @"/Users/songu/Desktop/17D22A1B-3CEB-40E8-9ABC-22FF04407928";
//     }
   // 开启本地代码调试
  /*  
   if ([aHost isEqualToString:@"login.m3.cmp"]) {
        return @"/Users/youlinguo/Documents/mplus/h5/trunk/src/apps/m3/login";
    }
    else if ([aHost isEqualToString:@"application.m3.cmp"]) {
        return @"/Users/youlinguo/Documents/mplus/h5/trunk/src/apps/m3/application";
    }
    else if ([aHost isEqualToString:@"commons.m3.cmp"]) {
        return @"/Users/youlinguo/Documents/mplus/h5/trunk/src/apps/m3/commons";
    }
    else if ([aHost isEqualToString:@"message.m3.cmp"]) {
        return @"/Users/youlinguo/Documents/mplus/h5/trunk/src/apps/m3/message";
    }
    else if ([aHost isEqualToString:@"my.m3.cmp"]) {
        return @"/Users/youlinguo/Documents/mplus/h5/trunk/src/apps/m3/my";
    }
    else if ([aHost isEqualToString:@"search.m3.cmp"]) {
        return @"/Users/youlinguo/Documents/mplus/h5/trunk/src/apps/m3/search";
    }
    else if ([aHost isEqualToString:@"todo.m3.cmp"]) {
        return @"/Users/youlinguo/Documents/mplus/h5/trunk/src/apps/m3/todo";
    }
   
    if ([aHost isEqualToString:@"cmp"]) {
        return @"/Users/youlinguo/Desktop/debug/cmp";
    }
    if ([aHost isEqualToString:@"todo.m3.cmp"]) {
        return @"/Users/youlinguo/Desktop/debug/todo";
    }
    if ([aHost isEqualToString:@"commons.m3.cmp"]) {
          return @"/Users/youlinguo/Desktop/debug/commons";
    }
    if ([aHost isEqualToString:@"meeting.v5.cmp"]) {
           return @"/Users/youlinguo/Desktop/debug/meeting";
     }
    if ([aHost isEqualToString:@"application.m3.cmp"]) {
        return @"/Users/youlinguo/Desktop/debug/application";
    }
   */
    // 开启本地代码调试结束
    
    // add by guoyl 去掉v
    aVersion = [aVersion stringByReplacingOccurrencesOfString:@"v" withString:@""];
    // add end
    NSDictionary *aDict = [[CMPAppManager appInfoMap] objectForKey:aHost];
    CMPDBAppInfo *appInfo = [aDict objectForKey:aVersion];
    if (!appInfo) {
        if (aDict.allValues.count){
            appInfo = aDict.allValues.firstObject;
        }
        if (!appInfo){
            appInfo = [[aDict allValues] lastObject];
        }
    }
    if (!appInfo) {
        NSLog(@"%@ verseion %@ not be found!", aHost, aVersion);
        return nil;
    }
    if (![NSString isNull:appInfo.extend2]) {
        return [CMPAppManager documentWithPath:appInfo.extend2];
    }
    return [CMPAppManager documentWithPath:appInfo.path];
}

@end
