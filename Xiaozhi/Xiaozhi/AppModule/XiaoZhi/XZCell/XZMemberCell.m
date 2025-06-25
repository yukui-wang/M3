//
//  XZMemberCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/23.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZMemberCell.h"
#import "XZMemberDetailView.h"

@interface XZMemberCell () {
    XZMemberDetailView *_memberView;
}

@end

@implementation XZMemberCell

- (void)setup {
    if (!_memberView) {
        _memberView = [[XZMemberDetailView alloc] init];
        [self addSubview:_memberView];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_memberView setFrame:CGRectMake(0, 10, self.width, self.height-20)];
}

- (void)setModel:(XZMemberModel *)model {
    [super setModel:model];
    [_memberView setupInfo:model];
}

@end
