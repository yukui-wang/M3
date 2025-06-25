//
//  XZQAFileView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/22.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAFileView.h"
#import "SPTools.h"

@interface XZQAFileView() {
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_sizeLabel;
}
@property (nonatomic, retain) XZQAFileModel *model;
@end


@implementation XZQAFileView

- (void)setup {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_titleLabel setFont:FONTSYS(15)];
        [_titleLabel setTextColor:UIColorFromRGB(0x333333)];
        [self addSubview:_titleLabel];
    }
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        [_sizeLabel setBackgroundColor:[UIColor clearColor]];
        [_sizeLabel setFont:FONTSYS(12)];
        [_sizeLabel setTextColor:UIColorFromRGB(0x939393)];
        [self addSubview:_sizeLabel];
    }
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFile)];
    [self addGestureRecognizer:tap];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setupInfo:(XZQAFileModel *)info {
    self.model = info;
    [_titleLabel setText:info.filename];
    [_sizeLabel setText:[SPTools fileSizeFormat:info.fileSize]];
    UIImage* image = [SPTools imageWithType:info.type];
    [_imageView setImage:image];
}

- (void)customLayoutSubviews {
    [_imageView setFrame:CGRectMake(18, 14, 42, 42)];
    CGFloat width = self.width-70-10;
    [_titleLabel setFrame:CGRectMake(70, 13, width, _titleLabel.font.lineHeight)];
    [_sizeLabel setFrame:CGRectMake(70, 43, width, _sizeLabel.font.lineHeight)];
    
}

- (void)clickFile {
    XZQAFileModel *model = (XZQAFileModel *)self.model;
    if (model.clickFileBlock) {
        model.clickFileBlock(model);
    }
}

+ (CGFloat)viewHeight {
    return 80;
}

@end
