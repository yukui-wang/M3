//
//  CMPNewVersionTipView.h
//  M3
//
//  Created by 程昆 on 2019/3/29.
//

#import <UIKit/UIKit.h>
typedef void(^CMPNewVersionTipViewDissmissBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CMPNewVersionTipView : UIView

- (void)showInView:(UIView *)view dissmiss:(CMPNewVersionTipViewDissmissBlock)dismissBlock;

@end

NS_ASSUME_NONNULL_END
