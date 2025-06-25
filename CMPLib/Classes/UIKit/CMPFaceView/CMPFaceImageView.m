//
//  CMPFaceImageView.m
//  CMPCore
//
//  Created by wujiansheng on 16/9/6.
//
//

#import "CMPFaceImageView.h"

@implementation CMPFaceImageView

@synthesize memberId = memberId_, type,circularColor = circularColor_;

- (void)dealloc {
    [memberId_ release];
    [circularColor_ release];
    circularColor_ = nil;
    [super dealloc];
}

@end
