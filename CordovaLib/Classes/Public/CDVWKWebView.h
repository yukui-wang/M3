//
//  CDVWKWebView.h
//  CordovaLib
//
//  Created by youlin on 2018/10/25.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CDVWKWebView : WKWebView
@property (nonatomic, readonly)NSString *webViewID; // 唯一标识
@property (nonatomic, weak)UIViewController *viewController; //  所在的viewController

+ (CDVWKWebView *)webViewWithID:(NSString *)aWebViewID;
+ (void)remove:(NSString *)aWebViewID;
+(NSString *)urlAddCompnentForValue:(NSString *)value key:(NSString *)key   url:(NSString *)aUrl;

@end

NS_ASSUME_NONNULL_END
