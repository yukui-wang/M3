//
//  CMPRCConvertMissionMessage.h
//  M3
//
//  Created by 曾祥洁 on 2018/9/27.
//

#import <RongIMKit/RongIMKit.h>

typedef NS_ENUM(NSInteger, RCSystemImMessageCategory) {
    RCSystemImMessageCategoryUnkown, 
    RCSystemImMessageCategoryColHasten, // 催办消息
    RCSystemImMessageCategoryTask // 消息转任务
};

NS_ASSUME_NONNULL_BEGIN

@interface CMPRCSystemImMessageExtraMessage :NSObject
@property (nonatomic , copy) NSString              * ir; // 是否已读 0 未读 1 已读
@property (nonatomic , copy) NSString              * ml; // 消息id
@property (nonatomic , copy) NSString              * mc; // 消息分类
@property (nonatomic , copy) NSString              * mMl; // 移动端穿透Url
@property (nonatomic , copy) NSString              * c; // 内容
@property (nonatomic , copy) NSString              * at; // 能否穿透 0 不穿透 1 穿透
@property (nonatomic , copy) NSString              * mi; // 消息id
@property (nonatomic , copy) NSString              * ui; // 接收人id
@property (nonatomic , copy) NSString              * t; // 发送时间 yyyy-MM-dd HH:mm:ss
@property (nonatomic , copy) NSString              * un; // 接收人name
@property (nonatomic , copy) NSString              * si; // 发送人id
@property (nonatomic , copy) NSString              * sn; // 发送人name
@property (nonatomic , copy) NSString              * mt; // 消息类型 0 是系统 1是普通
@property (strong, nonatomic) NSDictionary *extra;
@end

@interface CMPRCSystemImMessageExtra :NSObject
@property (nonatomic , strong) CMPRCSystemImMessageExtraMessage              * message;
@property (nonatomic , copy) NSString              * messageCategory;
@property (nonatomic , assign) NSInteger              messageType;
@end


@interface CMPRCSystemImMessage : RCMessageContent

@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *extra;
@property (strong, nonatomic) CMPRCSystemImMessageExtra *extraData;
/** 标题 **/
@property (nonatomic, copy) NSString *title;
/**业务消息类型**/
@property (nonatomic, copy) NSString *type;
/** 消息类型图标地址 **/
@property (nonatomic, copy) NSString *imgURL;
/** 业务消息发送人 **/
@property (nonatomic, copy) NSString *sendName;
/** 业务消息发送时间 **/
@property (nonatomic, copy) NSString *sendTime;
/** 移动消息穿透链接 **/
@property (nonatomic, copy) NSString *mobilePassURL;
/** PC穿透地址 **/
@property (nonatomic, copy) NSString *PCPassURL;
@property (nonatomic, copy) NSString *appId;
/** 消息类型 **/
@property (nonatomic, assign) RCSystemImMessageCategory category;
//0：只读   1：可穿透
@property (nonatomic, copy) NSString *actionType;

@end

NS_ASSUME_NONNULL_END
