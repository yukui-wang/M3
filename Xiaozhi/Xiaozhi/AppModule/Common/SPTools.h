//
//  SPTools.h
//  CMPCore
//
//  Created by CRMO on 2017/2/20.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SPConstant.h"

@interface SPTools : NSObject

/**
 删除字符串中的标点符号：
 ,.!?，。！？
 */
+ (NSString *)deletePunc:(NSString *)str;

//json格式字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//字典转json格式字符串：
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

/**
 截取好了小致之前的内容显示
  */
+ (NSString *)getMainText:(NSString *)text;

/**
 解析选人数字
*/
+ (NSInteger)getOptionNumber:(NSString *)str;

/**
 把数组构造成字符串，用逗号分隔
 */
+ (NSString *)arrayToStr:(NSArray *)arr;


/**
 获取当前viewcontroller
  */
+ (UIViewController *)currentViewController;


/**
 从用户输入的文本中获取名字
 */
+ (NSString *)getNameWithTitle:(NSString *)title;

/**
 从用户输入的文本中获取协同类型
 */
+ (NSString *)getTypeWithTitle:(NSString *)title;

/**
 去掉名字后面括号里面的内容
*/
+ (NSString *)getMainName:(NSString *)name;

/**
 0-9替换零-九 a-z替换啊-在 返回纯汉字字符串
  */
+ (NSString *)hanziStringWithString:(NSString*)string;

/**
 字符串相似度匹配
 
 @param string 源字符串
 @param string1 目标字符串
 @param distence 相似度范围（在码表中的前后相邻字数）
 @return no 匹配不成功 yes 匹配成功
 */
+ (BOOL)stringCodeCompare:(NSString*)string withString:(NSString*)string1 distence:(int)distence;

//文件大小处理
+ (NSString *)fileSizeFormat:(long long )fileSize;
+ (UIImage *)imageWithType:(NSString *)type;

//接口数据处理 防NSNull
+ (NSString *)stringValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (CGFloat)floatValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (NSInteger)integerValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (long long)longLongValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (NSDictionary *)dicValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (NSArray *)arrayValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (BOOL)boolValue:(NSDictionary *)dic forKey:(NSString *)key;
//NSAttributedString 转 Html
+ (NSString *)htmlStrFormAttributedStr:(NSAttributedString *)attStr;
//Html 转 NSAttributedString
+ (NSAttributedString *)attrStrFormHtmlStr:(NSString *)htmlStr;

+ (NSString *)localIntentDownloadPath;
+ (NSString *)localIntentFolderPath;
+ (NSString *)unZipLocalIntents;

//百度语音纠错
+ (NSString *)speechErrorCorrectionDownloadPath;
+ (NSString *)speechErrorCorrectionPath;
+ (NSString *)unZipspeechErrorCorrection;
+ (NSDictionary *)spErrorCorrectionDic;

+ (NSString *)pinyinRegularDownloadPath;
+ (NSString *)unZipPinyinRegularFile;
+ (NSString *)pinyinRegular;

+ (UIEdgeInsets)xzSafeAreaInsets;
+ (BOOL)isM3InHouse;
+ (UIWindow *)keyWindow;
+ (UITabBarController *)tabBarController;
+ (BOOL)tabbarCanExpand;
/*处理从通讯录拿的人员名字*/
+ (NSString *)memberNameWithName:(NSString *)aName;


+ (NSString *)speechPathWithName:(NSString *)name;
+ (void)pcmData:(NSData *)pcmData toWavFilePath:(NSString *)wavFilePath;

//判断数据是否为空对象，空string，空array，空dic
+ (BOOL)dataIsNull:(id)data;
@end
