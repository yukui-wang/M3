//
//  XZPinyinTool.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/9/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZPinyinTool.h"
#import "SPConstant.h"
#import "XZCore.h"
#import "XZM3RequestManager.h"
#import "SPTools.h"
#import <CMPLib/CMPOfflineContactMember.h>

//?option.n_a_s=1 使server返回参数为string类型，否者id是NSNumber
#define kSearchMemberByPinyinUrl   @"/rest/cmporgnization4M3/searchMemberByPinyin?option.n_a_s=1"

#define kSearchMemberInContactUrl @"/rest/addressbook/searchMember"
#define kSearchMemberInContactType @"XiaoZhi"
#define kSearchMemberInPageSize 20


@implementation XZPinyinTool

+ (NSString *)transformChineseToPinyin:(NSString *)name {
    if ([NSString isNull:name]) {
        return  @"";
    }
    NSMutableString *nameM = [[NSMutableString  alloc] initWithString:name];
    //转化出来的是带音标的拼音
    CFStringTransform((__bridge CFMutableStringRef)nameM, 0, kCFStringTransformMandarinLatin, NO);
    //去掉音标
    CFStringTransform((__bridge CFMutableStringRef)nameM, 0, kCFStringTransformStripDiacritics, NO);
    NSLog(@"transformChineseToPinyin:[%@]to[%@]",name,nameM);
    NSString *pingyin = [nameM lowercaseString];
    nameM = nil;
    return pingyin;
}

//汉字转拼音
+ (NSString *)pinyin:(NSString *)name {
    NSString *pingyin = [XZPinyinTool transformChineseToPinyin:name];
    pingyin = [pingyin replaceCharacter:@" " withString:@"--"];
    return  pingyin;
}
//汉字转近似拼音
+ (NSArray<NSString *> *)similarPinyin:(NSString *)pinyin {
    NSArray *array = [pinyin componentsSeparatedByString:@"-"];
    //声母
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *pin in array) {
        if ([pin length] == 0) {
            continue;
        }
        NSArray *pyArray = [XZPinyinTool similarPY:pin];
        if (result.count > 0) {
            NSArray *tempArray = [NSArray arrayWithArray:result];
            [result removeAllObjects];
            for (NSString *s in tempArray) {
                for (NSString *e in pyArray) {
                    NSString *v = [NSString stringWithFormat:@"%@%@",s,e];
                    [result addObject:v];
                }
            }
        }
        else {
            [result addObjectsFromArray:pyArray];
        }
    }
    NSString  *org = [pinyin replaceCharacter:@"-" withString:@""];
    [result removeObject:org];//去掉原始拼音
    return result;
}
+ (NSArray<NSString *> *)similarPY:(NSString *)pinyin{
    NSDictionary *initialDic = @{@"s":@"sh",
                                 @"sh":@"s",
                                 @"z":@"zh",
                                 @"zh":@"z",
                                 @"c":@"ch",
                                 @"ch":@"c",
                                 @"l":@"n",
                                 @"n":@"l"};
    //韵母
    NSDictionary *finalsDic = @{@"ing":@"in",
                                @"in":@"ing",
                                @"eng":@"en",
                                @"en":@"eng",
                                @"on":@"ong",
                                @"ong":@"on"
                                };
    NSTextCheckingResult *initialResult = [XZPinyinTool firstMatchInString:pinyin pattern:@"^(zh|sh|ch|z|s|c|n|l)(\\w+)"];
    NSTextCheckingResult *finalsResult = [XZPinyinTool firstMatchInString:pinyin pattern:@"(\\w+)(eng|ing|ong|en|in|on)$"];
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:pinyin];
    if (initialResult && finalsResult) {
        //声母韵母同时匹配
        NSString *initial0 = [XZPinyinTool value:pinyin result:initialResult index:1];
        NSString *initial1 = initialDic[initial0];
        NSString *finals0 = [XZPinyinTool value:pinyin result:finalsResult index:2];
        NSString *finals1 = finalsDic[finals0];
        [result addObject:[NSString stringWithFormat:@"%@%@",initial0,finals1]];
        [result addObject:[NSString stringWithFormat:@"%@%@",initial1,finals0]];
        [result addObject:[NSString stringWithFormat:@"%@%@",initial1,finals1]];
    }
    else if (initialResult) {
        //声母匹配
        NSString *initial = [XZPinyinTool value:pinyin result:initialResult index:1];
        NSString *other = [XZPinyinTool value:pinyin result:initialResult index:2];
        [result addObject:[NSString stringWithFormat:@"%@%@",initialDic[initial],other]];
    }
    else if (finalsResult) {
        //韵母匹配
        NSString *other = [XZPinyinTool value:pinyin result:finalsResult index:1];
        NSString *finals = [XZPinyinTool value:pinyin result:finalsResult index:2];
        [result addObject:[NSString stringWithFormat:@"%@%@",other,finalsDic[finals]]];
    }
    return result;
}

+ (NSTextCheckingResult *)firstMatchInString:(NSString *)command pattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *checkResult = [regex firstMatchInString:command options:NSMatchingReportProgress range:NSMakeRange(0, [command length])];
    return checkResult;
}

+ (NSString *)value:(NSString *)command result:(NSTextCheckingResult *)checkResult index:(NSInteger)index {
    NSRange range = [checkResult rangeAtIndex:index];
    if (range.location != NSNotFound) {
        return [command substringWithRange:range];
    }
    return @"";
}

+ (void)obtainMembersWithNameArray:(NSArray *)nameArray
                      memberType:(XZSearchMemberType)memberType
                        complete:(void(^)(NSArray* memberArray, NSArray *defSelectArray))complete {
    NSString *pattern = [XZCore sharedInstance].pinyinRegular;
    if([NSString isNull:pattern]) {
        if (complete) {
            complete(nil,nil);
        }
        return;
    }
    NSMutableArray *pinyinArray = [NSMutableArray array];
    NSMutableArray *pinyinOArray = [NSMutableArray array];//完全匹配拼音
    NSMutableArray *pinyinSArray = [NSMutableArray array];//近似拼音

    for (NSString *name in nameArray) {
        NSString *pinyin = [XZPinyinTool pinyin:name];
        NSMutableArray *tempPinyinArray = [NSMutableArray array];

        if (memberType == XZSearchMemberType_Contact_Keyboard ||
            memberType == XZSearchMemberType_Flow_Keyboard) {
            //键盘输入直接用拼音
            NSString *str = [pinyin replaceCharacter:@"-" withString:@""];
            [pinyinOArray addObject:str];
        }
        else {
            //最后加--，因为正则为-wu--jian--sheng-
            NSString *pinyinS = [NSString stringWithFormat:@"--%@--",pinyin];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            [regex enumerateMatchesInString:pinyinS options:NSMatchingReportProgress range:NSMakeRange(0, [pinyinS length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                NSRange range = result.range;
                if (range.location != NSNotFound && range.length > 0) {
                    NSString *str = [pinyinS substringWithRange:range];
                    str = [str replaceCharacter:@"-" withString:@""];
                    [tempPinyinArray addObject:str];
                }
            }];
            if (tempPinyinArray.count == 0 && (memberType == XZSearchMemberType_Contact_BUnit || memberType == XZSearchMemberType_Flow_BUnit)) {
                //百度返回的需要进似音
                NSArray *similarArray = [XZPinyinTool similarPinyin:pinyin];
                [pinyinSArray addObjectsFromArray:similarArray];
            }
            else {
                [pinyinOArray addObjectsFromArray:tempPinyinArray]; }
        }
    }
    [pinyinArray addObjectsFromArray:pinyinOArray];
    [pinyinArray addObjectsFromArray:pinyinSArray];

    if (pinyinArray.count == 0) {
        //没有匹配
        if (complete) {
            complete(nil,nil);
        }
        return;
    }
    NSString *equal = @"1";//是否精确匹配，1：精确，0：模糊。缺省模糊匹配。
    if (memberType == XZSearchMemberType_Contact_Keyboard ||
        memberType == XZSearchMemberType_Flow_Keyboard ||
        memberType == XZSearchMemberType_Contact_BUnit) {
        equal = @"0";
    }
    NSString *pinyinStr = [SPTools arrayToStr:pinyinArray];
    NSString *url = nil;
    NSDictionary *param = nil;
    NSDictionary *userInfoDic = nil;
    if (memberType == XZSearchMemberType_Contact_Native ||
        memberType == XZSearchMemberType_Contact_BUnit ||
        memberType == XZSearchMemberType_Contact_Keyboard) {
        //通讯录
        url = [XZCore fullUrlForPath:kSearchMemberInContactUrl];
        param = @{@"accId":@"-1",@"key":pinyinStr,@"type":kSearchMemberInContactType,@"equal":equal};
        userInfoDic = @{@"pinyinOArray":pinyinOArray,@"isContact":[NSNumber numberWithBool:YES]};
    }
    else {
        //协同选人
        url = [XZCore fullUrlForPath:kSearchMemberByPinyinUrl];
        param = @{@"pinyin":pinyinStr,@"equal":equal};
        userInfoDic = @{@"pinyinOArray":pinyinOArray,@"isContact":[NSNumber numberWithBool:NO]};
    }
    [[XZM3RequestManager sharedInstance]requestWithUrl:url params:param userInfo:userInfoDic handleCookies:YES method:@"POST" success:^(NSString *response,NSDictionary* userInfo) {
        BOOL isContact = [SPTools boolValue:userInfo forKey:@"isContact"];
        NSArray *pinyinOArray = [SPTools arrayValue:userInfo forKey:@"pinyinOArray"];
    
        NSDictionary *dic = [SPTools dictionaryWithJsonString:response];
        NSDictionary *memberDic = [SPTools dicValue:dic forKey:isContact ? @"children":@"m"];

        NSMutableArray *o1MemberArray = [NSMutableArray array];//默认勾选的
        NSMutableArray *o2MemberArray = [NSMutableArray array];//拼音
        NSMutableArray *sMemberArray = [NSMutableArray array];//近似音
        
        NSArray *allKeys = memberDic.allKeys;
        for (NSString * py in  allKeys) {
            NSArray *children = [SPTools arrayValue:memberDic forKey:py];
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSDictionary *childrenDic in children) {
                //太坑了，keyx大小写经常边，先转成小写key
                NSMutableDictionary *c = [NSMutableDictionary dictionary];
                for (NSString *key in childrenDic.allKeys) {
                    [c setObject:childrenDic[key] forKey:key.lowercaseString];
                }
                CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
                if (isContact) {
                    member.orgID = [SPTools stringValue:c forKey:@"i"];
                    member.name = [SPTools stringValue:c forKey:@"n"];
                    member.department =  [SPTools stringValue:c forKey:@"dn"];
                    member.postName =  [SPTools stringValue:c forKey:@"pn"];
                    NSString *sn = [SPTools stringValue:c forKey:@"sn"];
                    if ([sn isEqualToString:@"0"]) {
                        member.mobilePhone = kContactMemberHideVaule;
                    }
                    else {
                        member.mobilePhone = [SPTools stringValue:c forKey:@"tnm"];
                    }
                }
                else {
                    member.orgID = [SPTools stringValue:c forKey:@"id"];
                    member.name = [SPTools stringValue:c forKey:@"n"];
                    member.postName = [SPTools stringValue:c forKey:@"p"];
                    member.department = [SPTools stringValue:c forKey:@"d"];
                }
                [tempArray addObject:member];
            }
            if ([pinyinOArray containsObject:py]) {
                if (tempArray.count == 1) {
                    [o1MemberArray addObjectsFromArray:tempArray];
                }
                else {
                    [o2MemberArray addObjectsFromArray:tempArray];
                }
            }
            else {
                [sMemberArray addObjectsFromArray:tempArray];
            }
        }
        NSMutableArray *memberArray = [NSMutableArray array];
        [memberArray addObjectsFromArray:o1MemberArray];
        [memberArray addObjectsFromArray:o2MemberArray];
        [memberArray addObjectsFromArray:sMemberArray];
        if (complete) {
            complete(memberArray,o1MemberArray);
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        if (complete) {
            complete(nil,nil);
        }
    }];
}

@end
