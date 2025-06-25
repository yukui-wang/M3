//
//  CMPLocalAuthenticationState.m
//  M3
//
//  Created by CRMO on 2019/1/18.
//

#import "CMPLocalAuthenticationState.h"
#import <CMPLib/EGOCache.h>
#import <CMPLib/CMPCore.h>
#import "M3LoginManager.h"

@implementation CMPLocalAuthenticationState

- (BOOL)enableLoginTouchID {
    NSDictionary *dic = [[CMPLocalAuthenticationState stateJson] JSONValue];
    if (!dic ||
        ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSDictionary *touchID = dic[@"touchID"];
    NSNumber *enableLoginTouchID = touchID[@"login"];
    return [enableLoginTouchID boolValue];
}

- (BOOL)enableLoginFaceID {
    NSDictionary *dic = [[CMPLocalAuthenticationState stateJson] JSONValue];
    if (!dic ||
        ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSDictionary *touchID = dic[@"faceID"];
    NSNumber *enableLoginTouchID = touchID[@"login"];
    return [enableLoginTouchID boolValue];
}

+ (void)updateWithJson:(NSString *)json {
    if ([NSString isNull:json]) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@_LocalAuthenticationState", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID];
    [[EGOCache globalCache] setString:json forKey:key];
    NSLog(@"%s_%@",__func__,json);
}

+ (NSString *)stateJson {
    NSString *key = [NSString stringWithFormat:@"%@_%@_LocalAuthenticationState", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID];
    NSString *json = [[EGOCache globalCache] stringForKey:key];
    return json;
}

+(BOOL)updateFaceID:(BOOL)open
{
    if (![M3LoginManager sharedInstance].localAuthenticationState.enableLoginFaceID) {
        return NO;
    }
    NSDictionary *dic = [[CMPLocalAuthenticationState stateJson] JSONValue];
    NSMutableDictionary *faceDic = [NSMutableDictionary dictionaryWithDictionary:dic[@"faceID"]];
    [faceDic setObject:open ? @(1):@(0) forKey:@"login"];
    NSMutableDictionary *dicm = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dicm setObject:faceDic forKey:@"faceID"];
    [CMPLocalAuthenticationState updateWithJson:[dicm JSONRepresentation]];
    return YES;
}

+(BOOL)updateTouchID:(BOOL)open
{
    if (![M3LoginManager sharedInstance].localAuthenticationState.enableLoginTouchID) {
        return NO;
    }
    NSDictionary *dic = [[CMPLocalAuthenticationState stateJson] JSONValue];
    NSMutableDictionary *faceDic = [NSMutableDictionary dictionaryWithDictionary:dic[@"touchID"]];
    [faceDic setObject:open ? @(1):@(0) forKey:@"login"];
    NSMutableDictionary *dicm = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dicm setObject:faceDic forKey:@"touchID"];
    [CMPLocalAuthenticationState updateWithJson:[dicm JSONRepresentation]];
    return YES;
}

@end
