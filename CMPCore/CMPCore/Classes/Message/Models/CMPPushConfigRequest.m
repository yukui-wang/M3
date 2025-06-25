//
//  CMPPushConfigRequest.m
//  M3
//
//  Created by CRMO on 2018/1/17.
//

#import "CMPPushConfigRequest.h"

@implementation CMPPushConfigRequest

- (NSString *)requestUrl {
    NSString *userId = [CMPCore sharedInstance].userID;
    NSString *url;
    
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        url = [CMPCore fullUrlForPath:@"/rest/m3/config/user/new/message/settings"];
    } else {
        url = [CMPCore fullUrlForPathFormat:@"/rest/pns/setting/get/%@",userId];
    }
    
    return url;
}

@end
