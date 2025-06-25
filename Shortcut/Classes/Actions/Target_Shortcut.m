//
//  Target_Shortcut.m
//  ShortcutMenu
//
//  Created by CRMO on 2019/3/29.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "Target_Shortcut.h"
#import "CMPShortcutView.h"

@interface Target_Shortcut()<CMPShortcutViewDelegate>
@property (copy, nonatomic) void(^selectAction)(NSUInteger index);
@property (copy, nonatomic) void(^closeAction)(void);
@property (strong, nonatomic) CMPShortcutView *shortcutView;
@end

@implementation Target_Shortcut

- (void)Action_show:(NSDictionary *)params {
    UIView *parentView = params[@"pararentView"];
    NSArray *items = params[@"items"];
    self.selectAction = params[@"selectAction"];
    self.closeAction = params[@"closeAction"];
    NSMutableArray *aItems = [NSMutableArray array];
    
    for (NSDictionary *item in items) {
         [aItems addObject:[CMPShortcutItemModel yy_modelWithDictionary:item]];
    }
    
    self.shortcutView = [CMPShortcutView showInView:parentView shortcuts:[aItems copy] delegate:self];
}

- (void)Action_hide:(NSDictionary *)params {
    [self.shortcutView dismissWithoutAnimation];
    self.shortcutView = nil;
}

#pragma mark-
#pragma mark CMPShortcutViewDelegate

- (void)shortcutDidClose:(id)shortcut {
    if (self.closeAction) {
        self.closeAction();
    }
    self.shortcutView = nil;
}

- (void)shortcut:(id)shortcut selectedIndex:(NSUInteger)index {
    if (self.selectAction) {
        self.selectAction(index);
    }
     self.shortcutView = nil;
}

@end
