//
//  CMPAppViewItem.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/11.
//

#import "CMPAppViewItem.h"
#import <CMPLib/UIImageView+WebCache.h>

@implementation CMPAppModel
-(BOOL)isScanCodeApp
{
    return (/*[@"Scanning code" isEqualToString:_appName] || */[@"" isEqualToString:_appId]);
}
@end

@interface CMPAppViewItem()

@end

@implementation CMPAppViewItem

- (void)setup {
    
    [super setup];
    
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    
    UIView *contentV = [[UIView alloc] init];
    contentV.backgroundColor = [UIColor clearColor];
    contentV.tag = 111;
    [self addSubview:contentV];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(10);
        make.bottom.right.offset(-10);
    }];
    
    if (!_iconBgView) {
        _iconBgView = [[UIView alloc] init];
        _iconBgView.backgroundColor = [UIColor clearColor];
        _iconBgView.alpha = 0.1;
        _iconBgView.layer.cornerRadius = 8;
        [contentV addSubview:_iconBgView];
        [_iconBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
            make.height.mas_equalTo(_iconBgView.mas_width).multipliedBy(1);
        }];
    }
    
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.backgroundColor = [UIColor clearColor];
        _iconView.alpha = 1;
        [contentV addSubview:_iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_iconBgView);
            make.width.mas_equalTo(_iconBgView.mas_width).multipliedBy(0.5);
            make.height.mas_equalTo(_iconView.mas_width).multipliedBy(1);
        }];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = FONTBOLDSYS(12);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
        [_titleLabel sizeToFit];
        _titleLabel.numberOfLines = 0;
        [contentV addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.bottom.equalTo(contentV.mas_bottom);
        }];
    }
    
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc]init];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.font = [UIFont systemFontOfSize:13];
        _badgeLabel.backgroundColor = [UIColor redColor];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.layer.cornerRadius = 10;
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.clipsToBounds = YES;
        [_badgeLabel sizeToFit];
        [contentV addSubview:_badgeLabel];
        [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_iconBgView.mas_right).offset(0);
            make.centerY.equalTo(_iconBgView.mas_top).offset(0);
            make.width.mas_greaterThanOrEqualTo(20);
            make.height.mas_equalTo(_badgeLabel.mas_width).multipliedBy(1);
        }];
    }
    
    _iconBgView.userInteractionEnabled = NO;
    _iconView.userInteractionEnabled = NO;
    _titleLabel.userInteractionEnabled = NO;
    _badgeLabel.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAction)];
    [self addGestureRecognizer:tap];
}

-(void)setModel:(CMPAppModel *)model
{
    _model = model;
    
    _titleLabel.text = _model.appName;
    _badgeLabel.text = [NSString stringWithFormat:@"%ld",(long)_model.unread];
    _badgeLabel.hidden = !(_model.unread > 0);
    _iconBgView.backgroundColor = [UIColor cmp_colorWithName:_model.iconBgColor];
//    if ([_model isScanCodeApp]) {
//        [_iconView setImage:[UIImage imageNamed:@"login_view_scan_qrcode_blue_icon"]];
//    }else{
        NSString *server = [CMPCore sharedInstance].serverurl;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:[server stringByAppendingString:_model.iconUrl?:@""]] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
        }];
//    }
}

-(void)updateTheme:(NSInteger)theme
{
    _iconBgView.alpha = (theme == 2) ? 0.2 : 0.1;
}

-(void)_tapAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(cmpAppViewItem:didAction:model:ext:)]) {
        [_delegate cmpAppViewItem:self didAction:1 model:_model ext:nil];
    }
}

@end
