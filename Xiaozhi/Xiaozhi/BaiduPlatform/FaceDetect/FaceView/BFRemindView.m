//
//  BFRemindView.m
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//  

#import "BFRemindView.h"
#import "BFImageUtils.h"

@implementation BFRemindView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = OutSideColor.CGColor;
        self.layer.cornerRadius = 17;
        
        UIImageView * remindImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, (frame.size.height-27)/2.0, 27, 27)];
        remindImage.image = [BFImageUtils getImageResourceForName:@"warning"];
        [self addSubview:remindImage];
        
        UILabel * remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(remindImage.frame)+15, CGRectGetMinY(remindImage.frame), 120, CGRectGetHeight(remindImage.frame))];
        remindLabel.textColor = OutSideColor;
        remindLabel.font = [UIFont systemFontOfSize:22];
        remindLabel.text = @"请正对手机";
        [self addSubview:remindLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
