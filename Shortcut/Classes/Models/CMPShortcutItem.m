//
//  CMPQuickModuleItem.m
//  CMPCore
//
//  Created by wujiansheng on 2017/7/5.
//
//

#import "CMPShortcutItem.h"

@implementation CMPShortcutItemModel


@end

@interface CMPShortcutItem()

@property (strong, nonatomic) UIView *imageBKView;
/* topIconView */
@property (strong, nonatomic) UIImageView *topIconView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation CMPShortcutItem

- (void)setup {
    if (!_imageBKView) {
        _imageBKView = [[UIView alloc] init];
        _imageBKView.layer.cornerRadius = 35;
        _imageBKView.clipsToBounds = YES;
        [self addSubview:_imageBKView];
    }
    
    if (!_topIconView) {
        _topIconView= [[UIImageView alloc] init];
        [self addSubview:_topIconView];
    }
    
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = FONTBOLDSYS(12);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
        [self addSubview:_titleLabel];
    }
    
    _imageBKView.userInteractionEnabled = NO;
    _iconView.userInteractionEnabled = NO;
    _titleLabel.userInteractionEnabled = NO;
}

- (void)customLayoutSubviews {
    [_imageBKView setFrame:CGRectMake(self.width/2-35, 0, 70, 70)];
    [_topIconView setFrame:_imageBKView.frame];
   
    CGSize imageSize = _iconView.image.size;
    [_iconView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    _iconView.center = _imageBKView.center;
    [_titleLabel setFrame:CGRectMake(0, _imageBKView.height +10, self.width, _titleLabel.font.lineHeight+1)];
    
    if (!CMPThemeManager.sharedManager.isDisplayDrak) {
        _topIconView.cmp_width = _imageBKView.width + 20;
        _topIconView.cmp_height = _imageBKView.height + 20;
        _topIconView.cmp_x -= 10;
        
        _titleLabel.cmp_x = _topIconView.cmp_x;
        
    }
}

- (void)setInfo:(CMPShortcutItemModel *)info {
    _info = info;
    
    _titleLabel.text = SY_STRING(info.appName);
    _imageBKView.backgroundColor = info.color;
    if (CMPCore.sharedInstance.serverIsLaterV8_0 && [[CMPFeatureSupportControl quickModuleTopList] containsObject:info.appName]) {
        //新版本新界面
        _topIconView.image = info.icon;
        _imageBKView.hidden = YES;
        
    }else {
        _iconView.image = info.icon;
        _topIconView.hidden = YES;
    }
}

+ (CGFloat)defaultWidth {
    return 90;
}

+ (CGFloat)defaultHeight {
    NSInteger h = FONTSYS(12).lineHeight +1;
    return 70+ 10+ h;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_info) return;
    
    if (CMPCore.sharedInstance.serverIsLaterV8_0 && [[CMPFeatureSupportControl quickModuleTopList] containsObject:_info.appName] && !CMPThemeManager.sharedManager.isDisplayDrak) {
        _titleLabel.cmp_y += 10;
    }
}

@end
