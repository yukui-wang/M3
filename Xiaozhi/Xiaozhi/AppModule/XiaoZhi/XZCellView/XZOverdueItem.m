//
//  XZOverdueItem.m
//  M3
//
//  Created by wujiansheng on 2017/11/10.
//

#import "XZOverdueItem.h"

@implementation XZOverdueItem

+ (XZOverdueItem *)itemWithModel:(SPWillDoneModel *)model {
    NSInteger height = kOverdueModelHeight+1;
    XZOverdueItem *cell = [[XZOverdueItem alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [cell setupWithModel:model];
    return cell;
}

- (void)setupWithModel:(SPWillDoneModel*)model {
    _contentLabel.text =  [NSString stringWithFormat:@"%ld %@",(long)model.count,model.content];
}

@end
