//
//  RDVTabBar+Download.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2024/1/3.
//

#import "RDVTabBar+Download.h"
#import "CMPZipDownProgressView.h"
#import "CMPDownoadTipView.h"
#import <CMPLib/SOSwizzle.h>
#import "CMPZipDownProgressViewPad.h"
#import <CMPLib/CMPCommonTool.h>
#import "CMPCheckUpdateManager.h"

@implementation RDVTabBar (Download)

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(void)load{
    SOSwizzleInstanceMethod([self class], @selector(layoutSubviews),@selector(cmp_tabbar_layoutSubviews));
}

-(void)cmp_tabbar_layoutSubviews{
    [self cmp_tabbar_layoutSubviews];
    if (self.orientation == RDVTabBarVertical) {
        CGSize _r = self.bounds.size;
        CGFloat _w=24,_h=24;
        if (self.shortcutItems && self.shortcutItems.count) {
            RDVTabBarShortcutItem *item = self.shortcutItems.firstObject;
            [[self progressViewPad] setFrame:CGRectMake(_r.width/2-_w/2, item.cmp_y-15-_h, _w, _h)];
        }else{
            [[self progressViewPad] setFrame:CGRectMake(_r.width/2-_w/2, _r.height-15-_h, _w, _h)];
        }
        [self tipView].basePoint = CGPointMake(CGRectGetMaxX([self progressViewPad].frame)+15, [self progressViewPad].center.y);
    }else{
        [[self progressView] setFrame:CGRectMake(0, -2, self.bounds.size.width, 2)];
        [self tipView].basePoint = CGPointMake(self.bounds.size.width/2, -2-8);
    }
}

-(void)addDownloadView
{
    
    CMPDownoadTipView *v2 = [self tipView];
    [self addSubview:v2];

    if (self.orientation == RDVTabBarVertical) {
       
        CMPZipDownProgressViewPad *v = [self progressViewPad];
        [self addSubview:v];
        v2.direction = 1;
        
    }else{
        CMPZipDownProgressView *v = [self progressView];
        [self insertSubview:v atIndex:0];//系统高度4，无法修改，高保真2
        
        __block CGPoint p;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            p = self.frame.origin;
        });
        self.tabbarMoveBlock = ^{
            if ([self progressView].hidden) return;
            CGFloat _y = self.cmp_y;
            //you wen ti
            CGFloat dis = fabsf((p.y-_y))<12.0 ? fabsf((p.y-_y)) : 12.0;
            CGFloat val = dis/12.0;
            CGFloat al = 1.0 - val;
            [self progressView].alpha = al;
        };
    }
    
    if ([CMPCheckUpdateManager sharedManager].firstDownloadDone && [CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerDownload && ([CMPCheckUpdateManager sharedManager].infoModel.currentProgress<1 && [CMPCheckUpdateManager sharedManager].infoModel.currentProgress>0)) {
        [self updateProgress:[CMPCheckUpdateManager sharedManager].infoModel.currentProgress];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appdownloadStateChanged:) name:kNotificationName_AppsDownload object:nil];
    
    //test
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tap)];
//    [self addGestureRecognizer:tap];
//    [self updateProgress:0.5];
//    [self showTip:@"应用资源下载中"];
}

//-(void)_tap{
//    UIViewController *vc = [CMPCommonTool getCurrentShowViewController];
//    NSLog(@"top ctrl:%@",vc);
//}

-(void)_tapProgressV:(UITapGestureRecognizer *)ges {
    CMPZipDownProgressViewPad *vv = ges.view;
    if (vv){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_progressViewDidTap" object:@(vv.state)];
    }
}

-(void)updateProgress:(CGFloat)progress
{
    if (self.orientation == RDVTabBarVertical) {
        [[self progressViewPad] setState:0];
        if ([self progressViewPad].hidden){
            [self updateDownloadHide:NO];
        }
        if ((progress<=0 || progress>=1)){
            [self updateDownloadHide:YES];
        }
    }else{
        [[self progressView] setState:0];
        if ([self progressView].hidden){
            [self updateDownloadHide:NO];
        }
        [[self progressView] setProgress:progress animated:YES];
        if ((progress<=0)){
            [self updateDownloadHide:YES];
        }
    }
}

-(void)updateDownloadState:(NSInteger)state
{
    if (self.orientation == RDVTabBarVertical) {
        [[self progressViewPad] setState:state];
        [[self progressViewPad] setHidden:NO];
    }else{
        [[self progressView] setState:state];
        if(state == 0) {
            [[self progressView] setHidden:NO];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateDownloadHide:YES];
            });
        }
    }
}

-(void)updateDownloadHide:(BOOL)hide
{
    if (self.orientation == RDVTabBarVertical) {
        [[self progressViewPad] setHidden:hide];
    }else{
        [[self progressView] setHidden:hide];
    }
}

-(void)showTip:(NSString *)tip
{
    if (!tip || tip.length == 0) return;
    [[self tipView] showInfo:tip];
}

-(void)_appdownloadStateChanged:(NSNotification *)noti{
    if (![CMPCheckUpdateManager sharedManager].firstDownloadDone) return;
    [self dispatchAsyncToMain:^{
        NSDictionary *ob = noti.object;
        NSLog(@"tabbar recieve noti:%@",ob);
        NSString *state = ob[@"state"];
        if (state && [state isKindOfClass:NSString.class]) {
            if ([@"progress" isEqualToString:state]) {
                NSNumber *val = ob[@"value"];
                [self updateProgress:val.floatValue];
            }else if ([@"start" isEqualToString:state]) {
                NSString *val = ob[@"value"];
                [self showTip:val];
            }else if ([@"cancel" isEqualToString:state]) {
                [self updateProgress:0];
            }else if ([@"success" isEqualToString:state]) {
                NSString *val = ob[@"value"];
                if ([@"download" isEqualToString:val]){
                    [self updateDownloadState:1];
                }
            }else if ([@"fail" isEqualToString:state]) {
                NSString *val = ob[@"value"];
                if ([@"download" isEqualToString:val]){
                    [self updateDownloadState:2];
                }
            }else if ([@"alert" isEqualToString:state]) {
                NSString *val = ob[@"value"];
                if ([@"err_alert_click" isEqualToString:val]
                    ||[@"success_alert_click" isEqualToString:val]){
                    [self updateDownloadHide:YES];
                }
            }
        }
    }];
}


-(CMPZipDownProgressView *)progressView
{
    UIView *v = [self viewWithTag:226677];
    if (v && [v isKindOfClass:CMPZipDownProgressView.class]) return v;
    CMPZipDownProgressView *vv = [[CMPZipDownProgressView alloc] init];
    vv.hidden = YES;
    vv.tag = 226677;
    return vv;
}

-(CMPDownoadTipView *)tipView
{
    UIView *v = [self viewWithTag:227788];
    if (v && [v isKindOfClass:CMPDownoadTipView.class]) return v;
    CMPDownoadTipView *vv = [[CMPDownoadTipView alloc] init];
    vv.tag = 227788;
    return vv;
}


-(CMPZipDownProgressViewPad *)progressViewPad
{
    UIView *v = [self viewWithTag:228899];
    if (v && [v isKindOfClass:CMPZipDownProgressViewPad.class]) return v;
    CMPZipDownProgressViewPad *vv = [[CMPZipDownProgressViewPad alloc] init];
    vv.hidden = YES;
    vv.tag = 228899;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapProgressV:)];
    [vv addGestureRecognizer:tap];
    return vv;
}

@end
