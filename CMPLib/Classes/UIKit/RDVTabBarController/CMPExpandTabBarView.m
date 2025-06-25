//
//  CMPExpandTabBarView.m
//  CMPLib
//
//  Created by Shoujian Rao on 2022/5/26.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "CMPExpandTabBarView.h"
#import "CMPExpandTabBarCollectionCell.h"
#import <CMPLib/UIImageView+WebCache.h>
@interface CMPExpandTabBarView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation CMPExpandTabBarView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.collectionView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}

- (void)setItemArray:(NSArray<NSDictionary *> *)itemArray{
    _itemArray = itemArray;
    [_collectionView reloadData];
}

//显示红点
- (void)showBadge:(NSInteger)index show:(BOOL)show{
    NSDictionary *d = _itemArray[index];
    [d setValue:@(show) forKey:@"showRedPoint"];
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _itemArray.count;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        return nil;
//    }
//    return nil;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CMPExpandTabBarCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CMPExpandTabBarCollectionCell" forIndexPath:indexPath];
    NSDictionary *item = _itemArray[indexPath.item];
    cell.titleLabel.text = item[@"title"];
    if ([item[@"titleNormalColor"] isKindOfClass:UIColor.class]) {
        cell.titleLabel.textColor = item[@"titleNormalColor"];
    }
    
    UIImage *defaultImage = item[@"defaultImage"];
    NSString *url = item[@"imageUrl"];
    [cell.iconIgv sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImage];
    BOOL showRedPoint = [item[@"showRedPoint"] boolValue];
    cell.redPointView.hidden = !showRedPoint;
    return cell;
}
    
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_ItemClickBlock) {
        _ItemClickBlock(_itemArray[indexPath.item]);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(floor(UIScreen.mainScreen.bounds.size.width/5.0), 60);
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(self.collectionView.bounds.size.width, 50);
//}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
//        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
//        layout.headerReferenceSize = CGSizeMake(kCMPOcrScreenWidth, 35);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[CMPExpandTabBarCollectionCell class] forCellWithReuseIdentifier:@"CMPExpandTabBarCollectionCell"];
//        [_collectionView registerClass:CMPOcrInvoiceFolderHeaderCell.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ide523452353453"];
    }
    return _collectionView;
}
@end
