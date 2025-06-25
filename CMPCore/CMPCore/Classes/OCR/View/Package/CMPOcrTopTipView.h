//
//  CMPOcrTopTipView.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/21.
//

#import <CMPLib/CMPBaseView.h>

@interface CMPOcrTopTipView : CMPBaseView
- (void)showTip:(NSString *)tip;
+ (void)removeLastTipFromView:(UIView *)fromView;
@end

