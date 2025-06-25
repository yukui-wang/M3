//
//  CMPBubbleTipsView.h
//  CMPLib
//
//  Created by MacBook on 2019/12/11.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPBubbleTipsView : UIView

/* popBubble view的颜色 */
@property (strong, nonatomic) UIColor *viewColor;
/* arrowPointX */
@property (assign, nonatomic) CGFloat arrowPointX;
/* cornerRadius */
@property (assign, nonatomic) CGFloat cornerRadius;

@end

NS_ASSUME_NONNULL_END
