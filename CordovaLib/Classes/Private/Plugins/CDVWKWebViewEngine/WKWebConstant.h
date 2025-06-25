//
//  WKWebConstant.h
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/10.
//  Copyright © 2020 crmo. All rights reserved.
//

#ifndef WKWebConstant_h
#define WKWebConstant_h

//WKWebView消息接收name
#define kCMPBridgeName @"__CMPBridgeJSToNative__"
#define CDV_BRIDGE_NAME @"cordova"
#define kWKWebViewMessageHandlerName @"__cmpBridgeToNative__"

//原生向WKWebView发消息
#define kWKWebViewEvaluateJSMethod @"__cmpBridgeToJS__"


//原生cookie改变通知h5
#define knativeCookiesChangesNotification @"nativeCookiesChanges"


#endif /* WKWebConstant_h */
