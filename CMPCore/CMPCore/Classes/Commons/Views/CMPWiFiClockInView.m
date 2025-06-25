//
//  CMPWiFiClockInView.m
//  M3
//
//  Created by CRMO on 2019/1/21.
//

#import "CMPWiFiClockInView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/UIView+CMPView.h>

@interface CMPWiFiClockInButton()
@property (strong, nonatomic) CAShapeLayer *circleLayer;
@property (strong, nonatomic) CAShapeLayer *tickLayer;
@property (assign, nonatomic) CMPWiFiClockInButtonState buttonState;
@end

@implementation CMPWiFiClockInButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:58/255 green:173/255 blue:251/255 alpha:0.6];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat width = 74;
    CGFloat height = 24;
    if (_buttonState == CMPWiFiClockInButtonStateLoading ||
        _buttonState == CMPWiFiClockInButtonStateSuccess) {
        return CGRectMake((self.cmp_width-width)/2+10, (self.cmp_height-height)/2, width, height);
    } else {
        return CGRectMake((self.cmp_width-width)/2, (self.cmp_height-height)/2, width, height);
    }
}

- (void)updateState:(CMPWiFiClockInButtonState)state {
    if (state == CMPWiFiClockInButtonStateSuccess) {
        [self _successAnimation];
    } else if (state == CMPWiFiClockInButtonStateInit) {
        [self _removeAllAnimation];
    } else if (state == CMPWiFiClockInButtonStateLoading) {
        [self _loadingAnimation];
    }
    _buttonState = state;
    [self setNeedsLayout];
}

- (void)_removeAllAnimation {
    [self.circleLayer removeFromSuperlayer];
    [self.tickLayer removeFromSuperlayer];
}

- (void)_loadingAnimation {
    [self _removeAllAnimation];
    self.circleLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_circleLayer];
    CGFloat width = 18;
    CGFloat height = 18;
    _circleLayer.frame = CGRectMake(40, (self.cmp_height-height)/2, width, height);
    CGFloat radius = 9;
    _circleLayer.lineWidth = 2;
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_circleLayer.bounds.size.width / 2, _circleLayer.bounds.size.height / 2)
                                                        radius:radius
                                                    startAngle:0
                                                      endAngle:M_PI * 3/2
                                                     clockwise:YES];
    _circleLayer.path = [path CGPath];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.toValue = [NSNumber numberWithFloat:2*M_PI];
    anim.duration = 1;
    anim.beginTime = CACurrentMediaTime();
    anim.repeatCount = INFINITY;
    anim.removedOnCompletion = YES;
    anim.autoreverses = NO;
    [_circleLayer addAnimation:anim forKey:nil];
}

- (void)_successAnimation {
    [self _removeAllAnimation];
    self.tickLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_tickLayer];
    CGFloat width = 18;
    CGFloat height = 13;
    _tickLayer.frame = CGRectMake(40, (self.cmp_height-height)/2, width, height);
    _tickLayer.lineWidth = 2;
    _tickLayer.fillColor = [UIColor clearColor].CGColor;
    _tickLayer.strokeColor = [UIColor whiteColor].CGColor;
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(0, 6)];
    [path addLineToPoint:CGPointMake(6, height)];
    [path addLineToPoint:CGPointMake(width, 0)];
    _tickLayer.path = [path CGPath];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [_tickLayer addAnimation:pathAnimation forKey:nil];
}

@end

@interface CMPWiFiClockInView()

/** 上班时间前面的点 **/
@property (strong, nonatomic) UIView *dotView;
/** WiFi图标 **/
@property (strong, nonatomic) UIImageView *wifiIcon;

@end

@implementation CMPWiFiClockInView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.dateLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.workTimeLabel];
    [self addSubview:self.dotView];
    [self addSubview:self.wifiIcon];
    [self addSubview:self.wifiNameLabel];
    [self addSubview:self.clockInButton];
    [self addSubview:self.closeButton];
    
    [self.clockInButton setTitle:SY_STRING(@"WiFiClockIn_button") forState:UIControlStateNormal];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).inset(42);
        make.leading.equalTo(self.mas_leading).inset(39);
        make.width.equalTo(116);
        make.height.equalTo(20);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dateLabel.mas_bottom).inset(6);
        make.leading.equalTo(self.dateLabel.mas_leading);
        make.width.equalTo(116);
        make.height.equalTo(30);
    }];
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).inset(14);
        make.top.equalTo(self.timeLabel.mas_bottom).inset(50);
        make.width.height.equalTo(10);
    }];
    [self.workTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.dotView.mas_trailing).inset(14);
        make.centerY.equalTo(self.dotView);
        make.width.greaterThanOrEqualTo(120);
    }];
    [self.wifiIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(14);
        make.height.equalTo(10);
        make.centerY.equalTo(self.dotView);
        make.leading.equalTo(self.workTimeLabel.mas_trailing).inset(10);
    }];
    [self.wifiNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.wifiIcon.mas_trailing).inset(4);
        make.centerY.equalTo(self.dotView);
        make.width.equalTo(100);
        make.height.equalTo(18);
    }];
    [self.clockInButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).inset(25);
        make.trailing.equalTo(self.mas_trailing);
        make.width.equalTo(180);
        make.height.equalTo(90);
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(16);
        make.trailing.equalTo(self.mas_trailing).inset(10);
        make.bottom.equalTo(self.mas_bottom).inset(10);
    }];
}

#pragma mark-
#pragma mark Getter

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _dateLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _dateLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightMedium];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UILabel *)workTimeLabel {
    if (!_workTimeLabel) {
        _workTimeLabel = [[UILabel alloc] init];
        _workTimeLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _workTimeLabel.textColor = [UIColor colorWithHexString:@"#000000"];
        _workTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _workTimeLabel;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _dotView.backgroundColor = [UIColor colorWithHexString:@"#3AADFB"];
        _dotView.layer.cornerRadius = 5;
        _dotView.layer.masksToBounds = YES;
    }
    return _dotView;
}

- (UILabel *)wifiNameLabel {
    if (!_wifiNameLabel) {
        _wifiNameLabel = [[UILabel alloc] init];
        _wifiNameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _wifiNameLabel.textColor = [UIColor colorWithHexString:@"#A2ACC7"];
        _wifiNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _wifiNameLabel;
}

- (UIImageView *)wifiIcon {
    if (!_wifiIcon) {
        _wifiIcon = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageWithName:@"clockin_wifi_icon" type:@"png" inBundle:@"CMPLogin"];
        [_wifiIcon setImage:image];
        _wifiIcon.tag = 111;
    }
    return _wifiIcon;
}

- (CMPWiFiClockInButton *)clockInButton {
    if (!_clockInButton) {
        _clockInButton = [[CMPWiFiClockInButton alloc] init];
        UIImage *image = [UIImage imageWithName:@"clockin_button" type:@"png" inBundle:@"CMPLogin"];
        [_clockInButton setBackgroundImage:image forState:UIControlStateNormal];
        [_clockInButton setBackgroundColor:[UIColor clearColor]];
    }
    return _clockInButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        UIImage *image = [UIImage imageWithName:@"clockin_close_button" type:@"png" inBundle:@"CMPLogin"];
        [_closeButton setImage:image forState:UIControlStateNormal];
        [_closeButton cmp_expandClickArea:UIOffsetMake(20, 20)];
    }
    return _closeButton;
}

@end
