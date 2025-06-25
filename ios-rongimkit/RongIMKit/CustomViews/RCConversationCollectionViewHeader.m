//
//  RCConversationTableHeaderView.m
//  RCIM
//
//  Created by xugang on 6/21/14.
//  Copyright (c) 2014 RongCloud. All rights reserved.
//

#import "RCConversationCollectionViewHeader.h"

@interface RCConversationCollectionViewHeader ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation RCConversationCollectionViewHeader

#pragma mark - Propertie
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        if (@available(iOS 13.0, *)) {
            _indicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _indicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    }
    return _indicatorView;
}

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.indicatorView];
    }
    return self;
}

#pragma mark - Override
- (void)layoutSubviews {
    self.indicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

#pragma mark - Api
- (void)startAnimating {
    [self.indicatorView startAnimating];
}
- (void)stopAnimating {
    if (self.indicatorView.isAnimating == YES) {
        [self.indicatorView stopAnimating];
    }
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_indicatorView setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
}

@end
