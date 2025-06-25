//
//  CMPTopScreenDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2024/1/10.
//

#import <CMPLib/CMPDataProvider.h>

typedef void(^CompletionBlock)(id respData,NSError *error);
NS_ASSUME_NONNULL_BEGIN

@interface CMPTopScreenDataProvider : CMPDataProvider

- (void)topScreenCheckById:(NSString *)iid completion:(CompletionBlock)completionBlock;
- (void)topScreenGetAllCompletion:(CompletionBlock)completionBlock;
- (void)topScreenSaveByParam:(NSDictionary *)param completion:(CompletionBlock)completionBlock;
- (void)topScreenDelById:(NSString *)iid completion:(CompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
