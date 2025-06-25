//
//  XZBusinessMsgView.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//  业务消息 图表

#import "XZBaseMsgView.h"
#import "XZTransWebViewController.h"

@interface XZBusinessMsgView : XZBaseMsgView {
    XZTransWebViewController *_webviewController;
    UILabel *_noteLabel;//最后说明
    UIInterfaceOrientation _orientation;
}

@end
