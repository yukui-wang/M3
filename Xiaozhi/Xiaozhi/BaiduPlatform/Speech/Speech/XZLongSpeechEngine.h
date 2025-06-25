//
//  XZLongSpeechEngine.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LongSpeechFlushStrBlock)(NSString *flushStr);
typedef void(^LongSpeechCompleteBlock)(NSString *filePath,NSString *resultStr);
typedef void(^LongSpeechErrorBlock)(NSError *error);


@interface XZLongSpeechEngine : NSObject
+ (instancetype)sharedInstance;

- (void)recognizerWithFilePath:(NSString *)filePath
                 flushStrBlock:(LongSpeechFlushStrBlock)flushStrBlock
                 completeBlock:(LongSpeechCompleteBlock)completeBlock
                    errorBlock:(LongSpeechErrorBlock)errorBlock;
- (void)stopRecognizerLong;
- (void)cancelRecognizerLong;
@end

