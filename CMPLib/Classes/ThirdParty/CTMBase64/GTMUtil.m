//
//  GTMUtil.m
//  encode
//
//  Created by youlin guo on 14/12/26.
//  Copyright (c) 2014年 Seeyon. All rights reserved.
//

#import "GTMUtil.h"
#import <CommonCrypto/CommonCryptor.h>

#import "GTMBase64.h"

#define gkey            @"m1yanfa@seeyon.com119$#M1#$"
#define gIv             @"01234567"

@implementation GTMUtil

+ (NSString*)encrypt:(NSString*)plainText
{
	NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
	size_t plainTextBufferSize = [data length];
	const void *vplainText = (const void *)[data bytes];
	
	CCCryptorStatus ccStatus;
	uint8_t *bufferPtr = NULL;
	size_t bufferPtrSize = 0;
	size_t movedBytes = 0;
	
	bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
	
	const void *vkey = (const void *) [gkey UTF8String];
	const void *vinitVec = (const void *) [gIv UTF8String];
	
	ccStatus = CCCrypt(kCCEncrypt,
					   kCCAlgorithm3DES,
					   kCCOptionPKCS7Padding,
					   vkey,
					   kCCKeySize3DES,
					   vinitVec,
					   vplainText,
					   plainTextBufferSize,
					   (void *)bufferPtr,
					   bufferPtrSize,
					   &movedBytes);
	
	NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
	NSString *result = [GTMBase64 stringByEncodingData:myData];
	free(bufferPtr);
	return result;
}

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText {
	NSData *encryptData = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
	size_t plainTextBufferSize = [encryptData length];
	const void *vplainText = [encryptData bytes];
	
	CCCryptorStatus ccStatus;
	uint8_t *bufferPtr = NULL;
	size_t bufferPtrSize = 0;
	size_t movedBytes = 0;
	
	bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
	
	const void *vkey = (const void *) [gkey UTF8String];
	const void *vinitVec = (const void *) [gIv UTF8String];
	
	ccStatus = CCCrypt(kCCDecrypt,
					   kCCAlgorithm3DES,
					   kCCOptionPKCS7Padding,
					   vkey,
					   kCCKeySize3DES,
					   vinitVec,
					   vplainText,
					   plainTextBufferSize,
					   (void *)bufferPtr,
					   bufferPtrSize,
					   &movedBytes);
	NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
																	 length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
	free(bufferPtr);
	return [result autorelease];
}

@end
