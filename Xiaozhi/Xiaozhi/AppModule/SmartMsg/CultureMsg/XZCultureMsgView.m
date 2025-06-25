//
//  XZCultureMsgView.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZCultureMsgView.h"
#import "XZCultureMsg.h"
#import "XZCore.h"

@implementation XZCultureMsgView

- (void)dealloc {
    SY_RELEASE_SAFELY(_imageView);
    SY_RELEASE_SAFELY(_contentLabel);
    [super dealloc];
}

- (id)initWithMsg:(XZCultureMsg *)msg {
    if (self = [super initWithMsg:msg]) {
        NSURL *url = [NSURL URLWithString:[XZCore fullUrlForPath:msg.imgUrl]];
        _imageView.image =  [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];//{717, 855}
        _contentLabel.text = msg.content;
    }
    return self;
}

- (void)setup {
    [super setup];
    [_titleLabel setTextColor:UIColorFromRGB(0xE88786)];
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self addSubview:_scrollView];
    }
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_imageView];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setTextColor:UIColorFromRGB(0x3B496A)];
        [_contentLabel setFont:FONTSYS(16)];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.numberOfLines = 2;
        [_scrollView addSubview:_contentLabel];
    }
}

- (void)customLayoutSubviews {
    if (self.width == 0) {
        return;
    }
    [super customLayoutSubviews];
    NSInteger y = IS_PHONE_Landscape ? 20 : CGRectGetMaxY(_titleLabel.frame);
    [_scrollView setFrame:CGRectMake(0, y, self.width, self.height-y)];
   
    CGFloat h = IS_PHONE_Landscape ? 20 : (_scrollView.height - 286- 40)/2;
    y = h;
    [_imageView setFrame:CGRectMake(self.width/2-120, y, 240, 286)];
    y += _imageView.height+h;
    [_contentLabel setFrame:CGRectMake(5, y, self.width-10, 40)];
    y += _contentLabel.height;
    [_scrollView setContentSize:CGSizeMake(_scrollView.width, IS_PHONE_Landscape?y+20:y)];
}


@end
