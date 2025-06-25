//
//  CMPScreenShotView.h
//  CMPScreenShotView
//
//  Created by 郑文明 on 16/5/10.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPScreenShotView : UIView
@property (nonatomic, readonly) UIImageView *imgView;
@property (nonatomic, readonly) UIView *maskView;

- (void)showEffectChange:(CGPoint)pt;
- (void)restore;
- (void)setNoneEffect; // 不显示效果

@end
