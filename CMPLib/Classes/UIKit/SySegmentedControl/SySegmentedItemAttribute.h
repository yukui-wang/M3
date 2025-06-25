//
//  SySegmentedItemAttribute.h
//  M1Core
//
//  Created by guoyl on 12-12-27.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CMPObject.h"

typedef  NS_ENUM(NSUInteger, SySegmentedItemAttribute_Type){
    SySegmentedItemAttribute_Type_Blue = 1,
    SySegmentedItemAttribute_Type_Normal = 2,
    SySegmentedItemAttribute_Type_Wathet = 5

  
};
typedef  NS_ENUM(NSUInteger, SySegmentedItemAttribute_Position){
    SySegmentedItemAttribute_Position_First = 1,
    SySegmentedItemAttribute_Position_Middle = 2,
    SySegmentedItemAttribute_Position_Last = 3
    
};

@interface SySegmentedItemAttribute : CMPObject
@property (nonatomic, copy)NSString *title; //  标题
@property (nonatomic, retain)UIImage *image; // image
@property (nonatomic, retain)UIImage *rightImage; //  右边图标
@property (nonatomic, retain)UIImage *rightSelectedImage; //  右边图标
@property (nonatomic, retain)id userInfo;  // 用户自定义数据
@property (nonatomic, retain)UIFont *titleFont; // 字体
@property (nonatomic, retain)UIColor *titleColor; // 标题颜色
@property (nonatomic, retain)UIFont *selectedTitleFont;
@property (nonatomic, retain)UIColor *selectedTitleColor;
@property (nonatomic, assign)UIEdgeInsets rightImageEdgeInsets;                // default is UIEdgeInsetsZero
@property (nonatomic, retain)UIImage *selectedBackgroundImage; 
@property (nonatomic, retain)UIImage *backgroundImage;
@property (nonatomic, assign)UIEdgeInsets imageEdgeInsets;                // default is UIEdgeInsetsZero
@property (nonatomic, retain)UIImage *bottomImage;
@property (nonatomic, retain)UIImage *selectedBottomImage;
@property (nonatomic, assign)CGFloat marginTitleAndImage; // default is 5.0 
@property (nonatomic, assign)UIEdgeInsets titleEdgeInsets;
@property (nonatomic, assign)NSInteger segmentedItemTag;
@property(nonatomic,assign) NSInteger viewType;//1 iphone  2 iphone底部
@property (nonatomic, assign) SySegmentedItemAttribute_Position position;
@end
