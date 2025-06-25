//
//  XZTouchWindow.h
//  M3
//
//  Created by wujiansheng on 2017/11/9.
//

#import <UIKit/UIKit.h>

@interface XZTouchWindow : UIView

@property (nonatomic,copy) void(^didClickTapBtn)(BOOL isShow);
- (void)showInView:(UIView *)aView frame:(CGRect) f;
@end
