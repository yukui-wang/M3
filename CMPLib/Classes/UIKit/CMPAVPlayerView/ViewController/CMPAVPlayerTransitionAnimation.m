//
//  CMPAVPlayerTransitionAnimation.m
//  CMPLib
//
//  Created by MacBook on 2020/2/27.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPAVPlayerTransitionAnimation.h"
#import "CMPAVPlayerViewController.h"

#import <CMPLib/UIView+CMPView.h>

@implementation CMPAVPlayerTransitionAnimation

//返回动画事件
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.25f;
}

//所有的过渡动画事务都在这个方法里面完成
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    switch (_transitionType) {
        case CMPAVPlayerTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
        case CMPAVPlayerTransitionTypeDissmiss:
            [self dismissAnimation:transitionContext];
            break;
        case CMPAVPlayerTransitionTypePush:
            [self pushAnimation:transitionContext];
            break;
        case CMPAVPlayerTransitionTypePop:
            [self popAnimation:transitionContext];
            break;
    }
    
}

#pragma mark - transitionType

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    //通过viewControllerForKey取出转场前后的两个控制器，这里toVC就是转场后的VC、fromVC就是转场前的VC
    CMPAVPlayerViewController *toVC = (CMPAVPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //取出转场前后视图控制器上的视图view
    UIView *fromView = fromVC.view;//[transitionContext viewForKey:UITransitionContextFromViewKey];
    //这里有个重要的概念containerView，如果要对视图做转场动画，视图就必须要加入containerView中才能进行，可以理解containerView管理着所有做转场动画的视图
    UIView *containerView = [transitionContext containerView];
    
    //snapshotViewAfterScreenUpdates 对cell的imageView截图保存成另一个视图用于过渡，并将视图转换到当前控制器的坐标
    UIView *tempView = [fromView snapshotViewAfterScreenUpdates:NO];
    toVC.view.cmp_x = toVC.view.width;
    
    //设置动画前的各个控件的状态
    //tempView 添加到containerView中，要保证在最上层，所以后添加
    [containerView addSubview:tempView];
    [containerView addSubview:toVC.view];
    
    //开始做动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toVC.view.cmp_x = 0;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        //如果动画过渡取消了就标记不完成，否则才完成，这里可以直接写YES，如果有手势过渡才需要判断，必须标记，否则系统不会中断动画完成的部署，会出现无法交互之类的bug
        [transitionContext completeTransition:YES];
    }];
    
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    //通过viewControllerForKey取出转场前后的两个控制器，这里toVC就是转场后的VC、fromVC就是转场前的VC
    CMPAVPlayerViewController *fromVC = (CMPAVPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //取出转场前后视图控制器上的视图view
    UIView *fromView = fromVC.view;
    
    UIView *containerView = [transitionContext containerView];
    
    //截图
    UIView *tempView = [fromView snapshotViewAfterScreenUpdates:NO];
    //设置阴影
    tempView.layer.shadowOffset = CGSizeMake(0,-3.f);
    tempView.layer.shadowColor = UIColor.blackColor.CGColor;
    tempView.layer.shadowRadius = 5.f;
    tempView.layer.shadowOpacity = 0.75f;
    
    //tempView 添加到containerView中
    fromView.alpha = 0;
    [containerView addSubview:tempView];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        tempView.cmp_x = tempView.width;
    } completion:^(BOOL finished) {
        //由于加入了手势必须判断
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {
            //失败了隐藏tempView，显示fromView
            [tempView removeFromSuperview];
            fromView.alpha = 1.f;
        }else{
            //手势成功，cell的imageView也要显示出来
            //成功了移除tempView，下一次pop的时候又要创建，然后显示cell的imageView
            [tempView removeFromSuperview];
        }
    }];
    
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
        //如果动画过渡取消了就标记不完成，否则才完成，这里可以直接写YES，必须标记，否则系统不会中断动画完成动作，会一直处于动画过程中，出现无法交互之类的bug
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
     //完成转场
     [transitionContext completeTransition:YES];
    
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    //由于加入了手势必须判断
    [transitionContext completeTransition:YES];
}


@end
