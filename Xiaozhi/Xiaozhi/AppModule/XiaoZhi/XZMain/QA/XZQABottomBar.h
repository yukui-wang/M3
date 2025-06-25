//
//  XZQABottomBar.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#define kQABottomBarHeight 56

#import <CMPLib/CMPBaseView.h>
#import "SPConstant.h"

typedef void(^StartRecordingBlock)(void);
typedef void(^StopRecordingBlock)(void);
typedef void(^InputContentBlock)(NSString * _Nullable content);
typedef void(^BarHeightChangeBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface XZQABottomBar : CMPBaseView
@property(nonatomic, copy)StartRecordingBlock startRecordingBlock;
@property(nonatomic, copy)StopRecordingBlock stopRecordingBlock;
@property(nonatomic, copy)InputContentBlock inputContentBlock;
@property(nonatomic, copy)BarHeightChangeBlock barHeightChangeBlock;

- (CGFloat)viewHeight;
- (void)showWave;
- (void)showWaveWithVolume:(NSInteger)volume;
- (void)hideWave;
- (void)editContent:(NSString *)text;
- (void)hideKeyboard;
@end

NS_ASSUME_NONNULL_END
