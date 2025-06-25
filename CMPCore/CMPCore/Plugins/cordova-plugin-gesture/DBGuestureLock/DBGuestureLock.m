//
//  DBGuestureLockView.m
//  DBGuestureLock
//
//  Created by DeBao.Wu on 2/27/16.
//  Copyright © 2016 http://i36.Me/. All rights reserved.
//
#import "DBGuestureLock.h"
#import "DBGuestureButton.h"
#define DBGuestureLockPaswd @"Me_i36_DBGuestureLock_Password"
#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface DBGuestureLock() {
    NSInteger _incorrectCount;
    DBButtonState _state;
}

@property (nonatomic, assign)CGPoint currentPoint;
@property (nonatomic, strong)UIColor *lineColor;
@property (nonatomic, assign)CGFloat lineWidth;
@property (nonatomic, strong)NSMutableArray *selectedButtons;
@property (nonatomic, strong)NSMutableArray *buttonArray;

@property (nonatomic, assign)BOOL isPasswordSetup;

//Make theme writable
@property (nonatomic, assign)BOOL fillCenterPoint;
@property (nonatomic, assign)BOOL showCenterPoint;
@property (nonatomic, assign)CGFloat circleRadius;
@property (nonatomic, assign)CGFloat strokeWidth;
@property (nonatomic, assign)CGFloat centerPointRadius;
@property (nonatomic, strong)UIColor *fillColor;
@property (nonatomic, strong)UIColor *smallCircleColor;

@property (nonatomic, strong)UIColor *strokeColor;
@property (nonatomic, strong)UIColor *centerPointColor;

@end

@implementation DBGuestureLock

+(BOOL)passwordSetupStatus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults valueForKey:DBGuestureLockPaswd];
    if (password == nil || [password length] <= 0) {
        return NO;
    }
    
    return YES;
}

+(void)clearGuestureLockPassword {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue: nil forKey:DBGuestureLockPaswd];
}

+(NSString *)getGuestureLockPassword {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults valueForKey:DBGuestureLockPaswd];
    
    return password;
}

/*
-(BOOL)isPasswordSetup {
    return [[self class] passwordSetupStatus];
}*/

//@Override
/*
-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ([self.selectedButtons count]== 0) {
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth: self.lineWidth];
    [self.lineColor set];
    [path setLineJoinStyle: kCGLineJoinRound];
    [path setLineCapStyle: kCGLineCapRound];
    
    for (NSInteger i=0; i<[self.selectedButtons count]; i++) {
        DBGuestureButton *button = self.selectedButtons[i];
        if (i == 0) {
            [path moveToPoint:[button center]];
        } else {
            [path addLineToPoint: [button center]];
        }
        [button setNeedsDisplay];
    }
    [path addLineToPoint:self.currentPoint];
    [path stroke];
}
*/
-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    if ([self.buttonArray count]== 0) {
        return;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth: self.lineWidth];
    [self.lineColor set];
    [path setLineJoinStyle: kCGLineJoinRound];
    [path setLineCapStyle: kCGLineCapRound];
    
    for (NSInteger i=0; i<[self.buttonArray count]; i++) {
        DBGuestureButton *button = self.buttonArray[i];
        if (![self.selectedButtons containsObject:button]) {
            //未选中
            [self drawCircletWithButton:button buttonState:DBButtonStateNormal];
        }
    }
    for (NSInteger i=0; i<[self.selectedButtons count]; i++) {
        //选中
        DBGuestureButton *button = self.selectedButtons[i];
        [self drawCircletWithButton:button buttonState:_state== DBButtonStateIncorrect?DBButtonStateIncorrect:DBButtonStateSelected];
        if (i == 0) {
            [path moveToPoint:[button center]];
        } else {
            [path addLineToPoint: [button center]];
        }
    }
    [path addLineToPoint:self.currentPoint];
    [path stroke];
}

-(void)drawCircletWithButton:(DBGuestureButton *)button buttonState:(DBButtonState)state
{
    CGRect rect = button.frame;
    CGFloat width = rect.size.height > rect.size.width ? rect.size.width : rect.size.height;
    CGFloat radius = (width - 2*self.strokeWidth)/2;
    
    //if glv.circleRadius (from user) grater than radius,
    //it may cause the circle be draw out of the button.
    if (radius > (self.circleRadius - self.strokeWidth)) {
        radius = self.circleRadius - self.strokeWidth;
    }
    //边线颜色
    UIColor *strokeColor = [UIColor whiteColor];
    if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleStrokeOnState:)]) {
        strokeColor = [self.delegate colorOfButtonCircleStrokeOnState:state];
    }
    //整个大圆的填充色
    UIColor *fillColor  = [UIColor clearColor];
    if ([self.delegate respondsToSelector:@selector(colorForFillingButtonCircleOnState:)]) {
        fillColor = [self.delegate colorForFillingButtonCircleOnState:state];
    }
    //圆点外的小环颜色
    UIColor *smallCircleColor = nil;
    if ([self.delegate respondsToSelector:@selector(colorOfButtonSmallCircleStrokeOnState:)]) {
        smallCircleColor = [self.delegate colorOfButtonSmallCircleStrokeOnState:state];
    }
    //圆点颜色
    UIColor *centerPointColor = [UIColor clearColor];
    if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleCenterPointOnState:)]) {
        centerPointColor = [self.delegate colorOfButtonCircleCenterPointOnState:state];
    }

    CGFloat centerPointRadius = INTERFACE_IS_PAD ?  self.centerPointRadius : self.centerPointRadius ;//< self.circleRadius/4 ?self.circleRadius/4 :self.centerPointRadius;
    CGFloat smallCircleRadius = INTERFACE_IS_PAD ?(centerPointRadius+6): centerPointRadius+6;
    //边线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.strokeWidth);
    CGPoint centerPoint = button.center;
    CGFloat startAngle = -((CGFloat)M_PI / 2); // 90 degrees
    CGFloat endAngle = ((2 * (CGFloat)M_PI) + startAngle);
    [strokeColor setStroke];
    CGContextAddArc(context, centerPoint.x, centerPoint.y, radius+self.strokeWidth/2, startAngle, endAngle, 0); //0:counterclockwise, 1:clockwise
    CGContextStrokePath(context);
    
    if (self.showCenterPoint) {
        //整个大圆的
        [fillColor set];
        CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, startAngle, endAngle, 0); //0:counterclockwise, 1:clockwise
        CGContextFillPath(context);
        //圆点外的小环
        if (smallCircleColor) {
            [smallCircleColor set];
            CGContextAddArc(context, centerPoint.x, centerPoint.y, smallCircleRadius, startAngle, endAngle, 0); //0:counterclockwise, 1:clockwise
            CGContextFillPath(context);
        }
        //圆点
        if (self.fillCenterPoint) {
            [centerPointColor set];
        } else {
            [centerPointColor setStroke];
        }
        CGContextAddArc(context, centerPoint.x, centerPoint.y, centerPointRadius, startAngle, endAngle, 0); //0:counterclockwise, 1:clockwise
        if (self.fillCenterPoint) {
            CGContextFillPath(context);
        } else {
            CGContextStrokePath(context);
        }
    }
}


+(instancetype)lockOnView:(UIView*)view delegate:(id<DBGuestureLockDelegate>)delegate {
    CGFloat width = view.frame.size.height > view.frame.size.width ? view.frame.size.width : view.frame.size.height;
    CGFloat height = view.frame.size.height < view.frame.size.width ? view.frame.size.width : view.frame.size.height;
    CGRect frame = CGRectMake(0, height - width - 60, width, width);
    DBGuestureLock *lock = [[DBGuestureLock alloc] initWithFrame:frame];
    lock.delegate = delegate;
    
    return lock;
}

//@Override
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) { // Draw 9 Lock Buttons
        self.drawEnabled = YES;
        [self setPropertiesByState:DBButtonStateNormal];
        _selectedButtons = [[NSMutableArray alloc] initWithCapacity:0];
        _buttonArray = [[NSMutableArray alloc] initWithCapacity:0];
//        CGFloat width = frame.size.height > frame.size.width ? frame.size.width : frame.size.height;
//        CGFloat spacing = width / 10; //Split into 10 Part
//        CGFloat radius = spacing;
        
        CGFloat spacing = INTERFACE_IS_PAD ? 60:30;
        CGFloat radius = INTERFACE_IS_PAD ? 30:30;
        [self setCircleRadius:radius];
        CGFloat x= 0,y = 0;
        CGFloat leftX = (frame.size.width-radius*6-spacing*2)/2;
        CGFloat upY = (frame.size.height-radius*6-spacing*2)/2;

        for (NSInteger i=0; i<9; i++) { //Total 9 buttons
            NSInteger row = i/3; //3 buttons for each row
            NSInteger col = i%3; //3 buttons for each column
            x = leftX+col*(radius*2+spacing);
            y = upY+row*(radius*2+spacing);
            
//            CGRect frame = CGRectMake((1+col*3)*spacing, (1+row*3)*spacing, 2*radius, 2*radius);
            CGRect frame = CGRectMake(x, y, 2*radius, 2*radius);

            DBGuestureButton *button = [[DBGuestureButton alloc] initWithFrame: frame];
            [button setTag: i+1]; // Present for password number
            [self addSubview: button];
            [self setBackgroundColor:[UIColor clearColor]];
            [_buttonArray addObject:button];
        }
    }
    return self;
}

- (void)setDelegate:(id<DBGuestureLockDelegate>)delegate
{
    _delegate = delegate;
    [self setPropertiesByState:DBButtonStateNormal];
}
//@Override
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_drawEnabled) {
        return;
    }
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.currentPoint = point;
    
    for (DBGuestureButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, point)) {
            [button setSelected:YES];
            if (![self.selectedButtons containsObject:button]) {
                [self.selectedButtons addObject:button];
                [self setPropertiesByState:DBButtonStateSelected];
                [button setNeedsDisplay];
                if (_delegate &&[_delegate respondsToSelector:@selector(guestureLock:passwordAddPswd:)]) {
                    [_delegate guestureLock:self passwordAddPswd:[NSString stringWithFormat:@"%ld",(long)button.tag]];
                }
            }
        }
    }
    
    [self setNeedsDisplay];
}

//@Override
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_drawEnabled) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.currentPoint = point;
    
    for (DBGuestureButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, point)) {
            [button setSelected:YES];
            if (![self.selectedButtons containsObject:button]) {
                [self.selectedButtons addObject:button];
                [self setPropertiesByState:DBButtonStateSelected];
                if (_delegate &&[_delegate respondsToSelector:@selector(guestureLock:passwordAddPswd:)]) {
                    [_delegate guestureLock:self passwordAddPswd:[NSString stringWithFormat:@"%ld",(long)button.tag]];
                }
            }
        }
    }
    
    [self setNeedsDisplay];
}

//@Override
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_drawEnabled) {
        return;
    }
    [super touchesEnded:touches withEvent:event];
    
    //Get password
    NSMutableString *password = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger i=0; i<[self.selectedButtons count]; i++) {
        DBGuestureButton *button = self.selectedButtons[i];
        [password appendFormat:@"%li", (long)button.tag];
        if (_delegate &&[_delegate respondsToSelector:@selector(guestureLock:passwordAddPswd:)]) {
            [_delegate guestureLock:self passwordAddPswd:[NSString stringWithFormat:@"%ld",(long)button.tag]];
        }
    }
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *correctPswd = self.correctGuestureLockPaswd; //[defaults valueForKey:DBGuestureLockPaswd];
    if (correctPswd == nil || [correctPswd length] == 0) {
//        [defaults setValue: password forKey:DBGuestureLockPaswd];
        [self.delegate guestureLock:self didSetPassword:password];
        [self setPropertiesByState:DBButtonStateNormal];
    } else if ([password isEqualToString:correctPswd]) {
        [self resetButtons];
        self.userInteractionEnabled = NO;
        [self.delegate guestureLock:self didGetCorrectPswd:password];
        return;
//        [self setPropertiesByState:DBButtonStateNormal];
    } else { //incorrect
        if (password.length >= 4) {
            _incorrectCount ++;
        }
        [self.delegate guestureLock:self didGetIncorrectPswd:password incorrectCount:_incorrectCount];
        [self setPropertiesByState:DBButtonStateIncorrect];
    }
    
    DBGuestureButton *lastButton = [self.selectedButtons lastObject];
    [self setCurrentPoint:lastButton.center];
    [self setNeedsDisplay];
}

-(void)resetButtons {
    for (NSInteger i=0; i<[self.selectedButtons count]; i++) {
        DBGuestureButton *button = self.selectedButtons[i];
        [button setSelected:NO];
    }
    [self.selectedButtons removeAllObjects];
    [self setNeedsDisplay];
}

-(void)lockState:(NSArray *)states {
    NSNumber *stateNumber = [states objectAtIndex:0];
    [self setPropertiesByState:[stateNumber integerValue]];
}

-(void)setPropertiesByState:(DBButtonState)buttonState {
    _state = buttonState;
    switch (buttonState) {
        case DBButtonStateNormal:
            [self setUserInteractionEnabled:YES];
            [self resetButtons];
            
            self.fillCenterPoint = NO; //As default
            if ([self.delegate respondsToSelector:@selector(fillButtonCircleCenterPointOnState:)]) {
                self.fillCenterPoint = [self.delegate fillButtonCircleCenterPointOnState:DBButtonStateNormal];
            }
            
            self.showCenterPoint = YES; //As default
            if ([self.delegate respondsToSelector:@selector(showButtonCircleCenterPointOnState:)]) {
                self.showCenterPoint = [self.delegate showButtonCircleCenterPointOnState:DBButtonStateNormal];
            }
            
            self.strokeWidth = 1.f; //As default
            if ([self.delegate respondsToSelector:@selector(widthOfButtonCircleStrokeOnState:)]) {
                self.strokeWidth = [self.delegate widthOfButtonCircleStrokeOnState:DBButtonStateNormal];
            }
            
            self.centerPointRadius = 0.f; //As default
            if ([self.delegate respondsToSelector:@selector(radiusOfButtonCircleCenterPointOnState:)]) {
                self.centerPointRadius = [self.delegate radiusOfButtonCircleCenterPointOnState:DBButtonStateNormal];
            }
            
            self.lineWidth = 0.f;
            if ([self.delegate respondsToSelector:@selector(lineWidthOfGuestureOnState:)]) {
                self.lineWidth = [self.delegate lineWidthOfGuestureOnState:DBButtonStateNormal];
            }
            
            self.lineColor = [UIColor whiteColor];
            if ([self.delegate respondsToSelector:@selector(lineColorOfGuestureOnState:)]) {
                self.lineColor = [self.delegate lineColorOfGuestureOnState:DBButtonStateNormal];
            }
            
            //As default
            self.fillColor = [UIColor clearColor];
            if ([self.delegate respondsToSelector:@selector(colorForFillingButtonCircleOnState:)]) {
                self.fillColor = [self.delegate colorForFillingButtonCircleOnState:DBButtonStateNormal];
            }
            
            //As default
            self.strokeColor = [UIColor whiteColor];
            if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleStrokeOnState:)]) {
                self.strokeColor = [self.delegate colorOfButtonCircleStrokeOnState:DBButtonStateNormal];
            }
            
            //As default
            self.centerPointColor = [UIColor clearColor];
            if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleCenterPointOnState:)]) {
                self.centerPointColor = [self.delegate colorOfButtonCircleCenterPointOnState:DBButtonStateNormal];
            }
            
            //self.circleRadius = self.circleRadius;
            break;
        case DBButtonStateSelected:
            [self setUserInteractionEnabled:YES];
            
            self.fillCenterPoint = YES; //As default
            if ([self.delegate respondsToSelector:@selector(fillButtonCircleCenterPointOnState:)]) {
                self.fillCenterPoint = [self.delegate fillButtonCircleCenterPointOnState:DBButtonStateSelected];
            }
            
            self.showCenterPoint = YES; //As default
            if ([self.delegate respondsToSelector:@selector(showButtonCircleCenterPointOnState:)]) {
                self.showCenterPoint = [self.delegate showButtonCircleCenterPointOnState:DBButtonStateSelected];
            }
            
            self.strokeWidth = 1.f; //As default
            if ([self.delegate respondsToSelector:@selector(widthOfButtonCircleStrokeOnState:)]) {
                self.strokeWidth = [self.delegate widthOfButtonCircleStrokeOnState:DBButtonStateSelected];
            }
            
            self.centerPointRadius = 8.f; //As default
            if ([self.delegate respondsToSelector:@selector(radiusOfButtonCircleCenterPointOnState:)]) {
                self.centerPointRadius = [self.delegate radiusOfButtonCircleCenterPointOnState:DBButtonStateSelected];
            }
            
            self.lineWidth = 2.f;
            if ([self.delegate respondsToSelector:@selector(lineWidthOfGuestureOnState:)]) {
                self.lineWidth = [self.delegate lineWidthOfGuestureOnState:DBButtonStateSelected];
            }
            
            self.lineColor = [UIColor whiteColor];
            if ([self.delegate respondsToSelector:@selector(lineColorOfGuestureOnState:)]) {
                self.lineColor = [self.delegate lineColorOfGuestureOnState:DBButtonStateSelected];
            }
            
            //As default
            self.fillColor = [UIColor lightTextColor];
            if ([self.delegate respondsToSelector:@selector(colorForFillingButtonCircleOnState:)]) {
                self.fillColor = [self.delegate colorForFillingButtonCircleOnState:DBButtonStateSelected];
            }
            
            //As default
            self.strokeColor = [UIColor whiteColor];
            if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleStrokeOnState:)]) {
                self.strokeColor = [self.delegate colorOfButtonCircleStrokeOnState:DBButtonStateSelected];
            }
            
            //As default
            self.centerPointColor = [UIColor whiteColor];
            if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleCenterPointOnState:)]) {
                self.centerPointColor = [self.delegate colorOfButtonCircleCenterPointOnState:DBButtonStateSelected];
            }
            self.smallCircleColor = [UIColor clearColor];
            if ([self.delegate respondsToSelector:@selector(colorOfButtonSmallCircleStrokeOnState:)]) {
                self.smallCircleColor = [self.delegate colorOfButtonSmallCircleStrokeOnState:DBButtonStateSelected];
            }
            //self.circleRadius = self.circleRadius;
            break;
        case DBButtonStateIncorrect:
            [self setUserInteractionEnabled:NO];
            
            self.fillCenterPoint = YES; //As default
            if ([self.delegate respondsToSelector:@selector(fillButtonCircleCenterPointOnState:)]) {
                self.fillCenterPoint = [self.delegate fillButtonCircleCenterPointOnState:DBButtonStateIncorrect];
            }
            
            self.showCenterPoint = YES; //As default
            if ([self.delegate respondsToSelector:@selector(showButtonCircleCenterPointOnState:)]) {
                self.showCenterPoint = [self.delegate showButtonCircleCenterPointOnState:DBButtonStateIncorrect];
            }
            
            self.strokeWidth = 1.f; //As default
            if ([self.delegate respondsToSelector:@selector(widthOfButtonCircleStrokeOnState:)]) {
                self.strokeWidth = [self.delegate widthOfButtonCircleStrokeOnState:DBButtonStateIncorrect];
            }
            
            self.centerPointRadius = 8.f; //As default
            if ([self.delegate respondsToSelector:@selector(radiusOfButtonCircleCenterPointOnState:)]) {
                self.centerPointRadius = [self.delegate radiusOfButtonCircleCenterPointOnState:DBButtonStateIncorrect];
            }
            
            self.lineWidth = 2.f;
            if ([self.delegate respondsToSelector:@selector(lineWidthOfGuestureOnState:)]) {
                self.lineWidth = [self.delegate lineWidthOfGuestureOnState:DBButtonStateIncorrect];
            }
            
            self.lineColor = [UIColor orangeColor];
            if ([self.delegate respondsToSelector:@selector(lineColorOfGuestureOnState:)]) {
                self.lineColor = [self.delegate lineColorOfGuestureOnState:DBButtonStateIncorrect];
            }
            
            //As default
            self.fillColor = [UIColor lightTextColor];
            if ([self.delegate respondsToSelector:@selector(colorForFillingButtonCircleOnState:)]) {
                self.fillColor = [self.delegate colorForFillingButtonCircleOnState:DBButtonStateIncorrect];
            }
            
            //As default
            self.strokeColor = [UIColor orangeColor];
            if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleStrokeOnState:)]) {
                self.strokeColor = [self.delegate colorOfButtonCircleStrokeOnState:DBButtonStateIncorrect];
            }
            
            //As default
            self.centerPointColor = [UIColor orangeColor];
            if ([self.delegate respondsToSelector:@selector(colorOfButtonCircleCenterPointOnState:)]) {
                self.centerPointColor = [self.delegate colorOfButtonCircleCenterPointOnState:DBButtonStateIncorrect];
            }
            
            //self.circleRadius = self.circleRadius;
            if (_incorrectCount < kIncorrectCount_Max) {
                [self performSelector:@selector(lockState:) withObject:[NSArray arrayWithObject:[NSNumber numberWithInteger:DBButtonStateNormal]] afterDelay:1.f];
            }
            break;
        default:
            break;
    }
}




@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
