//
//  XZQAFileCell.m
//  M3
//
//  Created by wujiansheng on 2018/10/19.
//

#import "XZQAFileCell.h"
#import "XZQAFileModel.h"
#import "XZQAFileView.h"


@interface XZQAFileCell () {
    XZQAFileView *_fileView;
}
@end

//界面参照 RCFileMessageCell
@implementation XZQAFileCell

- (void)setup {
    [super setup];
    if (!_fileView) {
        _fileView = [[XZQAFileView alloc] init];
        [self addSubview:_fileView];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(XZQAFileModel *)model {
    [super setModel:model];
    [_fileView setupInfo:model];
}

- (void)clickFile {
    XZQAFileModel *model = (XZQAFileModel *)self.model;
    if (model.clickFileBlock) {
        model.clickFileBlock(model);
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    XZQAFileModel *model = (XZQAFileModel *)self.model;
    CGFloat width = model.scellWidth;
    [_fileView setFrame:CGRectMake(14, 10, width-28, [XZQAFileView viewHeight])];
}
@end
