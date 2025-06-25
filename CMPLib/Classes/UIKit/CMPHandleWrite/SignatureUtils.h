//
//  SignatureUtils.h
//  SeeyonFlow
//
//  Created by administrator on 11-8-27.
//  Copyright 2011年 北京致远协创软件有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kLayoutSignatureImageType_Cover 1 // 覆盖
#define kLayoutSignatureImageType_Vertical 2

@interface SignatureUtils : NSObject {
    
}

+ (NSString *)encodeBase64:(NSData *)input;

+ (NSData *)decodeBase64:(NSString *)input;

+ (NSString *)encodeBase64_str:(NSString *)aStr;

+ (NSString *)decodeBase64_str:(NSString *)input;

+ (NSString *)createUUID;

+ (NSString *)getSignatureResult:(NSString *)initValue image:(UIImage *)aImage userName:(NSString *)aName 
                            layoutType:(NSInteger)iType initSize:(CGSize)initSize;

+ (NSDictionary *)picDataStrWithInitValue:(NSString *)value;

+ (BOOL)isBase64Data:(NSString *)input;

@end
