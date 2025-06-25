//
//  SyDataUtils.m
//  M1Core
//
//  Created by xiang fei on 11-7-24.
//  Copyright 2011年 Seeyon. All rights reserved.
//

#import "CMPDataUtil.h"
#import <zlib.h>
#include <iconv.h>


@implementation CMPDataUtil

+ (NSMutableData *)uncompressZippedData:(NSMutableData *)compressedData {
	
    if ([compressedData length] == 0) {
		return compressedData;	
	}
	unsigned full_length = [compressedData length];  
	unsigned half_length = [compressedData length] / 2;  
	
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];  
	BOOL done = NO;  
	int status;  
	z_stream strm;  
	strm.next_in = (Bytef *)[compressedData bytes];  
	strm.avail_in = [compressedData length];  
	strm.total_out = 0;  
	strm.zalloc = Z_NULL;  
	strm.zfree = Z_NULL;  
	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;  
	while (!done) {  
		// Make sure we have enough room and reset the lengths.  
		if (strm.total_out >= [decompressed length]) {  
			[decompressed increaseLengthBy: half_length];  
		}  
		strm.next_out = [decompressed mutableBytes] + strm.total_out;  
		strm.avail_out = [decompressed length] - strm.total_out;  
		// Inflate another chunk.  
		status = inflate (&strm, Z_SYNC_FLUSH);  
		if (status == Z_STREAM_END) {  
			done = YES;  
		} else if (status != Z_OK) {  
			break;  
		}  
	}  
	if (inflateEnd (&strm) != Z_OK) return nil;  
	// Set real length.  
	if (done) {
		[decompressed setLength: strm.total_out];
		return decompressed;  
	} else {  
		return nil;  
	}
	return nil;
}

int code_convert(char *from_charset, char *to_charset, char *inbuf, size_t inlen, char *outbuf, size_t outlen) {
    iconv_t cd = NULL;
	
    cd = iconv_open(to_charset, from_charset);
    if(!cd)
        return -1;
	
    memset(outbuf, 0, outlen);
    if (iconv(cd, &inbuf, &inlen, &outbuf, &outlen) == -1)
        return -1;
	
    iconv_close(cd);
    return 0;
}

+ (NSString *)getANSIString:(NSData *)ansiData 
{
    char *ansiString = (char *)[ansiData bytes];
    int ansiLen = [ansiData length];
    int utf8Len = ansiLen * 2; 
    char *utf8String = (char *)malloc(utf8Len);
    memset(utf8String, 0, utf8Len);	 
    int result = code_convert("gb2312", "utf-8", ansiString, ansiLen, utf8String, utf8Len);
    if ( result == -1 ) {
        free(utf8String);
        return nil;
    }
    NSString *retString = [NSString stringWithUTF8String:utf8String];
    free(utf8String);
    return retString;
}

unsigned int countGBK(const char * str)  
{
    assert(str != NULL);  
    unsigned int len = (unsigned int)strlen (str);  
    unsigned int counter = 0;  
    unsigned char head = 0x80;  
    unsigned char firstChar, secondChar;  
    if (len == 0) {
		return counter;
	}
    for (unsigned int i = 0; i < len - 1; ++i)  
    {  
        firstChar = (unsigned char)str[i];  
        if (!(firstChar & head))continue;  
        secondChar = (unsigned char)str[i];  
        if (firstChar >= 161 && firstChar <= 247 && secondChar>=161 && secondChar <= 254)  
        {  
            counter+= 2;  
            ++i;  
        }  
    }  
    return counter;  
}  

unsigned int countUTF8(const char * str)  
{  
    assert(str != NULL);  
    unsigned int len = (unsigned int)strlen (str);  
    unsigned int counter = 0;  
    unsigned char head = 0x80;  
    unsigned char firstChar;  
    for (unsigned int i = 0; i < len; ++i)  
    {  
        firstChar = (unsigned char)str[i];  
        if (!(firstChar & head))continue;  
        unsigned char tmpHead = head;  
        unsigned int wordLen = 0 , tPos = 0;  
        while (firstChar & tmpHead)  
        {  
            ++ wordLen;  
            tmpHead >>= 1;  
        }  
        if (wordLen <= 1)continue; //utf8最小长度为2  
        wordLen --;  
        if (wordLen + i >= len)break;  
        for (tPos = 1; tPos <= wordLen; ++tPos)  
        {  
            unsigned char secondChar = (unsigned char)str[i + tPos];  
            if (!(secondChar & head))break;  
        }  
        if (tPos > wordLen)  
        {  
            counter += wordLen + 1;  
            i += wordLen;  
        }  
    }  
    return counter;  
}  

bool beUtf8(const char *str)  
{  
    unsigned int iGBK = countGBK(str);  
    unsigned int iUTF8= countUTF8(str);  
    if (iUTF8 > iGBK)return true;  
    return false;  
}  

+ (NSString *)textEncodingName:(NSData *)ansiData
{
    char *ansiString = (char *)[ansiData bytes];
    BOOL isUtf8 = beUtf8(ansiString);
    if (isUtf8) {
        return @"utf-8";
    }
    return @"gb2312";
}

+ (NSString *)unZipDataforSeeyon:(NSString *)responseString
{
	NSData *aData = [responseString dataUsingEncoding:NSISOLatin1StringEncoding];
	NSData *decompressData = [CMPDataUtil uncompressZippedData:(NSMutableData *)aData];
	responseString = [[[NSString alloc] initWithData:decompressData encoding:NSUTF8StringEncoding] autorelease];
	return responseString;
}

@end
