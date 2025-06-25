//
//  XZBaseItem.h
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZBaseView.h"
#import "SPConstant.h"

@interface XZBaseItem : UIControl {
    UILabel *_contentLabel;
    UIImageView *_dotImageView;
    id _touchTarget;
    SEL _touchAction;
}

+ (XZBaseItem *)itemWithModel:(NSObject *)model;
- (void)setup;
- (void)customLayoutSubviews;
- (void)addTarget:(id)target touchAction:(SEL)action;

@end
