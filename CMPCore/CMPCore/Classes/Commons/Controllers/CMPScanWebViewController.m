//
//  CMPScanWebViewController.m
//  CMPCore
//
//  Created by wujiansheng on 2017/7/22.
//
//

#import "CMPScanWebViewController.h"
#import "SyScanViewController.h"
#import <CMPLib/NSObject+CMPHUDView.h>


@interface CMPScanWebViewController () {
}

@end

@implementation CMPScanWebViewController

- (void)dealloc
{
    [_scanViewController.view removeFromSuperview];
    [_scanViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    NSLog(@"self.startPage = %@",self.startPage);
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [self.startPage replaceCharacter:@"file://" withString:@""];
    if (![manager fileExistsAtPath:path]) {
        NSString *nativePath = [[NSBundle mainBundle] pathForResource:@"m3-scan-page" ofType:@"html"];
        self.startPage = [NSString stringWithFormat:@"file://%@", nativePath];
    }
    [super viewDidLoad];
    if (!_scanViewController) {
        _scanViewController = [[SyScanViewController scanViewController] retain];
        __weak typeof(self) weakSelf = self;
        _scanViewController.scanWebViewController = weakSelf;
        _scanViewController.scanImage = self.scanImage;
        if (!self.scanImage) {
            [self.view addSubview:_scanViewController.view];
        }
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_scanViewController viewWillAppear:animated];
    
    if (self.scanImage) {
        [self showLoadingView];
        //延迟扫描操作，以便设置_scanViewController的delegate
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideLoadingView];
            [_scanViewController handleGivenImage:self.scanImage];
        });
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_scanViewController viewWillDisappear:animated];
}

- (void)dismissSubViewsAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [_scanViewController viewWillDisappear:NO];
    [_scanViewController.view removeFromSuperview];
    [_scanViewController release];
    _scanViewController = nil;
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    NSString *title = self.scanViewController.title;
    return title;
}

@end
