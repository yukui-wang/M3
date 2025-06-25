//
//  SPBaiduUnitInfo.h
//  M3
//
//  Created by wujiansheng on 2019/2/27.
//

#import <Foundation/Foundation.h>
#import "BaiduAppError.h"

@interface SPBaiduUnitInfo : NSObject

@property(nonatomic, copy) NSString *baiduUnitSceneID;
@property(nonatomic, copy) NSString *baiduUnitAppId;
@property(nonatomic, copy) NSString *baiduUnitApiKey;
@property(nonatomic, copy) NSString *baiduUnitSecretKey;
@property(nonatomic, copy) NSString *unitVersion;//unit 版本
@property(nonatomic, copy) NSString *unitUrl;//unit url 生产环境

@property (nonatomic, copy)NSString *xiaozVersion;
@property(nonatomic, assign) long long endTime;

@property(nonatomic,retain) BaiduAppError *baiduAppError;

- (id)initWithResult:(NSDictionary *)result;
- (id)initWithQAResult:(NSDictionary *)result;
- (id)initWithBaiduUnitApp:(NSDictionary *)dic;

+ (SPBaiduUnitInfo *)defaultInfo;
- (NSString *)logId;
- (NSString *)userId;

@end
