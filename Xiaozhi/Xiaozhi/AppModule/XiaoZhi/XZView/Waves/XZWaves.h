//
//  XZWaves.h
//  M3
//
//  Created by wujiansheng on 2017/11/17.
//

#import "XZBaseView.h"

@interface XZWaves : XZBaseView
@property (nonatomic,retain)UIColor *wavesColor;
@property (nonatomic,assign) CGFloat waveW ;//水纹周期
@property (nonatomic,assign) CGFloat waveA;//水纹振幅
@property (nonatomic,assign) CGFloat offsetX; //位移
@property (nonatomic,assign) CGFloat currentK; //当前波浪高度Y
@property (nonatomic,assign) CGFloat wavesSpeed;//水纹速度
@property (nonatomic,assign) CGFloat wavesWidth; //水纹宽度

@property (nonatomic,assign) BOOL sin; //sin正弦函数波浪公式 or cos余弦函数波浪公式

- (void)show;
- (void)stop;
@end
