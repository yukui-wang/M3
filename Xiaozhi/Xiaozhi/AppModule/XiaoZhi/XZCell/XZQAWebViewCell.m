//
//  XZQAWebViewCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAWebViewCell.h"
#import "XZWebViewModel.h"
#import "XZTransWebViewController.h"
@interface XZQAWebViewCell () {
    XZTransWebViewController *_webViewVC;
}

@end

@implementation XZQAWebViewCell

- (void)setup {
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setModel:(XZWebViewModel *)model {
    [super setModel:model];
    if (!_webViewVC) {
        _webViewVC = [[XZTransWebViewController alloc] init];
        _webViewVC.loadUrl = model.loadUrl;
        _webViewVC.gotoParams = model.gotoParams;
        _webViewVC.viewRect = NSStringFromCGRect(CGRectMake(0, 0, model.cellWidth, 10));
        [self.contentView addSubview:_webViewVC.view];
        _webViewVC.view.hidden = YES;
        UIView *webview =  _webViewVC.webView;
        webview.scrollView.bounces = NO;
        webview.scrollView.scrollEnabled = NO;
        _webViewVC.view.backgroundColor = [UIColor clearColor];
        webview.backgroundColor = [UIColor clearColor];
        __weak UIView *weakView = _webViewVC.view;
        __weak XZWebViewModel *weakModel = model;

        _webViewVC.webviewFinishLoad = ^(CGFloat webHeight) {
            NSLog(@"!!!! webHeight = %f",webHeight);
            weakModel.webviewHeight = webHeight;
            if (weakModel.webviewFinishLoad) {
                weakModel.webviewFinishLoad(webHeight);
            }
            weakView.hidden = NO;
        };
        _webViewVC.webViewModel = model;
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    XZWebViewModel *model = (XZWebViewModel *)self.model;
    if (!model) {
        return;
    }
    model.cellWidth = frame.size.width;
    _webViewVC.viewRect = NSStringFromCGRect(CGRectMake(0, 0, model.cellWidth, MAX(model.webviewHeight, 10)));
    [_webViewVC.view setFrame:CGRectMake(0, 10, model.cellWidth, MAX(model.webviewHeight, 10))];
}
@end
