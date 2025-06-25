//
//  XZQAGuideInfo.h
//  M3
//
//  Created by wujiansheng on 2018/10/22.
//

#import <CMPLib/CMPObject.h>

@interface XZQAGuideInfo : CMPObject
//接口返回
@property(nonatomic ,copy)NSString *intentId;//QA意图ID 无用
@property(nonatomic ,copy)NSString *intentName;//QA意图名称 无用
@property(nonatomic ,copy)NSString *welcoming;//欢迎语
@property(nonatomic ,retain)NSArray *tipsSet;//QA问题列表
@property(nonatomic ,assign)BOOL preset;

- (id)initWithResult:(NSDictionary *)result;
- (NSArray *)cellModels:(BOOL)showWelcome;

@end
