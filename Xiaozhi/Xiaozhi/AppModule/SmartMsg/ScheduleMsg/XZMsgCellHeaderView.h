//
//  XZMsgCellHeaderView.h
//  M3
//
//  Created by wujiansheng on 2018/9/14.
//

#import "XZBaseView.h"
#import "XZScheduleMsgItem.h"
@interface XZMsgCellHeaderView : XZBaseView {
    UILabel *_numberLabel;
    UILabel *_typeLabel;

}
- (id)initWithMsg:(XZScheduleMsgItem *)msg;
+ (CGFloat)cellHeight;
@end
