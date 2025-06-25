//
//  CMPExpandTabBarView.h
//  CMPLib
//
//  Created by Shoujian Rao on 2022/5/26.
//  Copyright © 2022 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CMPExpandTabBarView : UIView

/**
 @{ @"title":@"xxx",
    @"defaultImage":defaultImage,
    @"imageUrl":@"xxx",
    @"appId":@"xxx"
 }
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *itemArray;

@property (nonatomic, copy) void(^ItemClickBlock)(id);
- (void)showBadge:(NSInteger)index show:(BOOL)show;

@end

