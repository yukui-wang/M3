//
//  XZOpenM3AppHelper.h
//  M3
//
//  Created by wujiansheng on 2018/1/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CMPLib/CMPCachedUrlParser.h>

@interface XZOpenM3AppHelper : NSObject

+ (BOOL)canOpenM3AppWithAppId:(NSString *)appId;
+ (void)openM3AppWithAppId:(NSString *)appId;
/*处理url*/
+ (NSString *)urlWithUrl:(NSString *)url;
+ (void)showWebviewWithUrl:(NSString *)url;
+ (void)showWebviewWithUrl:(NSString *)url autoOrientation:(BOOL)autoOrientation;
+ (void)showWebviewWithUrl:(NSString *)url handleUrl:(BOOL)handleUrl autoOrientation:(BOOL)autoOrientation;
+ (void)pushWebviewWithUrl:(NSString *)url nav:(UINavigationController *)nav;
//url = nil 跳转中转界面
+ (void)openH5AppWithParams:(NSDictionary *)params
                        url:(NSString *)url
               inController:(UIViewController *)controller;
+ (void)showQAFile:(id)model;

@end
