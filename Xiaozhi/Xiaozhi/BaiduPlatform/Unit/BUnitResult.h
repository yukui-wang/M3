//
//  BUnitResult.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBUnitResult_SUCESS  @"satisfy"//场景完成
#define kBUnitResult_Fail  @"clarify"//场景中有参数不完成整

NS_ASSUME_NONNULL_BEGIN

@interface BUnitResult : NSObject
@property(nonatomic,copy)NSString *intentName;
@property(nonatomic,copy)NSString *intentId;
@property(nonatomic,copy)NSString *intentTarget;
@property(nonatomic,copy)NSString *intentType;
@property(nonatomic,copy)NSString *say;
@property(nonatomic,copy)NSString *currentText;
@property(nonatomic,strong)NSArray *QAExtra;
@property(nonatomic,strong)NSDictionary *infoDict;//词槽对应的是string
@property(nonatomic,strong)NSDictionary *infoListDict;//词槽对应的是list
@property(nonatomic,strong)NSArray *optionalOpenIntentList;//词槽对应的是list

- (BOOL)isEnd;
- (BOOL)needKeepSessionId;
@end



@interface BUnitQAExtra : NSObject
@property(nonatomic,copy)NSString *confidence;
@property(nonatomic,copy)NSString *intentName;
@property(nonatomic,copy)NSString *say;
@end


@interface BUnitOptionalOpenIntent : NSObject
@property(nonatomic,copy)NSString *displayName;
@property(nonatomic,copy)NSString *say;
@end


NS_ASSUME_NONNULL_END
