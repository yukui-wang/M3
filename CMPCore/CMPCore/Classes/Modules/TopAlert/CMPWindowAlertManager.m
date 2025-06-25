//
//  CMPWindowAlertManager.m
//  M3
//
//  Created by Kaku Songu on 12/1/22.
//

#import "CMPWindowAlertManager.h"
#import "CMPWindowAlertViewController.h"
#import "CMPWindowAlertBaseView.h"

@interface CMPWindowAlertManager()
{
    UIWindow *_mainWindow;
    CMPWindowAlertViewController *_mainVC;
}
@end

@implementation CMPWindowAlertManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

-(void)_instant
{
    if (!_mainVC) {
        _mainVC = [[CMPWindowAlertViewController alloc] init];
        _mainVC.dismissBlk = ^(id  _Nullable ext) {
            _mainWindow.rootViewController = nil;
            _mainWindow.hidden = true;
            _mainWindow = nil;
        };
    }
    if (!_mainWindow) {
        _mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _mainWindow.rootViewController = _mainVC;
        _mainWindow.windowLevel = UIWindowLevelAlert;
        _mainWindow.hidden = true;
//        _mainWindow.backgroundColor = [UIColor brownColor];
    }
}

-(void)showBehind:(UIView *)alertView
{
    [self _instant];
    if (alertView && [alertView isKindOfClass:CMPWindowAlertBaseView.class]){
        CGRect r = [UIScreen mainScreen].bounds;
        CGFloat sth = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat h = sth + 20 + [((CMPWindowAlertBaseView *)alertView) defaultHeight];
        r.size.height = h;
        _mainWindow.frame = r;
    }
    _mainWindow.hidden = false;
    [_mainVC showBehind:alertView];
}


- (void)handleDeviceOrientationChange:(NSNotification *)notification {
//    if (_mainWindow && _mainVC) {
//        CGRect curOldFrame = _mainWindow.frame;
//        CGRect r = [UIScreen mainScreen].bounds;
//        CGFloat or = r.size.height;
//        CGFloat h = 0;
//        UIView *alertView = [_mainVC showingAlertView];
//        if (alertView && [alertView isKindOfClass:CMPWindowAlertBaseView.class]){
//            CGFloat sth = [UIApplication sharedApplication].statusBarFrame.size.height;
//            h = sth + 20 + [((CMPWindowAlertBaseView *)alertView) defaultHeight];
////            r.size.height = h;
//        }
//
//        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//        switch (orientation) {
//            case UIDeviceOrientationPortrait:
//            {
//                r.size.height = h;
//            }
//                break;
//            case UIDeviceOrientationPortraitUpsideDown:
//            {
//                r.origin.y = or - h;
//                r.size.height = h;
//            }
//                break;
//            case UIDeviceOrientationLandscapeLeft:
//            {
//
//            }
//                break;
//            case UIDeviceOrientationLandscapeRight:
//            {
//
//            }
//                break;
//
//            default:
//                break;
//        }
//        _mainWindow.frame = curOldFrame;
////        [_mainWindow layoutIfNeeded];
//    }
}

@end
