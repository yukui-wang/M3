//
//  CMPTopCornerView.h
//  M3
//
//  Created by MacBook on 2019/10/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPTopCornerView : UIView

/* 自定义背景颜色 */
@property (strong, nonatomic) UIColor *customBgColor;
/* cornerRadius */
@property (assign, nonatomic) CGFloat cornerRadius;

@end

NS_ASSUME_NONNULL_END
