//
//  XZPromptModel.m
//  M3
//
//  Created by wujiansheng on 2017/12/2.
//

#import "XZPromptModel.h"

@implementation XZPromptModel
- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZPromptTableViewCell";
        self.ideltifier = @"XZPromptTableViewCell";
    }
    return self;
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        UIFont *font = [UIFont systemFontOfSize:14];
        CGFloat maxLabelWidth = self.scellWidth-151;
        CGSize s = [self.prompt sizeWithFontSize:font defaultSize:CGSizeMake(maxLabelWidth, MAXFLOAT)];
        _lableheight = s.height;
        _lableWidht = s.width;
        _cellHeight = _lableheight +4*2 +kXZCellSpace;
    }
    return _cellHeight;
}
- (void)dealloc {
    self.prompt = nil;
}

@end
