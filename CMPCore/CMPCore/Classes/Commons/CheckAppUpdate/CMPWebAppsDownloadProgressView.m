//
//  CMPWebAppsDownloadProgressView.m
//  M3
//
//  Created by CRMO on 2018/12/24.
//

#import "CMPWebAppsDownloadProgressView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/NSObject+Thread.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPWebAppsDownloadProgressView()

/** 下载进度条 **/
@property (strong, nonatomic) UIProgressView *progress;
/** 下载文字进度 **/
@property (strong, nonatomic) UILabel *progressLabel;
/** 下载错误图片 **/
@property (strong, nonatomic) UIImageView *errorImage;
/** 提示文字 **/
@property (strong, nonatomic) UILabel *tipLable;
/** 重新下载按钮 **/
@property (strong, nonatomic) UIButton *retryButton;
/** 重试按钮点击事件 **/
@property (copy, nonatomic) CMPWebAppsDownloadProgressViewRetry retryBlock;

@end

@implementation CMPWebAppsDownloadProgressView

#pragma mark-
#pragma mark Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    [self addSubview:self.progress];
    [self addSubview:self.progressLabel];
    [self addSubview:self.errorImage];
    [self addSubview:self.tipLable];
    [self addSubview:self.retryButton];
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.equalTo(6);
        make.leading.trailing.equalTo(self).inset(37);
    }];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.progress.mas_bottom).inset(8);
        make.width.equalTo(160);
        make.height.equalTo(20);
    }];
    [self.errorImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(170);
        make.height.equalTo(170);
    }];
    [self.tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.errorImage.mas_bottom);
        make.centerX.equalTo(self);
    }];
    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLable.mas_bottom).inset(20);
        make.width.equalTo(80);
        make.height.equalTo(30);
        make.centerX.equalTo(self);
    }];
}

- (void)layoutSubviews {
    UIInterfaceOrientation oritentation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(oritentation)) {
        [self.errorImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    } else if (UIInterfaceOrientationIsLandscape(oritentation)) {
        [self.errorImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self).centerOffset(CGPointMake(0, -20));
        }];
    }
    [super layoutSubviews];
}

#pragma mark-
#pragma mark API

- (void)showInView:(UIView *)view {
    [self dispatchAsyncToMain:^{
        [self _switchUpdateMode];
        [view addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }];
}

- (void)hide {
    [self dispatchAsyncToMain:^{
        [UIView animateWithDuration:1 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

- (void)updateProgress:(CGFloat )aProgress  animation:(BOOL)animation {
    [self dispatchAsyncToMain:^{
        [self _switchUpdateMode];
        [self.progress setProgress:aProgress animated:animation];
        self.progressLabel.text = [NSString stringWithFormat:SY_STRING(@"UpdatePackage_progress"), (int)(aProgress*100), "%"];
    }];
}

- (void)showErrorWithZipAppName:(NSString *)zipAppName retryAction:(CMPWebAppsDownloadProgressViewRetry)block {
    self.retryBlock = block;
    if (zipAppName.length) {
        if (![[zipAppName lowercaseString] containsString:@".zip"]) {
            zipAppName = [zipAppName stringByAppendingString:@".zip"];
        }
        _tipLable.text = [NSString stringWithFormat:@"%@%@",zipAppName,SY_STRING(@"UpdatePackage_updateFail")];
    }
    [self dispatchSyncToMain:^{
        [self _switchErrorMode];
    }];
}

#pragma mark-
#pragma mark 私有方法

- (void)_switchUpdateMode {
    self.progress.hidden = NO;
    self.progressLabel.hidden = NO;
    self.errorImage.hidden = YES;
    self.tipLable.hidden = YES;
    self.retryButton.hidden = YES;
}

- (void)_switchErrorMode {
    self.progress.hidden = YES;
    self.progressLabel.hidden = YES;
    self.errorImage.hidden = NO;
    self.tipLable.hidden = NO;
    self.retryButton.hidden = NO;
}

- (void)_tapRetry {
    if (_retryBlock) {
        _retryBlock();
    }
}

#pragma mark-
#pragma mark Getter

- (UIProgressView *)progress {
    if (!_progress) {
        _progress = [[UIProgressView alloc] init];
        [_progress.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = 3;
        }];
        _progress.progressTintColor = [UIColor cmp_colorWithName:@"theme-bgc"];
        _progress.trackTintColor = [UIColor cmp_colorWithName:@"input-bg"];
        _progress.layer.cornerRadius = 3;
        _progress.layer.masksToBounds = YES;
    }
    return _progress;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont systemFontOfSize:14];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.text = [SY_STRING(@"UpdatePackage_TipTitle_IsDownload") stringByAppendingString:@"..."];
        _progressLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    }
    return _progressLabel;
}

- (UIImageView *)errorImage {
    if (!_errorImage) {
        _errorImage = [[UIImageView alloc] init];
        _errorImage.image = [UIImage imageWithName:@"update_error" type:@"png" inBundle:@"CMPLogin"];
    }
    return _errorImage;
}

- (UILabel *)tipLable {
    if (!_tipLable) {
        _tipLable = [[UILabel alloc] init];
        _tipLable.font = [UIFont systemFontOfSize:16];
        _tipLable.textAlignment = NSTextAlignmentCenter;
        _tipLable.text = SY_STRING(@"UpdatePackage_updateFail");
        _tipLable.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    }
    return _tipLable;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [[UIButton alloc] init];
        [_retryButton setTitle:SY_STRING(@"UpdatePackage_ReDownload") forState:UIControlStateNormal];
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _retryButton.titleLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        _retryButton.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
        _retryButton.layer.cornerRadius = 15;
        _retryButton.layer.masksToBounds = YES;
        [_retryButton addTarget:self action:@selector(_tapRetry) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}

@end
