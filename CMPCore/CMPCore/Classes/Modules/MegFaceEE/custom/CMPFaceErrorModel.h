//
//  CMPFaceErrorModel.h
//  M3
//
//  Created by Shoujian Rao on 2023/10/12.
//

#import <Foundation/Foundation.h>

@interface CMPFaceErrorModel : NSObject

@property (nonatomic, assign) NSInteger errCode;//404
@property (nonatomic, copy) NSString *errMsg;//用户不存在
@property (nonatomic, copy) NSString *errEnum;//USER_NOT_FOUND，枚举

+ (CMPFaceErrorModel *)errCode:(NSInteger)errCode errMsg:(NSString *)errMsg errEnum:(NSString *)errEnum;
+ (CMPFaceErrorModel *)errFromNSError:(NSError *)error;
@end

