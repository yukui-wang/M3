//
//  RongIMKitExtensionManager.m
//  RongIMKit
//
//  Created by 岑裕 on 2016/10/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RongIMKitExtensionManager.h"
#import "RCIM.h"
#import "RCKitUtility.h"
#import "RCloudImageView.h"
#import "RongExtensionKit.h"

@interface RongIMKitExtensionManager () <RCExtensionServiceDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<RCExtensionMessageCellInfo *> *> *messageCellDict;

@end

@implementation RongIMKitExtensionManager

+ (instancetype)sharedManager {
    static RongIMKitExtensionManager *pDefaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (pDefaultManager == nil) {
            pDefaultManager = [[RongIMKitExtensionManager alloc] init];
            [RCExtensionService sharedService].delegate = pDefaultManager;
        }
    });
    return pDefaultManager;
}

#pragma mark - Dynamic Module Manager
- (void)loadAllExtensionModules {
    [[RCExtensionService sharedService] loadAllExtensionModules];
}

- (void)initWithAppKey:(NSString *)appkey {
    [[RCExtensionService sharedService] initWithAppKey:appkey];
}

- (void)didConnect:(NSString *)userId {
    [[RCExtensionService sharedService] didConnect:userId];
}

- (void)didDisconnect {
    [[RCExtensionService sharedService] didDisconnect];
}

- (void)didCurrentUserInfoUpdated:(RCUserInfo *)userInfo {
    [[RCExtensionService sharedService] didCurrentUserInfoUpdated:userInfo];
}

- (void)onMessageReceived:(RCMessage *)message {
    [[RCExtensionService sharedService] onMessageReceived:message];
}

- (BOOL)handleAlertForMessageReceived:(RCMessage *)message {
    return [[RCExtensionService sharedService] handleAlertForMessageReceived:message];
}

- (BOOL)handleNotificationForMessageReceived:(RCMessage *)message
                                        from:(NSString *)fromName
                                    userInfo:(NSDictionary *)userInfo {
    return [[RCExtensionService sharedService] handleNotificationForMessageReceived:message
                                                                               from:fromName
                                                                           userInfo:userInfo];
}

- (BOOL)onOpenUrl:(NSURL *)url {
    return [[RCExtensionService sharedService] onOpenUrl:url];
}

- (void)setScheme:(NSString *)scheme forModule:(NSString *)moduleName {
    [[RCExtensionService sharedService] setScheme:scheme forModule:moduleName];
}

#pragma mark - Cell UI
- (NSArray<RCExtensionMessageCellInfo *> *)getMessageCellInfoList:(RCConversationType)conversationType
                                                         targetId:(NSString *)targetId {
    self.messageCellDict = [[NSMutableDictionary alloc] init];

    for (id<RongIMKitExtensionModule> module in [[RCExtensionService sharedService] getAllExtensionModules]) {
        if ([module respondsToSelector:@selector(getMessageCellInfoList:targetId:)]) {
            [self.messageCellDict setValue:[module getMessageCellInfoList:conversationType targetId:targetId]
                                    forKey:NSStringFromClass([module class])];
        }
    }
    NSMutableArray<RCExtensionMessageCellInfo *> *result = [NSMutableArray<RCExtensionMessageCellInfo *> new];
    [self.messageCellDict
        enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSArray<RCExtensionMessageCellInfo *> *_Nonnull obj,
                                            BOOL *_Nonnull stop) {
            [result addObjectsFromArray:obj];
        }];

    return result;
}

- (void)didTapMessageCell:(RCMessageModel *)messageModel {
    Class contentClass = [messageModel.content class];

    [self.messageCellDict
        enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSArray<RCExtensionMessageCellInfo *> *_Nonnull obj,
                                            BOOL *_Nonnull stop) {
            for (RCExtensionMessageCellInfo *info in obj) {
                if (info.messageContentClass == contentClass) {
                    for (id<RongIMKitExtensionModule> module in
                         [[RCExtensionService sharedService] getAllExtensionModules]) {
                        if ([NSStringFromClass([module class]) isEqualToString:key]) {
                            if ([module respondsToSelector:@selector(didTapMessageCell:)]) {
                                [module didTapMessageCell:messageModel];
                            }
                            break;
                        }
                    }
                    *stop = YES;
                }
            }
        }];
}

#pragma mark - RCExtensionServiceDelegate
- (UIColor *)navigationBarTintColor {
    return [RCIM sharedRCIM].globalNavigationBarTintColor;
}
- (CGSize)portraitSize {
    return [RCIM sharedRCIM].globalMessagePortraitSize;
}
- (BOOL)exclusiveSoundStatus {
    return [RCIM sharedRCIM].isExclusiveSoundPlayer;
}
- (BOOL)isMediaSelectorContainVideo {
    return [RCIM sharedRCIM].isMediaSelectorContainVideo;
}
- (NSUInteger)maxRecordDuration {
    return [RCIM sharedRCIM].maxVoiceDuration;
}
- (BOOL)enableDarkMode {
    return [RCIM sharedRCIM].enableDarkMode;
}
- (UIImageView *)portraitView:(NSURL *)portraitURL {
    RCloudImageView *portraitView = [[RCloudImageView alloc] init];
    portraitView.frame = CGRectMake(10.0, 5.0, [RCIM sharedRCIM].globalMessagePortraitSize.width,
                                    [RCIM sharedRCIM].globalMessagePortraitSize.height);

    [portraitView setPlaceholderImage:[RCKitUtility imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
    [portraitView setImageURL:portraitURL];

    if ([RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_RECTANGLE) {
        portraitView.layer.cornerRadius = [RCIM sharedRCIM].portraitImageViewCornerRadius;
    } else if ([RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        portraitView.layer.cornerRadius = [RCIM sharedRCIM].globalMessagePortraitSize.height / 2;
    }
    portraitView.layer.masksToBounds = YES;
    portraitView.contentMode = UIViewContentModeScaleAspectFill;

    return portraitView;
}

- (void)extensionViewWillAppear:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                  extensionView:(UIView *)extensionView {
    for (id<RongIMKitExtensionModule> module in [[RCExtensionService sharedService] getAllExtensionModules]) {
        if ([module respondsToSelector:@selector(extensionViewWillAppear:targetId:extensionView:)]) {
            [module extensionViewWillAppear:conversationType targetId:targetId extensionView:extensionView];
        }
    }
}

- (void)extensionViewWillDisappear:(RCConversationType)conversationType targetId:(NSString *)targetId {
    for (id<RongIMKitExtensionModule> module in [[RCExtensionService sharedService] getAllExtensionModules]) {
        if ([module respondsToSelector:@selector(extensionViewWillDisappear:targetId:)]) {
            [module extensionViewWillDisappear:conversationType targetId:targetId];
        }
    }
}

- (void)containerViewWillDestroy:(RCConversationType)conversationType targetId:(NSString *)targetId {
    for (id<RongIMKitExtensionModule> module in [[RCExtensionService sharedService] getAllExtensionModules]) {
        if ([module respondsToSelector:@selector(containerViewWillDestroy:targetId:)]) {
            [module containerViewWillDestroy:conversationType targetId:targetId];
        }
    }
}

@end
