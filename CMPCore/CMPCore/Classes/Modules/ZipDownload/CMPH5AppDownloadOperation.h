//
//  CMPH5AppDownloadOperation.h
//  M3
//
//  Created by Shoujian Rao on 2023/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPH5AppDownloadOperation : NSOperation
- (instancetype)initWithApp:(NSDictionary *)app downloadSession:(NSURLSession *)session completion:(void(^)(id respData,NSError *error) )completion;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

NS_ASSUME_NONNULL_END
