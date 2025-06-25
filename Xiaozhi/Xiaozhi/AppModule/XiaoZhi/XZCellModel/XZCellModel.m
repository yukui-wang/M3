//
//  XZCellModel.m
//  M3
//
//  Created by wujiansheng on 2017/11/8.
//

#import "XZCellModel.h"


@implementation XZCellModel

- (void)dealloc {
    self.cellClass = nil;
    self.ideltifier = nil;
    self.cellClass = nil;
}

- (CGFloat)cellHeight{
    return 0;
}

- (void)disableOperate {
    
}

- (CGFloat)scellWidth {
    if (INTERFACE_IS_PHONE) {
        CGSize s =  [UIScreen mainScreen].bounds.size;
        return MIN(s.width, s.height);
    }
    return 768;
}

@end
