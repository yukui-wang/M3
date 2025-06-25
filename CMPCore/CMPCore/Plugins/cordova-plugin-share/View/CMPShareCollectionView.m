//
//  CMPShareCollectionView.m
//  M3
//
//  Created by MacBook on 2019/10/29.
//

#import "CMPShareCollectionView.h"
#import "CMPShareCollectionViewCell.h"
#import "CMPShareViewLayout.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPCore.h>


static CGFloat const kViewMargin = 10.f;
static NSInteger const kPhoneRowCount = 5;
NSInteger const kRowCount = 6;


@interface CMPShareCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>

/* topCollectionView */
@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation CMPShareCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    CMPShareViewLayout *lo = [[CMPShareViewLayout alloc] init];
    /// collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kViewMargin, 0, self.width - 2*kViewMargin, self.height) collectionViewLayout:lo];
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:@"CMPShareCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CMPShareCollectionViewCellId];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CMPShareCollectionViewCellId forIndexPath:indexPath];
    if (self.isDefaultList) {
        CMPShareCellModel *model = self.dataArray[indexPath.row];
        cell.shareModel = model;
    }else {
        CMPShareBtnModel *model = self.dataArray[indexPath.row];
        cell.shareBtnModel = model;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (CMP_IPAD_MODE) return CGSizeMake(CMP_SCREEN_WIDTH/kRowCount, self.height);
    
    return CGSizeMake(CMP_SCREEN_WIDTH/kPhoneRowCount, self.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPShareCellModel *shareCellModel = nil;
    CMPShareBtnModel *shareBtnModel = nil;
    if (self.isDefaultList) {
        shareCellModel = self.dataArray[indexPath.row];
    }else {
        shareBtnModel = self.dataArray[indexPath.row];
    }
    
    if ([self.delegate respondsToSelector:@selector(shareCollectionView:didSelectItemAtIndexPath:shareCellModel:shareBtnModel:)]) {
        [self.delegate shareCollectionView:collectionView didSelectItemAtIndexPath:indexPath shareCellModel:shareCellModel shareBtnModel:shareBtnModel];
    }
}

#pragma mark - 外部方法

- (void)reloadData {
    [_collectionView reloadData];
}

@end
