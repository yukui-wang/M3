//
//  RCKitUtility.m
//  iOS-IMKit
//
//  Created by xugang on 7/7/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "RCKitUtility.h"
#import "RCConversationModel.h"
#import "RCExtensionUtility.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCUserInfoCacheManager.h"
#import <SafariServices/SafariServices.h>
#import "RCForwardManager.h"
#import "RCloudImageLoader.h"
#import <objc/runtime.h>

@implementation RCKitUtility

+ (NSString *)localizedDescription:(RCMessageContent *)messageContent {
    NSString *objectName = [[messageContent class] getObjectName];
    return NSLocalizedStringFromTable(objectName, @"RongCloudKit", nil);
}

+ (NSString *)ConvertMessageTime:(long long)secs {
    NSString *timeText = nil;
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:secs];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [self getDateFormatter];
    [formatter setDateFormat:@"yyyy"];
    NSInteger currentYear = [[formatter stringFromDate:now] integerValue];
    NSInteger msgYear = [[formatter stringFromDate:messageDate] integerValue];

    [formatter setDateFormat:@"MM"];
    NSInteger currentMonth = [[formatter stringFromDate:now] integerValue];
    NSInteger msgMonth = [[formatter stringFromDate:messageDate] integerValue];

    [formatter setDateFormat:@"dd"];
    NSInteger currentDay = [[formatter stringFromDate:now] integerValue];
    NSInteger msgDay = [[formatter stringFromDate:messageDate] integerValue];

    NSString *locale = NSLocalizedStringFromTable(@"locale", @"RongCloudKit", nil);
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:locale]];

    NSString *formatStr = [self getDateFormatterString:messageDate];
    if (currentYear == msgYear) {
        if (currentMonth == msgMonth) {
            if (currentDay == msgDay) {
                [formatter setDateFormat:formatStr];
                return timeText = [formatter stringFromDate:messageDate];
            } else {
                if (currentDay - msgDay == 1) {
                    return timeText = NSLocalizedStringFromTable(@"Yesterday", @"RongCloudKit", nil);
                } else if (currentDay - msgDay < 7) {
                    [formatter setDateFormat:@"eeee"];
                    return timeText = [formatter stringFromDate:messageDate];
                } else {
                    [formatter setDateFormat:NSLocalizedStringFromTable(@"SameYearDate", @"RongCloudKit", nil)];
                    return timeText = [formatter stringFromDate:messageDate];
                }
            }
        } else {
            [formatter setDateFormat:NSLocalizedStringFromTable(@"SameYearDate", @"RongCloudKit", nil)];
            return timeText = [formatter stringFromDate:messageDate];
        }
    }
    [formatter setDateFormat:NSLocalizedStringFromTable(@"chatListDate", @"RongCloudKit", nil)];
    return timeText = [formatter stringFromDate:messageDate];
}

+ (NSString *)ConvertChatMessageTime:(long long)secs {
    NSString *timeText = nil;

    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:secs];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [self getDateFormatter];
    [formatter setDateFormat:@"yyyy"];
    NSInteger currentYear = [[formatter stringFromDate:now] integerValue];
    NSInteger msgYear = [[formatter stringFromDate:messageDate] integerValue];

    [formatter setDateFormat:@"MM"];
    NSInteger currentMonth = [[formatter stringFromDate:now] integerValue];
    NSInteger msgMonth = [[formatter stringFromDate:messageDate] integerValue];

    [formatter setDateFormat:@"dd"];
    NSInteger currentDay = [[formatter stringFromDate:now] integerValue];
    NSInteger msgDay = [[formatter stringFromDate:messageDate] integerValue];

    [formatter setLocale:[[NSLocale alloc]
                             initWithLocaleIdentifier:NSLocalizedStringFromTable(@"locale", @"RongCloudKit", nil)]];

    NSString *formatStr = [self getDateFormatterString:messageDate];
    [formatter setDateFormat:formatStr];
    if (currentYear == msgYear) {
        if (currentMonth == msgMonth) {
            if (currentDay == msgDay) {
                return timeText = [formatter stringFromDate:messageDate];
            } else {
                if (currentDay - msgDay == 1) {
                    return timeText = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(
                                                                               @"Yesterday", @"RongCloudKit", nil),
                                                                 [formatter stringFromDate:messageDate]];
                } else if (currentDay - msgDay < 7) {
                    [formatter setDateFormat:[NSString stringWithFormat:@"eeee %@", formatStr]];
                    return timeText = [formatter stringFromDate:messageDate];
                } else {
                    return [self getMessageDate:messageDate dateFormat:formatter];
                }
            }
        } else {
            return [self getMessageDate:messageDate dateFormat:formatter];
        }
    }
    return [self getMessageDate:messageDate dateFormat:formatter];
}

+ (NSString *)getMessageDate:(NSDate *)messageDate dateFormat:(NSDateFormatter *)formatter {
    [formatter setDateFormat:[NSString stringWithFormat:@"%@ %@",
                                                        NSLocalizedStringFromTable(@"chatDate", @"RongCloudKit", nil),
                                                        [self getDateFormatterString:messageDate]]];
    return [formatter stringFromDate:messageDate];
}

+ (NSString *)getDateFormatterString:(NSDate *)messageDate {
    NSString *formatStringForHours =
        [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    NSString *formatStr = nil;
    if (hasAMPM) {
        formatStr = [self getFormatStringByMessageDate:messageDate];
    } else {
        formatStr = @"HH:mm";
    }
    return formatStr;
}

+ (NSString *)getFormatStringByMessageDate:(NSDate *)messageDate {
    NSString *formatStr = nil;
    if ([[self class] isBetweenFromHour:0 toHour:6 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Dawn", @"RongCloudKit", nil);
    } else if ([[self class] isBetweenFromHour:6 toHour:12 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Forenoon", @"RongCloudKit", nil);
    } else if ([[self class] isBetweenFromHour:12 toHour:13 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Noon", @"RongCloudKit", nil);
    } else if ([[self class] isBetweenFromHour:13 toHour:18 currentDate:messageDate]) {
        formatStr = NSLocalizedStringFromTable(@"Afternoon", @"RongCloudKit", nil);
    } else {
        formatStr = NSLocalizedStringFromTable(@"Evening", @"RongCloudKit", nil);
    }
    return formatStr;
}

+ (BOOL)isBetweenFromHour:(NSInteger)fromHour toHour:(NSInteger)toHour currentDate:(NSDate *)currentDate {
    NSDate *date1 = [self getCustomDateWithHour:fromHour currentDate:currentDate];
    NSDate *date2 = [self getCustomDateWithHour:toHour currentDate:currentDate];
    if (([currentDate compare:date1] == NSOrderedDescending || [currentDate compare:date1] == NSOrderedSame) &&
        ([currentDate compare:date2] == NSOrderedAscending))
        return YES;
    return NO;
}

+ (NSDate *)getCustomDateWithHour:(NSInteger)hour currentDate:(NSDate *)currentDate {
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
                          NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = [RCExtensionUtility imageNamed:name ofBundle:bundleName];
    
    if ([@[@"message_cell_unselect",@"message_cell_select"] containsObject:name]) {
        
        if ([name isEqualToString:@"message_cell_select"]) {
            image = [UIImage imageNamed:@"share_btn_selected_circle"];
        }else if ([name isEqualToString:@"message_cell_unselect"]) {
            image = [UIImage imageNamed:@"share_btn_unselected_circle"];
            return image;
        }
        
        Class CMPThemeManagerClass = NSClassFromString(@"CMPThemeManager");
        SEL sharedManagerSEL = NSSelectorFromString(@"sharedManager");
        id cmpThemeManager = [CMPThemeManagerClass performSelector:sharedManagerSEL];
        //主题color
        SEL skinColorImageWithImageSEL = NSSelectorFromString(@"skinColorImageWithImage:");
        image = [cmpThemeManager performSelector:skinColorImageWithImageSEL withObject:image];
        return image;
    }
    
    if ([@[@"chat_to_bg_normal"] containsObject:name]) {
        Class CMPThemeManagerClass = NSClassFromString(@"CMPThemeManager");
        SEL sharedManagerSEL = NSSelectorFromString(@"sharedManager");
        id cmpThemeManager = [CMPThemeManagerClass performSelector:sharedManagerSEL];
        //brandColor
        SEL skinBrand2ColorWithImageSEL = NSSelectorFromString(@"skinBrand2ColorWithImage:");
        image = [cmpThemeManager performSelector:skinBrand2ColorWithImageSEL withObject:image];
        return image;
    }
    return image;
}

+ (UIColor *)getCMPThemeSkinColor{
    Class CMPThemeManagerClass = NSClassFromString(@"CMPThemeManager");
    SEL sharedManagerSEL = NSSelectorFromString(@"sharedManager");
    id cmpThemeManager = [CMPThemeManagerClass performSelector:sharedManagerSEL];
    UIColor *color = [cmpThemeManager valueForKey:@"skinThemeColor"];
    return color;
}

//导航使用
+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return theImage;
}

+ (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize {
    return [RCExtensionUtility getTextDrawingSize:text font:font constrainedSize:constrainedSize];
}

+ (NSString *)formatLocalNotification:(RCMessage *)message {
    RCMessageContent *messageContent = message.content;
    NSString *targetId = message.targetId;
    RCConversationType conversationType = message.conversationType;
    
    if ([messageContent respondsToSelector:@selector(conversationDigest)]) {
        NSString *formatedMsg = [messageContent performSelector:@selector(conversationDigest)];
        //当会话最后一条消息是文本且长度超过1W时，滑动会话列表卡顿,所以这里做截取
        if (formatedMsg.length > 500) {
            formatedMsg = [formatedMsg substringToIndex:500];
            formatedMsg = [formatedMsg stringByAppendingString:@"..."];
        }
        return formatedMsg;
    } else if ([messageContent isMemberOfClass:RCDiscussionNotificationMessage.class]) {
        RCDiscussionNotificationMessage *notification = (RCDiscussionNotificationMessage *)messageContent;
        return [RCKitUtility __formatDiscussionNotificationMessageContent:notification];
    } else if ([messageContent isMemberOfClass:RCGroupNotificationMessage.class]) {
        RCGroupNotificationMessage *notification = (RCGroupNotificationMessage *)messageContent;
        return [RCKitUtility __formatGroupNotificationMessageContent:notification];
    } else if ([messageContent isMemberOfClass:RCRecallNotificationMessage.class]) {
        RCRecallNotificationMessage *notification = (RCRecallNotificationMessage *)messageContent;
        return [RCKitUtility __formatRecallLocalNotificationMessageContent:notification
                                                                  targetId:targetId
                                                          conversationType:conversationType];
    } else if ([messageContent isMemberOfClass:[RCContactNotificationMessage class]]) {
        RCContactNotificationMessage *notification = (RCContactNotificationMessage *)messageContent;
        return [RCKitUtility __formatContactNotificationMessageContent:notification];
    } else if ([messageContent isMemberOfClass:[RCPublicServiceMultiRichContentMessage class]]) {
        RCPublicServiceMultiRichContentMessage *notification = (RCPublicServiceMultiRichContentMessage *)messageContent;
        RCRichContentItem *item = notification.richContents.firstObject;
        return item.title;
    } else if ([messageContent isMemberOfClass:[RCPublicServiceRichContentMessage class]]) {
        RCPublicServiceRichContentMessage *notification = (RCPublicServiceRichContentMessage *)messageContent;
        return notification.richContent.title;
    } else {
        return [RCKitUtility localizedDescription:messageContent];
    }
}


+ (NSString *)formatMessage:(RCMessageContent *)messageContent
                   targetId:(NSString *)targetId
           conversationType:(RCConversationType)conversationType
               isAllMessage:(BOOL)isAllMessage {
    if ([messageContent respondsToSelector:@selector(conversationDigest)]) {
        NSString *formatedMsg = [messageContent performSelector:@selector(conversationDigest)];
        //当会话最后一条消息是文本且长度超过1W时，滑动会话列表卡顿,所以这里做截取
        if (!isAllMessage && formatedMsg.length > 500) {
            formatedMsg = [formatedMsg substringToIndex:500];
            formatedMsg = [formatedMsg stringByAppendingString:@"..."];
        }
        return formatedMsg;
    } else if ([messageContent isMemberOfClass:RCDiscussionNotificationMessage.class]) {
        RCDiscussionNotificationMessage *notification = (RCDiscussionNotificationMessage *)messageContent;
        return [RCKitUtility __formatDiscussionNotificationMessageContent:notification];
    } else if ([messageContent isMemberOfClass:RCGroupNotificationMessage.class]) {
        RCGroupNotificationMessage *notification = (RCGroupNotificationMessage *)messageContent;
        return [RCKitUtility __formatGroupNotificationMessageContent:notification];
    } else if ([messageContent isMemberOfClass:RCRecallNotificationMessage.class]) {
        RCRecallNotificationMessage *notification = (RCRecallNotificationMessage *)messageContent;
        return [RCKitUtility __formatRCRecallNotificationMessageContent:notification
                                                               targetId:targetId
                                                       conversationType:conversationType];
    } else if ([messageContent isMemberOfClass:[RCContactNotificationMessage class]]) {
        RCContactNotificationMessage *notification = (RCContactNotificationMessage *)messageContent;
        return [RCKitUtility __formatContactNotificationMessageContent:notification];
    } else if ([messageContent isMemberOfClass:[RCPublicServiceMultiRichContentMessage class]]) {
        RCPublicServiceMultiRichContentMessage *notification = (RCPublicServiceMultiRichContentMessage *)messageContent;
        RCRichContentItem *item = notification.richContents.firstObject;
        return item.title;
    } else if ([messageContent isMemberOfClass:[RCPublicServiceRichContentMessage class]]) {
        RCPublicServiceRichContentMessage *notification = (RCPublicServiceRichContentMessage *)messageContent;
        return notification.richContent.title;
    } else {
        return [RCKitUtility localizedDescription:messageContent];
    }
}

+ (NSString *)formatMessage:(RCMessageContent *)messageContent
                   targetId:(NSString *)targetId
           conversationType:(RCConversationType)conversationType {
    return [self formatMessage:messageContent targetId:targetId conversationType:conversationType isAllMessage:NO];
}

+ (NSString *)formatMessage:(RCMessageContent *)messageContent {
    return [self formatMessage:messageContent targetId:nil conversationType:ConversationType_INVALID isAllMessage:NO];
}

#pragma mark private method

+ (NSString *)__formatContactNotificationMessageContent:(RCContactNotificationMessage *)contactNotification {
    RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:contactNotification.sourceUserId];
    if (userInfo.name.length) {
        if ([contactNotification.operation isEqualToString:ContactNotificationMessage_ContactOperationRequest]) {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"FromFriendInvitation", @"RongCloudKit", nil),
                                              userInfo.name];
        }
        if ([contactNotification.operation isEqualToString:ContactNotificationMessage_ContactOperationAcceptResponse]) {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AcceptFriendRequest", @"RongCloudKit", nil)];
        }
        if ([contactNotification.operation isEqualToString:ContactNotificationMessage_ContactOperationRejectResponse]) {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"RejectFriendRequest", @"RongCloudKit", nil),
                                              userInfo.name];
        }
    } else {
        return NSLocalizedStringFromTable(@"AddFriendInvitation", @"RongCloudKit", nil);
    }
    return nil;
}

+ (NSString *)__formatGroupNotificationMessageContent:(RCGroupNotificationMessage *)groupNotification {
    NSString *message = nil;

    NSData *jsonData = [groupNotification.data dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData == nil) {
        return nil;
    }
    NSDictionary *dictionary =
        [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSString *operatorUserId = groupNotification.operatorUserId;
    NSString *nickName =
        [dictionary[@"operatorNickname"] isKindOfClass:[NSString class]] ? dictionary[@"operatorNickname"] : nil;
    NSArray *targetUserNickName = [dictionary[@"targetUserDisplayNames"] isKindOfClass:[NSArray class]]
                                      ? dictionary[@"targetUserDisplayNames"]
                                      : nil;
    NSArray *targetUserIds =
        [dictionary[@"targetUserIds"] isKindOfClass:[NSArray class]] ? dictionary[@"targetUserIds"] : nil;
    BOOL isMeOperate = NO;
    if ([groupNotification.operatorUserId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        isMeOperate = YES;
        nickName = NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
    }
    if ([groupNotification.operation isEqualToString:@"Create"]) {
        message =
            [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveCreated" : @"GroupCreated",
                                                                  @"RongCloudKit", nil),
                                       nickName];
    } else if ([groupNotification.operation isEqualToString:@"Add"]) {
        if (targetUserNickName.count == 0) {
            message =
                [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil), nickName];
        } else {
            NSMutableString *names = [[NSMutableString alloc] init];
            NSMutableString *userIdStr = [[NSMutableString alloc] init];
            for (NSUInteger index = 0; index < targetUserNickName.count; index++) {
                if ([targetUserNickName[index] isKindOfClass:[NSString class]]) {
                    [names appendString:targetUserNickName[index]];
                    if (index != targetUserNickName.count - 1) {
                        [names appendString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
                    }
                }
            }
            for (NSUInteger index = 0; index < targetUserIds.count; index++) {
                if ([targetUserIds[index] isKindOfClass:[NSString class]]) {
                    [userIdStr appendString:targetUserIds[index]];
                    if (index != targetUserNickName.count - 1) {
                        [userIdStr appendString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
                    }
                }
            }
            if ([operatorUserId isEqualToString:userIdStr]) {
                message = [NSString
                    stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil), nickName];
            } else {
                if (targetUserIds.count > targetUserNickName.count) {
                    names = [NSMutableString
                        stringWithFormat:@"%@%@", names, NSLocalizedStringFromTable(@"GroupEtc", @"RongCloudKit", nil)];
                }
                message = [NSString
                    stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveInvited" : @"GroupInvited",
                                                                @"RongCloudKit", nil),
                                     nickName, names];
                
                //add by chengkun
                               if ([targetUserIds containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
                                   message = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveInvited" : @"GroupInvited", @"RongCloudKit", nil),
                                   nickName, NSLocalizedString(@"you", nil)];
                               }
               // add by chengkun end
                
                //ks fix -- V5-37416
                if (groupNotification.extra) {
                    NSData *extraJsonData = [groupNotification.extra dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *extraDic =
                        [NSJSONSerialization JSONObjectWithData:extraJsonData options:NSJSONReadingMutableContainers error:nil];
                    if (extraDic && [extraDic isKindOfClass:NSDictionary.class]) {
                        NSString *groupType = [NSString stringWithFormat:@"%@",extraDic[@"groupType"]].uppercaseString;
                        if ([@"DEPARTMENT" isEqualToString:groupType]) {
                            message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoinNoLe", @"RongCloudKit", nil),[targetUserIds containsObject:[RCIM sharedRCIM].currentUserInfo.userId] ? NSLocalizedString(@"you", nil) : names];
                        }
                    }
                }
                //ks end
                
                //add by chengkun 通过扫描二维码加入群聊
                if ([operatorUserId isEqualToString:@"7004378101471200365"]) {
                    message = [NSString stringWithFormat:@"%@%@",names,NSLocalizedString(@"rc_scan_code_join_group", nil)];
                }
                // add by chengkun end
            }
        }
    }
    
    // add by zl 新增群主变更、群公告变更
    else if ([groupNotification.operation isEqualToString:@"Replacement"]) {
        NSString *extra = groupNotification.extra;
        NSData *jsonData = [extra dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData == nil) {
            return nil;
        }
        NSDictionary *extraDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        if (isMeOperate) {
            message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupReplacement_who_changed_owner_to", @"Localizable", nil), nickName,extraDic[@"creatorName"]];
        }else{
            message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupReplacement", @"Localizable", nil), extraDic[@"creatorName"]];
        }
        
    } else if ([groupNotification.operation isEqualToString:@"Rebulletin"]) {
        message = NSLocalizedStringFromTable(@"GroupRebulletin", @"Localizable", nil);
    }
    // add by zl end
    
    // add by chengkun 设置管理员,取消管理员
    else if ([groupNotification.operation isEqualToString:@"SetAdmin"]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"msg_you_set_admin", nil),targetUserNickName.firstObject];
        //ks fix -- V5-36419
        if (!isMeOperate) {
            message = [NSString stringWithFormat:NSLocalizedString(@"msg_someone_set_admin", nil),nickName,targetUserNickName.firstObject];
        }
    }else if ([groupNotification.operation isEqualToString:@"UnSetAdmin"]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"msg_you_unset_admin", nil),targetUserNickName.firstObject];
        //ks fix -- V5-36419
        if (!isMeOperate) {
            message = [NSString stringWithFormat:NSLocalizedString(@"msg_someone_unset_admin", nil),nickName,targetUserNickName.firstObject];
        }
    }
    // add by chengkun end
    
    else if ([groupNotification.operation isEqualToString:@"Quit"]) {
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveQuit" : @"GroupQuit",
                                                                        @"RongCloudKit", nil),
                                             nickName];
    } else if ([groupNotification.operation isEqualToString:@"Kicked"]) {
        NSMutableString *names = [[NSMutableString alloc] init];
        for (NSUInteger index = 0; index < targetUserNickName.count; index++) {
            if ([targetUserNickName[index] isKindOfClass:[NSString class]]) {
                [names appendString:targetUserNickName[index]];
                if (index != targetUserNickName.count - 1) {
                    [names appendString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
                }
            }
        }
        if (targetUserIds.count > targetUserNickName.count) {
            names = [NSMutableString
                stringWithFormat:@"%@%@", names, NSLocalizedStringFromTable(@"GroupEtc", @"RongCloudKit", nil)];
        }
        message =
            [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveRemoved" : @"GroupRemoved",
                                                                  @"RongCloudKit", nil),
                                       nickName, names];
    } else if ([groupNotification.operation isEqualToString:@"Rename"]) {
        NSString *groupName =
            [dictionary[@"targetGroupName"] isKindOfClass:[NSString class]] ? dictionary[@"targetGroupName"] : nil;
        message = [NSString
            stringWithFormat:NSLocalizedStringFromTable(@"GroupChanged", @"RongCloudKit", nil), nickName, groupName];
    } else if ([groupNotification.operation isEqualToString:@"Dismiss"]) {
        message =
            [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveDismiss" : @"GroupDismiss",
                                                                  @"RongCloudKit", nil),
                                       nickName];
    } else {
        //ks fix -- 致信部门群转普通群的通知
        //convertDept2SimpleGroup
        //convertSimple2DeptGroup
        //如果下面的发现有问题，可以单独判断operation
        message = groupNotification.message;
    }
    return message;
}

+ (NSString *)__formatDiscussionNotificationMessageContent:(RCDiscussionNotificationMessage *)discussionNotification {
    if (nil == discussionNotification) {
        DebugLog(@"[RongIMKit] : No userInfo in cache & db");
        return nil;
    }
    NSArray *operatedIds = nil;
    NSString *operationInfo = nil;

    //[RCKitUtility sharedInstance].discussionNotificationOperatorName = userInfo.name;
    switch (discussionNotification.type) {
    case RCInviteDiscussionNotification:
    case RCRemoveDiscussionMemberNotification: {
        NSString *trimedExtension = [discussionNotification.extension
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *ids = [trimedExtension componentsSeparatedByString:@","];
        if (ids.count <= 0 && trimedExtension) {
            ids = [NSArray arrayWithObject:trimedExtension];
        }
        operatedIds = ids;
    } break;
    case RCQuitDiscussionNotification:
        break;

    case RCRenameDiscussionTitleNotification:
    case RCSwichInvitationAccessNotification:
        operationInfo = discussionNotification.extension;
        break;

    default:
        break;
    }

    // NSString *format = nil;
    NSString *message = nil;
    NSString *target = nil;
    NSString *userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    if (operatedIds) {
        if (operatedIds.count == 1) {
            if ([operatedIds[0] isEqualToString:userId]) {
                target = NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
            } else {
                RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:operatedIds[0]];
                if ([userInfo.name length]) {
                    target = userInfo.name;
                } else {
                    target = [[NSString alloc] initWithFormat:@"user<%@>", operatedIds[0]];
                }
            }
        } else {
            NSString *_members = NSLocalizedStringFromTable(@"MemberNumber", @"RongCloudKit", nil);
            target = [NSString stringWithFormat:@"%lu %@", (unsigned long)operatedIds.count, _members, nil];
            // target = [NSString stringWithFormat:NSLocalizedString(@"%d位成员", nil), operatedIds.count, nil];
        }
    }

    NSString *operator= discussionNotification.operatorId;
    if ([operator isEqualToString:userId]) {
        operator= NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
    } else {
        RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:operator];
        if ([userInfo.name length]) {
            operator= userInfo.name;
        } else {
            operator= [[NSString alloc] initWithFormat:@"user<%@>", operator];
        }
    }
    switch (discussionNotification.type) {
    case RCInviteDiscussionNotification: {
        NSString *_invite = NSLocalizedStringFromTable(@"Invite", @"RongCloudKit", nil);
        NSString *_joinDiscussion = NSLocalizedStringFromTable(@"JoinDiscussion", @"RongCloudKit", nil);
            message = [NSString stringWithFormat:@"%@ %@ %@ %@",operator, _invite,target,_joinDiscussion, nil];
            //            format = NSLocalizedString(@"%@邀请%@加入了讨论组", nil);
            //            message = [NSString stringWithFormat:format, operator, target, nil];
    } break;
    case RCQuitDiscussionNotification: {
        NSString *_quitDiscussion = NSLocalizedStringFromTable(@"QuitDiscussion", @"RongCloudKit", nil);

        // format = NSLocalizedString(@"%@退出了讨论组", nil);
            message = [NSString stringWithFormat:@"%@ %@", operator,_quitDiscussion, nil];
    } break;

    case RCRemoveDiscussionMemberNotification: {
        // format = NSLocalizedString(@"%@被%@移出了讨论组", nil);
        NSString *_by = NSLocalizedStringFromTable(@"By", @"RongCloudKit", nil);
        NSString *_removeDiscussion = NSLocalizedStringFromTable(@"RemoveDiscussion", @"RongCloudKit", nil);
            message = [NSString stringWithFormat:@"%@ %@ %@ %@", operator,_by, target,_removeDiscussion,nil];
    } break;
    case RCRenameDiscussionTitleNotification: {
        // format = NSLocalizedString(@"%@修改讨论组为\"%@\"", nil);
        NSString *_modifyDiscussion = NSLocalizedStringFromTable(@"ModifyDiscussion", @"RongCloudKit", nil);
        target = operationInfo;
            message = [NSString stringWithFormat:@"%@ %@ \"%@\"", operator,_modifyDiscussion, target, nil];
    } break;
    case RCSwichInvitationAccessNotification: {
        // 1 for off, 0 for on
        BOOL canInvite = ![operationInfo isEqualToString:@"1"];
        target = canInvite ? NSLocalizedStringFromTable(@"Open", @"RongCloudKit", nil)
                           : NSLocalizedStringFromTable(@"Close", @"RongCloudKit", nil);

        NSString *_inviteStatus = NSLocalizedStringFromTable(@"InviteStatus", @"RongCloudKit", nil);

        // format = NSLocalizedString(@"%@%@了成员邀请", nil);
        message =
            [NSString stringWithFormat:@"%@ %@ %@", operator, target, _inviteStatus, nil];
    } break;
    default:
        break;
    }
    return message;
}

+ (NSString *)__formatRCRecallNotificationMessageContent:
                  (RCRecallNotificationMessage *)recallNotificationMessageNotification
                                                targetId:(NSString *)targetId
                                        conversationType:(RCConversationType)conversationType {
    if (!recallNotificationMessageNotification || !recallNotificationMessageNotification.operatorId) {
        return nil;
    }

    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    NSString *operator= recallNotificationMessageNotification.operatorId;
    if (recallNotificationMessageNotification.isAdmin) {
        return
            [NSString stringWithFormat:NSLocalizedStringFromTable(@"OtherHasRecalled", @"RongCloudKit", nil),
                                       NSLocalizedStringFromTable(@"AdminWithMessageRecalled", @"RongCloudKit", nil)];
    }else if ([operator isEqualToString:currentUserId]) {
        return [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"SelfHaveRecalled", @"RongCloudKit", nil)];
    } else {
        RCUserInfo *userInfo;
        if (conversationType == ConversationType_GROUP && targetId.length > 0) {
            userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:operator inGroupId:targetId];
        }

        if (userInfo.name.length == 0) {
            userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:operator];
        }
        NSString *operatorName;
        if ([userInfo.name length]) {
            operatorName = userInfo.name;
        } else {
            operatorName= [[NSString alloc] initWithFormat:@"user<%@>", operator];
        }
        return [NSString
            stringWithFormat:NSLocalizedStringFromTable(@"OtherHasRecalled", @"RongCloudKit", nil), operatorName];
    }
}

+ (NSString *)__formatRecallLocalNotificationMessageContent:(RCRecallNotificationMessage *)recallNotificationMessageNotification
                                                   targetId:(NSString *)targetId
                                           conversationType:(RCConversationType)conversationType {
    if (!recallNotificationMessageNotification || !recallNotificationMessageNotification.operatorId) {
        return nil;
    }

    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    NSString *operator= recallNotificationMessageNotification.operatorId;
    if (recallNotificationMessageNotification.isAdmin) {
        return
            [NSString stringWithFormat:NSLocalizedStringFromTable(@"OtherHasRecalled", @"RongCloudKit", nil),
                                       NSLocalizedStringFromTable(@"AdminWithMessageRecalled", @"RongCloudKit", nil)];
    }else if ([operator isEqualToString:currentUserId]) {
        return [NSString stringWithFormat:@"%@", NSLocalizedStringFromTable(@"SelfHaveRecalled", @"RongCloudKit", nil)];
    } else {
        RCUserInfo *userInfo;
        if (conversationType == ConversationType_GROUP && targetId.length > 0) {
            userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:operator inGroupId:targetId];
        }

        if (userInfo.name.length == 0) {
            userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:operator];
        }
        NSString *operatorName;
        if ([userInfo.name length]) {
            operatorName = userInfo.name;
        } else {
            operatorName= [[NSString alloc] initWithFormat:@"user<%@>", operator];
        }
        if (conversationType == ConversationType_GROUP) {
            return [NSString
                stringWithFormat:NSLocalizedStringFromTable(@"OtherHasRecalled", @"RongCloudKit", nil), operatorName];
        } else {
            return [NSString
                stringWithFormat:NSLocalizedStringFromTable(@"MessageHasRecalled", @"RongCloudKit", nil)];
        }
    }
}

+ (BOOL)isVisibleMessage:(RCMessage *)message {
    if ([[message.content class] persistentFlag] & MessagePersistent_ISPERSISTED) {
        return YES;
    } else if (!message.content && message.messageId > 0 && [RCIM sharedRCIM].showUnkownMessage) {
        return YES;
    }
    return NO;
}

+ (BOOL)isUnkownMessage:(long)messageId content:(RCMessageContent *)content {
    if (!content && messageId > 0 && [RCIM sharedRCIM].showUnkownMessage) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)getNotificationUserInfoDictionary:(RCMessage *)message {
    return [RCKitUtility getNotificationUserInfoDictionary:message.conversationType
                                                fromUserId:message.senderUserId
                                                  targetId:message.targetId
                                                objectName:message.objectName
                                                 messageId:message.messageId
                                                messageUId:message.messageUId];
}

+ (NSDictionary *)getNotificationUserInfoDictionary:(RCConversationType)conversationType
                                         fromUserId:(NSString *)fromUserId
                                           targetId:(NSString *)targetId
                                         objectName:(NSString *)objectName {

    return [RCKitUtility getNotificationUserInfoDictionary:conversationType
                                                fromUserId:fromUserId
                                                  targetId:targetId
                                                objectName:objectName
                                                 messageId:0
                                                messageUId:@""];
}

+ (NSDictionary *)getNotificationUserInfoDictionary:(RCConversationType)conversationType
                                         fromUserId:(NSString *)fromUserId
                                           targetId:(NSString *)targetId
                                         objectName:(NSString *)objectName
                                          messageId:(long)messageId
                                         messageUId:(NSString *)messageUId {
    NSString *type = @"PR";
    switch (conversationType) {
    case ConversationType_PRIVATE:
        type = @"PR";
        break;
    case ConversationType_GROUP:
        type = @"GRP";
        break;
    case ConversationType_DISCUSSION:
        type = @"DS";
        break;
    case ConversationType_CUSTOMERSERVICE:
        type = @"CS";
        break;
    case ConversationType_SYSTEM:
        type = @"SYS";
        break;
    case ConversationType_APPSERVICE:
        type = @"MC";
        break;
    case ConversationType_PUBLICSERVICE:
        type = @"MP";
        break;
    case ConversationType_PUSHSERVICE:
        type = @"PH";
        break;
    default:
        return nil;
    }
    return @{
        @"rc" : @{
            @"cType" : type ?: @"",
            @"fId" : fromUserId ?: @"",
            @"oName" : objectName ?: @"",
            @"tId" : targetId ?: @"",
            @"mId" : [NSString stringWithFormat:@"%ld", messageId],
            @"id" : messageUId ?: @""
        }
    };
}

+ (NSDictionary *)getNotificationUserInfoDictionary:(RCConversationType)conversationType
                                         fromUserId:(NSString *)fromUserId
                                           targetId:(NSString *)targetId
                                     messageContent:(RCMessageContent *)messageContent {
    NSString *type = @"PR";
    switch (conversationType) {
    case ConversationType_PRIVATE:
        type = @"PR";
        break;
    case ConversationType_GROUP:
        type = @"GRP";
        break;
    case ConversationType_DISCUSSION:
        type = @"DS";
        break;
    case ConversationType_CUSTOMERSERVICE:
        type = @"CS";
        break;
    case ConversationType_SYSTEM:
        type = @"SYS";
        break;
    case ConversationType_APPSERVICE:
        type = @"MC";
        break;
    case ConversationType_PUBLICSERVICE:
        type = @"MP";
        break;
    case ConversationType_PUSHSERVICE:
        type = @"PH";
        break;
    default:
        return nil;
    }
    return @{
        @"rc" : @{
            @"cType" : type ?: @"",
            @"fId" : fromUserId ?: @"",
            @"oName" : [[messageContent class] getObjectName] ?: @"",
            @"tId" : targetId ?: @"",
            @"id" : @""
        }
    };
}

+ (NSString *)getFileTypeIcon:(NSString *)fileType {
    return [RCExtensionUtility getFileTypeIcon:fileType];
}

+ (NSString *)getReadableStringForFileSize:(long long)byteSize {
    if (byteSize < 0) {
        return @"0 B";
    } else if (byteSize < 1024) {
        return [NSString stringWithFormat:@"%lld B", byteSize];
    } else if (byteSize < 1024 * 1024) {
        double kSize = (double)byteSize / 1024;
        return [NSString stringWithFormat:@"%.2f KB", kSize];
    } else if (byteSize < 1024 * 1024 * 1024) {
        double kSize = (double)byteSize / (1024 * 1024);
        return [NSString stringWithFormat:@"%.2f MB", kSize];
    } else {
        double kSize = (double)byteSize / (1024 * 1024 * 1024);
        return [NSString stringWithFormat:@"%.2f GB", kSize];
    }
}

+ (UIImage *)defaultConversationHeaderImage:(RCConversationModel *)model {
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        if (model.conversationType == ConversationType_SYSTEM || model.conversationType == ConversationType_PRIVATE ||
            model.conversationType == ConversationType_CUSTOMERSERVICE) {
            return IMAGE_BY_NAMED(@"default_portrait_msg");
        } else if (model.conversationType == ConversationType_GROUP) {
            return IMAGE_BY_NAMED(@"default_group_portrait");
        } else if (model.conversationType == ConversationType_DISCUSSION) {
            return IMAGE_BY_NAMED(@"default_discussion_portrait");
        }
    } else if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        if (model.conversationType == ConversationType_PRIVATE || model.conversationType == ConversationType_SYSTEM) {
            return IMAGE_BY_NAMED(@"default_portrait");
        } else if (model.conversationType == ConversationType_CUSTOMERSERVICE) {
            return IMAGE_BY_NAMED(@"portrait_kefu");
        } else if (model.conversationType == ConversationType_DISCUSSION) {
            return IMAGE_BY_NAMED(@"default_discussion_collection_portrait");
        } else if (model.conversationType == ConversationType_GROUP) {
            return IMAGE_BY_NAMED(@"default_collection_portrait");
        }
    } else if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
        return IMAGE_BY_NAMED(@"default_portrait");
    }
    return IMAGE_BY_NAMED(@"default_portrait");
}

+ (NSString *)defaultTitleForCollectionConversation:(RCConversationType)conversationType {
    if (conversationType == ConversationType_PRIVATE) {
        return NSLocalizedStringFromTable(@"conversation_private_collection_title", @"RongCloudKit", nil);
    } else if (conversationType == ConversationType_DISCUSSION) {
        return NSLocalizedStringFromTable(@"conversation_discussion_collection_title", @"RongCloudKit", nil);
    } else if (conversationType == ConversationType_GROUP) {
        return NSLocalizedStringFromTable(@"conversation_group_collection_title", @"RongCloudKit", nil);
    } else if (conversationType == ConversationType_CUSTOMERSERVICE) {
        return NSLocalizedStringFromTable(@"conversation_customer_collection_title", @"RongCloudKit", nil);
    } else if (conversationType == ConversationType_SYSTEM) {
        return NSLocalizedStringFromTable(@"conversation_systemMessage_collection_title", @"RongCloudKit", nil);
    }
    return nil;
}

+ (int)getConversationUnreadCount:(RCConversationModel *)model {
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        return [[RCIMClient sharedRCIMClient] getUnreadCount:@[ @(model.conversationType) ]];
    } else {
        return [[RCIMClient sharedRCIMClient] getUnreadCount:model.conversationType targetId:model.targetId];
    }
}

+ (BOOL)getConversationUnreadMentionedStatus:(RCConversationModel *)model {
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        return [[RCIMClient sharedRCIMClient] getUnreadMentionedCount:@[ @(model.conversationType) ]] != 0;
    } else {
        return [[RCIMClient sharedRCIMClient] getConversation:model.conversationType targetId:model.targetId]
            .hasUnreadMentioned;
    }
}

+ (void)syncConversationReadStatusIfEnabled:(RCConversation *)conversation {
    if (conversation.conversationType == ConversationType_PRIVATE &&
        [[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(conversation.conversationType)]) {
        [[RCIMClient sharedRCIMClient] sendReadReceiptMessage:conversation.conversationType
                                                     targetId:conversation.targetId
                                                         time:conversation.sentTime
                                                      success:nil
                                                        error:nil];
    } else if ((conversation.conversationType == ConversationType_PRIVATE &&
                ![[RCIM sharedRCIM]
                        .enabledReadReceiptConversationTypeList containsObject:@(conversation.conversationType)]) ||
               conversation.conversationType == ConversationType_GROUP ||
               conversation.conversationType == ConversationType_DISCUSSION ||
               conversation.conversationType == ConversationType_APPSERVICE ||
               conversation.conversationType == ConversationType_PUBLICSERVICE) {
        [[RCIMClient sharedRCIMClient] syncConversationReadStatus:conversation.conversationType
                                                         targetId:conversation.targetId
                                                             time:conversation.sentTime
                                                          success:nil
                                                            error:nil];
    }
}

+ (NSString *)getPinYinUpperFirstLetters:(NSString *)hanZi {
    return [RCExtensionUtility getPinYinUpperFirstLetters:hanZi];
}

+ (void)openURLInSafariViewOrWebView:(NSString *)url base:(UIViewController *)viewController {
    if (!url || url.length == 0) {
        DebugLog(@"[RongIMKit] : Push to web Page url is nil");
        return;
    }
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    url = [self checkOrAppendHttpForUrl:url];
    if (![RCIM sharedRCIM].embeddedWebViewPreferred && RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSURL *targetUrl = [NSURL URLWithString:url];
        if (targetUrl) {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:targetUrl];
            safari.modalPresentationStyle = UIModalPresentationFullScreen;
            [viewController presentViewController:safari animated:YES completion:nil];
        } else {
            RCLogI(@"Push to web Page url is Invalid");
        }
    } else {
        UIViewController *webview = [[RCIMClient sharedRCIMClient] getPublicServiceWebViewController:url];
        [webview setValue:[RCIM sharedRCIM].globalNavigationBarTintColor forKey:@"backButtonTextColor"];
        [viewController.navigationController pushViewController:webview animated:YES];
    }
}

+ (NSString *)checkOrAppendHttpForUrl:(NSString *)url {
    if (![[url lowercaseString] hasPrefix:@"http://"] && ![[url lowercaseString] hasPrefix:@"https://"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    return url;
}

+ (BOOL)validateCellPhoneNumber:(NSString *)cellNum {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString *MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";

    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString *CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";

    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString *CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";

    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
    NSString *CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";

    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";

    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];

    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];

    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];

    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    // NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];

    if (([regextestmobile evaluateWithObject:cellNum] == YES) || ([regextestcm evaluateWithObject:cellNum] == YES) ||
        ([regextestct evaluateWithObject:cellNum] == YES) || ([regextestcu evaluateWithObject:cellNum] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)validateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+ (NSDateFormatter *)getDateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    return dateFormatter;
}

+ (UIWindow *)getKeyWindow {
    return [RCExtensionUtility getKeyWindow];
}

+ (UIEdgeInsets)getWindowSafeAreaInsets {
    return [RCExtensionUtility getWindowSafeAreaInsets];
}

/*
 参考文档:
 https://blog.csdn.net/weixin_39339407/article/details/81162726
 https://www.jianshu.com/p/df094c044096
 https://www.jianshu.com/p/326ed98d92bb
 */
+ (UIImage *)fixOrientation:(UIImage *)image {

    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp)
        return image;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (image.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;

    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;

    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, image.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
    default:
        break;
    }

    switch (image.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;

    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
    default:
        break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx =
        CGBitmapContextCreate(NULL, image.size.width, image.size.height, CGImageGetBitsPerComponent(image.CGImage), 0,
                              CGImageGetColorSpace(image.CGImage), CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        // Grr...
        CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
        break;

    default:
        CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
        break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (BOOL)currentDeviceIsIPad {
    return [[UIDevice currentDevice].model containsString:@"iPad"];
}

+ (void)showAlertController:(NSString *)title
                    message:(NSString *)message
             preferredStyle:(UIAlertControllerStyle)style
                    actions:(NSArray<UIAlertAction *> *)actions
           inViewController:(UIViewController *)controller {

    dispatch_main_async_safe(^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
        for (UIAlertAction *action in actions) {
            [alertController addAction:action];
        }
        if (style == UIAlertControllerStyleActionSheet && [self currentDeviceIsIPad]) {
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            popPresenter.sourceView = window;
            popPresenter.sourceRect = CGRectMake(window.frame.size.width / 2, window.frame.size.height / 2, 0, 0);
            popPresenter.permittedArrowDirections = 0;
        }
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}

+ (UIColor *)generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    return [RCExtensionUtility generateDynamicColor:lightColor darkColor:darkColor];
}

+ (BOOL)hasLoadedImage:(NSString *)imageUrl {
    return [[RCloudImageLoader sharedImageLoader] hasLoadedImageURL:[NSURL URLWithString:imageUrl]];
}

+ (NSData *)getImageDataForURLString:(NSString *)imageUrl {
    return [[RCloudImageLoader sharedImageLoader] getImageDataForURL:[NSURL URLWithString:imageUrl]];
}

+ (CGSize)getTextDrawingSizeWithText:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize
{
    if (!text || text.length == 0) {
        return CGSizeZero;
    }
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, constrainedSize.width, constrainedSize.height)];
    textView.text = text;
    textView.font = font;
    CGSize constraint = [textView sizeThatFits:constrainedSize];
    return constraint;
}

@end
