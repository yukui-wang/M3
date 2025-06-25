//
//  Target_SpeechReply.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/18.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "Target_SpeechReply.h"
#import "XZLongSpeechEngine.h"
@implementation Target_SpeechReply

- (void)Action_obtainSpeechReply:(NSDictionary *)params {
    [[XZLongSpeechEngine sharedInstance] recognizerWithFilePath:params[@"path"] flushStrBlock:params[@"flushStr"]  completeBlock:params[@"complete"]  errorBlock:params[@"error"]];
}

- (void)Action_stopSpeechReply:(NSDictionary *)params {
    [[XZLongSpeechEngine sharedInstance] stopRecognizerLong];
}

- (void)Action_cancelSpeechReply:(NSDictionary *)params {
    [[XZLongSpeechEngine sharedInstance] cancelRecognizerLong];
}

@end
