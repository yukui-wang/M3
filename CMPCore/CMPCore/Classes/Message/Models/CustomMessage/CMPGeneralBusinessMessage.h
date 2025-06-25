//
//  CMPGeneralBusinessMessage.h
//  M3
//
//  Created by 程昆 on 2019/11/1.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPQuickProcessDidSelectButtonBlock)(NSUInteger index,NSDictionary *quickprocessRequestParam);

@interface CMPGeneralBusinessMessage : RCMessageContent

/**
 * messageId
 */
@property (nonatomic,copy) NSString *messageId;

/**
 * content
 */
@property (nonatomic,copy) NSString *content;

/**
 * messageCard
 */
@property (nonatomic,copy) NSDictionary *messageCard;


#pragma mark - messageCardContent 解析字段

/**
 * uuid
 */
@property (nonatomic,copy) NSString *uuid;
/**
 * 各个应用主键
 */
@property (nonatomic,copy) NSString *appId;
/**
 * 应用类型
 */
@property (nonatomic,copy) NSString *messageCategory;
/**
 * 标题
 */
@property (nonatomic,copy) NSString *messageContent;
/**
 * 动态数据(拼接内容)
 */
@property (nonatomic,copy) NSArray *dynamicData;
/**
 * 部分消息卡片会显示图片,有图片的把文件的fileId传过来
 */
@property (nonatomic,copy) NSString *imageUrl;
/**
 * pc端穿透url
 */
@property (nonatomic,copy) NSString *pcUrl;
/**
 * 移动端穿透url
 */
@property (nonatomic,copy) NSString *mobileUrlParam;
/**
 * 移动端是否允许穿透
 */
@property (nonatomic,assign) BOOL mobileOpenEnable;
/**
 * 移动端图标图片 先预留 不一定用
 */
@property (nonatomic,copy) NSString *mobilePicUrl;
/**
 * 扩展字段
 */
@property (nonatomic,copy) NSString *extraData;

/**
 * appName
 */
@property (nonatomic,copy) NSString *appName;

/**
 * appIconUrl
 */
@property (nonatomic,copy) NSString *appIconUrl;

#pragma mark - 临时缓存字段
/**
 * tagImageUrl
 */
//@property (nonatomic,copy) NSString *tagImageUrl;

@end

NS_ASSUME_NONNULL_END
