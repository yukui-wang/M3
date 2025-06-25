//
//  BaiduNlpApp.h
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import <Foundation/Foundation.h>
#import "BaiduAppError.h"

@interface BaiduNlpApp : NSObject
@property(nonatomic, copy) NSString *nlpAppID ;
@property(nonatomic, copy) NSString *nlpAPIKey;
@property(nonatomic, copy) NSString *nlpSecretKey;
@property(nonatomic, retain) BaiduAppError *baiduAppError;
- (id)initWithBaiduNlpApp:(NSDictionary *)dic;

@end
