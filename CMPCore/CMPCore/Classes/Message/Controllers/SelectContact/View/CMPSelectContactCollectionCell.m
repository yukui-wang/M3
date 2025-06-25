//
//  CMPSelectContactCollectionCell.m
//  M3
//
//  Created by Shoujian Rao on 2023/8/31.
//

#import "CMPSelectContactCollectionCell.h"

@interface CMPSelectContactCollectionCell()



@end

@implementation CMPSelectContactCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
//        self.textLabel.backgroundColor = UIColor.lightTextColor;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.numberOfLines = 1; // 支持多行文本
        self.textLabel.textColor = UIColor.blackColor;
        self.textLabel.font = [UIFont systemFontOfSize:14];
        
        [self.contentView addSubview:self.textLabel];
        
        self.textLabel.layer.cornerRadius = 15;
        self.textLabel.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 更新UILabel的frame
    self.textLabel.frame = self.contentView.bounds;
}
@end
