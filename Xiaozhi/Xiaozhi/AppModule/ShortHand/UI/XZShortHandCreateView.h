//
//  XZShortHandCreateView.h
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import <CMPLib/CMPBaseView.h>
#import "XZRippleView.h"
#import "XZShortHandTextView.h"

@interface XZShortHandCreateView : CMPBaseView

@property(nonatomic, retain)UITextField *titleView;
@property(nonatomic, retain)XZShortHandTextView *contentView;
@property(nonatomic, retain)UIButton *speakButton;

- (void)showWaveView:(id)delegate;
- (void)hideWaveView;
- (void)hideKeyboard;
@end

