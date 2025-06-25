//
//  NSString+XMP_Extensions.h
//  XmppDemo
//
//  Created by weitong on 13-2-25.
//  Copyright (c) 2013年 weit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XMP_Extensions)

+ (NSString *)fileSizeFormat:(NSString *)fileSize;
+ (NSString *)fileSizeFormatForUpload:(NSUInteger)fileSize;
+ (NSString *)fileNameForUpload:(NSString *)fileId andFileName:(NSString *)fileName;


+ (BOOL)isEmptyTrim:(NSString *)string;

+ (NSString *)fileTypeName:(NSString *)fileName;
+ (NSString *)fileMD5:(NSString*)path;

+ (NSString *)chectString:(NSString *)string;




@end
