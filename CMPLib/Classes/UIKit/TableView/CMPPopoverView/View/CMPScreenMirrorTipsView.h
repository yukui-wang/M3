//
//  CMPScreenMirrorTipsView.h
//  CMPLib
//
//  Created by MacBook on 2019/11/6.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPScreenMirrorTipsView : UIView

+ (instancetype)viewWithFrame:(CGRect)frame;

/* checkClicked */
@property (copy, nonatomic) void(^checkClicked)(void);

@end

NS_ASSUME_NONNULL_END
