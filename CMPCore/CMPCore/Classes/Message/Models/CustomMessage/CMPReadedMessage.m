//
//  CMPReadedMessage.m
//  CMPCore
//
//  Created by CRMO on 2017/8/31.
//
//

#import "CMPReadedMessage.h"
#import <CMPLib/NSObject+JSON.h>
#import <CMPLib/CMPConstant.h>

//static NSString *const kReadedMessageKeyItemId = @"itemId";
static NSString *const kReadedMessageKeyExtra = @"extra";
//static NSString *const kReadedMessageKeyType = @"type";

@implementation CMPReadedMessage

- (void)dealloc {
    SY_RELEASE_SAFELY(_extraDic);
    SY_RELEASE_SAFELY(_itemId);
    SY_RELEASE_SAFELY(_extra);
    [super dealloc];
}

#pragma mark -
#pragma mark -RCMessageCoding
/*!
 将消息内容序列化，编码成为可传输的json数据
 */
- (NSData *)encode {
    NSDictionary *dic = @{kReadedMessageKeyExtra : _extra};
    NSString *jsonStr = [dic JSONRepresentation];
    return [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
}

/*!
 将json数据的内容反序列化，解码生成可用的消息内容
 */
- (void)decodeWithData:(NSData *)data {
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [dataStr JSONValue];
    
    if (![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"RC---CMPReadedMessage decodeWithData error,dic is not NSDictionary!");
        [dataStr release];
        dataStr = nil;
        return;
    }
    
//    _itemId = [dic[kReadedMessageKeyItemId] copy];
//    _type = [dic[kReadedMessageKeyType] copy];
    _extra = [dic[kReadedMessageKeyExtra] copy];
    
    [dataStr release];
    dataStr = nil;
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"RC:ReadedMsg";
}

/*!
 返回可搜索的关键内容列表
 */
- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}


#pragma mark -
#pragma mark -RCMessagePersistentCompatible

/*!
 返回消息的存储策略
 */
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

- (NSString *)itemId {
    NSDictionary *extra = self.extraDic;
    if (!extra ||
        ![extra isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return extra[@"itemId"];
}

- (NSInteger)conversationType {
    NSDictionary *extra = self.extraDic;
    if (!extra ||
        ![extra isKindOfClass:[NSDictionary class]]) {
        return -1;
    }
    return [extra[@"conversationType"] integerValue];
}

- (long long)timestamp {
    NSDictionary *extra = self.extraDic;
    if (!extra ||
        ![extra isKindOfClass:[NSDictionary class]]) {
        return -1;
    }
    return [extra[@"timestamp"] integerValue];
}


- (NSDictionary *)extraDic {
    NSDictionary *extraDic = [_extra JSONValue];
    if (!extraDic ||
        ![extraDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return extraDic;
}

@end
