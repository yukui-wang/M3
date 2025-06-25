//
//  XZTextEditView.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZBaseView.h"
#import "XZViewDelegate.h"
#define kDefaultTextEditHeight 54

@protocol XZTextEditViewDelegate <NSObject>

- (void)textEditViewFinishInputText:(NSString *)text;
- (void)needShowMessage:(NSString *)string;

@end

@interface XZTextEditView : XZBaseView

@property(nonatomic,assign)id<XZViewDelegate> delegate;//老版本用pre
@property(nonatomic,assign)id<XZTextEditViewDelegate> viewDelegate;//新版本用

@property(nonatomic,retain)UIButton *speakButton;
@property(nonatomic,retain)UITextView *textView;
@property(nonatomic,retain)UILabel *placeholderLabel;
- (void)showText:(NSString *)text;
- (void)showKeyboard;
- (void)hideKeyboard;
- (void)clearInput;
@end
