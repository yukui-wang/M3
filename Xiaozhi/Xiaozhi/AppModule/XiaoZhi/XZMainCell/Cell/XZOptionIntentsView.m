//
//  XZOptionIntentsView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/7/3.
//  Copyright © 2019 wujiansheng. All rights reserved.
//


#define kOptionIntentsViewTag 10000
#define kOptionIntentsItemHeight 60

#import "XZOptionIntentsView.h"

@interface XZOptionIntentsView () {
    UIView *_cardView;
}
@property(nonatomic, strong)NSArray *viewList;
@property(nonatomic, strong)NSArray *intentList;

@end

@implementation XZOptionIntentsView
- (void)setup {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.layer.cornerRadius = 10;
        _cardView.layer.masksToBounds = YES;
        
        [self addSubview:_cardView];
    }
}

- (void)setupData:(NSArray *)intents {
    for (UIView *view in self.viewList) {
        [view removeFromSuperview];
    }
    self.viewList = nil;
    self.intentList = intents;
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger t = 0; t < intents.count; t++) {
        XZAppIntent *intent = intents[t];
        UILabel *label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:FONTSYS(16)];
        [label setTextColor:[UIColor blackColor]];
        label.text = intent.appName;
        label.tag = kOptionIntentsViewTag + t;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickIntentLabel:)];
        [label addGestureRecognizer:tap];
        [_cardView addSubview:label];
        [label setFrame:CGRectMake(14, t*kOptionIntentsItemHeight+1, _cardView.width-15, kOptionIntentsItemHeight-1)];
        
        [array addObject:label];
        if (t > 0) {
           UIView *line = [[UIView alloc] initWithFrame:CGRectMake(14, t*kOptionIntentsItemHeight, _cardView.width-15, 1)];
            line.backgroundColor = UIColorFromRGB(0xe4e4e4);
            [self addSubview:line];
            [_cardView addSubview:line];
        }
    }
    self.viewList = array;
    [self customLayoutSubviews];
}

- (void)customLayoutSubviews {
    [_cardView setFrame:CGRectMake(14, 0, self.width-28, self.height)];
    for (UIView *view in self.viewList) {
        CGRect r = view.frame;
        r.size.width = _cardView.width-15;
        view.frame = r;
    }
}

- (void)clickIntentLabel:(UITapGestureRecognizer *)tap {
    UIView *view = [tap view];
    XZAppIntent *intent = self.intentList[view.tag - kOptionIntentsViewTag];
    if (intent.openBlock) {
        intent.openBlock(intent);
    }
}

+ (CGFloat)viewHeight:(NSInteger)count {
    return count *kOptionIntentsItemHeight;
}
@end
