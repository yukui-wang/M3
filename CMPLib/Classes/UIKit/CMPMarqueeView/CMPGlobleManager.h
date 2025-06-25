//
//  SyGlobleManager.h
//  WeiboUI
//
//  Created by weitong on 12-7-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define kNotificationName_DismissModalView @"notificationName_DismissModalView"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CMPObject.h"

@class CMPMarqueeView;
@class CMPModalView;

@interface CMPGlobleManager : NSObject {
    CMPMarqueeView                                     *_globeMarqueeView;
    BOOL                                               _isPoping;
    CMPModalView *_modalView;
}

@property(nonatomic,retain) CMPMarqueeView          *globeMarqueeView;

+ (CMPGlobleManager *)sharedSyGlobleManager;

- (void)pushMarqueeView:(NSString *)text;
- (void)pushMarqueeViewDelay:(NSString *)text;
- (void)pushMarqueeView:(NSString *)text autoHide:(BOOL)aAutoHide animated:(BOOL)aAnimated;
- (void)dismissMarqueeView:(BOOL)animated;
- (void)setPopMarqueeViewEnable:(BOOL)enable;
- (void)pushMarqueeView:(NSString *)text autoHide:(BOOL)aAutoHide animated:(BOOL)aAnimated immediately:(BOOL)aImmediately;
//
- (void)popModalViewWithContentView:(UIView *)aContentView autoHide:(BOOL)autoHide;
- (void)presentView:(UIView *)aView fromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;
- (void)dismissModalView:(BOOL)animated;

@end
