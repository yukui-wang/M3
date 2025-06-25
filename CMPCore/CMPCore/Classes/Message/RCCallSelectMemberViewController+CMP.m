//
//  RCCallSelectMemberViewController+CMP.m
//  M3
//
//  Created by Kaku Songu on 9/14/23.
//

#import "RCCallSelectMemberViewController+CMP.h"
#import <CMPLib/SOSwizzle.h>

@implementation RCCallSelectMemberViewController (CMP)

+ (void)load {
    SOSwizzleInstanceMethod(self, @selector(viewDidAppear:),@selector(rc_viewDidAppear:));
}

-(void)rc_viewDidAppear:(BOOL)animated{
    [self rc_viewDidAppear:animated];
    //设置1
//    if (@available(iOS 16.0, *)){
//        self.navigationController.navigationBar.translucent = NO;
//        [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
//    }
    //设置2
    if (@available(iOS 16.0, *)) {
        self.navigationController.navigationBar.translucent = NO;
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
           [navBarAppearance configureWithOpaqueBackground];
           [navBarAppearance setTitleTextAttributes:
                   @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        self.navigationController.navigationBar.standardAppearance = navBarAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance;
    }
}

@end
