//
//  XZBaseItem.m
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZBaseItem.h"
#import "XZScheduleItem.h"
#import "XZOverdueItem.h"
#import "XZWillDoneItem.h"
#import "XZNewsItem.h"
@interface XZBaseItem () {
    UIView *_leftLine;
}

@end

@implementation XZBaseItem


- (id)init {
    if (self = [super init]) {
        [self setup];
        [self customLayoutSubviews];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        [self customLayoutSubviews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    BOOL needReload = NO;
    if (self.width != frame.size.width  || self.height != frame.size.height) {
        needReload = YES;
    }
    [super setFrame:frame];
    if (needReload) {
        [self customLayoutSubviews];
    }
}

- (void)setup {
    if (!_leftLine) {
        _leftLine = [[UIView alloc] init];
        _leftLine.backgroundColor = UIColorFromRGB(0x006ff1);
        [self addSubview:_leftLine];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = UIColorFromRGB(0x006ff1);
        [self addSubview:_contentLabel];
    }
    if (!_dotImageView) {
        _dotImageView = [[UIImageView alloc] init];
        _dotImageView.image = XZ_IMAGE(@"xz_showdetail.png");
        [self addSubview:_dotImageView];
    }
    self.backgroundColor = UIColorFromRGB(0xe3eefc);
    
    [self addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragOutside];
    [self addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragOutside];
    [self addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchCancel];
}
- (void)touchDownAction:(id)sender {
    [self setTapColor];
}
- (void)touchUpInsideAction:(id)sender {
    [self setDefaultColor];
    [_touchTarget performSelector:_touchAction withObject:self afterDelay:0];
}
- (void)otherTouchesAction: (id)sender{
    [self setDefaultColor];
}

- (void)customLayoutSubviews{
    [_leftLine setFrame:CGRectMake(0, 0, 2, self.height)];
    [_contentLabel setFrame:CGRectMake(12, 10, self.width-38, self.height-20)];
    [_dotImageView setFrame:CGRectMake(self.width-18, self.height/2-8, 9, 16)];
}

+ (XZBaseItem*)itemWithModel:(NSObject *)model {
    
    NSString *class = NSStringFromClass(model.class);
    XZBaseItem * cell = nil;
    if ([class isEqualToString:@"XZNewsItemModel"]) {
        cell = [XZNewsItem itemWithModel:(id)model];
    }
    else if ([class isEqualToString:@"SPScheduleModel"]) {
        cell = [XZScheduleItem itemWithModel:(id)model];
    } else if ([class isEqualToString:@"SPWillDoneModel"]) {
        //仅显示几条超期待办
        cell = [XZOverdueItem itemWithModel:(id)model];
    } else if ([class isEqualToString:@"SPWillDoneItemModel"]) {
        //需要显示 标题 发起人 时间
        cell = [XZWillDoneItem itemWithModel:(id)model];
    }
    else {
        cell = [XZScheduleItem itemWithModel:(id)model];
    }
    return  cell;
}
- (void)setDefaultColor {
    self.backgroundColor = UIColorFromRGB(0xe3eefc);
}

- (void)setTapColor {
    self.backgroundColor = UIColorFromRGB(0xc8e0ff);
}
- (void)addTarget:(id)target touchAction:(SEL)action {
    _touchTarget = target;
    _touchAction = action;
}
@end
