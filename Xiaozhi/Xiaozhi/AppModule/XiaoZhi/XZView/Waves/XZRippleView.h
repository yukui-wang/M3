//
//  XZRippleView.h
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZBaseView.h"
#import "XZViewDelegate.h"

@interface XZRippleView : XZBaseView

@property(nonatomic, assign)id<XZViewDelegate> delegate;
- (void)show;
- (void)removeFromParentView;
- (void)showAnalysisAnimation;
@end


