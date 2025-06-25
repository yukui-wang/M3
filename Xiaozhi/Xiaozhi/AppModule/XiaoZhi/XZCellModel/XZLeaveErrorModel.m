//
//  XZLeaveErrorModel.m
//  M3
//
//  Created by wujiansheng on 2018/1/9.
//

#import "XZLeaveErrorModel.h"

@implementation XZLeaveErrorModel
- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZLeaveErrorCell";
        self.ideltifier = @"XZLeaveErrorCell";
        self.chatCellType = ChatCellTypeRobotMessage;
        self.canOperate = YES;
        self.showClickTitle = NO;
    }
    return self;
}
- (void)setCanOperate:(BOOL)canOperate {
    if (!canOperate && _canOperate) {
        _cellHeight = 0;
    }
    _canOperate = canOperate;
}
- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        self.lableWidth = self.scellWidth-144;
        NSInteger heigh = 10;
        UIFont *font = [UIFont systemFontOfSize:16];
        
        CGSize s = [self.contentInfo sizeWithFontSize:font defaultSize:CGSizeMake(self.lableWidth, MAXFLOAT)];
        if (s.height < font.lineHeight+2) {
            self.lableWidth = s.width;
        }
        heigh += s.height;
        heigh += 10;//文本空白
        heigh += kXZCellSpace;//气泡空白
        if (self.canOperate) {
            heigh += 42;//发送等按钮高度及间距
        }
        _cellHeight = heigh;
    }
    return _cellHeight;
}
- (void)showLeave {
    self.canOperate = NO;
    if (self.showLeaveBlock) {
        self.showLeaveBlock(self);
    }
}
- (void)cancel {
    self.canOperate = NO;
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
}
- (void)disableOperate {
    self.canOperate = NO;
}

- (void)dealloc {
    
    self.showLeaveBlock = nil;
    self.cancelBlock = nil;
    self.contentInfo = nil;
    self.buttonTitle = nil;
    self.templateId = nil;
    self.formData = nil;
    self.sendOnload = nil;
}

@end
