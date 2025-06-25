//
//  CMPPicListHeaderView.m
//  CMPLib
//
//  Created by MacBook on 2019/12/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPPicListHeaderView.h"
#import "UIView+CMPView.h"
#import "UIColor+Hex.h"

NSString * const CMPPicListHeaderViewId = @"CMPPicListHeaderViewId";

@interface CMPPicListHeaderView()

/* textLabel */
@property (strong, nonatomic) UILabel *textLabel;

@end

@implementation CMPPicListHeaderView

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel.alloc initWithFrame:CGRectMake(14.f, 0, self.width - 28.f, self.height)];
        _textLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.font = [UIFont systemFontOfSize:12.f];
    }
    return _textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.textLabel];
        if (_title) {
            _textLabel.text = _title;
        }else {
            _textLabel.text = @"";
        }
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title.copy;
    if (title) {
       _textLabel.text = title;
    }else {
        _textLabel.text = @"";
    }
    
}

@end
