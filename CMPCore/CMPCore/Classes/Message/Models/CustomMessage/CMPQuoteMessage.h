//
//  CMPQuoteMessage.h
//  M3
//
//  Created by Kaku Songu on 4/19/21.
//

#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RCMessageModel.h>

#define kQuotedMessageType_Text @"TextMessage"
#define kQuotedMessageType_Quote @"QuoteMessage"

NS_ASSUME_NONNULL_BEGIN

@interface CMPQuoteMessage : RCTextMessage

@property (nonatomic,copy) NSString *quotedMsgUId;//被引用消息的服务器id
@property (nonatomic,copy) NSString *quotedMsgType;//被引用消息的类型
@property (nonatomic,copy) NSString *quotedMsgId;//被引用消息的本地id
@property (nonatomic,strong) RCMessageContent *quotedMsgContent;//被引用的消息体
@property (nonatomic,copy) NSString *quotedShowStr;//被引用消息显示的内容

-(instancetype)initWithMessageContent:(RCMessageContent *)msgContent
                   quotedMessageModel:(RCMessageModel *)quotedMsgModel
                                  ext:(nullable id)ext;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
                              ext:(nullable id)ext;

@end

NS_ASSUME_NONNULL_END


//{
//"userId": "6145739283791432398",
//"userName": "张新飞",
//"toId": "7147409173071939797",
//"toName": "孙坤军,郭金龙,张新飞",
//"from_c": "PC",
//"pcMAC": "00-FF-E7-2E-87-B1",
//"diyStyle": {
//"color": "#000000",
//"font-size": "1.4rem",
//"font-family": "inherit",
//"font-style": "normal",
//"font-weight": "normal",
//"text-decoration": "none"
//},
//"messageUId": "BOT2-UG0A-G12E-NRBJ",
//"messageType": "TextMessage",
//"messageId": "3_2289786",
//"content": "@张新飞 引用消息  完整的一条消息内容  整一个格式出来呢。  前面全是零散的   出一个最终版吧。",
//"name": "孙坤军"
//}
