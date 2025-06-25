//
//  RCTipLabel+Custom.m
//  CMPCore
//
//  Created by CRMO on 2017/9/7.
//
//

#import "RCTipLabel+Custom.h"

@implementation RCTipLabel(Custom)

- (void)setText:(NSString *)text { // 数字不显示超链接
    [self setText:text dataDetectorEnabled:NO];
}

@end
