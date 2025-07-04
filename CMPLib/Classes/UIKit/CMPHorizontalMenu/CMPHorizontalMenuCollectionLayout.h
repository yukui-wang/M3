//
//  CMPHorizontalMenuCollectionLayout.h
//  YFMHorizontalMenu
//
//  Created by CMP on 2018/11/26.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPHorizontalMenuCollectionLayout : UICollectionViewLayout

@property (nonatomic,assign) NSInteger rowCount;

@property (nonatomic,assign) NSInteger columCount;

/**
 获取当前页数

 @return 页数
 */
-(NSInteger)currentPageCount;
@end
