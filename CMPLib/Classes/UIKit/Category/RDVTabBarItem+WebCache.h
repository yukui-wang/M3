//
//  RDVTabBarItem+WebCache.h
//  CMPLib
//
//  Created by CRMO on 2017/11/13.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import "RDVTabBarItem.h"

@interface RDVTabBarItem(WebCache)

/**
 设置未选中图标

 @param imageUrl 未选中图标网络Url
 @param placeHolder 占位图本地路径
 */
- (void)cmp_setImageUrl:(NSString *)imageUrl placeHolder:(UIImage *)placeHolder;

/**
 设置选中图标

 @param imageUrl 选中图标网络URL
 @param placeHolder 占位图本地路径
 */
- (void)cmp_setSelectedImageUrl:(NSString *)imageUrl placeHolder:(UIImage *)placeHolder;

@end
