//
//  NSString+XMP_Extensions.m
//  XmppDemo
//
//  Created by weitong on 13-2-25.
//  Copyright (c) 2013年 weit. All rights reserved.
//

#import "NSString+XMP_Extensions.h"
#import "RegexKitLite.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (XMP_Extensions)

+ (NSString *)fileSizeFormat:(NSString *)fileSize
{
    if (fileSize) {
        int fs = fileSize.intValue;
        if (fs < 1024) {
            return [NSString stringWithFormat:@"%dKB",fs];
        }else if (fs < 1024*1024){
            return [NSString stringWithFormat:@"%.2fMB",fs/1024.0];
        }else if (fs < 1024*1024*1024){
            return [NSString stringWithFormat:@"%.2fGB",fs/1024.0/1024.0];
        }
    }
    return @"0K";
    
}

+ (NSString *)fileSizeFormatForUpload:(NSUInteger)fileSize
{
    int size = MAX(fileSize/1024, 1);
    return [NSString stringWithFormat:@"%d",size];
}

+ (NSString *)fileNameForUpload:(NSString *)fileId andFileName:(NSString *)fileName
{
    if (!fileName)  return fileId;
    NSString* fileType = @"";
    NSUInteger dotLocation = [fileName rangeOfString:@"." options:NSBackwardsSearch].location;
    if (dotLocation != NSNotFound) {
        fileType = [fileName substringFromIndex:dotLocation];
    }
    return [NSString stringWithFormat:@"%@%@",fileId,[fileName substringFromIndex:dotLocation]];
}


static NSString* kRegexkitEmpty = @"[^\\s]+";
+ (BOOL)isEmptyTrim:(NSString *)string
{
    if (string && ![string isEqualToString:@""]) {        
        return ![string isMatchedByRegex:kRegexkitEmpty];
    }
    return YES;
}

+ (NSString *)fileTypeName:(NSString *)fileName
{
    if (fileName) {
        NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            return [fileName substringFromIndex:range.location];
        }
    }
    return @"";
}

#define CHUNK_SIZE_BIG      10240  
+ (NSString *)fileMD5:(NSString*)path
{  
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];  
    if(handle == nil)  
        return nil;  
    
    CC_MD5_CTX md5_ctx;  
    CC_MD5_Init(&md5_ctx);  
    
    NSData* filedata;  
    do {  
        filedata = [handle readDataOfLength:CHUNK_SIZE_BIG];  
        CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);  
    }  
    while([filedata length]);  
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];  
    CC_MD5_Final(result, &md5_ctx);  
    
    [handle closeFile];  
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

+ (NSString *)chectString:(NSString *)string
{
    if (!string ||string.length ==0) {
        return @"";
    }
    NSMutableString *htmlStr = [NSMutableString stringWithString:string];
    [htmlStr replaceOccurrencesOfString:@"&amp;" withString:@"&"
                                options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
    [htmlStr replaceOccurrencesOfString:@"&quot;" withString:@"\""
                                options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
    [htmlStr replaceOccurrencesOfString:@"&lt;" withString:@"<"
                                options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
    [htmlStr replaceOccurrencesOfString:@"&gt;"  withString:@">"
                                options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
    [htmlStr replaceOccurrencesOfString:@"&apos;" withString:@"'"
                                options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
    return htmlStr;
    
}

@end
