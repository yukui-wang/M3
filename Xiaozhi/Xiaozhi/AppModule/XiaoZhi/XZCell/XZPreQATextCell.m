//
//  XZQATextCell.m
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//

#import "XZPreQATextCell.h"
#import "XZPreQATextModel.h"

@interface XZPreQATextCell() {
    XZTapLabel *_textLabel;
}
@end

@implementation XZPreQATextCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_textLabel);
    [super dealloc];
}

- (void)setup {
    [super setup];
    if (!_textLabel) {
        _textLabel = [[XZTapLabel alloc] init];
        _textLabel.userInteractionEnabled = YES;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_contentBGView addSubview:_textLabel];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTaped:)];
        [_textLabel addGestureRecognizer:tap];
        SY_RELEASE_SAFELY(tap);
    }
}

- (void)labelTaped:(UITapGestureRecognizer *)tap {
    XZPreQATextModel *textModel = (XZPreQATextModel *)self.model;
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

- (void)setModel:(XZPreQATextModel *)model {
    [super setModel:model];
    if (!model) {
        return;
    }
    //代表纯文本 直击 替换内容 而且 与有点击模块的没有复用的
    CGFloat x = 18;
    CGRect frame = CGRectMake(x, 10, model.contentSize.width,  model.contentSize.height);
    _textLabel.attributedText = model.attrString;
    _textLabel.frame = frame;
    [self customLayoutSubviewsFrame:self.bounds];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame{
    XZPreQATextModel *model = (XZPreQATextModel *)self.model;
    CGFloat iconWidth = 36;
    
    [_iconView setFrame:CGRectMake(12, 0, iconWidth, iconWidth)];
    [_contentBGView setFrame:CGRectMake(12+iconWidth+4, 0, model.contentSize.width +31, self.height-kXZCellSpace)];
    _iconView.image = XZ_IMAGE(@"xz_icon_cell.png");
    _contentBGView.image = [XZ_IMAGE(@"xz_chat_robot.png") resizableImageWithCapInsets:UIEdgeInsetsMake(19, 24, 19, 18) resizingMode:UIImageResizingModeStretch];
}



@end
