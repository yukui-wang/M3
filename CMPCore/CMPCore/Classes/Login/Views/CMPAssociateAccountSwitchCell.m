//
//  CMPAssociateAccountSwitchCell.m
//  M3
//
//  Created by CRMO on 2018/6/19.
//

#import "CMPAssociateAccountSwitchCell.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIView+RTL.h>
#import <CMPLib/CMPThemeManager.h>

static const CGFloat kNameLabelMarginLeft = 14;
static const CGFloat kNameLabelHeight = 22;
static const CGFloat kCheckIconHeight = 12;
static const CGFloat kCheckIconMarginRight = 16;
static NSString * const kUnderlineColor = @"ECECEC";

@interface CMPAssociateAccountSwitchCell()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *serverLabel;
@property (strong, nonatomic) UIImageView *checkIcon;
@property (strong, nonatomic) UIView *underline;

@end

@implementation CMPAssociateAccountSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

#pragma mark-
#pragma mark-UI布局

- (void)initView {
    [self setBackgroundColor:[UIColor cmp_colorWithName:@"white-bg"]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.nameLabel];
    [self addSubview:self.serverLabel];
    [self addSubview:self.underline];
    [self addSubview:self.checkIcon];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    CGFloat nameLabelMarginRight = 0;
    if (!_checkIcon.hidden) {
        nameLabelMarginRight = kCheckIconHeight + kCheckIconMarginRight + 8;
    }
    
    CGFloat nameLabely = 12;
    CGFloat nameLabelWidth = self.cmp_width - kNameLabelMarginLeft - nameLabelMarginRight;
    _nameLabel.cmp_y = nameLabely;
    _nameLabel.cmp_width = nameLabelWidth;
    
    _serverLabel.cmp_y = _nameLabel.cmp_y + _nameLabel.cmp_height + 4;
    _serverLabel.cmp_width = _nameLabel.cmp_width;
    
    CGFloat checkIconx = self.cmp_width - kCheckIconMarginRight - kCheckIconHeight;
    CGFloat checkIcony = (self.cmp_height - kCheckIconHeight) / 2;
    _checkIcon.cmp_x = checkIconx;
    _checkIcon.cmp_y = checkIcony;
    
    CGFloat underlineWidth = self.cmp_width - kNameLabelMarginLeft;
    CGFloat underlineY = self.cmp_height - 1;
    _underline.cmp_width = underlineWidth;
    _underline.cmp_y = underlineY;
    
    [_nameLabel resetFrameToFitRTL];
    [_serverLabel resetFrameToFitRTL];
    [_checkIcon resetFrameToFitRTL];
    [_underline resetFrameToFitRTL];
}

- (void)showBottomLine {
    self.underline.hidden = NO;
}

- (void)hideBottomLine {
    self.underline.hidden = YES;
}

#pragma mark-
#pragma mark Getter & Setter

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;
}

- (void)setServer:(NSString *)server {
    _server = server;
    if ([NSString isNull:server]) {
        self.serverLabel.hidden = YES;
    } else {
        self.serverLabel.text = server;
    }
}

- (void)setShowCheck:(BOOL)showCheck {
    _showCheck = showCheck;
    self.checkIcon.hidden = !showCheck;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _nameLabel.cmp_x = kNameLabelMarginLeft;
        _nameLabel.cmp_height = kNameLabelHeight;
    }
    return _nameLabel;
}

- (UILabel *)serverLabel {
    if (!_serverLabel) {
        _serverLabel = [[UILabel alloc] init];
        _serverLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _serverLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _serverLabel.cmp_x = kNameLabelMarginLeft;
        _serverLabel.cmp_height = 15;
    }
    return _serverLabel;
}

- (UIImageView *)checkIcon {
    if (!_checkIcon) {
        _checkIcon = [[UIImageView alloc] init];
        [_checkIcon setImage:[[CMPThemeManager sharedManager] skinColorImageWithImage:[UIImage imageWithName:@"ass_check" inBundle:@"CMPLogin"]]];
        _checkIcon.cmp_height = kCheckIconHeight;
        _checkIcon.cmp_width = kCheckIconHeight;
    }
    return _checkIcon;
}

- (UIView *)underline {
    if (!_underline) {
        _underline = [[UIView alloc] init];
        _underline.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
        _underline.cmp_height = 1;
        _underline.cmp_x = kNameLabelMarginLeft;
    }
    return _underline;
}

@end
