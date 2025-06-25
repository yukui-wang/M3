//
//  CMPMyFilesBottomView.m
//  M3
//
//  Created by MacBook on 2019/10/12.
//

#import "CMPMyFilesBottomView.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/YBIBUtilities.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPThemeManager.h>
static CGFloat const kViewMargin = 20.f;
static CGFloat const kBtnTopMargin = 6.f;
static CGFloat const kIponeXH = 20.f;

@interface CMPMyFilesBottomView()

/* 取消按钮 */
@property (strong, nonatomic) UIButton *cancelBtn;
/* sendBtn */
@property (strong, nonatomic) UIButton *sendBtn;
/* 分割线 */
@property (weak, nonatomic) UIView *separatorLine;


@end

@implementation CMPMyFilesBottomView

#pragma mark - lazy loading

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        CGFloat w = (self.width - 3.f*kViewMargin)/2.f;
        CGFloat h = 38.f;//self.height - 2.f*kBtnTopMargin;
        CGFloat x = kViewMargin;
        CGFloat y = kBtnTopMargin;
        if ([YBIBUtilities isIphoneX]) {
            h = self.height - 2.f*kBtnTopMargin - kIponeXH;
        }
        _cancelBtn.frame = CGRectMake(x, y, w, h);
        [_cancelBtn setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_cancelBtn cmp_setRoundView];
        _cancelBtn.layer.borderColor = [UIColor cmp_colorWithName:@"theme-bgc"].CGColor;
        _cancelBtn.layer.borderWidth = 0.5f;
        [_cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] init];
        CGFloat w = _cancelBtn.width;
        CGFloat h = _cancelBtn.height;
        CGFloat x = self.width - w - kViewMargin;
        CGFloat y = kBtnTopMargin;
        _sendBtn.frame = CGRectMake(x, y, w, h);
        [_sendBtn setTitle:SY_STRING(@"file_management_send_btn") forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendBtn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_sendBtn cmp_setRoundView];
        [_sendBtn addTarget:self action:@selector(sendClicked) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sendBtn;
}

#pragma mark - initialization

+ (instancetype)bottomViewWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([YBIBUtilities isIphoneX]) {
        frame.size.height += kIponeXH;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSeperatorLine];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.sendBtn];
    }
    return self;
}

- (void)addSeperatorLine {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5f)];
    seperator.backgroundColor = RGB_COLOR(200.f,200.f,222.f);
    [self addSubview:seperator];
    _separatorLine = seperator;
}

- (void)layoutSubviews {
    if (CMP_IPAD_MODE) {
        {
            CGFloat w = (self.width - 3.f*kViewMargin)/2.f;
            CGFloat h = self.height - 2.f*kBtnTopMargin;
            CGFloat x = kViewMargin;
            CGFloat y = kBtnTopMargin;
            if ([YBIBUtilities isIphoneX]) {
                h = self.height - 2.f*kBtnTopMargin - kIponeXH;
            }
            _cancelBtn.frame = CGRectMake(x, y, w, h);
        }
        
        {
            CGFloat w = _cancelBtn.width;
            CGFloat h = _cancelBtn.height;
            CGFloat x = self.width - w - kViewMargin;
            CGFloat y = kBtnTopMargin;
            _sendBtn.frame = CGRectMake(x, y, w, h);
        }
        
        {
            _separatorLine.frame = CGRectMake(0, 0, self.width, 0.5f);
        }
        
    }
    [super layoutSubviews];
}

#pragma mark - 按钮点击

- (void)sendClicked {
    if (_myFilesBottomViewSendClicked) {
        _myFilesBottomViewSendClicked();
    }
}

- (void)cancelClicked {
    if (_myFilesBottomViewCancelClicked) {
        _myFilesBottomViewCancelClicked();
    }
}

#pragma mark - 外部方法

- (void)setNumOfSelectedFielsWithNum:(NSInteger)num {
    if (num > 0) {
        [_sendBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",SY_STRING(@"file_management_send_btn"),num] forState:UIControlStateNormal];
    }else {
        [_sendBtn setTitle:SY_STRING(@"file_management_send_btn") forState:UIControlStateNormal];
    }
}

@end
