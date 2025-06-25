//
//  RCBurnCountDownButton.m
//  RongIMKit
//
//  Created by linlin on 2018/6/7.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCBurnCountDownButton.h"
#import "RCKitUtility.h"

@implementation RCBurnCountDownButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[RCKitUtility imageNamed:@"burn_image_time_normal" ofBundle:@"RongCloud.bundle"]
                        forState:UIControlStateNormal];
        [self setBackgroundImage:[RCKitUtility imageNamed:@"burn_image_time_highlighted" ofBundle:@"RongCloud.bundle"]
                        forState:UIControlStateHighlighted];
        self.userInteractionEnabled = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)setBurnCountDownButtonHighlighted {
    self.highlighted = YES;
}

- (BOOL)isBurnCountDownButtonHighlighted {
    __block BOOL isHighlighted = NO;
    if (self.highlighted == YES) {
        isHighlighted = YES;
    }
    return isHighlighted;
}

- (void)messageDestructing:(NSInteger)duration {
    NSNumber *whisperMsgDuration = @(duration);

    if (duration <= 0) {

    } else {
        NSDecimalNumber *subTime =
            [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", whisperMsgDuration]];
        NSDecimalNumber *divTime = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumberHandler *handel = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                                scale:0
                                                                                     raiseOnExactness:NO
                                                                                      raiseOnOverflow:NO
                                                                                     raiseOnUnderflow:NO
                                                                                  raiseOnDivideByZero:NO];
        NSDecimalNumber *showTime = [subTime decimalNumberByDividingBy:divTime withBehavior:handel];
        [self setTitle:[NSString stringWithFormat:@"%@", showTime] forState:UIControlStateHighlighted];
    }
}

@end
