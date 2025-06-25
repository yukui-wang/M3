//
//  XZMemberTextView.h
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZBaseView.h"
#import "XZViewDelegate.h"

@protocol XZMemberTextViewDelegate <NSObject>

- (void)memberTextViewDidSelectMembers:(NSArray *)members string:(NSString *)string isMultiSelect:(BOOL)isMultiSelect;
- (void)needShowMessage:(NSString *)string;

@end

@interface XZMemberTextView : XZBaseView

@property(nonatomic,retain)UIButton *speakButton;
@property(nonatomic,assign)BOOL isMultiSelect;//是否是多选
@property(nonatomic,assign)id<XZViewDelegate> delegate;//老版本用pre
@property(nonatomic,assign)id<XZMemberTextViewDelegate> viewDelegate;//新版本用

@property(nonatomic,assign)BOOL isShow;

- (void)showKeyboard;
- (void)hideKeyboard;
- (void)clearInput;
- (void)clearView;
- (CGFloat)viewHeightForWidth:(CGFloat)width;
- (void)showText:(NSString *)text;
@end



