//
//  XZWebViewTableViewCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZWebViewTableViewCell.h"
#import "XZWebViewModel.h"
#import "XZTransWebViewController.h"
@interface XZWebViewTableViewCell () {
    XZTransWebViewController *_webViewVC;
}

@end

@implementation XZWebViewTableViewCell

- (void)setup {
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(XZWebViewModel *)model {
    XZWebViewModel *cmodel = (XZWebViewModel *)self.model;
    BOOL iscurrentModel = [model.modelId isEqualToString:cmodel.modelId]?YES:NO;
    if (iscurrentModel && _webViewVC) {
        if (!_webViewVC.view.superview) {
            [self addSubview:_webViewVC.view];
        }
        return;
    }
    [super setModel:model];
    if (_webViewVC && _webViewVC.view.superview == self) {
        [_webViewVC.view removeFromSuperview];
    }
    _webViewVC = model.viewController;
    [self addSubview:_webViewVC.view];
    _webViewVC.viewRect = NSStringFromCGRect(CGRectMake(0, 0, model.cellWidth, model.webviewHeight));
    [_webViewVC.view setFrame:CGRectMake(0, 10, model.cellWidth, model.webviewHeight)];

    UIView *webview =  _webViewVC.webView;
    webview.scrollView.bounces = NO;
    webview.scrollView.scrollEnabled = NO;
}

@end
