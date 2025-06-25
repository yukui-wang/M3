//
//  RCLocationPickerViewController+CMP.m
//  M3
//
//  Created by Kaku Songu on 3/31/22.
//

#import "RCLocationPickerViewController+CMP.h"
#import <CMPLib/SOSwizzle.h>
#import <objc/runtime.h>

@implementation RCLocationPickerViewController (CMP)

+ (void)load {
    SOSwizzleInstanceMethod([self class], @selector(viewDidLoad), @selector(RCLocationPicker_viewDidLoad));
}

- (void)RCLocationPicker_viewDidLoad {
    //V5-24777
    if (@available(iOS 15.0, *)) {
        UIView *aView = [[UIView alloc] init];
        aView.backgroundColor = [UIColor lightGrayColor];
        aView.frame = CGRectMake(0, -100, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.view addSubview:aView];
    }
    [self RCLocationPicker_viewDidLoad];
}

@end
