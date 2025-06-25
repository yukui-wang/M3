//
//  CMPOcrValidateManageDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/10.
//

#import <CMPLib/CMPDataProvider.h>


@interface CMPOcrValidateManageDataProvider : CMPDataProvider

- (void)requestOcrTaskWithPackageId:(NSString *)packageId successBlock:(nullable void (^)(NSArray *arr))successBlock failedBlock:(nullable void(^)(NSError *error))failedBlock;

@end

