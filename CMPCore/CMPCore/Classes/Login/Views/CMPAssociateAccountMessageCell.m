//
//  CMPAssociateAccountMessageCell.m
//  M3
//
//  Created by CRMO on 2018/6/26.
//

#import "CMPAssociateAccountMessageCell.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPThemeManager.h>

static const CGFloat kNameLabelMarginLeft = 14;
static const CGFloat kNameLabelHeight = 22;
static const CGFloat kUnreadViewHeight = 10;
static const CGFloat kUnreadViewWidht = 10;
static const CGFloat kUnreadViewMarginRight = 13;

@interface CMPAssociateAccountMessageCell()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIView *unreadView;
@property (strong, nonatomic) UIView *underline;

@end

@implementation CMPAssociateAccountMessageCell

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
    [self addSubview:self.underline];
    [self addSubview:self.unreadView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    CGFloat nameLabelMarginRight = 0;
    if (!_unreadView.hidden) {
        nameLabelMarginRight = kUnreadViewWidht + kUnreadViewMarginRight + 8;
    }
    
    CGFloat nameLabely = (self.cmp_height - kNameLabelHeight) / 2;
    CGFloat nameLabelWidth = self.cmp_width - kNameLabelMarginLeft - nameLabelMarginRight;
    _nameLabel.cmp_y = nameLabely;
    _nameLabel.cmp_width = nameLabelWidth;
    
    CGFloat unreadLabelX = self.cmp_width - kUnreadViewMarginRight - kUnreadViewWidht;
    CGFloat unreadLabelY = (self.cmp_height - kUnreadViewHeight) / 2;
    _unreadView.cmp_x = unreadLabelX;
    _unreadView.cmp_y = unreadLabelY;
    
    CGFloat underlineWidth = self.cmp_width - kNameLabelMarginLeft;
    CGFloat underlineY = self.cmp_height - 1;
    _underline.cmp_width = underlineWidth;
    _underline.cmp_y = underlineY;
}

#pragma mark-
#pragma mark Getter & Setter

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;
}

- (void)setShowUnread:(BOOL)showUnread {
    _showUnread = showUnread;
    self.unreadView.hidden = !showUnread;
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

- (UIView *)unreadView {
    if(!_unreadView) {
        _unreadView = [[UILabel alloc] init];
        _unreadView.cmp_height = kUnreadViewHeight;
        _unreadView.cmp_width = kUnreadViewWidht;
        _unreadView.backgroundColor = [UIColor cmp_colorWithName:@"hl-bgc3"];
        _unreadView.layer.cornerRadius = kUnreadViewHeight / 2;
        _unreadView.layer.masksToBounds = YES;
    }
    return _unreadView;
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

