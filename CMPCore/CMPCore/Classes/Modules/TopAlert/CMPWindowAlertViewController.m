//
//  CMPWindowAlertViewController.m
//  M3
//
//  Created by Kaku Songu on 12/1/22.
//

#import "CMPWindowAlertViewController.h"
#import "CMPWindowAlertBaseView.h"

@interface CMPWindowAlertViewController ()<CMPWindowAlertBaseViewDelegate>

@property (nonatomic,strong) NSMutableArray *alertViewsArr;
@property (nonatomic,weak) __block CMPWindowAlertBaseView *showingView;

@end

@implementation CMPWindowAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
}

-(BOOL)_toShow:(CMPWindowAlertBaseView *)alertView
{
    if (alertView && !_showingView){
        [self.view addSubview:alertView];
        CGFloat h = [alertView defaultHeight];
        CMPDirection showDir = [alertView defaultShowDirection];
        [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(10);
            make.right.offset(-10);
            make.height.equalTo(h);
            if (showDir == CMPDirection_Bottom) {
                make.bottomMargin.equalTo(h);
            }else{
                make.topMargin.equalTo(-h);
            }
        }];
        _showingView = alertView;
        _showingView.baseDelegate = self;
        __weak typeof(self) wSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.6 animations:^{
                [alertView mas_updateConstraints:^(MASConstraintMaker *make) {
                    if (showDir == CMPDirection_Bottom) {
                        make.bottomMargin.equalTo(-0);
                    }else{
                        make.topMargin.equalTo(10);
                    }
                }];
                [wSelf.view layoutIfNeeded];
                
                if (wSelf.showingView.defaultDismissTime > 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(wSelf.showingView.defaultDismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf _toRemove:wSelf.showingView result:^(BOOL success) {
                            if (success) {
                                [wSelf showNext];
                            }
                        }];
                    });
                }
            }];
        });
        
        return YES;
    }
    return NO;
}

-(void)_toRemove:(CMPWindowAlertBaseView *)alertView result:(void(^)(BOOL success))rslt
{
    if (alertView) {
        CGFloat h = [alertView defaultHeight];
        __weak typeof(self) wSelf = self;
        [UIView animateWithDuration:0.5 animations:^{
            CMPDirection dismissDir = [alertView defaultDismissDirection];
            [alertView mas_updateConstraints:^(MASConstraintMaker *make) {
                if (dismissDir == CMPDirection_Bottom) {
                    make.bottomMargin.equalTo(h);
                }else{
                    make.topMargin.equalTo(-h);
                }
            }];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [wSelf.alertViewsArr removeObject:alertView];
            if ([alertView isEqual:wSelf.showingView]) {
                wSelf.showingView.baseDelegate = nil;
                [wSelf.showingView removeFromSuperview];
                wSelf.showingView = nil;
            }
            if (!wSelf.alertViewsArr.count) {
                if (wSelf.dismissBlk) {
                    wSelf.dismissBlk(wSelf);
                }
            }
            if (rslt) rslt(YES);
        }];
    }else{
        if (rslt) rslt(YES);
    }
}

-(BOOL)showNext
{
    if (_alertViewsArr && _alertViewsArr.count){
        CMPWindowAlertBaseView *toShowV = self.alertViewsArr.firstObject;
        return [self _toShow:toShowV];
    }
    return NO;
}

-(BOOL)showFront:(CMPWindowAlertBaseView *)alertView
{
    if (alertView && [alertView isKindOfClass:CMPWindowAlertBaseView.class]){
        [self.alertViewsArr insertObject:alertView atIndex:0];
        return [self showNext];
    }
    return NO;
}

-(BOOL)showBehind:(CMPWindowAlertBaseView *)alertView
{
    if (alertView && [alertView isKindOfClass:CMPWindowAlertBaseView.class]){
        [self.alertViewsArr addObject:alertView];
        return [self showNext];
    }
    return NO;
}

-(UIView *)showingAlertView
{
    return _showingView;
}

-(void)cmpWindowAlertBaseView:(CMPWindowAlertBaseView *)alertView didAct:(CMPWindowAlertBaseViewAction)action ext:(id)ext
{
    switch (action) {
        case CMPWindowAlertBaseViewActionDismiss:
        {
            [self _toRemove:alertView result:^(BOOL success) {
                [self showNext];
            }];
        }
            break;
            
        default:
            break;
    }
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (_showingView) {
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:_showingView];
//        if (CGRectContainsPoint([_showingView frame], point)) {
//            return;
//        }
//    }
//    [[CMPCommonManager keyWindow] touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (_showingView) {
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:_showingView];
//        if (CGRectContainsPoint([_showingView frame], point)) {
//            return;
//        }
//    }
//    [[UIApplication sharedApplication].keyWindow touchesMoved:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (_showingView) {
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:_showingView];
//        if (CGRectContainsPoint([_showingView frame], point)) {
//            return;
//        }
//    }
//    [[UIApplication sharedApplication].keyWindow touchesEnded:touches withEvent:event];
//}

-(NSMutableArray *)alertViewsArr
{
    if (!_alertViewsArr){
        _alertViewsArr = [NSMutableArray array];
    }
    return _alertViewsArr;
}

@end
