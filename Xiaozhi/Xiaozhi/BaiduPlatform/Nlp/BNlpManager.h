//
//  BNlpManager.h
//  M3
//
//  Created by wujiansheng on 2019/1/4.
//

#import <CMPLib/CMPObject.h>


@interface BNlpManager : CMPObject
+ (instancetype)sharedInstance;
- (void)clearData;
- (void)requestAnalysisText:(NSString *)text
                   keyArray:(NSArray *)keyArray
                 completion:(void (^)(NSDictionary *result, NSError * error))completionBlock;
@end

