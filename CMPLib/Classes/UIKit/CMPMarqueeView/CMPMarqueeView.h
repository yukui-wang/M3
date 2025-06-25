//
//  SyMarqueeView.h
//  WeiboUI
//
//  Created by weitong on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPBaseView.h"

@interface CMPMarqueeView : UIView{
    UIImageView                    *_backgroundImageView;
    UILabel                        *_textLable;
    UIButton                       *_closeButton;
    BOOL _showing;
    BOOL _autoHide;
    
}

@property(nonatomic, retain) UIImageView            *backgroundImageView;
@property(nonatomic, retain) UILabel                *textLable;
@property(nonatomic, assign) BOOL disablePop;

- (void)pop:(NSString *)text autoHide:(BOOL)autoHide animated:(BOOL)aAnimated immediately:(BOOL)aImmediate;
- (void)dismiss:(BOOL)animated;

@end
