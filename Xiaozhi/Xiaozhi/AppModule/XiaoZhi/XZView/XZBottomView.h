//
//  XZBottomView.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZBaseView.h"
#define kXZBottomViewH 49//78

@interface XZBottomView : XZBaseView {
    UIView *_line;
}
@property(nonatomic, retain)UIButton *keyboardButton;//底部键盘按钮
@property(nonatomic, retain)UIButton *helpButton;//底部语音按钮

@end
