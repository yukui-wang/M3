//
//  Target_SpeechView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/18.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "Target_SpeechView.h"
#import "CMPSpeechView.h"

@interface Target_SpeechView () {
    CMPSpeechView *_speechView;
}

@end

@implementation Target_SpeechView

- (void)Action_showSpeechViewInView:(NSDictionary *)params {
    if (!_speechView) {
        UIView *view = params[@"view"];
        NSInteger type = [params[@"type"] integerValue];
        SpeechViewEndBlock endBlock = params[@"endBlock"];
        SpeechViewCancelBlock cancelBlock = params[@"cancelBlock"];
        _speechView = [[CMPSpeechView alloc] initWithType:type endBlock:endBlock cancelBlock:cancelBlock];
        _speechView.frame = view.bounds;
        [view addSubview:_speechView];
    }
}

- (void)Action_removeSpeechView:(NSDictionary *)params {
    [_speechView didDismiss];
    [_speechView removeFromSuperview];
    _speechView = nil;
}

@end
