//
//  XZDialogTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2017/12/2.
//

#import "XZDialogTableViewCell.h"
#import "XZCore.h"
@interface XZDialogTableViewCell() {
}
@end

@implementation XZDialogTableViewCell


- (void)dealloc {
    SY_RELEASE_SAFELY(_iconView);
    SY_RELEASE_SAFELY(_contentBGView);
    [super dealloc];
}

- (void)setup {
    [super setup];
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 18;
        _iconView.layer.masksToBounds = YES;
        [self addSubview:_iconView];
    }
    if (!_contentBGView) {
        _contentBGView = [[UIImageView alloc] init];
        _contentBGView.userInteractionEnabled = YES;
        [self addSubview:_contentBGView];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame{
    XZTextModel *model = (XZTextModel *)self.model;
    CGFloat iconWidth = 36;
    if (model.chatCellType == ChatCellTypeUserMessage) {
        CGFloat bgwidth = model.lableWidth +31;
        CGFloat x = self.width-12-iconWidth-4- bgwidth;
        [_contentBGView setFrame:CGRectMake(x, 0, bgwidth, model.cellHeight-kXZCellSpace)];
        x += bgwidth+4;
        [_iconView setFrame:CGRectMake(x, 0, iconWidth, iconWidth)];
        _iconView.image = [XZCore sharedInstance].userProfileImage;
        _contentBGView.image = [XZ_IMAGE(@"xz_chat_user.png") resizableImageWithCapInsets:UIEdgeInsetsMake(19, 18, 19, 24)];
    }
    else {
        [_iconView setFrame:CGRectMake(12, 0, iconWidth, iconWidth)];
        [_contentBGView setFrame:CGRectMake(12+iconWidth+4, 0, model.lableWidth +31, self.height-kXZCellSpace)];
        _iconView.image = XZ_IMAGE(@"xz_icon_cell.png");
        _contentBGView.image = [XZ_IMAGE(@"xz_chat_robot.png") resizableImageWithCapInsets:UIEdgeInsetsMake(19, 24, 19, 18) resizingMode:UIImageResizingModeStretch];
    }
}

@end
