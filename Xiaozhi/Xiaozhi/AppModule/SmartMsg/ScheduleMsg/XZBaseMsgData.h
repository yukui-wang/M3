//
//  XZBaseMsgData.h
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#define kMsgDataContentFont  [UIFont boldSystemFontOfSize:16]

#import <CMPLib/CMPObject.h>

@interface XZBaseMsgData : CMPObject
@property(nonatomic, copy)NSString *content;
@property(nonatomic, copy)NSString *gotoUrl;
@property(nonatomic, retain)NSDictionary *gotoParams;
@property(nonatomic, retain)NSDictionary *extData;
@property (nonatomic, copy) NSString *cellClass;
@property (nonatomic, copy) NSString *ideltifier;
@property(nonatomic, retain)NSAttributedString *timeStr;

- (id)initWithMsg:(NSDictionary *)msg;
- (NSString *)stringValue:(NSString *)vaule;
- (CGFloat)cellHeightForWidth:(CGFloat)width;
@end
