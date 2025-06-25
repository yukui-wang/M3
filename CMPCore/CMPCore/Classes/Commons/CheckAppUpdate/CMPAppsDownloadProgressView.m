//
//  CMPAppsDownloadView.m
//  M3
//
//  Created by youlin on 2018/6/14.
//

#import "CMPAppsDownloadProgressView.h"
#import "CMPCheckUpdateManager.h"
#import <CMPLib/Masonry.h>
#import "M3LoginManager.h"
#import <CMPLib/CMPLoginDBProvider.h>

@interface CMPAppsDownloadProgressView ()
{
    UILabel *_tipInfoLbl;
    UIActivityIndicatorView *_activityIndicatorView;
    UIImageView *_iconImageView;
    UILabel *_errorLabel;
    UIButton *_errorButton;
}

@property (nonatomic,strong) UIView *errorInfoBgView;
@property (nonatomic,strong) UILabel *errorJoinLabel;
@property (nonatomic,strong) UIButton *errorLogoutButton;


@end

@implementation CMPAppsDownloadProgressView

- (void)dealloc
{
    [_tipInfoLbl release];
    _tipInfoLbl = nil;
    
    [_activityIndicatorView stopAnimating];
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
    
    [_iconImageView removeFromSuperview];
    [_iconImageView release];
    _iconImageView = nil;
    
    [_errorLabel release];
    _errorLabel = nil;
    
    _errorButton = nil;
    
    [_errorInfoBgView release];
    _errorInfoBgView = nil;
    
    [super dealloc];
}

- (void)setup
{
    self.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activityIndicatorView.hidesWhenStopped = NO;
        [_activityIndicatorView startAnimating];
        [self addSubview:_activityIndicatorView];
    }
    if (!_tipInfoLbl) {
        _tipInfoLbl = [[UILabel alloc] init];
        _tipInfoLbl.backgroundColor = [UIColor clearColor];
        _tipInfoLbl.font = [UIFont systemFontOfSize:12.0f];
        _tipInfoLbl.textAlignment = NSTextAlignmentLeft;
        _tipInfoLbl.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        _tipInfoLbl.text = [SY_STRING(@"UpdatePackage_TipTitle_IsDownload") stringByAppendingString:@"..."];
        [self addSubview:_tipInfoLbl];
    }
    
    
    // error
    self.errorInfoBgView = [[[UIView alloc] init] autorelease];
    [self addSubview:self.errorInfoBgView];
    self.errorInfoBgView.hidden = YES;
    
    if (!_iconImageView) {
        UIImage *aImage = [UIImage imageWithName:@"ass_tip" inBundle:@"CMPLogin"];
        _iconImageView = [[UIImageView alloc] initWithImage:aImage];
        [self.errorInfoBgView addSubview:_iconImageView];
    }
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.backgroundColor = [UIColor clearColor];
        _errorLabel.font = [UIFont systemFontOfSize:14.0f];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        _errorLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
        _errorLabel.text = [NSString stringWithFormat:@"%@ ",SY_STRING(@"common_appDownloadFail")];
        [self.errorInfoBgView addSubview:_errorLabel];
    }
    if (!_errorButton) {
        _errorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_errorButton setTitle:SY_STRING(@"UpdatePackage_ReDownload")  forState:UIControlStateNormal];
//        [_errorButton setTitleColor:[UIColor cmp_colorWithName:@"hl-fc2"] forState:UIControlStateNormal];
        [_errorButton setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
        _errorButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _errorButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_errorButton addTarget:self action:@selector(errorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.errorInfoBgView addSubview:_errorButton];
    }
    if (!_errorJoinLabel) {
           _errorJoinLabel = [[UILabel alloc] init];
           _errorJoinLabel.backgroundColor = [UIColor clearColor];
           _errorJoinLabel.font = [UIFont systemFontOfSize:14.0f];
           _errorJoinLabel.textAlignment = NSTextAlignmentLeft;
           _errorJoinLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
           _errorJoinLabel.text = [NSString stringWithFormat:@" %@ ",SY_STRING(@"common_or")];
           [self.errorInfoBgView addSubview:_errorJoinLabel];
    }
    if (!_errorLogoutButton) {
            _errorLogoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_errorLogoutButton setTitle:SY_STRING(@"common_exit") forState:UIControlStateNormal];
    //        [_errorButton setTitleColor:[UIColor cmp_colorWithName:@"hl-fc2"] forState:UIControlStateNormal];
            [_errorLogoutButton setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
            _errorLogoutButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            _errorLogoutButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            [_errorLogoutButton addTarget:self action:@selector(errorLogoutButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.errorInfoBgView addSubview:_errorLogoutButton];
    }
    
    [self.errorInfoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.centerX.equalTo(self);
        make.leading.equalTo(_iconImageView.mas_leading);
        make.trailing.equalTo(_errorLogoutButton.mas_trailing);
    }];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.centerY.equalTo(self.errorInfoBgView);
        make.size.equalTo(CGSizeMake(14, 14));
    }];
    [_errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImageView.mas_trailing).offset(8);
        make.centerY.equalTo(self.errorInfoBgView);
    }];
    [_errorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_errorLabel.mas_trailing);
        make.centerY.equalTo(self.errorInfoBgView);
    }];
    [self.errorJoinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_errorButton.mas_trailing);
        make.centerY.equalTo(self.errorInfoBgView);
    }];
    [self.errorLogoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.errorJoinLabel.mas_trailing);
        make.centerY.trailing.equalTo(self.errorInfoBgView);
    }];
    
}

// 重新下载
- (void)errorButtonAction:(id)sender
{
    [[CMPCheckUpdateManager sharedManager] redownload];
}

// 退出到登录页
- (void)errorLogoutButton:(id)sender
{
    M3LoginManager *loginManager = [M3LoginManager sharedInstance];
    [loginManager logout];
    [[CMPCore sharedInstance].loginDBProvider clearLoginPasswordWithServerId:kCMP_ServerID];
    [loginManager showLoginViewControllerWithMessage:nil];
}

- (void)customLayoutSubviews
{
    CGSize tipSize = [self sizeWithText:_tipInfoLbl.text font:_tipInfoLbl.font maxSize:CGSizeMake(220, self.height)];
    CGFloat x = self.width/2 - tipSize.width/2 - 39/2;
    _activityIndicatorView.frame = CGRectMake(x, 5, 29, 29);
    _tipInfoLbl.frame = CGRectMake(x + 29, 0, tipSize.width, self.height);
}

- (void)showUpdateProgress
{
    self.errorInfoBgView.hidden = YES;
    // 显示现在进度信息
    _activityIndicatorView.hidden = NO;
    [_activityIndicatorView startAnimating];
    _tipInfoLbl.hidden = NO;
    self.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
//    [self customLayoutSubviews];
}

- (void)updateProgress:(CGFloat )aProgress
{
    if (_tipInfoLbl.hidden) {
        [self showUpdateProgress];
    }
    _tipInfoLbl.text = [NSString stringWithFormat:@"%@（%.0f%%）",SY_STRING(@"UpdatePackage_TipTitle_IsDownload"), aProgress];
    [self customLayoutSubviews];
}

- (void)showError:(NSError *)aError byZipAppName:(NSString *)zipAppName
{
    self.errorInfoBgView.hidden = NO;
    // 隐藏下载信息
    _tipInfoLbl.hidden = YES;
    _activityIndicatorView.hidden = YES;
    [_activityIndicatorView stopAnimating];
    if (zipAppName.length) {
        if (![[zipAppName lowercaseString] containsString:@".zip"]) {
            zipAppName = [zipAppName stringByAppendingString:@".zip"];
        }
        _errorLabel.text = [NSString stringWithFormat:@"%@%@ ",zipAppName,SY_STRING(@"common_appDownloadFail")];
    }
    self.backgroundColor = [UIColor cmp_colorWithName:@"errormask-bgc"];
    [self customLayoutSubviews];
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
