//
//  WKWebRequestManager+CMP.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/11/11.
//

#import "WKWebRequestManager+CMP.h"
#import <CMPLib/CMPJSLocalStorageManager.h>

@implementation WKWebRequestManager (CMP)

- (void)localstorageRequestWithBody:(NSDictionary *)body
                      webview:(nullable WKWebView *)webview
               completedBlock:(nullable WKWebRequestCallback)completedBlock {
    NSString *action = body[@"action"];
    NSString *key = body[@"key"];
    NSLog(@"ks log --- localstorageRequestWithBody---- body:%@",body);
    
//    if (!IOS11_Later) {
//        NSLog(@"ks log --- localstorageRequestWithBody---- os version low");
//        if (completedBlock) {
//            completedBlock(@"");
//        }
//        return;
//    }
    
    if ([WKWebRequest isNullString:action]) {
        NSLog(@"ks log --- localstorageRequestWithBody---- action null");
        if (completedBlock) {
            completedBlock(@"");
        }
        return;
    }
    
    void(^consoleAllBlk)(void) = ^{
//        NSDictionary *dic = [CMPJSLocalStorageManager allLocalStorageInfo];
//        NSLog(@"ks log --- localstorageRequestWithBody---- 所有操作后的数据：%@",dic);
    };
    
    if ([action isEqualToString:@"setItem"]) {
        NSString *val = body[@"value"];
        BOOL result = [CMPJSLocalStorageManager setItem:val forKey:key];
//        NSLog(@"ks log --- localstorageRequestWithBody----setItem key:%@ --- value:%@ --- result:%@",key,val,[NSString stringWithBool:result]);
        if (completedBlock) {
            completedBlock([NSString stringWithBool:result]);
        }
        
        consoleAllBlk();
        
    }else if ([action isEqualToString:@"getItem"]){
        NSString *result = [CMPJSLocalStorageManager getItem:key];
//        NSLog(@"ks log --- localstorageRequestWithBody----getItem key:%@ --- result:%@",key,result);
        if (completedBlock) {
            completedBlock(result);
        }
    }else if ([action isEqualToString:@"removeItem"]){
        BOOL result = [CMPJSLocalStorageManager removeItem:key];
//        NSLog(@"ks log --- localstorageRequestWithBody----removeItem key:%@ ---  result:%@",key,[NSString stringWithBool:result]);
        if (completedBlock) {
            completedBlock([NSString stringWithBool:result]);
        }
        
        consoleAllBlk();
        
    }else if ([action isEqualToString:@"getAllData"]){
        NSDictionary *dic = [CMPJSLocalStorageManager allLocalStorageInfo];
//        NSLog(@"ks log --- localstorageRequestWithBody----getAllData 所有数据withNoPrefix：%@",dic);
        
        if (completedBlock) {
            completedBlock([dic JSONRepresentation]);
        }
    }
}


- (void)cookiepolicyRequestWithBody:(NSDictionary *)body
                      webview:(nullable WKWebView *)webview
               completedBlock:(nullable WKWebRequestCallback)completedBlock
{
    if ([CMPCore sharedInstance].serverID) {
        NSString *action = [NSString stringWithFormat:@"%@",body[@"action"]];
        NSString *key = [@"cmp_cookiepolicy_" stringByAppendingString:[CMPCore sharedInstance].serverID];
        [[NSUserDefaults standardUserDefaults] setObject:action forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (void)conndidrespRequestWithBody:(NSDictionary *)body
                      webview:(nullable WKWebView *)webview
               completedBlock:(nullable WKWebRequestCallback)completedBlock
{
    if ([CMPCore sharedInstance].serverID) {
        NSString *key = [@"cmp_conndidresp_" stringByAppendingString:[CMPCore sharedInstance].serverID];
        [[NSUserDefaults standardUserDefaults] setObject:body forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)verifyRequestWithBody:(NSDictionary *)body
                      webview:(nullable WKWebView *)webview
                     completedBlock:(nullable WKWebRequestCallback)completedBlock {
    if (!completedBlock) return;
    NSString *condition = body[@"condition"];
    NSString *param = body[@"param"];
    NSString *key = body[@"key"];
    NSLog(@"ks log --- localstorageRequestWithBody---- body:%@",body);
    if (condition && [@"equal" isEqualToString:condition]) {
        if (key && [@"ctxpath" isEqualToString:key.lowercaseString]) {
            NSString *curUrl = [CMPCore sharedInstance].currentServer.fullUrl;
            if (param && curUrl && [param isKindOfClass:NSString.class] && [param hasPrefix:curUrl]) {
                completedBlock(@"1");
                return;
            }
            completedBlock(@"0");
            return;
        }
    }
    completedBlock(@"");
}

@end
