//
//  CMPCallIdentificationGuideViewController.m
//  M3
//
//  Created by CRMO on 2018/4/12.
//

#import "CMPCallIdentificationGuideViewController.h"
#import "CMPCallIdentificationGuideView.h"

@implementation CMPCallIdentificationGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CMPCallIdentificationGuideView *view = (CMPCallIdentificationGuideView *)self.mainView;
    [view.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [view.kownButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
