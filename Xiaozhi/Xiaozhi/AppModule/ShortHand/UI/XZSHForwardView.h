//
//  XZSHForwardView.h
//  M3
//
//  Created by wujiansheng on 2019/1/9.
//

typedef enum {
    XZSHForwardType_Coll = 1,
    XZSHForwardType_Task,
    XZSHForwardType_Calendar,
    XZSHForwardType_Metting,
    XZSHForwardType_Msg
}XZSHForwardType;

#import <CMPLib/CMPBaseView.h>
#import "XZShortHandObj.h"

typedef  void (^ForwardDataBlock)(XZShortHandObj *data,XZSHForwardType type);

@interface XZSHForwardView : CMPBaseView
@property(nonatomic, copy) ForwardDataBlock forwardDataBlock;

//语音速记是否有权限转发
+ (BOOL)canShortHandleForward;
+ (void)showInView:(UIView *)view pushController:(UIViewController *)vc data:(XZShortHandObj *)data;

@end

