//
//  XZQAFileCell.m
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//

#import "XZPreQAFileCell.h"
#import "XZPreQAFileModel.h"
#import "SPTools.h"

//界面参照 RCFileMessageCell
@implementation XZPreQAFileCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_imageView);
    SY_RELEASE_SAFELY(_titleLabel);
    SY_RELEASE_SAFELY(_sizeLabel);

    [super dealloc];
}

- (void)setup {
    [super setup];
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_contentBGView addSubview:_imageView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_titleLabel setFont:FONTSYS(15)];
        [_titleLabel setTextColor:UIColorFromRGB(0x333333)];
        [_contentBGView addSubview:_titleLabel];
    }
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        [_sizeLabel setBackgroundColor:[UIColor clearColor]];
        [_sizeLabel setFont:FONTSYS(12)];
        [_sizeLabel setTextColor:UIColorFromRGB(0x939393)];
        [_contentBGView addSubview:_sizeLabel];
    }
    _contentBGView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFile)];
    [_contentBGView addGestureRecognizer:tap];
    SY_RELEASE_SAFELY(tap);
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    XZPreQAFileModel *model = (XZPreQAFileModel *)self.model;
    CGFloat iconWidth = 36;
    [_iconView setFrame:CGRectMake(12, 0, iconWidth, iconWidth)];
    [_contentBGView setFrame:CGRectMake(12+iconWidth+4, 0, model.contentBGWidth, self.height-kXZCellSpace)];
    _iconView.image = XZ_IMAGE(@"xz_icon_cell.png");
    _contentBGView.image = [XZ_IMAGE(@"xz_chat_robot.png") resizableImageWithCapInsets:UIEdgeInsetsMake(19, 24, 19, 18) resizingMode:UIImageResizingModeStretch];
    [_imageView setFrame:CGRectMake(18, 14, 42, 42)];
    CGFloat width = _contentBGView.width-70-10;
    [_titleLabel setFrame:CGRectMake(70, 13, width, _titleLabel.font.lineHeight)];
    [_sizeLabel setFrame:CGRectMake(70, 43, width, _sizeLabel.font.lineHeight)];

}


- (void)setModel:(XZPreQAFileModel *)model {
    [super setModel:model];
    [_titleLabel setText:model.filename];
    [_sizeLabel setText:[SPTools fileSizeFormat:model.fileSize]];
    UIImage* image = [SPTools imageWithType:model.type];
    [_imageView setImage:image]; 
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)clickFile {
    XZPreQAFileModel *model = (XZPreQAFileModel *)self.model;
    if (model.clickFileBlock) {
        model.clickFileBlock(model);
    }
}

@end
