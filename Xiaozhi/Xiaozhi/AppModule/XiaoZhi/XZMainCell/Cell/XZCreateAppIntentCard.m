//
//  XZCreateAppIntentCard.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/24.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCreateAppIntentCard.h"

@interface XZCreateAppIntentCard () {
}
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)NSMutableArray *viewList;
@property(nonatomic, strong)NSArray *infoList;

@end


@implementation XZCreateAppIntentCard


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_titleLabel setFont:FONTSYS(14)];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setBackgroundColor:UIColorFromRGB(0x297FFB)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (NSMutableArray *)viewList {
    if (!_viewList) {
        _viewList = [[NSMutableArray alloc] init];
    }
    return _viewList;
}

- (void)setup {
    [self addSubview:self.titleLabel];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
}

- (UILabel *)leftLabel {
    UILabel *leftLabel = [[UILabel alloc] init];
    [leftLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [leftLabel setFont:FONTSYS(14)];
    [leftLabel setTextColor:UIColorFromRGB(0x999999)];
    [leftLabel setBackgroundColor:[UIColor clearColor]];
    leftLabel.numberOfLines = 0;
    return leftLabel;
}

- (UILabel *)contentLabel {
    UILabel *contentLabel = [[UILabel alloc] init];
    [contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [contentLabel setFont:FONTSYS(14)];
    [contentLabel setTextColor:[UIColor blackColor]];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    contentLabel.numberOfLines = 0;
    return contentLabel;
}

- (void)setupWithAppName:(NSString *)name infoList:(NSArray *)infoList {
    [self.titleLabel setText:name];
    self.infoList = infoList;
    for (UIView *view in self.viewList) {
        [view removeFromSuperview];
    }
    [self.viewList removeAllObjects];
    CGFloat y = [self viewHeightForWidth:self.width];
    if (y != self.height) {
        CGRect f = self.frame;
        f.size.height = y;
        self.frame = f;
    }
}

- (CGFloat)viewHeightForWidth:(CGFloat)width {
    for (UIView *view in self.viewList) {
        [view removeFromSuperview];
    }
    [self.viewList removeAllObjects];
    CGFloat y = 54;
    
    //get best width
    NSInteger bestWidth = 0;
    UILabel *tempLabel = [self leftLabel];
    for (NSArray *array in self.infoList) {
        NSString *title = array[0];
        [tempLabel setText:title];
        CGSize tsize = [tempLabel sizeThatFits:CGSizeMake(10000, 100000)];
        NSInteger labelwidth = tsize.width+1;
        if (labelwidth > 86) {
            bestWidth = 86 ;
            break;
        }
        else {
            bestWidth = MAX(bestWidth, labelwidth);
        }
    }
    
    CGFloat leftX = 14;
    CGFloat contentX = leftX+bestWidth+10;
    
    NSInteger maxHeight = FONTSYS(14).lineHeight*5+1;
    
    for (NSArray *array in self.infoList) {
        NSString *title = array[0];
        NSString *value = array[1];
        UILabel *titleLabel = [self leftLabel];
        [titleLabel setText:title];
        [self addSubview:titleLabel];
        [self.viewList addObject:titleLabel];
        CGSize tsize = [titleLabel sizeThatFits:CGSizeMake(bestWidth, 100000)];
        NSInteger theight = tsize.height+1;
        theight = MIN(maxHeight, theight);
        [titleLabel setFrame:CGRectMake(leftX, y, tsize.width, theight)];
        
        UILabel *valueLabel = [self contentLabel];
        [valueLabel setText:value];
        [self addSubview:valueLabel];
        [self.viewList addObject:valueLabel];
        CGSize vsize = [valueLabel sizeThatFits:CGSizeMake(width-contentX-10, 100000)];
        NSInteger vheight = vsize.height+1;
        vheight = MIN(maxHeight, vheight);
        [valueLabel setFrame:CGRectMake(contentX, y, vsize.width, vheight)];
        y += MAX(theight, vheight);
        y += 14;
    }
    y += 14;
    return y;
}


- (void)customLayoutSubviews {
    [self.titleLabel setFrame:CGRectMake(0, 0, self.width, 40)];
}

@end
