//
//  CMPCopDrawerCollectionCell.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/13.
//

#import "CMPCopDrawerCollectionCell.h"
#import <CMPLib/CMPThemeManager.h>
@interface CMPCopDrawerCollectionCell()



@end

@implementation CMPCopDrawerCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        [self.contentView addSubview:_iconImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.numberOfLines = 2;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        self.iconImageView.frame = CGRectMake((self.contentView.frame.size.width - 24) / 2, 10, 24, 24);
        self.nameLabel.frame = CGRectMake(6, self.contentView.frame.size.height-38, self.contentView.frame.size.width-12,32);
    }
    return self;
}

@end
