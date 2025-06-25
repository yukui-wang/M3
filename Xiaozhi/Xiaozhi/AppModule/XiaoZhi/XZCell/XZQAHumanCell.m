//
//  XZQAHumanCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAHumanCell.h"
#import "XZQAHumanModel.h"
#import "SPConstant.h"
#import "XZSpeechLoadingView.h"
@interface XZQAHumanCell () {
    UIView *_touchView;
    UIImageView *_editView;
    UIImageView *_bubbleView;
    UILabel *_contentLabel;
    XZSpeechLoadingView *_loadingView;
}

@end

@implementation XZQAHumanCell

- (void)setup {
    if (!_touchView) {
        _touchView = [[UIView alloc] init];
        [self addSubview:_touchView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editText)];
        [_touchView addGestureRecognizer:tap];
    }
    if (!_editView) {
        _editView = [[UIImageView alloc] initWithImage:XZ_IMAGE(@"xz_qa_edit.png")];
        [_touchView addSubview:_editView];
    }
    if (!_bubbleView) {
        _bubbleView = [[UIImageView alloc] init];
        [_touchView addSubview:_bubbleView];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = FONTSYS(16);
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        [_bubbleView addSubview:_contentLabel];
    }
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    [self setSelectBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSpace:)];
    [self addGestureRecognizer:tap];
    self.separatorHide = YES;
}
- (void)showLoadingView {
    if (!_loadingView) {
        _loadingView = [[XZSpeechLoadingView alloc] initWithFrame:CGRectMake(10,10, [XZSpeechLoadingView defWidth], 40)];
        [self addSubview:_loadingView];
    }
    [_loadingView show];
}

- (void)hideLoadingView {
    [_loadingView hide];
}


- (void)customLayoutSubviewsFrame:(CGRect)frame {
    if (!self.model) {
        return;
    }
    XZQAHumanModel *model = (XZQAHumanModel *)self.model;
    CGSize bubbleSize = model.bubbleSize;
    CGFloat twidth = 12+6+bubbleSize.width;
    [_touchView setFrame:CGRectMake(self.width-twidth-10, 10, twidth, bubbleSize.height)];
    [_editView setFrame:CGRectMake(0, bubbleSize.height/2-6, 12, 12)];
    [_bubbleView setFrame:CGRectMake(18, 0, bubbleSize.width, bubbleSize.height)];
    [_contentLabel setFrame:CGRectMake(10, 10, bubbleSize.width-26, bubbleSize.height-20)];
    _bubbleView.image = [XZ_IMAGE(@"xz_qa_h_b.png") resizableImageWithCapInsets:UIEdgeInsetsMake(25, 11, 16, 30)];
    _loadingView.frame = CGRectMake(10, CGRectGetMaxY(_bubbleView.frame)+10, [XZSpeechLoadingView defWidth], 40);
}



- (void)setModel:(XZQAHumanModel *)model {
    [super setModel:model];
    _contentLabel.text = model.content;
    [self customLayoutSubviewsFrame:self.frame];
    if (model.showAnimation) {
        [self showLoadingView];
    }
    else {
        [self hideLoadingView];
    }
}

- (void)editText {
    if (!self.model) {
        return;
    }
    XZQAHumanModel *model = (XZQAHumanModel *)self.model;
    if (model.editContentBlock) {
        model.editContentBlock(model.content);
    }
}
- (void)clickSpace:(UIGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:self];
    if (location.x < _touchView.originX-5) {
        //隐藏键盘
        XZQAHumanModel *model = (XZQAHumanModel *)self.model;
        if (model.clickSpaceBlock) {
            model.clickSpaceBlock();
        }
    }
}

@end
