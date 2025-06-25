//
//  CMPSelContactPushCell.m
//  M3
//
//  Created by wujiansheng on 2018/6/25.
//

#import "CMPSelContactPushCell.h"
#import <CMPLib/CMPThemeManager.h>

@implementation CMPSelContactPushCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_infoLabel);
    SY_RELEASE_SAFELY(_pushView);
    [super dealloc];
}

- (void)setup {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc]init];
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.font = FONTSYS(16);
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        [self addSubview:_infoLabel];
    }
    if (!_pushView) {
        _pushView = [[UIImageView alloc] init];
        _pushView.image = [UIImage imageWithName:@"login_server_arrow" inBundle:@"CMPLogin"];
        [self addSubview:_pushView];
    }
    self.separatorImageView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    self.separatorLeftMargin = 14;
    self.selectionStyle  = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
}
- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGFloat x = 14;
    [_infoLabel setFrame:CGRectMake(x, 0, self.width - x -22, self.height)];
    [_pushView setFrame:CGRectMake(self.width - 22, (self.height - 14) * 0.5, 9, 14)];
}


@end
