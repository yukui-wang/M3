//
//  CMPNetworkTipView.m
//  M3
//
//  Created by youlin on 2018/1/4.
//

#import "CMPNetworkTipView.h"
#import <CMPLib/UIView+RTL.h>
#import <CMPLib/Masonry.h>

@interface CMPNetworkTipView()
{
}

@end

@implementation CMPNetworkTipView

- (void)dealloc
{
    [_imageView release];
    _imageView = nil;
    
    [_tipInfoLbl release];
    _tipInfoLbl = nil;
    
    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame andTip:(NSString *)tip{
    if (self = [super initWithFrame:frame]) {
        CGFloat w = frame.size.width;
        CGFloat h = frame.size.height;
        self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        bgView.backgroundColor = [UIColor cmp_colorWithName:@"errormask-bgc"];
        [self addSubview:bgView];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        
        if (!_tipInfoLbl) {
            _tipInfoLbl = [[UILabel alloc] init];
            _tipInfoLbl.font = [UIFont systemFontOfSize:14];
            _tipInfoLbl.textAlignment = NSTextAlignmentLeft;
            _tipInfoLbl.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
            [containerView addSubview:_tipInfoLbl];
            _tipInfoLbl.text = tip;
            [_tipInfoLbl sizeToFit]; // 根据文本内容调整label的大小
        }
        
        CGFloat totalWidth = 14+8+_tipInfoLbl.frame.size.width;
        CGFloat x = (frame.size.width - totalWidth)/2;
        
        if (!_imageView) {
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, (h-14)/2, 14, 14)];
            _imageView.image = [UIImage imageNamed:@"network_disconnect.png"];
            [containerView addSubview:_imageView];
        }
        
        _tipInfoLbl.frame = CGRectMake(CGRectGetMaxX(_imageView.frame)+8, 0, _tipInfoLbl.frame.size.width, h);

    }
    return self;
}

- (void)setup11
{
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 40)];
    bgView.backgroundColor = [UIColor cmp_colorWithName:@"errormask-bgc"];
    [self addSubview:bgView];
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:containerView];
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"network_disconnect.png"];
        [containerView addSubview:_imageView];
    }
    if (!_tipInfoLbl) {
        _tipInfoLbl = [[UILabel alloc] init];
        _tipInfoLbl.font = [UIFont systemFontOfSize:14];
        _tipInfoLbl.textAlignment = NSTextAlignmentLeft;
        _tipInfoLbl.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
        [containerView addSubview:_tipInfoLbl];
    }
    
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.centerY.mas_equalTo(containerView);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.tipInfoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.centerY.mas_equalTo(containerView);
        make.leading.mas_equalTo(self.imageView.mas_trailing).offset(8);
    }];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
}

@end
