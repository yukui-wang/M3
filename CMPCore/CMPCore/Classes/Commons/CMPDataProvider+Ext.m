//
//  CMPDataProvider+Ext.m
//  M3
//
//  Created by youlin on 2019/12/17.
//

#import "CMPDataProvider+Ext.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CMPLib/AFSecurityPolicy.h>

@implementation CMPDataProvider (Ext)

- (AFSecurityPolicy *)createCertificate
{
    // 自签名证书在路径
    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:@"service" ofType:@"cer"];
    // 自签名证书转换成二进制数据
    NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
    if (!certData) {
        return nil;
    }
    // 将二进制数据放到NSSet中
    NSSet *certSet = [NSSet setWithObject:certData];
    /* AFNetworking中的AFSecurityPolicy实例化方法
      第一个参数：
      AFSSLPinningModeNone,  //不验证
      AFSSLPinningModePublicKey,   //只验证公钥
      AFSSLPinningModeCertificate,   //验证证书
      第二个参数：存放二进制证书数据的NSSet
    */
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:certSet];
    // shareManager 是继承自AFHTTPSessionManager的一个类的实例对象
//    sharedManager.securityPolicy = policy;
    return policy;
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    // todo
    return YES;
}

@end
