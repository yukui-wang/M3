//
//  NSStringAdditions.m
//  nsstringAddtion
//
//  Created by  on 12-9-27.
//  Copyright (c) 2012年 www.seeyon.com. All rights reserved.
//

#import "NSString+CMPString.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(CMPString)

- (NSString *)deleteBothSidesWhitespaces
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *) replaceCharacter:(NSString *)oStr withString:(NSString *)nStr
{
    NSMutableString *_str = [NSMutableString stringWithString:self];
    [_str replaceOccurrencesOfString:oStr withString:nStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, _str.length)];
    return _str;
}

- (BOOL) isContainWhitespaceAndNewlines
{
    NSCharacterSet *_whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; i++) {
        unichar c = [self characterAtIndex:i]; 
        if ([_whiteSpace characterIsMember:c]) {
            return YES;
        }
    }
    return  NO;
}

- (BOOL) isWhitespaceAndNewlines
{
    NSCharacterSet *_whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if (![_whiteSpace characterIsMember:c]) {
            return NO;
        }
    }
    return  YES;
}
 
- (BOOL) isEmptyOrWhitespace
{
    return 0 == self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

-(NSString *)urlEncodingNew
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

-(NSString *)urlDecodeNew
{
    return [self stringByRemovingPercentEncoding];
}

- (NSString*) urlCFEncoded
{
    NSString *encodedString = [(NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            NULL,
                                            kCFStringEncodingUTF8) autorelease];
    return encodedString;

}

-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

    return decodedString;
}

- (NSString*) urlUTF8Encoded
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)urlEncoding
{
    return [self stringByRemovingPercentEncoding];
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingUTF8);
//    self = [self stringByReplacingPercentEscapesUsingEncoding:enc];
//    return self;
}

- (NSString *)urlEncoding2Times
{
    NSString *aUrl = [self urlEncoding];
    self = [aUrl urlEncoding];
    return self;
}

+ (NSString*) getCachesDirectory
{
    NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [_paths objectAtIndex:0];
}

+ (NSString*) getDocumentsDirectory
{
	NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return ([_paths count] > 0) ? [_paths objectAtIndex:0] : nil;
}


+ (NSString*) DataToASCIIString:(NSData*)data
{
	return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

- (NSString*) compositePublicKeyFromJavaKeyString
{
	NSString *_strResult = [self substringToIndex:64];
	NSUInteger lineCount = [self length] / 64;
	for (int i = 1; i < lineCount; i ++) {
		_strResult = [_strResult stringByAppendingFormat:@"\n%@",[self substringWithRange:NSMakeRange(i * 64, 64)]];
	}
	_strResult = [_strResult stringByAppendingFormat:@"\n%@",[self substringFromIndex:lineCount * 64]];;
	
	return [NSString stringWithFormat:@"%@\n%@\n%@",@"-----BEGIN PUBLIC KEY-----",_strResult,@"-----END PUBLIC KEY-----"];
}

- (NSString*) compositePrivateKeyFromJavaKeyString
{
	NSString *_strResult = [self substringToIndex:64];
	NSUInteger lineCount = [self length] / 64;
	for (int i = 1; i < lineCount; i ++) {
		_strResult = [_strResult stringByAppendingFormat:@"\n%@",[self substringWithRange:NSMakeRange(i * 64, 64)]];
	}
	_strResult = [_strResult stringByAppendingFormat:@"\n%@",[self substringFromIndex:lineCount * 64]];;
	
	return [NSString stringWithFormat:@"%@\n%@\n%@",@"-----BEGIN RSA PRIVATE KEY-----",_strResult,@"-----END RSA PRIVATE KEY-----"];	
}

- (NSString *)trim{
    return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)valueOf:(int)n {
    return [NSString stringWithFormat: @"%d", n];
}

- (BOOL)isSame:(NSString *)s {
    return ([self caseInsensitiveCompare:s] == NSOrderedSame);
}

- (NSString *)firstUpper{
    NSString *s1 = [self substringToIndex:1].uppercaseString;
    NSString *s2 = [self substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@", s1, s2];
}

+ (NSString *)stringWithLongLong:(long long)value {
    return [[NSNumber numberWithLongLong:value] stringValue];
}

+ (NSString *)stringWithInt:(NSInteger)aValue {
    return [[NSNumber numberWithInteger:aValue] stringValue];
}

+ (NSString *)stringWithBool:(BOOL)aValue {
    return aValue ? @"true" : @"false";
}

//
+ (NSMutableString *)replaceString:(NSString *)str
{
    if (!str) {
        return nil;
    }
	NSMutableString *htmlStr = [[NSMutableString alloc] initWithString:str];
	[htmlStr replaceOccurrencesOfString:@"\"" withString:@"&quot;"
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	[htmlStr replaceOccurrencesOfString:@"<" withString:@"&lt;"
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	[htmlStr replaceOccurrencesOfString:@">"  withString:@"&gt;"
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	[htmlStr replaceOccurrencesOfString:@"&" withString:@"&amp;"
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	return [htmlStr autorelease];
}

+ (NSString *)stringFromHtmlStr:(NSString *)str
{
	if (!str) {
		return nil;
	}
	NSMutableString *htmlStr = [[NSMutableString alloc] initWithString:str];
	[htmlStr replaceOccurrencesOfString:@"<br/>" withString:@"\n"
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	[htmlStr replaceOccurrencesOfString:@"<br>" withString:@"\n"
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	[htmlStr replaceOccurrencesOfString:@"&#039;" withString:@"'"
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	[htmlStr replaceOccurrencesOfString:@"&nbsp;" withString:@" "
								options:NSBackwardsSearch range:NSMakeRange(0, [htmlStr length])];
	return [htmlStr autorelease];
}

+ (BOOL)isNull:(NSString *)aStr
{
    NSString *string = aStr;
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    if ([aStr isEqualToString:@"<null>"]) {
        return YES;
    }
    if ([aStr isEqualToString:@"null"]) {
        return YES;
    }
    return NO;
//    if (aStr && [aStr isKindOfClass:[NSString class]] && [aStr length] > 0 && ![aStr isEqualToString:@"<null>"]) {
//        return NO;
//    }
//    return YES;
}

+ (BOOL)isNotNull:(NSString *)aStr
{
    return ![NSString isNull:aStr];
}

+ (BOOL)isNumber:(NSString *)aStr
{
    if ([NSString isNull:aStr]) {
        return NO;
    }
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if([pred evaluateWithObject:aStr]) {
        return YES;
    }
    return NO;
}

+ (NSString *)uuid
{
	CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
	// Get the string representation of CFUUID object.
	NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
	CFRelease(uuidObject);
	return [uuidStr autorelease];
}


- (NSMutableString *)deleteSpecialChar
{
	self = [self replaceCharacter:@"\\n" withString:@"<br/>"];
	self = [self replaceCharacter:@"\\r" withString:@"<br/>"];
	NSMutableString *result = [NSMutableString stringWithString:self];
    NSString *character = nil;
    for (int i = 0; i < result.length; i ++) {
        character = [result substringWithRange:NSMakeRange(i, 1)];
        if ([character isEqualToString:@"\\"]) {
			[result deleteCharactersInRange:NSMakeRange(i, 1)];
		}
    }
	return result;
}


+ (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}

+ (NSString *)typeSafeTransform:(NSString *)str {
    if (str) {
        return str;
    } else {
        return @"";
    }
}

- (NSString *)decodeFromPercentEscapeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    NSString *aValue = [outputStr stringByRemovingPercentEncoding];
//    NSString *aValue = [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (aValue) {
        return aValue;
    }
    return self;
}

- (NSString *)handleFileNameSpecialCharactersAtPath {
    return [self replaceCharacter:@"/" withString:@":"];
}

- (NSString *)originalFileNameSpecialCharactersAtPath {
    return [self replaceCharacter:@":" withString:@"/"];
}


- (NSString *)appendHtmlUrlParam:(NSString *)aKey value:(NSString *)aValue
{
	// 判断是否存在?号
	NSRange r = [self rangeOfString:@"?"];
	if (r.length > 0) {
		return [self stringByAppendingFormat:@"&%@=%@", aKey, aValue];
	}
	return [self stringByAppendingFormat:@"?%@=%@", aKey, aValue];
}

- (NSString *)urlPath
{
	NSArray *aList1 = [self componentsSeparatedByString:@"?"];
	if (aList1.count > 0) {
		return [aList1 objectAtIndex:0];
	}
	return nil;
}

- (NSDictionary *)urlPropertyValue
{
	NSArray *aList = [self componentsSeparatedByString:@"?"];
	if (aList.count < 2) {
		return nil;
	}
	NSMutableDictionary *aDict = [NSMutableDictionary dictionary];
	NSString *rootPath = [aList objectAtIndex:0];
	[aDict setObject:rootPath forKey:@"rootPath"];
	NSString *aValueStr = [aList objectAtIndex:1];
	NSArray *aList1 = [aValueStr componentsSeparatedByString:@"&"];
	for (NSString *aStr in aList1) {
		NSArray *l = [aStr componentsSeparatedByString:@"="];
		if (l.count == 2) {
			NSString *k = [l objectAtIndex:0];
			NSString *v = [l objectAtIndex:1];
			[aDict setObject:v forKey:k];
		}
	}
	return aDict;
}

- (NSDictionary *)propertyValue
{
    NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
    NSArray *aList1 = [self componentsSeparatedByString:@","];
    for (NSString *aStr in aList1) {
        NSArray *l = [aStr componentsSeparatedByString:@"="];
        if (l.count == 2) {
            NSString *k = [[l objectAtIndex:0]replaceCharacter:@" " withString:@""];
            NSString *v = [l objectAtIndex:1];
            [aDict setObject:v forKey:k];
        }
    }
    return [aDict autorelease];
}

- (CGSize)sizeWithFontSize:(UIFont*)fontSize defaultSize:(CGSize)defaultSize
{
    CGSize stringSize;
    UIFont *stringFont = fontSize;
    NSDictionary *attribute = @{NSFontAttributeName: stringFont};
    CGRect f= [self boundingRectWithSize:defaultSize
                                 options:
               NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                              attributes:attribute
                                 context:nil];
    stringSize.height =  ceilf(f.size.height);
    stringSize.width = ceilf(f.size.width);
    return stringSize;
}

//计算字符个数
+ (int)textLength:(NSString *)text
{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++)
    {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number + 0.5;
        }
    }
    return ceil(number);
}

#define CHUNK_SIZE_BIG      10240

- (NSString *)md5String
{
    const char *myPasswd = [self UTF8String];
    unsigned char mdc[16];
    CC_MD5(myPasswd, (CC_LONG)strlen(myPasswd), mdc);
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i< 16; i++) {
        [md5String appendFormat:@"%02x",mdc[i]];
    }
    return md5String;
}

/**
 * 网址正则验证 1或者2使用哪个都可以
 *
 *  @param string 要验证的字符串
 *
 *  @return 返回值类型为BOOL
 */
- (BOOL)urlValidation:(NSString *)string
{
    NSError *error;
    // 正则1
    NSString *regulaStr =@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    // 正则2
    regulaStr =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                          options:NSRegularExpressionCaseInsensitive
                                                                            error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches){
//        NSString* substringForMatch = [string substringWithRange:match.range];
        NSLog(@"匹配");
        return YES;
    }
    return NO;
}

+ (unsigned int)stringFromHexString:(NSString *)hexString
{
    if(hexString == nil)
    return 0;
    
    const char *a = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int map[103] = {0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,1,
        2,3,4,5,6,7,8,9,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,10,11,12,
        13,14,15};
    
    unsigned int tmp = 0x00000000;
    
    size_t len = strlen(a);
    
    for(int i = 0; i < len; i++){
        
        char t = a[len-i-1];
        int value = map[t];
        tmp += value*pow(16,i);
    }

    return tmp;
}

+ (NSString *)createFontUnicodeHexIdentifyWithHexString:(NSString *)hexString;
{
    unsigned int lowHexVaue = [NSString stringFromHexString:hexString];
    unsigned int result = 0xfffe0000;
    result = result|lowHexVaue;
    
        result = ((result & 0xff000000) >> 16)
        | ((result & 0x00ff0000) >>  16)
        | ((result & 0x0000ff00) <<  8)
        | ((result & 0x000000ff) << 24);
         
    NSData *data = [NSData dataWithBytes:&result length:sizeof(result)];
    NSLog(@"%@",data);
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
    return [ret autorelease];
}


//md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)srcString
{
    if (!srcString) {
        return nil;
    }
    const char *cStr = [srcString UTF8String ];
    
    unsigned char digest[ CC_MD5_DIGEST_LENGTH ];
    
    CC_MD5 ( cStr, (CC_LONG) strlen (cStr), digest );
    
    NSMutableString *result = [ NSMutableString stringWithCapacity : CC_MD5_DIGEST_LENGTH * 2 ];
    
    for ( int i = 0 ; i < CC_MD5_DIGEST_LENGTH ; i++)
        
        [result appendFormat : @"%02x" , digest[i]];
    
    return result;
}

- (NSString *)sha1
{
    // see http://www.makebetterthings.com/iphone/how-to-get-md5-and-sha1-in-objective-c-ios-sdk/
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (BOOL)containsSpecialCharacters {
    BOOL isContains = NO;
    NSString *specialString = @"#%<>^`\[]{|}/:?@";
    NSInteger length = specialString.length;
    for (NSInteger i = 0; i < length; i++) {
        NSString *c = [specialString substringWithRange:NSMakeRange(i, 1)];
        if ([self containsString:c]) {
            isContains = YES;
            break;
        }
    }
    return isContains;
}

//是否包含表情
- (BOOL)containsEmoji
{
    __block BOOL returnValue = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              const unichar hs = [substring characterAtIndex:0];
                              if (0xd800 <= hs && hs <= 0xdbff) {
                                  if (substring.length > 1) {
                                      const unichar ls = [substring characterAtIndex:1];
                                      const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          returnValue = YES;
                                      }
                                  }
                              }
                              else if (substring.length > 1) {
                                  const unichar ls = [substring characterAtIndex:1];
                                  if (ls == 0x20e3) {
                                      returnValue = YES;
                                  }
                              }
                              else {
                                  if (0x2100 <= hs && hs <= 0x27ff) {
                                      if (hs < 0x278b || hs > 0x2792) {
                                         //0x278b ---  0x2792  是中文九宫格
                                          returnValue = YES;
                                      }
                                  }
                                  else if (0x2B05 <= hs && hs <= 0x2b07) {
                                      returnValue = YES;
                                  }
                                  else if (0x2934 <= hs && hs <= 0x2935) {
                                      returnValue = YES;
                                  }
                                  else if (0x3297 <= hs && hs <= 0x3299) {
                                      returnValue = YES;
                                  }
                                  else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                      returnValue = YES;
                                  }
                              }
                          }];
    
    return returnValue;
}

- (BOOL)justContainsNumber {
    if ([NSString isNull:self]) {
        return NO;
    }
    NSString *trimStr = [self replaceCharacter:@" " withString:@""];
    if ([NSString isNull:trimStr]) return NO;
    
    NSString *firstC = [trimStr substringToIndex:1];
    if ([firstC isEqualToString:@"-"]) {
        if (trimStr.length >1) {
            trimStr = [trimStr substringFromIndex:1];
        }
        else {
            return NO;
        }
    }
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if([pred evaluateWithObject:trimStr]) {
        return YES;
    }
    return NO;
}

- (NSString *)formatPhoneNumber {
    NSString *trimStr = [self replaceCharacter:@" " withString:@""];
    NSRange range;
    NSMutableString *formattedStr = [NSMutableString string];
    
    for(int i = 0; i < trimStr.length; i += range.length) {
        range = [trimStr rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *s = [trimStr substringWithRange:range];
        if ( i+1 > 3 &&
            ((i+1)-3)%4 == 1) {
            [formattedStr appendString:@" "];
        }
        [formattedStr appendString:s];
    }
    
    return [formattedStr copy];
}

- (NSString *)formatWifiBssid {
    
    NSArray *separatedArr = [self  componentsSeparatedByString:@":"];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    [separatedArr enumerateObjectsUsingBlock:^(NSString  *str, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *copyStr = [str copy];
        if (str.length < 2) {
            copyStr = [NSString stringWithFormat:@"0%@",str];
        }
        [infoArr addObject:copyStr];
    }];
    
    return  [infoArr componentsJoinedByString:@":"];
    
}

- (NSString*)stringByTruncatingTailWithFont:(UIFont *)font width:(CGFloat)width {
    NSMutableString *resultString = [[self mutableCopy] autorelease];
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    if ([resultString boundingRectWithSize:CGSizeZero options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size.width <= width) {
        return self;
    }
    
    if (resultString.length < 6) {
        return self;
    }
    
    NSRange range = {resultString.length - 3, 3};
    [resultString replaceCharactersInRange:range withString:@"..."];
    
//    NSInteger left = resultString.length / 2 - 2;
//    NSInteger right = left + 4;
    
    while ([resultString boundingRectWithSize:CGSizeZero options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size.width > width) {
        [resultString deleteCharactersInRange:NSMakeRange(resultString.length - 4, 1)];
//        if (resultString.length % 2 == 0) {
//            [resultString deleteCharactersInRange:NSMakeRange(left, 1)];
//            right--;
//            left--;
//        } else {
//            if (right >= resultString.length) {
//                break;
//            }
//            [resultString deleteCharactersInRange:NSMakeRange(right, 1)];
//        }
    }
    
    return resultString;
}


- (BOOL)isUrlPath {
    NSString *lowerStr = self.lowercaseString;
    if ([lowerStr hasPrefix:@"http"] || [lowerStr hasPrefix:@"https"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isFilePath {
    return [self.lowercaseString hasPrefix:@"file"];
}

+ (NSString *)deviceTokenStringWithDeviceToken:(NSData *)deviceToken {
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSUInteger iCount = deviceToken.length;
    for (NSUInteger i = 0; i < iCount; i++) {
         [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
    }
    return [deviceTokenString copy];
}

- (CGFloat)getWidthWithHeight:(CGFloat)height font:(UIFont *)font {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    return rect.size.width;
}

- (CGFloat)getHeightWithWidth:(CGFloat)width font:(UIFont *)font {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    return rect.size.height;
}

- (CGFloat)getHeightWithWidth:(CGFloat)width font:(UIFont *)font numberOfLines:(NSInteger)numberOfLines {
    UILabel *sizeLable = [[UILabel alloc] init];
    sizeLable.font = font;
    sizeLable.numberOfLines = numberOfLines;
    sizeLable.text = self;
    CGSize size = [sizeLable sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return size.height;
}

//emoji编码
- (NSString *)emojiEncode{
    NSString *uniStr = [NSString stringWithUTF8String:[self UTF8String]];
    NSData *uniData = [uniStr dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *emojiText = [[NSString alloc] initWithData:uniData encoding:NSUTF8StringEncoding];
    return emojiText;
}
 
//emoji解码
- (NSString *)emojiDecode{
    const char *jsonString = [self UTF8String];
    NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
    NSString *emojiText = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
    return emojiText;
}

//秒数转为时长
+ (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

+ (NSString *)convertToString:(id)convertedObject {
    NSString *convertString = nil;
    if ([convertedObject isKindOfClass:[NSNumber class]]) {
        convertString = [convertedObject stringValue];
    } else if ([convertedObject  isKindOfClass:[NSString class]]) {
        convertString = convertedObject;
    }
    return convertString;
}

- (NSString *)stringValue {
    return [self copy];
}

+ (NSString *)fileNameAppendSuffix:(NSString *)fileName suffix:(NSInteger)suffix {
    NSString *pathExtension = fileName.pathExtension;
    NSString *name = fileName.stringByDeletingPathExtension;
    NSString *tempName = [NSString stringWithFormat:@"%@(%ld).%@",name,(long)suffix,pathExtension];
    return tempName;
}

// 判断是否是11位手机号码
+ (BOOL)judgePhoneNumber:(NSString *)phoneNum {
    /**
     * 移动号段正则表达式
     */
    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    /**
     * 联通号段正则表达式
     */
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    /**
     * 电信号段正则表达式
     */
    NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    
    // 一个判断是否是手机号码的正则表达式
    NSString *pattern = [NSString stringWithFormat:@"(%@)|(%@)|(%@)",CM_NUM,CU_NUM,CT_NUM];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
        NSString *mobile = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (mobile.length != 11) {
            NO;
        }
        
        // 无符号整型数据接收匹配的数据的数目
        NSUInteger numbersOfMatch = [regularExpression numberOfMatchesInString:mobile options:NSMatchingReportProgress range:NSMakeRange(0, mobile.length)];
        if (numbersOfMatch>0) return YES;
    
    return NO;
    
}

-(NSString *)urlStrSafeHandle
{
    if (![self containsString:@"://"]) {
        return self;
    }
    //ks fix -- 8.1sp2 10m 临时兼容处理，后续专项修改
    //V5-38251【V8.1SP2-M10】打印预览报错
    if ([self containsString:@"/trans/htmlToPdf?"]) {
        return self;
    }
    //end
    NSString *aStr = [[NSString alloc] initWithString:self];
    NSString *bStr;
    BOOL goon = YES;
    while (goon) {
        bStr = [aStr stringByRemovingPercentEncoding];
        if (!bStr || [aStr isEqualToString:bStr]) {
            goon = NO;
        }else{
            aStr = bStr;
        }
    };
//    NSArray *arr = [aStr componentsSeparatedByString:@"?"];
//    if (arr.count == 2) {
//        NSString *queryStr = arr.lastObject;
//        if (queryStr.length>0) {
//            queryStr = [queryStr stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
//            aStr = [arr.firstObject stringByAppendingFormat:@"?%@",queryStr];
//        }
//    }
    NSURLComponents *components = [[NSURLComponents alloc]initWithString:aStr];
    if([components.host containsString:@"["] && [components.host containsString:@"["]){
        return [self encodeIPv6:aStr];
    }

    return [aStr stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

- (NSString *)encodeIPv6:(NSString *)ipv6Str{
    NSString *urlString = ipv6Str;
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    NSString *host = components.host;
    NSString *encodedHost = [host stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    components.host = encodedHost;

    NSString *path = components.path;
    NSString *encodedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    components.path = encodedPath;

    NSString *query = components.query;
    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    components.query = encodedQuery;

    NSURL *encodedUrl = components.URL;
    
    return encodedUrl.absoluteString;
}

- (void)cmp_enumerateRangeOfString:(NSString *)searchString usingBlock:(void (^)(NSRange searchStringRange, NSUInteger idx, BOOL *stop))block
{
    if ([self isKindOfClass:[NSString class]] && self.length &&
        [searchString isKindOfClass:[NSString class]] && searchString.length) {
        NSArray <NSString *>*separatedArray = [self componentsSeparatedByString:searchString];
        if (separatedArray.count < 2) {
            return ;
        }
        NSUInteger count = separatedArray.count - 1; //少遍历一次，由于拆分以后，最后一部分是没用的
        NSUInteger length = searchString.length;
        __block NSUInteger location = 0;
        [separatedArray enumerateObjectsUsingBlock:^(NSString * _Nonnull componentString, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == count) {
                *stop = YES;
            }
            else {
                location += componentString.length; //跳过待筛选串前面的串长度
                if (block) {
                    block(NSMakeRange(location, length), idx, stop);
                }
                location += length; //跳过待筛选串的长度
            }
        }];
    }
}

@end

