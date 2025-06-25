//
//  CMPInvoiceWechatHelper.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/1/11.
//

#import "CMPInvoiceWechatHelper.h"
#import <CMPLib/CMPDataProvider.h>
#import "CMPCommonManager.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIViewController+CMPViewController.h>

/**
 https://developers.weixin.qq.com/doc/offiaccount/WeChat_Invoice/Auto-print/API_Documentation.html#9
 1.从m3后台获取accesstoken
 2.通过accesstoken获取商户授权ticket。https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=ACCESS_TOKEN&type=wx_card
 3.对拿到的ticket等信息进行排序加密,生成cardSign(将 api_ticket、appid、location_id、timestamp、nonce_str、card_id、card_type的value值进行字符串的字典序排序
 将所有参数字符串拼接成一个字符串进行sha1加密，得到cardSign)
 4.通过调用微信Api跳转微信(注：传入的时间戳要和之前进行sha1加密的时间戳相同)
 5.在AppDelegate转发回调
 6.在onResp方法里拿到发票的id,再用POST请求 拿到发票详细的信息
 */

@interface CMPInvoiceWechatHelper()<CMPDataProviderDelegate>
{
    NSString *_secret;
    __block NSString *_ticket;
    NSTimeInterval _timeStamp;
    NSString *_openId;
    
    //三方app传入或平台获取
    NSString *_appId;
    __block NSString *_accessToken;
    NSString *_cardSign;
    
    void(^_fetchInvoiceListCompletion)(id respData,NSError *error,id ext);
}
@end

@implementation CMPInvoiceWechatHelper

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

-(instancetype)init
{
    self = [super init];
    if (self) {
        _appId = @"";
        _accessToken = @"";
        _cardSign = @"";
//        _appId = @"wx83c77f328ae636d7";
//        _secret = @"0e64b86c9e9a1f746946df1ce16d0ee4";
        _timeStamp = [NSDate date].timeIntervalSince1970*1000;
    }
    return self;
}

-(BOOL)config:(NSDictionary *)config
{
    NSInteger tag = 0;
    if (config) {
        NSString *str = config[@"appInfoId"];
        if ([NSString isNotNull:str]) {
            _appId = str;
            tag+=1;
        }else{
            str = config[@"appId"];
            if ([NSString isNotNull:str]) {
                _appId = str;
                tag+=1;
            }
        }
        str = config[@"wxAccessToken"];
        if ([NSString isNotNull:str]) {
            _accessToken = str;
            tag+=1;
        }else{
            str = config[@"accessToken"];
            if ([NSString isNotNull:str]) {
                _accessToken = str;
                tag+=1;
            }
        }
        str = config[@"cardSign"];
        if ([NSString isNotNull:str]) {
            _cardSign = str;
            tag+=1;
        }
    }
    return tag==3;
}

- (void)onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:WXChooseInvoiceResp.class]) {
        WXChooseInvoiceResp *chooseInvoiceResp = (WXChooseInvoiceResp *)resp;
        NSArray *itemArray = chooseInvoiceResp.cardAry;
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:itemArray.count];
        for (WXInvoiceItem *item in itemArray) {
               NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
               [dicM setObject:item.cardId ? item.cardId : @"" forKey:@"card_id"];
               [dicM setObject:item.encryptCode ? item.encryptCode : @"" forKey:@"encrypt_code"];
               [resultArray addObject:dicM];
       }
       NSDictionary *listParm = @{
                                  @"item_list":resultArray,
                                  };
        [self fetchWXInvoiceListDetailWithParams:listParm accessToken:_accessToken completion:^(id respData, NSError *error, id ext) {
            if (self->_fetchInvoiceListCompletion) {
                self->_fetchInvoiceListCompletion(respData,error,ext);
            }
        }];
    }
}

-(void)fetchWXConfigFromPlatWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion
{
    NSString *url = [NSString stringWithFormat:@"%@", [CMPCore fullUrlPathMapForPath:@"/rest/m3/card/invoice/signature"]];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    aDataRequest.headers =  [CMPDataProvider headers];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)fetchWXAccessTokenFromPlatWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion
{
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%@&secret=%@",_appId,_secret];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion,@"identifier":@"WXFetchInvoiceToken"};
    aDataRequest.headers =  [CMPDataProvider headers];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)fetchWXTicketWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion
{
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/cgi-bin/ticket/getticket?type=wx_card&access_token=%@",_accessToken];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion,@"identifier":@"WXFetchInvoiceTicket"};
//    aDataRequest.headers =  [CMPDataProvider headers];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


-(void)fetchWXCardSignFromPlatWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion
{
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/cgi-bin/ticket/getticket?type=wx_card&access_token=%@",_accessToken];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    aDataRequest.headers =  [CMPDataProvider headers];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


-(BOOL)updateAppId:(NSString *)appid
{
    if (!appid||appid.length==0) {
        return NO;
    }
    _appId = appid;
    return YES;
}

-(NSString *)genCardSignWithNonceStr:(NSString *)nonceStr andTimeStr:(NSString *)timeStamp andApiTicket:(NSString *)ticket andAppId:(NSString *)appId
{
    NSMutableDictionary *cardSignDic = [NSMutableDictionary dictionary];
    [cardSignDic setObject:nonceStr forKey:@"nonceStr"];
    [cardSignDic setObject:timeStamp forKey:@"timestamp"];
    [cardSignDic setObject:ticket forKey:@"api_ticket"];
    [cardSignDic setObject:@"INVOICE" forKey:@"cardType"];
    [cardSignDic setObject:appId forKey:@"appid"];
    NSMutableString *contentString = [NSMutableString string];
    NSArray *values = [cardSignDic allValues];
    //按字母顺序排序
    NSArray *sortedArray = [values sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *value in sortedArray) {
        [contentString appendFormat:@"%@", value];
    }
    NSString *cardSign = [contentString sha1];
    
    return cardSign;
}

-(void)getWXInvoiceWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion
{
    void(^blk)(void) = ^{
        [self sendWXInvoiceListRequestWithCompletion:completion];
    };
    if ([NSString isNull:_appId]||[NSString isNull:_accessToken]||[NSString isNull:_cardSign]) {
        [self fetchWXConfigFromPlatWithCompletion:^(id respData, NSError *error, id ext) {
            if (!error) {
                BOOL configResult = [self config:respData];
                if (configResult) {
                    blk();
                }else{
                    [[CMPCommonTool getCurrentShowViewController] showAlertMessage:error.domain];
                }
            }else{
                [[CMPCommonTool getCurrentShowViewController] showAlertMessage:error.domain];
            }
        }];
    }else{
        blk();
    }
//    if (!_accessToken) {
//        [self fetchWXAccessTokenFromPlatWithCompletion:^(id respData, NSError *error, id ext) {
//            if (!error) {
//                self->_accessToken = respData;
//                [self fetchWXCardSignFromPlatWithCompletion:^(id respData, NSError *error, id ext) {
//                    if (!error) {
//                        self->_cardSign = respData;
//                        blk();
//                    }
//                }];
//            }
//        }];
//    }else if (!_cardSign){
//        [self fetchWXCardSignFromPlatWithCompletion:^(id respData, NSError *error, id ext) {
//            if (!error) {
//                self->_cardSign = respData;
//                blk();
//            }
//        }];
//    }else{
//        blk();
//    }
}


-(void)sendWXInvoiceListRequestWithCompletion:(void(^)(id respData,NSError *error,id ext) )completion
{
    if (!completion) {
        return;
    }
    if (!_appId||_appId.length==0) {
        completion(nil,[NSError errorWithDomain:@"appid null" code:-1001 userInfo:nil],nil);
        return;
    }
    if (!_cardSign||_cardSign.length==0) {
        completion(nil,[NSError errorWithDomain:@"cardSign null" code:-1001 userInfo:nil],nil);
        return;
    }
    if (!_timeStamp) {
        completion(nil,[NSError errorWithDomain:@"timeStamp null" code:-1001 userInfo:nil],nil);
        return;
    }
    
    BOOL isWXApplnstalled = [WXApi isWXAppInstalled];
    if (!isWXApplnstalled) {
        completion(nil,[NSError errorWithDomain:@"Wechat Not installed" code:-1001 userInfo:nil],nil);
        return;
    }
    
    _fetchInvoiceListCompletion = completion;
    
    [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString * _Nonnull log) {
        NSLog(@"%@",log);
    }];
    BOOL regisSuc = [WXApi registerApp:_appId universalLink:@"https://m3.seeyon.com/m3/jump/"];
    NSLog(@"WXApi registerApp: %@",@(regisSuc));
    
//    [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult * _Nonnull result) {
//        NSLog(@"wx universal step : %ld, result:%@",(long)step,result);
//    }];
    
    WXChooseInvoiceReq *cardReq = [[WXChooseInvoiceReq alloc] init];
    cardReq.appID = _appId;
    cardReq.timeStamp = _timeStamp;
    cardReq.nonceStr = @"sfim_invoice";
    cardReq.cardSign = _cardSign;
    [WXApi sendReq:cardReq completion:^(BOOL success) {
    }];//发送
}


-(void)getWXInvoiceWithTicket:(NSString*)ticket appId:(NSString *)appId timestamp:(NSTimeInterval)timestamp completion:(void(^)(id respData,NSError *error,id ext) )completion
{
    if (!appId||appId.length==0) {
        return;
    }
    if (!completion) {
        return;
    }
    BOOL isWXApplnstalled = [WXApi isWXAppInstalled];
    if (!isWXApplnstalled) {
        completion(nil,[NSError errorWithDomain:@"Wechat Not installed" code:-1001 userInfo:nil],nil);
        return;
    }
    
    _fetchInvoiceListCompletion = completion;
    
    WXChooseInvoiceReq *cardReq = [[WXChooseInvoiceReq alloc] init];
    cardReq.appID = appId;
    cardReq.timeStamp = timestamp;
    NSString* timeStamp = [NSString stringWithFormat:@"%d",cardReq.timeStamp];
    cardReq.nonceStr = @"sfim_invoice";

    NSString *cardSign = [self genCardSignWithNonceStr:cardReq.nonceStr andTimeStr:timeStamp andApiTicket:ticket andAppId:appId];
    cardReq.cardSign = cardSign;
    [WXApi sendReq:cardReq completion:^(BOOL success) {
        
    }];//发送
}


/**
 请求：
 {
     "item_list": [
         {
             "card_id": "pjZ8Yt7KKEXWMpETmwG2ZZxX2m6E",
             "encrypt_code": "O/mPnGTpBu22a1szmK2 "
         },
         {
             "card_id": "pjZ8YtxSguaLUaaDqzeAf385soJM",
             "encrypt_code": "O/mPnGTpBu22a1szmK2ogz "
         }
     ]
 }
 返回：
 {
     "errcode": 0,
     "errmsg": "ok",
     "item_list": [
         {
             "user_info": {
                 "fee": 123,
                 "title": "灌哥发票",
                 "billing_time": 1504085973,
                 "billing_no": "1504085973",
                 "billing_code": "aabbccdd",
                 "info": [
                     {
                         "name": "牙膏",
                         "num": 3,
                         "unit": "个",
                         "price": 10000
                     }
                 ],
                 "fee_without_tax": 2345,
                 "tax": 123,
                 "detail": "项目",
                 "pdf_url": "http://pdfurl",
                 "reimburse_status": "INVOICE_REIMBURSE_INIT",
                 "order_id": "1504085935",
                 "check_code": "check_code",
                 "buyer_number": "buyer_number"
             },
             "card_id": "pjZ8Yt7KKEXWMpETmwG2ZZxX2m6E",
             "openid": "oZI8Fj8L63WugQsljlzzfCcw3AkQ",
             "type": "广东省增值税普通发票",
             "payee": "测试-收款方",
             "detail": "detail"
         },
         {
             "user_info": {
                 "fee": 123,
                 "title": "灌哥发票",
                 "billing_time": 1504083578,
                 "billing_no": "1504083578",
                 "billing_code": "aabbccdd",
                 "info": [
                     {
                         "name": "牙膏",
                         "num": 3,
                         "unit": "个",
                         "price": 10000
                     }
                 ],
                 "fee_without_tax": 2345,
                 "tax": 123,
                 "detail": "项目",
                 "pdf_url": " http://pdfurl",
                 "reimburse_status": "INVOICE_REIMBURSE_INIT",
                 "order_id": "1504083522",
                 "check_code": "check_code",
                 "buyer_number": "buyer_number"
             },
             "card_id": "pjZ8YtxSguaLUaaDqzeAf385soJM",
             "openid": "oZI8Fj8L63WugQsljlzzfCcw3AkQ",
             "type": "广东省增值税普通发票",
             "payee": "测试-收款方",
             "detail": "detail"
         }
     ]
}
 */
-(void)fetchWXInvoiceListDetailWithParams:(NSDictionary *)params accessToken:(NSString *)accessToken completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!accessToken || !accessToken.length) {
        return;
    }
    if (!params || !params.count) {
        return;
    }
    if (!completion) {
        return;
    }
    NSString *url = [@"https://api.weixin.qq.com/card/invoice/reimburse/getinvoicebatch?access_token=" stringByAppendingString:accessToken];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion":completion,@"identifier":@"WXFetchInvoiceListDetail"};
    aDataRequest.requestParam = [params JSONRepresentation];
//    aDataRequest.headers =  [CMPDataProvider headers];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)updateWXInvoiceStateWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    [self updateWXInvoiceStateWithParams:params accessToken:_accessToken completion:completion];
}
/**
 请求参数

 请求参数使用JSON格式，字段如下:

 参数    类型    是否必填    描述
 openid    String    是    用户openid
 reimburse_status    String    是    发票报销状态，见备注7.2
 invoice_list    List    是    发票列表
 invoice_list每个对象包含以下字段：

 参数    类型    是否必填    描述
 card_id    String    是    发票卡券的card_id
 encrypt_code    String    是    发票卡券的加密code，和card_id共同构成一张发票卡券的唯一标识
 */
-(void)updateWXInvoiceStateWithParams:(NSDictionary *)params accessToken:(NSString *)accessToken completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!accessToken || !accessToken.length) {
        return;
    }
    if (!params || !params.count) {
        return;
    }
    NSString *url = [@"https://api.weixin.qq.com/card/invoice/reimburse/updatestatusbatch?access_token=" stringByAppendingString:accessToken];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion,@"identifier":@"WXUpdateInvoiceState"};
    aDataRequest.requestParam = [params JSONRepresentation];
    aDataRequest.headers =  [CMPDataProvider headers];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
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
        if (identifier && [identifier hasPrefix:@"WX"]) {
            NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"errcode"]];
            if ([code isEqualToString:@"0"]) {
                id respData = responseObj;
                completionBlk(respData,nil,responseObj);
            }else{
                NSString *msg = responseObj[@"errmsg"];
                NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
                completionBlk(nil,err,responseObj);
            }
            return;
        }
        
        NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"code"]];
        if ([code isEqualToString:@"200"]) {
            id respData = responseObj[@"data"];
            completionBlk(respData,nil,responseObj);
        }else{
            NSString *msg = responseObj[@"msg"];
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
