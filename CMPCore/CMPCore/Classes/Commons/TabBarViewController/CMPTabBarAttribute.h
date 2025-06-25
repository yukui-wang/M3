//
//  CMPTabBarAttribute.h
//  CMPCore
//
//  Created by yang on 2017/2/15.
//
//

#import <Foundation/Foundation.h>

@interface CMPTabBarAttribute : NSObject
@property (nonatomic,copy) NSString *iconNormalColor;
@property (nonatomic,copy) NSString *iconSelectedColor;
@property (nonatomic,copy) NSString *titleColor;
@property (nonatomic,copy) NSString *titleSelectedColor;
@property (nonatomic,copy) NSString *titleFontName;
@property (nonatomic,assign) int titleFontSize;
@property (nonatomic,copy) NSString *bgColor;

/// V8.0新增属性
@property (nonatomic,copy) NSString *bgImg;
@property (nonatomic,copy) NSString *theme;
@end
