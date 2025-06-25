//
//  CMPHorizontalMenuCollectionLayout.m
//  YFMHorizontalMenu
//
//  Created by CMP on 2018/11/26.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "CMPHorizontalMenuCollectionLayout.h"
#import "CMPConstant.h"

@interface CMPHorizontalMenuCollectionLayout ()

/**
 预计算 contentSize 大小
 */
@property (nonatomic,assign) CGSize contentSize;
/**
 预计算所有的 cell 布局属性
 */
@property (strong,nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes;

@end

@implementation CMPHorizontalMenuCollectionLayout

-(NSMutableArray<UICollectionViewLayoutAttributes *> *)layoutAttributes{
    if (_layoutAttributes == nil) {
        _layoutAttributes = [NSMutableArray array];
    }
    return _layoutAttributes;
}

-(NSInteger)currentPageCount{
    NSInteger rowCount = INTERFACE_IS_PHONE ? 5 : 8;
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    NSInteger pageCount = (count - 1) / rowCount + 1;
    return pageCount;
}

/**
 准备layout
 */
-(void)prepareLayout{
    // 清理数据源
    [self.layoutAttributes removeAllObjects];
    self.contentSize = CGSizeZero;
    
    NSInteger rowCount = INTERFACE_IS_PHONE ? 5 : 8;
    
    // 预先计算好所有的 layout 属性
    // 预计算 contentSize
    // 先要拿到 到底有多少个 item
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    NSInteger pageCount = (count - 1) / rowCount + 1;
    
    //预计算了contengSize
    self.contentSize = CGSizeMake(pageCount * self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    NSInteger index = 0;
    NSInteger itemWidth = self.collectionView.frame.size.width / rowCount;
    NSInteger itemHeight = self.collectionView.frame.size.height;
    
    //计算每个cell的属性大小
    for (NSInteger i = 0; i < count; i ++) {
        index = i;
        //创建索引
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //通过索引创建cell 布局属性
        // UICollectionViewLayoutAttributes 这个内部应该保存 cell 布局以及一些位置信息等等
        UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
        CGFloat x =  index * itemWidth;
        CGFloat y = 0;
        
        layoutAttribute.frame = CGRectMake(x, y, itemWidth, itemHeight);
        
        [self.layoutAttributes addObject:layoutAttribute];
    }
}

-(CGSize)collectionViewContentSize{
    return self.contentSize;
}

/**
 在指定区域范围内需要提供cell信息

 @param rect 执行区域
 @return 属性列表
 */
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray<UICollectionViewLayoutAttributes *> *visibledAttributes = [NSMutableArray array];
    [self.layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [visibledAttributes addObject:obj];
        }
    }];
    return visibledAttributes;
}

@end
