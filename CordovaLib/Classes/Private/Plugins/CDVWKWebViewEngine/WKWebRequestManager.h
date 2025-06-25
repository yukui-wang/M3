//
//  WKAjaxRequestManager.h
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/1.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKWebRequest.h"
#import "WKWebConstant.h"
#import "WKWebResponseRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebRequestManager : NSObject

+ (BOOL)isWKWebSyncRequestWithBody:(NSDictionary *)body;
+ (void)wkWebRequestWithBody:(NSDictionary *)body
                     webview:(nullable WKWebView *)webview
              completedBlock:(nullable WKWebRequestCallback) completedBlock;
+ (id)cacheResponseForUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
