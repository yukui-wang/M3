//
//  JXPagerView+CMP.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/12/29.
//

#import "JXPagerView+CMP.h"
#import <CMPLib/SOSwizzle.h>

@implementation JXPagerView (CMP)

+ (void)load {
    SOSwizzleInstanceMethod(self, @selector(refreshTableHeaderView),@selector(cmp_pagerView_refreshTableHeaderView));
}

-(void)cmp_pagerView_refreshTableHeaderView
{
    UIView *tableHeaderView = [self.delegate tableHeaderViewInPagerView:self];
    if (!tableHeaderView) {
        return;
    }
    [self cmp_pagerView_refreshTableHeaderView];
}

@end
