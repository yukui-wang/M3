//
//  CMPIconInfo.h
//  iconfont
//
//  Created by yang on 2017/2/13.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CMPIconInfo : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, retain) UIColor *color;

- (instancetype)initWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color;
+ (instancetype)iconInfoWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color;

@end
