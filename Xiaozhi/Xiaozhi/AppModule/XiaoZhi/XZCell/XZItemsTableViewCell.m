//
//  XZItemsTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2017/12/2.
//

#import "XZItemsTableViewCell.h"
#define kViewTag 1000


@interface XZItemsTableViewCell()

@property(nonatomic ,retain)UIButton *moreBtn;
@property(nonatomic ,copy)NSString   *ideltifier;

@end

@implementation XZItemsTableViewCell

- (void)dealloc {
    self.ideltifier = nil;
    SY_RELEASE_SAFELY(_moreBtn);
    [super dealloc];
}


- (void)labelTaped:(UITapGestureRecognizer *)tap {
    
    XZTextModel *textModel = (XZTextModel *)self.model;
    if( !textModel.tapEnable) {
        return;
    }
    XZTapLabel *view = (XZTapLabel *)tap.view;
    XZTextInfoModel *info = [textModel.showItems objectAtIndex:view.tag-kViewTag];
    if (info.tapModel.count > 0) {
        CGPoint point = [tap locationInView:view];
        NSUInteger loca =  [view  locationForPoint:point];
        for (XZTextTapModel *model in info.tapModel) {
            if (NSLocationInRange(loca, model.range))  {
                if (textModel.clickTextBlock) {
                    textModel.clickTextBlock(model.text);
                }
                break;
            }
        }
    }
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_moreBtn setTitle:@"查看更多" forState:UIControlStateNormal];
        [_moreBtn setTitleColor:UIColorFromRGB(0x0075ff) forState:UIControlStateNormal];
        [_moreBtn setImage:XZ_IMAGE(@"xz_view_more.png") forState:UIControlStateNormal];
        [_moreBtn setImage:XZ_IMAGE(@"xz_view_more_h.png") forState:UIControlStateHighlighted];
        [_moreBtn addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}


- (XZTapLabel *)tapLabel {
    XZTapLabel * tapLabel = [[XZTapLabel alloc] init];
    tapLabel.lineBreakMode = NSLineBreakByCharWrapping;
    tapLabel.userInteractionEnabled = YES;
    tapLabel.numberOfLines = 0;
    [_contentBGView addSubview:tapLabel];
    return [tapLabel autorelease];
}

- (void)setModel:(XZTextModel *)model {
    
    [super setModel:model];
    if (!model || model.showItems.count ==0 ) {
        return;
    }
    [self customLayoutSubviewsFrame:self.bounds];
    
    if([self.ideltifier isEqualToString:model.ideltifier]) {
        //点击模块的  点击模块的ideltifier都不一样只需要处理一次就好
        return;
    }
    self.ideltifier = model.ideltifier;
    CGFloat x = model.chatCellType == ChatCellTypeUserMessage ? 10:18;
    CGFloat y = 0;
    NSInteger tag = kViewTag;
    for (XZTextInfoModel *mode in model.showItems) {
        if ([mode.info isKindOfClass:[NSAttributedString class]]) {
            y += 10;
            CGRect frame = CGRectMake(x, y, mode.size.width, mode.size.height);
            XZTapLabel *label = [self tapLabel];
            label.attributedText = mode.info;
            label.frame = frame;
            label.tag = tag;
            UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTaped:)];
            [label addGestureRecognizer:tap];
            SY_RELEASE_SAFELY(tap);
            __weak XZTapLabel *weakLable = label;
            __weak XZTextInfoModel *weakMode = mode;
            mode.reloadTextBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakLable.attributedText = weakMode.info;
                });
            };
            
            y += mode.size.height+10;
        }
        else {
            CGRect frame = CGRectMake(8, y, mode.size.width-8, mode.size.height);
            XZBaseItem *cell = [XZBaseItem itemWithModel:mode.info];
            cell.frame =frame;
            cell.tag = tag;
            [_contentBGView addSubview:cell];
            [cell addTarget:self touchAction:@selector(tapItem:)];
            y += mode.size.height +1;
        }
        tag ++;
    }
    if (model.showMoreBtn) {
        [self.moreBtn removeFromSuperview];
        [_contentBGView addSubview:self.moreBtn];
        [_moreBtn setFrame:CGRectMake(8, y, _contentBGView.width-10, 44)];
        UIImage *image = XZ_IMAGE(@"xz_view_more.png");
        CGFloat titleWidth = [_moreBtn.titleLabel.text sizeWithFontSize:_moreBtn.titleLabel.font defaultSize:CGSizeMake(320, 100)].width;
        CGFloat imageWidth = image.size.width;
        [_moreBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth-5, 0, imageWidth+5)];
        [_moreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, titleWidth+5, 0, -titleWidth-5)];
    }
    else {
        if (_moreBtn) {
            [_moreBtn removeFromSuperview];
            self.moreBtn = nil;
        }
    }
}

- (void)moreBtnClicked:(id)sender {
    XZTextModel *model = (XZTextModel *)self.model;
    if (model.moreBtnClickAction) {
        model.moreBtnClickAction(model);
    }
}

- (void)tapItem:(XZBaseItem *)view {
    XZTextModel *model = (XZTextModel *)self.model;
    if (model.clickBlock) {
        XZTextInfoModel *info = [model.showItems objectAtIndex:view.tag-kViewTag];
        model.clickBlock(info.info);
    }
}

@end

