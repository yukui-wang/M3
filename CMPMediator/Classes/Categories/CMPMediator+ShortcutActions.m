//
//  CMPMediator+ShortcutMenuActions.m
//  CMPMediator
//
//  Created by CRMO on 2019/3/29.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPMediator+ShortcutActions.h"

NSString * const kCMPMediatorTargetShortcut = @"Shortcut";
NSString * const kCMPMediatorActionShow = @"show";
NSString * const kCMPMediatorActionHide = @"hide";

@implementation CMPMediator (ShortcutActions)

- (void)CMPMediator_showShortcutInView:(UIView *)view
                                 items:(NSArray *)items
                          selectAction:(CMPMediatorShortcutSelectAction)selectAction
                           closeAction:(_Nullable CMPMediatorShortcutCloseAction)closeAction {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:view forKey:@"pararentView"];
    [params setObject:items forKey:@"items"];
    if (selectAction) {
        [params setObject:selectAction forKey:@"selectAction"];
    }
    
    __weak __typeof(self)weakSelf = self;
    CMPMediatorShortcutCloseAction close = ^{
        [weakSelf releaseCachedTargetWithTargetName:kCMPMediatorTargetShortcut];
        if (closeAction) {
            closeAction();
        }
    };
    [params setObject:close forKey:@"closeAction"];
    
    [self performTarget:kCMPMediatorTargetShortcut
                 action:kCMPMediatorActionShow
                 params:[params copy]
      shouldCacheTarget:YES];
}

- (void)CMPMediator_hideShortcut {
    [self performTarget:kCMPMediatorTargetShortcut
                 action:kCMPMediatorActionHide
                 params:nil
      shouldCacheTarget:YES];
    [self releaseCachedTargetWithTargetName:kCMPMediatorTargetShortcut];
}

@end
