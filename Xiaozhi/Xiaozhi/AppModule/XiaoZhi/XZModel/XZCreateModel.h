//
//  XZCreateModel.h
//  M3
//
//  Created by wujiansheng on 2018/8/8.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPOfflineContactMember.h>
#import "BUnitResult.h"
@interface XZCreateModel : NSObject
@property(nonatomic, copy)NSString *subject;
@property(nonatomic, copy)NSString *content;
- (NSString *)submitUrl;
- (NSString *)showUrl;
- (NSDictionary *)requestParam;
- (NSDictionary *)speechInput;



- (id)initWithJsonFile:(NSDictionary *)dic;
- (void)setupWithUnitResult:(BUnitResult *)dic;
- (void)setSpeechString:(NSString *)str;
- (void)setSpeechMembers:(NSArray *)members;

@end
