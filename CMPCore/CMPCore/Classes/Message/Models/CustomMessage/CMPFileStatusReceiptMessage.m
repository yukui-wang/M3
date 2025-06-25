//
//  CMPFileStatusReceiptMessage.m
//  CMPCore
//
//  Created by CRMO on 2017/9/14.
//
//

#import "CMPFileStatusReceiptMessage.h"
#import <CMPLib/NSObject+JSON.h>
#import <CMPLib/CMPConstant.h>

static NSString *const kUCSystemMessageKeyExtra = @"extra";
static NSString *const kUCSystemMessageKeyFileStatus = @"fileStatusReceipt";

@implementation CMPFileStatusReceiptMessage
- (void)dealloc {
    SY_RELEASE_SAFELY(_fileStatusReceipt);
    SY_RELEASE_SAFELY(_extra);
    SY_RELEASE_SAFELY(_msgUId);
    [super dealloc];
}

#pragma mark -
#pragma mark -RCMessageCoding
/*!
 将消息内容序列化，编码成为可传输的json数据
 */
- (NSData *)encode {
    NSDictionary *dic = @{kUCSystemMessageKeyExtra : _extra,
                          kUCSystemMessageKeyFileStatus : _fileStatusReceipt};
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
        NSLog(@"CMPFileStatusReceiptMessage decodeWithData error,dic is not NSDictionary!");
        [dataStr release];
        dataStr = nil;
        return;
    }
    
    _extra = [dic[kUCSystemMessageKeyExtra] copy];
    _fileStatusReceipt = [dic[kUCSystemMessageKeyFileStatus] copy];
    
    [dataStr release];
    dataStr = nil;
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"RC:FileStatusReceipt";
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

- (NSString *)msgUId {
    NSDictionary *extraDic = [_extra JSONValue];
    if (!extraDic || ![extraDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *msgId = extraDic[@"msgUId"];
    return msgId;
}

- (CMPFileStatusReceipt)status {
    return [_fileStatusReceipt integerValue];
}

@end
