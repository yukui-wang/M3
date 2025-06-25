//
//  CMPLbsImageView.m
//  CMPCore
//
//  Created by wujiansheng on 16/7/27.
//
//

#import "CMPLbsImageView.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/RTL.h>

@interface CMPLbsImageView()
{
    UIView *_lineview;
    
    UIImageView *_sexImageView;
    UIImageView *_locationImageView;
    CAGradientLayer *_topLayer;
    CAGradientLayer *_bottomLayer;

}

@end
@implementation CMPLbsImageView

- (void)dealloc
{
    
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_dateLabel);
    SY_RELEASE_SAFELY(_nameLabel);
    SY_RELEASE_SAFELY(_locationLabel);
    SY_RELEASE_SAFELY(_sexImageView);
    SY_RELEASE_SAFELY(_locationImageView);
    
    
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self customLayoutSubviews];
    }
    return self;
}

- (void)setup {
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    _topLayer = [CAGradientLayer layer];  // 设置渐变效果
    _topLayer.borderWidth = 0;
    _topLayer.frame = CGRectMake(0, 320-100, 320, 100);
    [self.layer insertSublayer:_topLayer atIndex:0];
    
    
    _bottomLayer = [CAGradientLayer layer];  // 设置渐变效果
    _bottomLayer.borderWidth = 0;
    _bottomLayer.frame = CGRectMake(0, 320-100, 320, 100);
    [self.layer insertSublayer:_bottomLayer atIndex:0];
    
    UIColor * topBegin= [[UIColor blackColor] colorWithAlphaComponent:1.0];
    UIColor * topEnd = [CMP_HEXCOLOR(0x2C2C2C) colorWithAlphaComponent:0.0];
    _topLayer.colors = [NSArray arrayWithObjects:(id)topBegin.CGColor,(id)topEnd.CGColor, nil];
    
    UIColor * bottomBegin= [CMP_HEXCOLOR(0x727272) colorWithAlphaComponent:0.0];
    UIColor * bottomEnd =  [[UIColor blackColor] colorWithAlphaComponent:0.6];
    _bottomLayer.colors = [NSArray arrayWithObjects:(id)bottomBegin.CGColor,(id)bottomEnd.CGColor, nil];
    
    if (!_lineview) {
        _lineview = [[UIView alloc] init];
        _lineview.backgroundColor = UIColorFromRGB(0xffffff);
        [self addSubview:_lineview];
    }
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont boldSystemFontOfSize:24];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_timeLabel];
    }
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        [self addSubview:_dateLabel];
    }
    //人员
    if(!_sexImageView) {
        _sexImageView = [[UIImageView alloc] init];
        _sexImageView.image = [UIImage imageNamed:@"CMPTakeLbsPhoto.bundle/img_member.png"];
        [self addSubview:_sexImageView];
    }
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_nameLabel];
    }
    //定位
    if(!_locationImageView) {
        _locationImageView = [[UIImageView alloc] init];
        _locationImageView.image = [UIImage imageNamed:@"CMPTakeLbsPhoto.bundle/img_location.png"];
        [self addSubview:_locationImageView];
    }
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.font = [UIFont systemFontOfSize:12];
        _locationLabel.backgroundColor = [UIColor clearColor];
        _locationLabel.textColor = [UIColor whiteColor];
        [self addSubview:_locationLabel];
    }
}

- (void)setFrame:(CGRect)frame
{
    BOOL isResizing = YES;
    if (frame.size.width == self.frame.size.width && frame.size.height == self.frame.size.height) {
        isResizing = NO;
    }
    [super setFrame:frame];
    if (isResizing) {
        [self customLayoutSubviews];
    }
}


- (void)customLayoutSubviews
{
    _topLayer.frame = CGRectMake(0, 0, self.width, 120);
    _bottomLayer.frame = CGRectMake(0, self.height - 80, self.width, 80);
    
    // 时间显示
    CGFloat x = 20 + 2 + 10;
    CGFloat y = 23;
    NSInteger h = 33;
    CGFloat maxWidth = self.width;
    CGFloat defaultWidth = maxWidth - 20 - 2 - 10*2;
    CGSize s =  [_timeLabel.text sizeWithFontSize:_timeLabel.font defaultSize:CGSizeMake(defaultWidth, 18)];
    NSInteger w = s.width + 1;
    [_timeLabel setFrame:CGRectMake(x, y, w, h)];
    x += w + 10;
    h = 18;
    [_dateLabel setFrame:CGRectMake(x, 35, defaultWidth-x, h)];
    [_lineview setFrame:CGRectMake(20, 25, 2, 70)];
    
    //人员
    x = 20 + 2 + 10;
    [_sexImageView setFrame:CGRectMake(x, 63, 9, 12)];
    defaultWidth = maxWidth - 20 - 2 - 10*2;
    s =  [_nameLabel.text sizeWithFontSize:_nameLabel.font defaultSize:CGSizeMake(defaultWidth, 18)];
    w = s.width + 1;
    [_nameLabel setFrame:CGRectMake(x + 9 + 4, 60, w, 18)];
    
    //定位
    [_locationImageView setFrame:CGRectMake(x, 81 , 9, 12)];
    s =  [_locationLabel.text sizeWithFontSize:_locationLabel.font defaultSize:CGSizeMake(defaultWidth, 18)];
    w = s.width + 1;
    [_locationLabel setFrame:CGRectMake(x + 9 + 4, 78, w, 18)];
    
    [_timeLabel resetFrameToFitRTL];
    [_dateLabel resetFrameToFitRTL];
    [_lineview resetFrameToFitRTL];
    [_sexImageView resetFrameToFitRTL];
    [_nameLabel resetFrameToFitRTL];
    [_locationImageView resetFrameToFitRTL];
    [_locationLabel resetFrameToFitRTL];
    
}


-(void)hideName
{
    _nameLabel.hidden = YES;
    _sexImageView.hidden = YES;
}

- (void)showDateTimeWithTime:(NSString *)time
{
    NSString *week = [CMPDateHelper getWeekdayString:[CMPDateHelper stringToCFGregorianDate2:time]];
//    NSString *dateAndTime = [CMPDateHelper currentDate];
    _timeLabel.text = [[time substringFromIndex:11] substringToIndex:5];
    _dateLabel.text = [NSString stringWithFormat:@"%@ %@",[time substringToIndex:10],week];
    [self customLayoutSubviews];
}

- (UIImage *)result
{
    UIImage *result =  [self imageWithUIView:self];
    return result;
}


@end
