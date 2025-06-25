//
//  CMPInvoiceAlipayHelper.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/14.
//

#import "CMPInvoiceAlipayHelper.h"
//#import  <AFServiceSDK/AFServiceSDK.h>
#import <CMPLib/CMPDataProvider.h>
#import "CMPCommonManager.h"
#import <CMPLib/NSString+CMPString.h>
/**
 https://opendocs.alipay.com/open/02awbo
 */
@interface CMPInvoiceAlipayHelper()<CMPDataProviderDelegate>
{
    
}
@property(nonatomic,copy)void(^fetchInvoiceListCompletion)(id respData,NSError *error,id ext);

@end

@implementation CMPInvoiceAlipayHelper

static id shareInstance;

+(instancetype)shareInstance {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [[self alloc] init];
            }
        }
    }
    return shareInstance;
}

+(BOOL)handleOpenURL:(NSURL *)url
{
//    if ([url.host isEqualToString:@"apmqpdispatch"]) {
//        [AFServiceCenter handleResponseURL:url withCompletion:^(AFServiceResponse *response) {
//            void(^fetchInvoiceListCompletion)(id respData,NSError *error,id ext) = [CMPInvoiceAlipayHelper shareInstance].fetchInvoiceListCompletion;
//            if (AFResSuccess == response.responseCode) {
//                NSLog(@"%@", response.result);
//                [[CMPInvoiceAlipayHelper shareInstance] fetchAliInvoiceListDetailWithParams:nil accessToken:nil completion:^(id respData, NSError *error, id ext) {
//                    if (fetchInvoiceListCompletion) {
//                        if (AFResSuccess == response.responseCode) {
//                            NSLog(@"%@", response.result);
//                            fetchInvoiceListCompletion(response.result,nil,response);
//                        }else{
//                            fetchInvoiceListCompletion(response.result,[NSError errorWithDomain:@"ali err" code:response.responseCode userInfo:nil],response);
//                        }
//                    }
//                }];
//            }else{
//                if (fetchInvoiceListCompletion) {
//                    fetchInvoiceListCompletion(response.result,[NSError errorWithDomain:@"ali err" code:response.responseCode userInfo:nil],response);
//                }
//            }
//        }];
//        return YES;
//    }
    return NO;
}

-(void)getAliInvoiceWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion
{
    if (!completion) {
        return;
    }
    _fetchInvoiceListCompletion = completion;
    
    [self demoAuth];
}


- (void)demoAuth
{
//    NSDictionary *params = @{kAFServiceOptionBizParams: @{
//    @"url": @"/www/invoiceSelect.htm?scene=INVOICE_EXPENSE&einvMerchantId=914406066176547680&serverRedirectUrl=https%3A%2F%2Fdctest.mideadc.com"
//    },
//    kAFServiceOptionCallbackScheme: @"seeyonM3Phone",
//    };
//    [AFServiceCenter callService:AFServiceEInvoice withParams:params andCompletion:^(AFServiceResponse *response) {
//        NSLog(@"%@", response.result);
//    }];
}


-(void)fetchAliInvoiceListDetailWithParams:(NSDictionary *)params accessToken:(NSString *)accessToken completion:(void(^)(id respData,NSError *error,id ext))completion
{
//    if (!accessToken || !accessToken.length) {
//        return;
//    }
//    if (!params || !params.count) {
//        return;
//    }
//    if (!completion) {
//        return;
//    }
//    NSString *url = @"https://openapi.alipay.com/gateway.do?timestamp=2013-01-01 08:08:08&method=alipay.ebpp.invoice.token.batchquery&app_id=22367&sign_type=RSA2&sign=ERITJKEIJKJHKKKKKKKHJEREEEEEEEEEEE&version=1.0&charset=GBK&biz_content=AlipayEbppInvoiceOutputBytokenBatchqueryModel";
//    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
//    aDataRequest.requestUrl = url;
//    aDataRequest.delegate = self;
//    aDataRequest.requestMethod = kRequestMethodType_POST;
//    aDataRequest.requestType = kDataRequestType_Url;
//    aDataRequest.userInfo = @{@"completion" : completion,@"identifier":@"AlipayFetchInvoiceListDetail"};
//    aDataRequest.requestParam = [params JSONRepresentation];
//    aDataRequest.headers =  [CMPDataProvider headers];
//    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)updateAliInvoiceStateWithParams:(NSDictionary *)params accessToken:(NSString *)accessToken completion:(void(^)(id respData,NSError *error,id ext))completion
{
//    if (!accessToken || !accessToken.length) {
//        return;
//    }
//    if (!params || !params.count) {
//        return;
//    }
//    NSString *url = @"https://openapi.alipay.com/gateway.do?timestamp=2013-01-01 08:08:08&method=alipay.ebpp.invoice.list.expense.sync&app_id=19361&sign_type=RSA2&sign=ERITJKEIJKJHKKKKKKKHJEREEEEEEEEEEE&version=1.0&charset=GBK&biz_content=AlipayEbppInvoiceListExpenseSyncModel";
//    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
//    aDataRequest.requestUrl = url;
//    aDataRequest.delegate = self;
//    aDataRequest.requestMethod = kRequestMethodType_POST;
//    aDataRequest.requestType = kDataRequestType_Url;
//    aDataRequest.userInfo = @{@"completion" : completion,@"identifier":@"AlipayUpdateInvoiceState"};
//    aDataRequest.requestParam = [params JSONRepresentation];
//    aDataRequest.headers =  [CMPDataProvider headers];
//    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    // 网络监听，检查是否能够连接服务器 add by guoyl at 2018/1/10
    [CMPCommonManager updateReachableServer:nil];
    // end
    
    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (!completionBlk) {
        return;
    }
    
    NSDictionary *responseObj = [aResponse.responseStr JSONValue];
    if (responseObj) {
        
        NSString *identifier = userInfo[@"identifier"];
        if (identifier && [identifier hasPrefix:@"Alipay"]) {
            NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"errcode"]];
            if ([code isEqualToString:@"0"]) {
                id respData = responseObj[@"item_list"];
                completionBlk(respData,nil,responseObj);
            }else{
                NSString *msg = responseObj[@"errmsg"];
                NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
                completionBlk(nil,err,responseObj);
            }
            return;
        }
        
        NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"code"]];
        if ([code isEqualToString:@"0"]) {
            id respData = responseObj[@"data"];
            completionBlk(respData,nil,responseObj);
        }else{
            NSString *msg = responseObj[@"message"];
            NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
            completionBlk(nil,err,responseObj);
        }
    }else{
        NSError *err = [NSError errorWithDomain:@"response null" code:-1 userInfo:nil];
        completionBlk(nil,err,responseObj);
    }
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
    NSDictionary *userInfo = aRequest.userInfo;
    
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (completionBlk) {
        completionBlk(nil,error,nil);
    }
}

@end
