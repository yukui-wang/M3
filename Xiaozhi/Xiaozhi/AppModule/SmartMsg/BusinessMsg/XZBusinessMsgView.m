//
//  XZBusinessMsgView.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZBusinessMsgView.h"
#import "XZBusinessMsg.h"
@implementation XZBusinessMsgView

- (void)dealloc {
    [_webviewController.view removeFromSuperview];
    SY_RELEASE_SAFELY(_webviewController);
    SY_RELEASE_SAFELY(_noteLabel);
    [super dealloc];
}

- (id)initWithMsg:(XZBusinessMsg *)msg {
    if (self = [super initWithMsg:msg]) {
        if (!_noteLabel) {
            _noteLabel = [[UILabel alloc] init];
            [_noteLabel setBackgroundColor:[UIColor clearColor]];
            [_noteLabel setTextColor:UIColorFromRGB(0x939BAD)];
            [_noteLabel setFont:FONTSYS(14)];
            [_noteLabel setTextAlignment:NSTextAlignmentCenter];
            [self addSubview:_noteLabel];
            [_noteLabel setText:@"成功没有秘诀，贵在坚持不懈，加油哦~~~"];
            _orientation = [UIApplication sharedApplication].statusBarOrientation;
        }
    }
    return self;
}

- (void)setup {
    [super setup];
}

- (CGRect)webviewRect {
    CGFloat y = CGRectGetMaxY(_titleLabel.frame);
    CGFloat h = IS_PHONE_Landscape ? self.height : _noteLabel.originY -y;
    return CGRectMake(1, y, self.width-2, h);
}

- (void)loadView {
    if (!_webviewController) {
        XZBusinessMsg *msg = (XZBusinessMsg *)self.msg;
        _webviewController = [[XZTransWebViewController alloc] init];
        _webviewController.loadUrl = msg.loadUrl;
        _webviewController.gotoParams = msg.gotoParams;
        CGRect r = [self webviewRect];
        [_webviewController.view setFrame:r];
        r.origin = CGPointZero;
        _webviewController.viewRect = NSStringFromCGRect(r);
        [self addSubview:_webviewController.view];
    }
}


- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    _noteLabel.hidden = IS_PHONE_Landscape;
    [_noteLabel setFrame:CGRectMake(0, self.height-20, self.width, 20)];
    CGRect r = [self webviewRect];
    _webviewController.viewRect = NSStringFromCGRect(r);
    [_webviewController.view setFrame:r];
    if (_orientation != [UIApplication sharedApplication].statusBarOrientation) {
        _orientation = [UIApplication sharedApplication].statusBarOrientation;
        [_webviewController reloadWebview];
    }
}

@end
