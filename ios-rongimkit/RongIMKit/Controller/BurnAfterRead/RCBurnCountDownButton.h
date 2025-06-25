//
//  RCBurnCountDownButton.h
//  RongIMKit
//
//  Created by linlin on 2018/6/7.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCBurnCountDownButton : UIButton

- (void)setBurnCountDownButtonHighlighted;

- (void)messageDestructing:(NSInteger)duration;

- (BOOL)isBurnCountDownButtonHighlighted;

@end
