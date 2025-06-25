//
//  CMPSSOHelper.h
//  M3
//  单点登录
//  Created by CRMO on 2018/7/31.
//

#import <CMPLib/CMPObject.h>

@interface CMPSSOHelper : CMPObject

/**
 通过URL单点登录
 
 方式一：seeyonm3phone://m3?loginParams=%7b%22name%22%3a%22wangxk%22%2c%22password%22%3a%22123456%22%7d
 方式二：seeyonm3phone://m3?aaaa=123&b=234566&c=55555
 */
- (void)ssoWithUrl:(NSURL *)url;

/**
 判断URL中是否携带了SSO参数
 */
+ (BOOL)cotainSSOParam:(NSURL *)url;

@end
