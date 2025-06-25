//
//  XZMsgWebViewController.h
//  M3
//
//  Created by wujiansheng on 2018/9/19.
//
//中转界面

#import <CMPLib/CMPBannerWebViewController.h>
#import "XZWebViewModel.h"
@interface XZTransWebViewController : CMPBannerWebViewController {
    CGFloat _webHeight;
}

@property(nonatomic, retain)NSDictionary *gotoParams;
@property(nonatomic, copy)NSString *loadUrl;
@property(nonatomic, copy)NSString *viewRect;

@property(nonatomic, copy)void(^webviewFinishLoad)(CGFloat webHeight);
@property(nonatomic, assign)XZWebViewModel *webViewModel;//弱引用，防止循环调用

- (void)reloadWebview;
- (void)handleOptionValue:(NSDictionary *)params;
- (void)handleNextIntent:(NSDictionary *)params;
- (void)handleOptionCommands:(NSDictionary *)params;
- (void)webviewChangeHeight:(NSString *)height;
@end

