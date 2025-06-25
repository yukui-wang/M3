//
//  Target_Shortcut.h
//  ShortcutMenu
//
//  Created by CRMO on 2019/3/29.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_Shortcut : NSObject

- (void)Action_show:(NSDictionary *)params;
- (void)Action_hide:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
