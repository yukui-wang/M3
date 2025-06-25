//
//  XZQATextCell.m
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//

#import "XZQATextCell.h"
#import "XZQATextModel.h"
#import "XZTapLabel.h"
@interface XZQATextCell() {
    UIView *_bkView;
    XZTapLabel *_textLabel;
}
@end

@implementation XZQATextCell


- (void)setup {
    [super setup];
    if (!_bkView) {
        _bkView = [[UIView alloc] init];
        [self addSubview:_bkView];
        _bkView.backgroundColor = [UIColor whiteColor];
        _bkView.layer.cornerRadius = 10;
        _bkView.layer.masksToBounds = YES;
    }
    if (!_textLabel) {
        _textLabel = [[XZTapLabel alloc] init];
        _textLabel.userInteractionEnabled = YES;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:_textLabel];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTaped:)];
        [_textLabel addGestureRecognizer:tap];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)labelTaped:(UITapGestureRecognizer *)tap {
    XZQATextModel *textModel = (XZQATextModel *)self.model;
    XZTapLabel *view = (XZTapLabel *)tap.view;
    if (textModel.clickItems.count > 0) {
        CGPoint point = [tap locationInView:view];
        NSUInteger loca =  [view  locationForPoint:point];
        for (XZTextTapModel *model in textModel.clickItems) {
            if (NSLocationInRange(loca, model.range))  {
                if (model.tapType == XZTextTapTypeNormal) {
                }
                else if (model.tapType == XZTextTapTypeLink) {
                    if (textModel.clickLinkBlock) {
                        textModel.clickLinkBlock(model.text);
                    }
                }
                else if (model.tapType == XZTextTapTypeAPP) {
                    if (textModel.clickAppBlock) {
                        textModel.clickAppBlock(model.text);
                    }
                }
                break;
            }
        }
    }
}

- (void)setModel:(XZQATextModel *)model {
    [super setModel:model];
    if (!model) {
        return;
    }
    //代表纯文本 直击 替换内容 而且 与有点击模块的没有复用的
    _textLabel.attributedText = model.attrString;
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    XZQATextModel *model = (XZQATextModel *)self.model;
    CGFloat width = model.scellWidth;
    [_bkView setFrame: CGRectMake(14, 10, width-28,  self.height-20)];
    [_textLabel setFrame: CGRectMake(28, 24, width-56,  self.height-48)];
}

@end
