//
//  XZScheduleItem.m
//  M3
//
//  Created by wujiansheng on 2017/11/10.
//

#import "XZScheduleItem.h"

@implementation XZScheduleItem


+ (XZScheduleItem*)itemWithModel:(SPScheduleModel *)model {
    NSInteger height = kScheduleModelHeight+1;
    XZScheduleItem *cell = [[XZScheduleItem alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [cell setupWithModel:model];
    return cell;
}

- (void)setupWithModel:(SPScheduleModel*)model {
    _contentLabel.numberOfLines = 0;
    _contentLabel.text = model.content;
}

@end
