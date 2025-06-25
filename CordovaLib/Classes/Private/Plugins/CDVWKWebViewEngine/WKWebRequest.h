//
//  WKWebRequest.h
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/8.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "WKWebResponseRecord.h"
typedef void (^WKWebRequestCallback)(NSString * _Nullable data);

NS_ASSUME_NONNULL_BEGIN

@protocol WKWebRequestDelegate;

@interface WKWebRequest : NSObject
@property(nonatomic, copy, nullable)NSString *callbackID;
@property(nonatomic, copy, nullable)WKWebRequestCallback completedBlock;
@property(nonatomic, assign, nullable)id<WKWebRequestDelegate> delegate;
@property(nonatomic, weak, readonly, nullable)WKWebView *webView;
@property(nonatomic, copy)NSString *url;
@property(nonatomic, assign)BOOL needCacheResponse;
@property(nonatomic, strong)WKWebResponseRecord *responseRecord;
@property(nonatomic, copy)NSString *responseUrl;

- (id)initWithBody:(NSDictionary *)body webView:(WKWebView *)webView;
- (void)send;
- (void)abort;
+ (BOOL)isNullString:(NSString *)aStr;
+ (NSString *)callbackStringWithId:(id)requestId
                          httpCode:(NSInteger)httpCode
                           headers:(nullable NSDictionary *)headers
                              data:(NSString *)data
                       responseURL:(NSString *)responseURL
                        base64Data:(nullable NSString *)base64Data;
+ (NSStringEncoding)stringEncodingWithHeaders:(NSDictionary *)headers;
@end



@protocol WKWebRequestDelegate <NSObject>

- (void)wkWebRequest:(WKWebRequest *)webRequest didCompletedWithResponse:(NSString *)response;
- (void)wkWebRequest:(WKWebRequest *)webRequest uploadProgressWithResponse:(NSString *)response;

@end
NS_ASSUME_NONNULL_END
