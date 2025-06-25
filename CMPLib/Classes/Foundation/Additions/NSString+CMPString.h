//
//  NSStringAdditions.h
//  nsstringAddtion
//
//  Created by  on 12-9-27.
//  Copyright (c) 2012年 www.seeyon.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NSString(CMPString)
//删除两端空格
- (NSString *)deleteBothSidesWhitespaces;
//替换字符
- (NSString *) replaceCharacter:(NSString *)oStr withString:(NSString *)nStr;

//是否包含空格或空行
- (BOOL) isContainWhitespaceAndNewlines;

//是否是空格或空行
- (BOOL) isWhitespaceAndNewlines;

//用来判断textField.text/textView.text是否为空或空白
- (BOOL) isEmptyOrWhitespace;

-(NSString *)urlEncodingNew;
-(NSString *)urlDecodeNew;

//转换url中特殊含义字符：!#$%&'()*+,/:;=?@[]
- (NSString*) urlCFEncoded;

//decode url
-(NSString *)URLDecodedString:(NSString *)str;

//utf8 编码
- (NSString*) urlUTF8Encoded;

//缓存目录路径
+ (NSString*) getCachesDirectory;

//文件目录路径
+ (NSString*) getDocumentsDirectory;

+ (NSString*) DataToASCIIString:(NSData*)data;

- (NSString*) compositePublicKeyFromJavaKeyString;

- (NSString*) compositePrivateKeyFromJavaKeyString;

+ (unsigned int)stringFromHexString:(NSString *)hexString;
+ (NSString *)createFontUnicodeHexIdentifyWithHexString:(NSString *)hexString;

// 删除空格
- (NSString *)trim;
// int to string
+ (NSString *)valueOf:(int)n;
// 是否相似
- (BOOL)isSame:(NSString *)s;
// 第一个字母大写
- (NSString *)firstUpper;
+ (NSString *)stringWithLongLong:(long long)value;
+ (NSString *)stringWithInt:(NSInteger)aValue;
+ (NSString *)stringWithBool:(BOOL)aValue;
+ (NSMutableString *)replaceString:(NSString *)str;
+ (NSString *)stringFromHtmlStr:(NSString *)str;
+ (BOOL)isNull:(NSString *)aStr;
+ (BOOL)isNotNull:(NSString *)aStr;
+ (BOOL)isNumber:(NSString *)aStr; // 是否为数字
+ (NSString *)uuid;

+ (NSString *)typeSafeTransform:(NSString *)str;



- (NSMutableString *)deleteSpecialChar;

+ (NSString*)deviceString;

- (NSString *)decodeFromPercentEscapeString;

- (NSString *)handleFileNameSpecialCharactersAtPath;

- (NSString *)originalFileNameSpecialCharactersAtPath;

- (NSString *)appendHtmlUrlParam:(NSString *)aKey value:(NSString *)aValue;

- (NSString *)urlPath;
- (NSDictionary *)urlPropertyValue;
- (NSDictionary *)propertyValue;
- (CGSize)sizeWithFontSize:(UIFont*)fontSize defaultSize:(CGSize)defaultSize;

- (NSString *)urlEncoding;
- (NSString *)urlEncoding2Times;

//计算字符个数
+ (int)textLength:(NSString *)text;

//md5
- (NSString *)md5String;

- (BOOL)urlValidation:(NSString *)string;
+ (NSString *)md5:(NSString *)srcString;

- (NSString *)sha1;

/// 是否包含特殊字符
- (BOOL)containsSpecialCharacters;
//是否包含表情
- (BOOL)containsEmoji;
// 是否仅包含数字
- (BOOL)justContainsNumber;
// 格式化手机号，格式： 3 4 4，例如：133 1234 1234，长度限制为11
- (NSString *)formatPhoneNumber;
/**
 格式化wifi bssid，格式：22:bc:5a:09:e1:38 将少于一位的补齐两位

 @return 格式化完成的 wifi bssid
 */
- (NSString *)formatWifiBssid;


/**
 截断一个字符串，例如：abcdddeeede 截取后 abc...

 @param font 字体
 @param width 宽度
 @return 截取之后的字符串
 */
- (NSString*)stringByTruncatingTailWithFont:(UIFont *)font
                                      width:(CGFloat)width;

//是否是http或https路径
- (BOOL)isUrlPath;
//是否是本地file://路径
- (BOOL)isFilePath;

//将deviceToken转为NSString
+ (NSString *)deviceTokenStringWithDeviceToken:(NSData *)deviceToken;
//固定高度,获取文字宽度
- (CGFloat)getWidthWithHeight:(CGFloat)height font:(UIFont *)font;
//固定宽度,获取文字高度
- (CGFloat)getHeightWithWidth:(CGFloat)width font:(UIFont *)font;
//固定宽度,文字行数,获取文字高度
- (CGFloat)getHeightWithWidth:(CGFloat)width font:(UIFont *)font numberOfLines:(NSInteger)numberOfLines;
//emoji编码
- (NSString *)emojiEncode;
//emoji解码
- (NSString *)emojiDecode;
//秒数转为时长
+ (NSString *)timeFormatted:(int)totalSeconds;
//返回字符串对象
+ (NSString *)convertToString:(id)convertedObject;

//给文件名添加同名后缀
+ (NSString *)fileNameAppendSuffix:(NSString *)fileName suffix:(NSInteger)suffix;

// 判断是否是11位手机号码
+ (BOOL)judgePhoneNumber:(NSString *)phoneNum;

-(NSString *)urlStrSafeHandle;
- (void)cmp_enumerateRangeOfString:(NSString *)searchString usingBlock:(void (^)(NSRange searchStringRange, NSUInteger idx, BOOL *stop))block;
@end
