//
//  CMPInvoiceHelper.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/14.
//

#import "CMPInvoiceHelper.h"
#import "CMPAccessTokenManager.h"
#import "CMPInvoiceWechatHelper.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPSMEncryptManager.h"

@implementation CMPInvoiceHelper

+(NSDictionary *)fetchCmpNewAccessTokenByParams:(NSDictionary *)params
{
    return [CMPAccessTokenManager generateNewAccessTokenByParams:params];
}

+(BOOL)fetchOtherPlatformInvoiceList:(NSDictionary *)params result:(void(^)(id data, NSError *error))resultBlk
{
    if (!resultBlk) {
        return NO;
    }
    if (!params) {
        resultBlk(nil,[NSError errorWithDomain:@"params is nil" code:-1001 userInfo:nil]);
        return NO;
    }
    NSString *accessToken = params[@"accessToken"];
    if (!accessToken) {
        resultBlk(nil,[NSError errorWithDomain:@"accessToken is null" code:-1001 userInfo:nil]);
        return NO;
    }
    BOOL isExperied = [CMPAccessTokenManager verifyAccessTokenExperied:accessToken];
    if (isExperied) {
        resultBlk(nil,[NSError errorWithDomain:@"token is experied" code:-1001 userInfo:nil]);
        return NO;
    }
    
    NSString *plat = params[@"plat"];
    if (!plat){
        resultBlk(nil,[NSError errorWithDomain:@"plat is null" code:-1001 userInfo:nil]);
        return NO;
    }
    //需要提示用户确权
    NSString *appName = params[@"appName"]?:@"";
    CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:appName message:@"此应用想访问微信" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] callback:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
            {
                if ([@"weixin" isEqualToString:plat]) {
                    BOOL isSelfSignature = [params[@"isSelfSignature"] boolValue];
                    if (isSelfSignature) {
                        BOOL suc = [[CMPInvoiceWechatHelper shareInstance] config:params];
                        if (!suc) {
                            resultBlk(nil,[NSError errorWithDomain:@"self signature fail" code:-1001 userInfo:nil]);
                            return;
                        }
                    }
                    [[CMPInvoiceWechatHelper shareInstance] getWXInvoiceWithCompletion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                        if (!error) {
                            NSString *data = [respData yy_modelToJSONString];
                            NSString *str = [[CMPSMEncryptManager shareInstance] encryptText:data];
                            resultBlk(str,nil);
                        }else{
                            resultBlk(respData,error);
                        }
                    }];
                    
                }else if ([@"alipay" isEqualToString:plat]){
                    
                }
            }
                break;
                
            default:
                break;
        }
    }];
    [alert show];
    
    return YES;
}

+(BOOL)decodeCmpInvoiceDataByParams:(NSDictionary *)param result:(void(^)(id data, NSError *error))resultBlk
{
    if (!param || !resultBlk) {
        return NO;
    }
    NSString *accessToken = param[@"accessToken"];
    if (!accessToken || accessToken.length == 0) {
        resultBlk(nil,[NSError errorWithDomain:@"accessToken is null" code:-1001 userInfo:nil]);
        return NO;
    }
    NSString *invoiceData = param[@"invoiceData"];
    if (!invoiceData || invoiceData.length == 0) {
        resultBlk(nil,[NSError errorWithDomain:@"invoiceData is null" code:-1001 userInfo:nil]);
        return NO;
    }
    BOOL isExperied = [CMPAccessTokenManager verifyAccessTokenExperied:accessToken];
    if (isExperied) {
        resultBlk(nil,[NSError errorWithDomain:@"token is experied" code:-1001 userInfo:nil]);
        return NO;
    }
    NSString *str = [[CMPSMEncryptManager shareInstance] decryptText:invoiceData];
    resultBlk(str,nil);
    return YES;
}

@end
