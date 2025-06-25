//
//  XZGuideTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2018/1/4.
//

#import "XZGuideTableViewCell.h"
#import "XZGuideMode.h"

@interface XZGuideTableViewCell() {
    UILabel *_titleLabel;
    UILabel *_contentLabel;
    UIButton *_moreBtn;
}

@end

@implementation XZGuideTableViewCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_titleLabel)
    SY_RELEASE_SAFELY(_contentLabel)
    [super dealloc];
}

- (void)setup {
    [super setup];
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FONTSYS(16);
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        [_contentBGView addSubview:_titleLabel];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = FONTSYS(16);
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        [_contentBGView addSubview:_contentLabel];
    }
}

- (void)addmMoreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_moreBtn setTitle:@"查看更多" forState:UIControlStateNormal];
        [_moreBtn setTitleColor:UIColorFromRGB(0x0075ff) forState:UIControlStateNormal];
        
        UIImage *image = XZ_IMAGE(@"xz_view_more.png");
        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationRight];
        [_moreBtn setImage:image forState:UIControlStateNormal];
        
        UIImage *imageh = XZ_IMAGE(@"xz_view_more_h.png");
        imageh = [UIImage imageWithCGImage:imageh.CGImage scale:2 orientation:UIImageOrientationRight];
        [_moreBtn setImage:imageh forState:UIControlStateHighlighted];
        [_moreBtn addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_contentBGView addSubview:_moreBtn];
    }
}

- (void)moreBtnClicked:(id)sender {
    XZGuideMode *aModel = (XZGuideMode *)self.model;
    [aModel moreBtnClick];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [super customLayoutSubviewsFrame:frame];
    XZGuideMode *model = (XZGuideMode *)self.model;
    CGFloat y = 10;
    NSInteger h = _titleLabel.font.lineHeight+1;
    [_titleLabel setFrame:CGRectMake(18, y, model.lableWidth, h)];
    y += _titleLabel.height;
    h = _moreBtn ?_contentBGView.height-y-5-30:_contentBGView.height-y-5;// 5为_titleLabel空白 30为更多按钮+10
    [_contentLabel setFrame:CGRectMake(18, y, model.lableWidth, h)];
    
    if (_moreBtn) {
        [_moreBtn setFrame:CGRectMake(8, CGRectGetMaxY(_contentLabel.frame), _contentBGView.width-10, 20)];
        UIImage *image = XZ_IMAGE(@"xz_view_more.png");
        CGFloat titleWidth = [_moreBtn.titleLabel.text sizeWithFontSize:_moreBtn.titleLabel.font defaultSize:CGSizeMake(320, 100)].width;
        CGFloat imageWidth = image.size.width;
        [_moreBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth-5, 0, imageWidth+5)];
        [_moreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, titleWidth+5, 0, -titleWidth-5)];
    }
}

- (void)setModel:(XZGuideMode *)model {
    [super setModel:model];
    _titleLabel.text = model.contentInfo;
    _contentLabel.attributedText = model.guideInfo;
    if (model.showMore) {
        [self addmMoreBtn];
    }
    else {
        [_moreBtn removeFromSuperview];
        _moreBtn = nil;
    }
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
