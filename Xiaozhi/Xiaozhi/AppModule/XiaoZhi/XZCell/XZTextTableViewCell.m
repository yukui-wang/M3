//
//  XZTextTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2017/11/8.
//


#import "XZTextTableViewCell.h"

@interface XZTextTableViewCell() {
    XZTapLabel *_textLabel;
}
@end

@implementation XZTextTableViewCell

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
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_contentBGView addSubview:_textLabel];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTaped:)];
        [_textLabel addGestureRecognizer:tap];
        SY_RELEASE_SAFELY(tap);
    }
}

- (void)labelTaped:(UITapGestureRecognizer *)tap {
    XZTextModel *textModel = (XZTextModel *)self.model;
//    if( !textModel.tapEnable) {
//        return;
//    }
    XZTapLabel *view = (XZTapLabel *)tap.view;
    XZTextInfoModel *info = [textModel.showItems firstObject];
    if (info.tapModel.count > 0) {
        CGPoint point = [tap locationInView:view];
        NSUInteger loca =  [view  locationForPoint:point];
        for (XZTextTapModel *model in info.tapModel) {
            if (NSLocationInRange(loca, model.range))  {
                if (model.tapType == XZTextTapTypeNormal) {
                    if (textModel.clickTextBlock) {
                        textModel.clickTextBlock(model.text);
                    }
                }
                else if (model.tapType == XZTextTapTypeLink) {
                    if (textModel.clickLinkBlock) {
                        textModel.clickLinkBlock(model.text);
                    }
                }
                else if (model.tapType == XZTextTapTypeDownload) {
                   
                }
                break;
            }
        }
    }
}

- (void)setModel:(XZTextModel *)model {
    [super setModel:model];
    if (!model || model.showItems.count ==0 ) {
        return;
    }
    //代表纯文本 直击 替换内容 而且 与有点击模块的没有复用的
    CGFloat x = model.chatCellType == ChatCellTypeUserMessage ? 10:18;
    XZTextInfoModel *mode = [model.showItems firstObject];
    CGRect frame = CGRectMake(x, 10, mode.size.width, mode.size.height);
    _textLabel.attributedText = mode.info;
    _textLabel.frame = frame;
    [self customLayoutSubviewsFrame:self.bounds];
    __weak XZTapLabel *weakLable = _textLabel;
    __weak XZTextInfoModel *weakMode = mode;
    mode.reloadTextBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakLable.attributedText = weakMode.info;
        });
    };

}
@end
