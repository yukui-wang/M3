//
//  XZSearchResultCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/7/4.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSearchResultCell.h"
#import "XZSearchResultModel.h"
#import "XZBaseItem.h"
@interface XZSearchResultCell() {
    UIView *_bkView;
    NSMutableArray *_itemsArray;
}
@property(nonatomic ,retain)UIButton *moreBtn;

@end


@implementation XZSearchResultCell

- (void)setup {
    if(!_bkView) {
        _bkView = [[UIView alloc] init];
        _bkView.layer.cornerRadius = 8;
        _bkView.layer.masksToBounds = YES;
        _bkView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bkView];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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


- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_bkView setFrame:CGRectMake(14, 10, self.width-28, self.height-20)];
    for (UIView *view in _itemsArray) {
        CGRect r = view.frame;
        r.size.width =_bkView.width;
        view.frame = r;
    }
}


- (void)setModel:(XZSearchResultModel *)model {
    [super setModel:model];
    
    if (!_itemsArray) {
        _itemsArray = [[NSMutableArray alloc] init];
    }
    for (UIView *view in _itemsArray) {
        [view removeFromSuperview];
    }
    [_itemsArray removeAllObjects];
    NSInteger y = 0;
    for (NSInteger t = 0 ;t < model.items.count;t++) {
        NSObject *obj  =  model.items[t];
        CGRect frame = CGRectMake(0, y, _bkView.width, [model.itemHeightArray[t] integerValue]);
        XZBaseItem *cell = [XZBaseItem itemWithModel:obj];
        cell.frame = frame;
        cell.tag = 1000+t;
        [_bkView addSubview:cell];
        [cell addTarget:self touchAction:@selector(tapItem:)];
        y += cell.height;
        [_itemsArray addObject:cell];
    }
    
    if (model.showMoreBtn) {
        [self.moreBtn removeFromSuperview];
        [_bkView addSubview:self.moreBtn];
        [_moreBtn setFrame:CGRectMake(0, y, _bkView.width, 44)];
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
    [self customLayoutSubviewsFrame:self.frame];
}


- (void)tapItem:(XZBaseItem *)view {
    XZSearchResultModel *model = (XZSearchResultModel *)self.model;
    if (model.stopSpeakBlock) {
        model.stopSpeakBlock();
    }
    if (model.clickBlock) {
        id obj = [model.items objectAtIndex:view.tag-1000];
        model.clickBlock(obj);
    }
}

- (void)moreBtnClicked:(id)sender {
    XZSearchResultModel *model = (XZSearchResultModel *)self.model;
    if (model.moreBtnClickAction) {
        model.moreBtnClickAction(model);
    }
}

@end
