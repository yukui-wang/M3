//
//  SPTools.m
//  CMPCore
//
//  Created by CRMO on 2017/2/20.
//
//

#define kXZIntentTempPath       @"Documents/XiaoZhiFile/Intent/temp"
#define kXZIntentZipPath        @"Documents/XiaoZhiFile/Intent/ZipFiles"
#define kXZIntentTempFilePath   @"Documents/XiaoZhiFile/Intent/tempFile"
#define kXZIntentFolderPath     @"Documents/XiaoZhiFile/Intent/intentFiles"

#define kSpeechErrorCorrectionPath   @"Documents/XiaoZhiFile/speechErrorCorrection/temp"
#define kSpeechErrorCorrectionFolderPath @"Documents/XiaoZhiFile/speechErrorCorrection/files"


#define kPinyinRegularTempDownloadPath       @"Documents/XiaoZhiFile/PinyinRegular/tempZip"
#define kPinyinRegularFilePath              @"Documents/XiaoZhiFile/PinyinRegular/file"

#import "SPTools.h"
#import "XZCore.h"
#import <CMPLib/ZipArchiveUtils.h>
#import "XZMainProjectBridge.h"
@implementation SPTools

/**
 删除字符串中的标点符号：
 ,.!?，。！？
 
 @param str 待处理字符串
 
 */
+ (NSString *)deletePunc:(NSString *)str {    
    NSError *error = nil;
    NSString *result = str;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？-]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *regexResult = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    if (regexResult.count > 0) {
        for (int i = 0; i<regexResult.count; i++) {
            NSTextCheckingResult *res = regexResult[i];
            result = [result stringByReplacingOccurrencesOfString:[str substringWithRange:res.range] withString:@""];
        }
    }
    return result;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSString * responseString;
    responseString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"</br>" withString:@""];
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSObject *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&err];
    if ([dic isKindOfClass:[NSArray class]]) {
        return [(NSArray *)dic firstObject];
    }
    return (NSDictionary *)dic;
}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+ (NSString *)getMainText:(NSString *)text {    
    NSRange range1 = [text rangeOfString:SPEECH_END_KEY];
    NSRange range2 = [text rangeOfString:SPEECH_END_KEY2];
    NSRange range3 = [text rangeOfString:SPEECH_END_KEY3];
    NSRange range4 = [text rangeOfString:SPEECH_END_KEY4];
    NSRange range5 = [text rangeOfString:SPEECH_END_KEY5];
    NSRange range6 = [text rangeOfString:SPEECH_END_KEY6];
    
    if (range1.length != 0) {
        return [text substringToIndex:range1.location];
    }
    
    if (range2.length != 0) {
        return [text substringToIndex:range2.location];
    }
    if (range3.length != 0) {
        return [text substringToIndex:range3.location];
    }
    if (range4.length != 0) {
        return [text substringToIndex:range4.location];
    }
    if (range5.length != 0) {
        return [text substringToIndex:range5.location];
    }
    if (range6.length != 0) {
        return [text substringToIndex:range6.location];
    }
    return text;
}

+ (NSInteger)getOptionNumber:(NSString *)str {
    if ([str rangeOfString:@"0"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"1"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"2"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"3"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"4"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"5"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"6"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"7"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"8"].location != NSNotFound) {
        return [str integerValue];
    }
    if ([str rangeOfString:@"9"].location != NSNotFound) {
        return [str integerValue];
    }
    NSString *result = [str stringByReplacingOccurrencesOfString:@"二十" withString:@"20"];
    result = [result stringByReplacingOccurrencesOfString:@"十九" withString:@"19"];
    result = [result stringByReplacingOccurrencesOfString:@"十八" withString:@"18"];
    result = [result stringByReplacingOccurrencesOfString:@"十七" withString:@"17"];
    result = [result stringByReplacingOccurrencesOfString:@"十六" withString:@"16"];
    result = [result stringByReplacingOccurrencesOfString:@"十五" withString:@"15"];
    result = [result stringByReplacingOccurrencesOfString:@"十四" withString:@"14"];
    result = [result stringByReplacingOccurrencesOfString:@"十三" withString:@"13"];
    result = [result stringByReplacingOccurrencesOfString:@"十二" withString:@"12"];
    result = [result stringByReplacingOccurrencesOfString:@"十一" withString:@"11"];
    result = [result stringByReplacingOccurrencesOfString:@"十" withString:@"10"];
    result = [result stringByReplacingOccurrencesOfString:@"九" withString:@"9"];
    result = [result stringByReplacingOccurrencesOfString:@"八" withString:@"8"];
    result = [result stringByReplacingOccurrencesOfString:@"七" withString:@"7"];
    result = [result stringByReplacingOccurrencesOfString:@"六" withString:@"6"];
    result = [result stringByReplacingOccurrencesOfString:@"五" withString:@"5"];
    result = [result stringByReplacingOccurrencesOfString:@"四" withString:@"4"];
    result = [result stringByReplacingOccurrencesOfString:@"三" withString:@"3"];
    result = [result stringByReplacingOccurrencesOfString:@"二" withString:@"2"];
    result = [result stringByReplacingOccurrencesOfString:@"一" withString:@"1"];
    
    result = [[result componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    if (!result) {
        NSLog(@"speech---没有提取到数字");
        return 0;
    }
    NSLog(@"speech---提取到数字：%@", result);
    return [result integerValue];
}

+ (NSString *)arrayToStr:(NSArray *)arr {
    NSString *result = @"";
    for (NSString *str in arr) {
        result = [NSString stringWithFormat:@"%@%@%@", result,result.length>0?@",":@"", str];
    }
    // 去掉多余的逗号
    if ([result characterAtIndex:(result.length - 1)] == ',') {
        result = [result substringToIndex:(result.length - 1)];
    }
    return result;
}



+ (UIViewController *)currentViewController {
    
//    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIWindow *keyWindow = [SPTools keyWindow];
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

+ (NSString *)getNameWithTitle:(NSString *)title {
    NSString *result;
    result = [title stringByReplacingOccurrencesOfString:@"查找" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"发给我的" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"待办" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"已办" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"协同" withString:@""];
    return result;
}

+ (NSString *)getTypeWithTitle:(NSString *)title {
    if ([title containsString:@"已办"]) {
        return @"4";
    } else if ([title containsString:@"待办"]) {
        return @"3";
    } else {
        NSLog(@"speech---getTypeWithTitle：请输入已办和待办");
        return @"";
    }
}

/**
 去掉名字后面括号里面的内容
 @param name 待处理名字
 @return 处理结果
 */
+ (NSString *)getMainName:(NSString *)name {
    NSError *error = nil;
    NSString *result = name;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\(|\\（)[^\\(]*(\\)|\\）)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *regexResult = [regex matchesInString:name options:0 range:NSMakeRange(0, name.length)];
    if (regexResult.count > 0) {
        for (int i = 0; i<regexResult.count; i++) {
            NSTextCheckingResult *res = regexResult[i];
            result = [result stringByReplacingOccurrencesOfString:[name substringWithRange:res.range] withString:@""];
        }
    }
    
    return result;
}

/**
 0-9替换零-九 a-z替换啊-在 返回纯汉字字符串
 */
+ (NSString *)hanziStringWithString:(NSString*)string {
    //step1.replace
    NSDictionary *dic = @{@"0":@"零",@"1":@"一",@"2":@"二",@"3":@"三",@"4":@"四",@"5":@"五",@"6":@"六",@"7":@"七",@"8":@"八",@"9":@"九",@"a":@"啊",@"b":@"吧",@"c":@"才",@"d":@"的",@"e":@"额",@"f":@"发",@"g":@"个",@"h":@"好",@"i":@"了",@"j":@"就",@"k":@"看",@"l":@"了",@"m":@"吗",@"n":@"你",@"o":@"哦",@"p":@"跑",@"q":@"去",@"r":@"人",@"s":@"是",@"t":@"他",@"u":@"有",@"v":@"为",@"w":@"我",@"x":@"想",@"y":@"有",@"z":@"在"};
    __block NSString *string1 = [string lowercaseString];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
        string1 = [string1 stringByReplacingOccurrencesOfString:key withString:obj];
    }];
    //step2.match and replace
    NSString *pattern = @"[^\\u4e00-\\u9fa5]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSString *ss = [regex stringByReplacingMatchesInString:string1 options:0 range:NSMakeRange(0, string1.length) withTemplate:@""];
    
    return ss;
}

/**
 字符串相似度匹配
 
 @param string 源字符串
 @param string1 目标字符串
 @param distence 相似度范围（在码表中的前后相邻字数）
 @return no 匹配不成功 yes 匹配成功
 */
+ (BOOL)stringCodeCompare:(NSString*)string withString:(NSString*)string1 distence:(int)distence {
    if ((string.length != string1.length) || !string.length) {
        return NO;
    }
    for (int i = 0; i < string.length; i++) {
        int code1 = [self getDBCSCodeWithChar:[string substringWithRange:NSMakeRange(i, 1)]];
        int code2 = [self getDBCSCodeWithChar:[string1 substringWithRange:NSMakeRange(i, 1)]];
        if (abs(code1-code2) <= distence) {
            continue;
        } else {
            return NO;
            break;
        }
    }
    return YES;
}

+ (int)getDBCSCodeWithChar:(NSString*)cc {
    int code = -1;
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data=[cc dataUsingEncoding:encoding];
    Byte bs[2];
    if (data.length < 2) {
        code = (int)cc;
    } else
        [data getBytes:&bs length:data.length];
    code = (bs[0] << 8) | (bs[1] & 0x00FF);
    return code;
}

+ (NSString *)fileSizeFormat:(long long )fileSize {
    if (fileSize < 1024) {
        return [NSString stringWithFormat:@"%lldB",fileSize];
    }
    else if (fileSize < 1024*1024){
        return [NSString stringWithFormat:@"%.1fKB",fileSize/1024.0];
    }
    else if (fileSize < 1024*1024*1024){
        return [NSString stringWithFormat:@"%.1fMB",fileSize/1024.0/1024.0];
    }
    return @"0K";
}

+ (UIImage *)imageWithType:(NSString *)type {
    //同融云消息
    NSMutableSet *imageTypeSet = [NSMutableSet setWithObjects:@"PNG", @"JPG", @"JPEG", @"BMP",
                                  @"TIFF", @"TIF", @"TGA", @"WMF", @"ICO", @"DIB", nil];
    NSMutableSet *audioTags = [NSMutableSet setWithObjects:@"CAF", @"MP3", @"WAV", @"MID", @"MP1", @"MP2",
                               @"RA", @"ASF", @"WMA", @"AMR", nil];
    NSMutableSet *videoTags = [NSMutableSet setWithObjects:@"MP4", @"MOV", @"M4V",  @"RMNV", @"AVI", nil];
    // change buy wujs OA-209905 BAT 不支持查看
    NSMutableSet *textTags = [NSMutableSet setWithObjects:@"TXT", @"INI", @"JAVA", @"M",
                               @"MM", @"H", @"CPP", nil];
    NSMutableSet *officeDocTypeSet = [NSMutableSet setWithObjects:@"DOC", @"DOCX",
                                      @"RTF", nil];
    NSMutableSet *officeExceTypeSet = [NSMutableSet setWithObjects: @"XLS", @"XLSX", nil];
    NSMutableSet *officePPtTypeSet = [NSMutableSet setWithObjects:@"PPT",@"PPTX", nil];
    NSMutableSet *officePdfTypeSet = [NSMutableSet setWithObjects:@"PDF", nil];
    NSString *extention = [type uppercaseString];
    NSString *imageName = @"OtherFile.png";
    if ([imageTypeSet containsObject:extention]){
        imageName = @"PictureFile.png";
    }
    else if ([audioTags containsObject:extention]) {
        imageName = @"Mp3File.png";
    }
    else if ([videoTags containsObject:extention]) {
        imageName = @"VideoFile.png";
    }
    else if ([textTags containsObject:extention]) {
        imageName = @"TextFile.png";
    }
    else if ([officeDocTypeSet containsObject:extention]){
        imageName = @"WordFile.png";
    }
    else if ([officeExceTypeSet containsObject:extention]){
        imageName = @"ExcelFile.png";
    }
    else if ([officePPtTypeSet containsObject:extention]){
        imageName = @"pptFile.png";
    }
    else if ([officePdfTypeSet containsObject:extention]){
        imageName = @"PdfFile.png";
    }
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"RongCloud.bundle/%@",imageName]];
    return image;
}

+ (NSString *)stringValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *value = dic[key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}


+ (CGFloat)floatValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return 0.0;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(floatValue)]) {
        CGFloat f = [value floatValue];
        return f;
    }
    return 0.0;
}

+ (NSInteger)integerValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

+ (long long)longLongValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(longLongValue)]) {
        return [value longLongValue];
    }
    return 0.0;
}

+ (NSDictionary *)dicValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *value = dic[key];
    if (value && [value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

+ (NSArray *)arrayValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSArray *value = dic[key];
    if (value && [value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

+ (BOOL)boolValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}

//NSAttributedString 转 Html
+ (NSString *)htmlStrFormAttributedStr:(NSAttributedString *)attStr {
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [attStr dataFromRange:NSMakeRange(0, attStr.length) documentAttributes:documentAttributes error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return htmlString;
}
//Html 转 NSAttributedString
+ (NSAttributedString *)attrStrFormHtmlStr:(NSString *)htmlStr {
    NSAttributedString* attributeString = [[NSAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}  documentAttributes:nil error:nil];
    return attributeString;
}

#pragma mark intent path Start

+ (NSString *)localIntentDownloadPath {
    NSString *path = [[SPTools createFullPath:kXZIntentTempPath]stringByAppendingPathComponent:@"appsscript.zip"];
    return path;
}

+ (NSString *)localIntentFolderPath {
    NSString *serverId = [XZCore serverID];
    NSString *path = [NSString stringWithFormat:@"%@/%@",kXZIntentFolderPath,serverId];
    NSString *filePath = [SPTools createFullPath:path];
    return filePath;
}

+ (NSString *)zipPathWithServerId:(NSString *)serverId {
    NSString *path = [NSString stringWithFormat:@"%@/%@",kXZIntentZipPath,serverId];
    NSString *filePath = [[SPTools createFullPath:path] stringByAppendingPathComponent:@"appsscript.zip"];
    return filePath;
}

+ (NSString *)unZipLocalIntents {
    
    NSString *serverId = [XZCore serverID];
    NSString *tempZipPath = [SPTools localIntentDownloadPath];
    NSString *fileZipPath = [SPTools zipPathWithServerId:serverId];
    //1 下载的临时目录下的zip移动到zip，目录
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileZipPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileZipPath error:nil];
    }
    [[NSFileManager defaultManager] moveItemAtPath:tempZipPath toPath:fileZipPath error:nil];
  
    //2 zip解压到临时目录
    NSString *tempFile = [SPTools createFullPath:kXZIntentTempFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
    }
    BOOL isUnZipSucces = [ZipArchiveUtils unZipArchiveNOPassword:fileZipPath unzipto:tempFile];
    if (!isUnZipSucces) {
        return nil;
    }
    //3 解压成功后的文件移动到对应目录
    NSArray *fileArray = [[NSFileManager defaultManager] subpathsAtPath:tempFile];
    if (fileArray.count == 0) {
        return nil;
    }
    NSString *folderPath = [SPTools localIntentFolderPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
    }
    [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:folderPath error:nil];

    return folderPath;
}


+ (NSString *)speechErrorCorrectionDownloadPath {
    NSString *path = [[SPTools createFullPath:kSpeechErrorCorrectionPath]stringByAppendingPathComponent:@"speechErrorCorrection.json"];
    return path;
}

+ (NSString *)speechErrorCorrectionPath {
    NSString *serverId = [XZCore serverID];
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@",kSpeechErrorCorrectionFolderPath,serverId];
    folderPath = [SPTools createFullPath:folderPath];
    NSString *path = [folderPath stringByAppendingPathComponent:@"speechErrorCorrection.json"];
    return path;
}

+ (NSString *)unZipspeechErrorCorrection {
    NSString *tempPath = [SPTools speechErrorCorrectionDownloadPath];
    NSString *filePath = [SPTools speechErrorCorrectionPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    }
    [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:filePath error:nil];
    return filePath;
}

+ (NSDictionary *)spErrorCorrectionDic {
    NSString *path = [SPTools speechErrorCorrectionPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [NSDictionary dictionary];
    }
    NSString *json = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!json) {
        return [NSDictionary dictionary];
    }
    NSDictionary *result = [SPTools dictionaryWithJsonString:json];
    if (!result || ![result isKindOfClass:[NSDictionary class]]) {
        return [NSDictionary dictionary];
    }
    return result;
}


+ (NSString *)pinyinRegularDownloadPath {
    NSString *path = [[SPTools createFullPath:kPinyinRegularTempDownloadPath]stringByAppendingPathComponent:@"xzPinyinRegular.txt"];
    return path;
}

+ (NSString *)pinyinRegularFilePath:(NSString *)fpath {
    NSString *serverId = [XZCore serverID];
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@",fpath,serverId];
    folderPath = [SPTools createFullPath:folderPath];
    NSString *path = [folderPath stringByAppendingPathComponent:@"xzPinyinRegular.txt"];
    return path;
}


+ (NSString *)unZipPinyinRegularFile {
    
    NSString *tempPath = [SPTools pinyinRegularDownloadPath];
    NSString *filePath = [SPTools pinyinRegularFilePath:kPinyinRegularFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:filePath error:nil];
    return filePath;
}

+ (NSString *)pinyinRegular {
    NSString *filePath = [SPTools pinyinRegularFilePath:kPinyinRegularFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return content;
}


+ (NSString *)createFullPath:(NSString *)aPath {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:aPath];
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (exists && !isDirectory) {
        [NSException raise:@"FileExistsAtDownloadTempPath" format:@"Cannot create a directory for the downloadFileTempPath at '%@', because a file already exists",path];
    }
    else if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [NSException raise:@"FailedToCreateCacheDirectory" format:@"Failed to create a directory for the downloadFileTempPath at '%@'",path];
        }
    }
    NSURL *URL = [NSURL fileURLWithPath:path];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return path;
}

#pragma mark intent path end

+ (UIEdgeInsets)xzSafeAreaInsets {
    if (@available(iOS 11.0, *)) {
        if (INTERFACE_IS_PHONE) {
            return [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
        }
    }
    return UIEdgeInsetsMake(20, 0, 0, 0);
}
// 是否是企业版本
+ (BOOL)isM3InHouse
{
    NSDictionary *aDict = [[NSBundle mainBundle] infoDictionary];
    NSString *aBundleIdentifier = [aDict objectForKey:@"CFBundleIdentifier"];
    if ([aBundleIdentifier isEqualToString:kM3AppIDInHouse]) {
        return YES;
    }
    return NO;
}

+ (UIWindow *)keyWindow {
    
    id delegate =  [UIApplication sharedApplication].delegate;
    if ([delegate respondsToSelector:@selector(window)]) {
        UIWindow *window = [delegate performSelector:@selector(window)];
        return window;
    }
    return nil;
}
+ (UITabBarController *)tabBarController {
    return [XZMainProjectBridge tabBarViewController];
}

+ (BOOL)tabbarCanExpand {
    return [XZMainProjectBridge tabbarCanExpand];
}

+ (NSString *)replaceString:(NSString *)string withRegExpStr:(NSString *)regExpStr replacement:(NSString *)replacement {
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:regExpStr
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];
    NSString *resultStr = string;
    // 替换匹配的字符串为 searchStr
    resultStr = [regExp stringByReplacingMatchesInString:resultStr
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, resultStr.length)
                                            withTemplate:replacement];
    return resultStr;
}

+ (NSString *)memberNameWithName:(NSString *)aName {
/*memberName = memberName.replaceAll("\\(([^\\)]*?)\\)","").replaceAll("（([^）]*?)）","").replaceAll("\\d","").replaceAll("\\s","").replaceAll("(PMO\\-\\S*\\-)","").replaceAll("[\\*~!@#\\$%\\^&_+=\\-\\|:;\\{\\}\\[\\]\\\"\\'\\?\\<\\>\\,\\.]","")*/
    if(!aName) {
        return @"";
    }
    NSString *resultStr = aName;
    NSString *replacement = @"";
    NSString *regExpStr = @"\\(([^\\)]*?)\\)";//去掉(xxx)
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
    regExpStr = @"（([^）]*?)）";//去掉（xxx）
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
   
    regExpStr = @"\\[([^）]*?)\\]";//去掉[xxx]
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
    regExpStr = @"【([^）]*?)】";//去掉【xxx】
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
    regExpStr = @"\\d";//去掉数字
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
    regExpStr = @"\\s";//去掉空格
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
    regExpStr = @"(PMO\\-\\S*\\-)";
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
    regExpStr = @"[\\*~!@#\\$%\\^&_+=\\-\\|:;\\{\\}\\[\\]\\\"\\'\\?\\<\\>\\,\\.【】]";//去掉其他特殊字符
    resultStr = [SPTools replaceString:resultStr withRegExpStr:regExpStr replacement:replacement];
    return resultStr;
}

+ (NSString *)speechPathWithName:(NSString *)name {
    NSString *path = [[SPTools createFullPath:@"Documents/XiaoZhiFile/SpeechFile"]stringByAppendingPathComponent:name];
    return path;
}

+ (void)pcmData:(NSData *)pcmData toWavFilePath:(NSString *)wavFilePath {
    if (!pcmData || [NSString isNull:wavFilePath]) {
        return;
    }
    FILE *fout;
    short NumChannels = 1;       //录音通道数
    short BitsPerSample = 16;    //线性采样位数
    int SamplingRate = 16000;     //录音采样率(Hz)
    int numOfSamples = (int)[pcmData length];
    
    int ByteRate = NumChannels*BitsPerSample*SamplingRate/8;
    short BlockAlign = NumChannels*BitsPerSample/8;
    int DataSize = NumChannels*numOfSamples*BitsPerSample/8;
    int chunkSize = 16;
    int totalSize = 46 + DataSize;
    short audioFormat = 1;
    
    if((fout = fopen([wavFilePath cStringUsingEncoding:1], "w")) == NULL)
    {
        printf("Error opening out file ");
    }
    fwrite("RIFF", sizeof(char), 4,fout);
    fwrite(&totalSize, sizeof(int), 1, fout);
    fwrite("WAVE", sizeof(char), 4, fout);
    fwrite("fmt ", sizeof(char), 4, fout);
    fwrite(&chunkSize, sizeof(int),1,fout);
    fwrite(&audioFormat, sizeof(short), 1, fout);
    fwrite(&NumChannels, sizeof(short),1,fout);
    fwrite(&SamplingRate, sizeof(int), 1, fout);
    fwrite(&ByteRate, sizeof(int), 1, fout);
    fwrite(&BlockAlign, sizeof(short), 1, fout);
    fwrite(&BitsPerSample, sizeof(short), 1, fout);
    fwrite("data", sizeof(char), 4, fout);
    fwrite(&DataSize, sizeof(int), 1, fout);
    fclose(fout);
    
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForUpdatingAtPath:wavFilePath];
    [handle seekToEndOfFile];
    [handle writeData:pcmData];
    [handle closeFile];
}

//判断数据是否为空对象，空string，空array，空dic
+ (BOOL)dataIsNull:(id)data {
    if (!data) {
        return YES;
    }
    if ([data isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([data isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)data;
        return str.length == 0;
    }
    if ([data isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)data;
        return array.count == 0;
    }
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)data;
        return dic.count == 0;
    }
    return NO;
}
@end
