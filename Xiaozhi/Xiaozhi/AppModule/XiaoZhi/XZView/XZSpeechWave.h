//
//  XZSpeechWave.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/4.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZSpeechWave : XZBaseView

- (void)show;
- (void)showWaveWithVolume:(NSInteger)volume;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
