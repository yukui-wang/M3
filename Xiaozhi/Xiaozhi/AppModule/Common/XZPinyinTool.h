//
//  XZPinyinTool.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/9/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPObject.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, XZSearchMemberType) {
    XZSearchMemberType_Contact_Native = 1,//通讯录 本地
    XZSearchMemberType_Contact_BUnit,//通讯录 百度unit返回的
    XZSearchMemberType_Contact_Keyboard,//通讯录 键盘
    XZSearchMemberType_Flow_Native,//协同、本地
    XZSearchMemberType_Flow_BUnit,//协同、百度unit返回的
    XZSearchMemberType_Flow_Keyboard//协同、键盘
};
NS_ASSUME_NONNULL_BEGIN

@interface XZPinyinTool : CMPObject
//汉字转拼音间隔“-”
+ (NSString *)pinyin:(NSString *)name;
//汉字转近似拼音
+ (NSArray<NSString *> *)similarPinyin:(NSString *)pinyin;
+ (void)obtainMembersWithNameArray:(NSArray *)nameArray
                        memberType:(XZSearchMemberType)memberType
                          complete:(void(^)(NSArray* memberArray, NSArray *defSelectArray))complete;
@end

NS_ASSUME_NONNULL_END
