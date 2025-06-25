//
//  UIViewController+KSSafeArea.m
//  CMPLib
//
//  Created by Kaku Songu on 5/10/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "UIViewController+KSSafeArea.h"
#import "SOSwizzle.h"
#import <objc/runtime.h>


@implementation UIViewController (KSSafeArea)

+ (void)load {
    SOSwizzleInstanceMethod([self class], @selector(loadView), @selector(sf_loadView));
    SOSwizzleInstanceMethod([self class], @selector(viewDidLoad), @selector(sf_viewDidLoad));
    SOSwizzleInstanceMethod([self class], @selector(updateViewConstraints), @selector(sf_updateViewConstraints));
    SOSwizzleInstanceMethod([self class], @selector(viewSafeAreaInsetsDidChange), @selector(sf_viewSafeAreaInsetsDidChange));
    SOSwizzleInstanceMethod([self class], @selector(viewWillLayoutSubviews), @selector(sf_viewWillLayoutSubviews));
    SOSwizzleInstanceMethod([self class], @selector(viewDidLayoutSubviews), @selector(sf_viewDidLayoutSubviews));
}

-(void)sf_loadView
{
    [self sf_loadView];
    
    UIView *baseSafeView = [[UIView alloc] init];
    baseSafeView.backgroundColor = [UIColor clearColor];
    baseSafeView.alpha = 0.0;
    baseSafeView.tag = 7799;
    baseSafeView.userInteractionEnabled = NO;
    [self.view insertSubview:baseSafeView atIndex:0];
}

- (void)sf_viewDidLoad {
    [self sf_viewDidLoad];
    if (self.automaticallyAdjustsScrollViewInsets) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)sf_updateViewConstraints
{
    [self sf_updateViewConstraints];
    
    [self _updateConstrantAction];
}


-(void)sf_viewSafeAreaInsetsDidChange
{
    [self sf_viewSafeAreaInsetsDidChange];
    
    [self _updateConstrantAction];
}

-(void)sf_viewWillLayoutSubviews
{
    [self sf_viewWillLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        
    }else{
        [self _updateConstrantAction];
    }
}

-(void)sf_viewDidLayoutSubviews
{
    [self sf_viewDidLayoutSubviews];
//    NSLog(@"%@‘s _baseSafeView frame : %@",NSStringFromClass(self.class),NSStringFromCGRect(self.baseSafeView.frame));
}

-(void)_updateConstrantAction
{
    UIEdgeInsets ef = ks_safeAreaInset(self.view);
    
    if (@available(iOS 11.0, *)) {
        
    }else{
        
        CGFloat _topSp = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat _bottomSp = 0;
        if (self.navigationController && self.navigationController.navigationBar.hidden==NO && (self.edgesForExtendedLayout == UIRectEdgeAll || self.edgesForExtendedLayout == UIRectEdgeTop) && !self.isNeedManualClipToTop) {
            
            _topSp = self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
            
        }
        if (self.tabBarController && self.tabBarController.tabBar.hidden == NO && self.tabBarController.tabBar.translucent == YES && (self.edgesForExtendedLayout == UIRectEdgeAll || self.edgesForExtendedLayout == UIRectEdgeBottom)) {
            
            if (self.navigationController.viewControllers.count==1) {
                _bottomSp = self.tabBarController.tabBar.bounds.size.height;
            }
        }
        ef.top = _topSp;
        ef.bottom = _bottomSp;
    }
    
//    [_baseSafeView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.offset(ef.top);
//        make.left.offset(ef.left);
//        make.bottom.offset(-ef.bottom);
//        make.right.offset(-ef.right);
//    }];
    
    CGRect selfViewFrame = self.view.frame;
    self.baseSafeView.frame = CGRectMake(selfViewFrame.origin.x+ef.left, selfViewFrame.origin.y+ef.top, selfViewFrame.size.width-ef.left-ef.right, selfViewFrame.size.height-ef.top-ef.bottom);
    
    
    if (self.baseSafeViewFrameChangedBlock) {
        self.baseSafeViewFrameChangedBlock(self.baseSafeView.frame,ef);
    }

}



-(UIView *)baseSafeView
{
    UIView *safeV = [self.view viewWithTag:7799];
    return safeV;
}



-(void)setIsNeedManualClipToTop:(BOOL)isNeedManualClipToTop
{
    objc_setAssociatedObject(self,
                             @selector(setIsNeedManualClipToTop:),
                             [NSNumber numberWithBool:isNeedManualClipToTop],
                             OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)isNeedManualClipToTop
{
    return [objc_getAssociatedObject(self, @selector(setIsNeedManualClipToTop:)) boolValue];
}

-(void)setBaseSafeViewFrameChangedBlock:(void (^)(CGRect,UIEdgeInsets))baseSafeViewFrameChangedBlock
{
    objc_setAssociatedObject(self,
                             @selector(setBaseSafeViewFrameChangedBlock:),
                             baseSafeViewFrameChangedBlock,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void(^)(CGRect,UIEdgeInsets))baseSafeViewFrameChangedBlock
{
    return objc_getAssociatedObject(self, @selector(setBaseSafeViewFrameChangedBlock:));
}

@end
