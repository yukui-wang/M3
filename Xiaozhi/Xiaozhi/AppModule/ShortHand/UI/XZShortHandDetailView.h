//
//  XZShortHandDetailView.h
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import <CMPLib/CMPBaseView.h>
#import "XZShortHandObj.h"

@interface XZShortHandDetailView : CMPBaseView

@property(nonatomic, retain)UITextField *titleView;
@property(nonatomic, retain)UITextView *contentView;
@property(nonatomic, retain)XZShortHandObj *data;
@property(nonatomic, retain)UIButton *editBtn;
@property(nonatomic, retain)UIButton *forwardBtn;

@end
