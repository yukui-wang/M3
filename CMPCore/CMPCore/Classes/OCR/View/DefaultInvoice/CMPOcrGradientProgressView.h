//
//  CMPOcrGradientProgressView.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrGradientProgressView : UIView

/**
 *  进度条背景颜色  默认是 （230, 244, 245）
 */
@property (nonatomic, strong) UIColor *bgProgressColor;

/**
 *  进度条渐变颜色数组，颜色个数>=2
 *  默认是 @[(id)MQRGBColor(252, 244, 77).CGColor,(id)MQRGBColor(252, 93, 59).CGColor]
 */
@property (nonatomic, strong) NSArray *colorArr;

/**
 *  进度 默认是0.65
 */
@property (nonatomic, assign) CGFloat progress;

@end

NS_ASSUME_NONNULL_END
