//
//  XZMsgWebViewController.m
//  M3
//
//  Created by wujiansheng on 2018/9/19.
//

#import "XZTransWebViewController.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import "XZCore.h"
@implementation XZTransWebViewController

- (void)dealloc {
    [self removeWebObservers];
    self.gotoParams = nil;
    self.loadUrl = nil;
    self.viewRect = nil;
    self.webviewFinishLoad = nil;
    self.webViewModel = nil;
}

- (CGRect)mainFrame {
    if (self.viewRect) {
        CGRect r = CGRectFromString(self.viewRect);
        return r;
    }
    return  [super mainFrame];
}

- (void)viewDidLoad {
    NSString *url = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:self.loadUrl]];
    self.startPage = url?url:self.loadUrl;
    [super viewDidLoad];
    self.allowRotation = [XZCore allowRotation];
    [self addWebObservers];
    self.view.backgroundColor = [UIColor clearColor];
}
- (void)setupNavigationBarHidden {
    UINavigationController *nav = [super navigationController];
    if (nav) {
        nav.navigationBarHidden = [self navigationBarHidden];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubviewsWithFrame:(CGRect)frame {
    if (self.viewRect) {
        if (frame.size.width == 0) {
            return;
        }
        CGRect s = CGRectFromString(self.viewRect);
        self.view.frame = CGRectMake(0, self.view.originY, self.view.width, s.origin.y*2+s.size.height);
        self.mainView.frame = self.mainView.bounds;
        self.webView.frame = s;
    }
    else {
        [super layoutSubviewsWithFrame:frame];
    }
}

- (void)reloadWebview {
    [(WKWebView *)self.webView reload];
}

- (void)handleOptionValue:(NSDictionary *)params {
    if (self.webViewModel.optionValueBlock) {
        self.webViewModel.canDisappear = YES;
        self.webViewModel.optionValueBlock(params);
    }
}

- (void)handleNextIntent:(NSDictionary *)params {
    if (self.webViewModel.nextIntentBlock) {
        self.webViewModel.nextIntentBlock(params);
    }
}

- (void)handleOptionCommands:(NSDictionary *)params {
    if (self.webViewModel.optionCommandsBlock) {
        self.webViewModel.optionCommandsBlock(params);
    }
}
- (void)webviewChangeHeight:(NSString *)height {
//    CGFloat result = [self.webView sizeThatFits:CGSizeZero].height;
//    if (self.webviewFinishLoad) {
//        self.webviewFinishLoad(result);
//    }
}

- (UINavigationController *)navigationController {
    //处理 view 在tableviewcell中打开附件的情况
    UINavigationController *nav = [super navigationController];
    if (!nav && self.webViewModel) {
        nav = self.webViewModel.nav;
    }
    return nav;
}
#pragma mark 获取卡片高度
- (UIScrollView *)scrollView {
    return self.webView.scrollView;
}

- (void)addWebObservers {
    UIScrollView *scrollView = self.scrollView;
    if(scrollView) {
        [scrollView addObserver:self forKeyPath:@"contentSize"
                        options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeWebObservers {
    UIScrollView *scrollView = self.scrollView;
    if(scrollView) {
        [scrollView removeObserver:self forKeyPath:@"contentSize"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.scrollView && [keyPath isEqualToString:@"contentSize"]) {
        CGSize size = self.scrollView.contentSize;
        CGFloat newHeight = size.height;
        CGFloat width = size.width;
        if (newHeight > 20 && _webHeight != newHeight && width == self.webView.width && self.webviewFinishLoad) {
            _webHeight = newHeight;
            self.webviewFinishLoad(_webHeight);
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
