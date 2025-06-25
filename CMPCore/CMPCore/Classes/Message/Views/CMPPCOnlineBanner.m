//
//  CMPPCOnlineBanner.m
//  M3
//
//  Created by CRMO on 2019/5/24.
//

#import "CMPPCOnlineBanner.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
#import "CMPOnlineDevModel.h"

@interface CMPPCOnlineBanner()
@property (strong, nonatomic) UIImageView *muteView;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UIView *line;
@end

@implementation CMPPCOnlineBanner

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
        
        self.containerView = [[UIView alloc] init];
        [self addSubview:self.containerView];
        
        [self.containerView addSubview:self.iconView];
        [self.containerView addSubview:self.textLabel];
        [self.containerView addSubview:self.muteView];
        
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
        [self.containerView addSubview:self.line];
        
//        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.bottom.centerX.equalTo(self);
//        }];
        
//        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.centerY.equalTo(containerView);
//            make.trailing.equalTo(self.textLabel.mas_leading).offset(-5);
//        }];
//        
//        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.trailing.centerY.equalTo(containerView);
//            make.height.equalTo(30);
//        }];
//        [line mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(containerView);
//            make.trailing.leading.equalTo(self);
//            make.height.equalTo(0.5);
//        }];
        
//        [self.muteView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(14, 14));
//            make.centerY.equalTo(self.containerView);
//            make.trailing.equalTo(self.iconView.mas_leading).offset(-8);
//        }];
        
    }
    return self;
}

-(void)updateTipMessageWithOnlineModel:(CMPOnlineDevModel*)model muteState:(BOOL)isMute{
    if (!model) {
        return;
    }
    _textLabel.text = model.messagePageTip;
    [_textLabel sizeToFit];
    if (model.isMultiOnline) {
        if ([model isOnlyPhoneOnline]) {
            _iconView.image = [[UIImage imageNamed:@"msg_phoneonline"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
        }
        else if ([model isOnlyPadOnline]) {
            _iconView.image = [[UIImage imageNamed:@"msg_padonline"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
        }
        else {
            _iconView.image = [[UIImage imageNamed:@"msg_pconline"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
        }
    }else{
        _iconView.image = [UIImage imageNamed:@""];
    }
    
    _muteView.hidden = !isMute;
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    self.containerView.frame = CGRectMake(0, 0, w, h);
    if (_muteView.hidden){
        CGFloat totalW = 14 + 8 + self.textLabel.frame.size.width;
        CGFloat x = (w - totalW)/2;

        self.iconView.frame = CGRectMake(x, (h-14)/2, 14, 14);
    }else{
        CGFloat totalW =14+8+ 14 + 8 + self.textLabel.frame.size.width;
        CGFloat x = (w - totalW)/2;
        self.muteView.frame = CGRectMake(x, (h-14)/2, 14, 14);
        self.iconView.frame = CGRectMake(CGRectGetMaxX(self.muteView.frame)+8, (h-14)/2, 14, 14);
    }
    
    CGFloat xx = CGRectGetMaxX(self.iconView.frame) + 8;
    self.textLabel.frame = CGRectMake(xx, 0, w - xx, h);
    self.line.frame = CGRectMake(0, h-0.5, w, 0.5);
    
    [self layoutSubviews];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
//    UIView *containerV = _textLabel.superview;
//    CGPoint c = containerV.center;
//    if (_muteView.hidden){
//        c.x = self.center.x;
//    }else{
//        c.x = self.center.x+11;
//    }
//    containerV.center = c;
}

- (UIImageView *)muteView {
    if (!_muteView) {
        _muteView = [[UIImageView alloc] init];
        _muteView.image = [[UIImage imageNamed:@"msg_jingyin"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
        _muteView.hidden = YES;
    }
    return _muteView;
}

- (void)setTip:(NSString *)tip{
    self.textLabel.text = tip;
    [self.textLabel sizeToFit];
    [self layoutSubviews];
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [[UIImage imageNamed:@"msg_pconline"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]];
    }
    return _iconView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.text = @"";
    }
    return _textLabel;
}

@end
