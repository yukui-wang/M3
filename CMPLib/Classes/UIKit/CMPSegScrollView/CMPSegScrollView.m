//
//  CMPSegScrollView.m
//  CMPLib
//
//  Created by Kaku Songu on 4/7/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "CMPSegScrollView.h"
#import "KSLabel.h"
#import "Masonry.h"
@implementation CMPSegScrollViewItem
-(NSString *)title
{
    if (!_title || ![_title isKindOfClass:[NSString class]]) {
        return @"";
    }
    return _title;
}
@end


@interface CMPSegScrollViewCell : UICollectionViewCell

@property (nonatomic,strong) KSLabel *titleLb;
@property (nonatomic,strong) UIView *indicatorView;

-(void)setTitle:(NSString *)title;
-(void)setIsSelected:(BOOL)isSelected;

@end


@implementation CMPSegScrollViewCell

-(KSLabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[KSLabel alloc] init];
        _titleLb.textColor = [UIColor grayColor];
        _titleLb.font = [UIFont systemFontOfSize:16];
        _titleLb.textAlignment = NSTextAlignmentCenter;
//        _titleLb.layer.cornerRadius = 10;
//        _titleLb.layer.borderWidth = 0.5;
//        _titleLb.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        _titleLb.layer.masksToBounds = YES;
//        _titleLb.edgeInsets = UIEdgeInsetsMake(4, 15, 4, 13);
    }
    return _titleLb;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        _indicatorView = [[UIView alloc] init];
        _indicatorView.layer.cornerRadius = 2;
        _indicatorView.backgroundColor = [UIColor cmp_colorWithName:@"theme-bdc"];
        [self addSubview:_indicatorView];
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.height.equalTo(@4);
            make.width.equalTo(@30);
            make.centerX.equalTo(_titleLb);
        }];
        _indicatorView.hidden = YES;
    }
    return self;
}


-(void)setTitle:(NSString *)title
{
    self.titleLb.text = title;
}

-(void)setIsSelected:(BOOL)isSelected
{
    _indicatorView.hidden = !isSelected;
    self.titleLb.textColor = isSelected ? [UIColor cmp_colorWithName:@"main-fc"] : [UIColor cmp_colorWithName:@"desc-fc"];
}

@end


@interface CMPSegScrollView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation CMPSegScrollView

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
        [self addSubview:self.collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

    }
    return self;
}

-(void)setItemsArr:(NSArray<CMPSegScrollViewItem *> *)itemsArr
{
    if (_itemsArr != itemsArr) {
        _itemsArr = itemsArr;
        [self.collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           
            CGFloat w1 = self.bounds.size.width;
            CGFloat w2 = self.collectionView.contentSize.width;
            if (w2 >= w1) {
                
                [self->_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self);
                }];
                
                self->_collectionView.scrollEnabled = YES;
                
            }else{
                
                [self->_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.equalTo(self);
                    make.center.equalTo(self);
                    make.width.equalTo(w2);
                }];
                
                self->_collectionView.scrollEnabled = NO;
            }
        });
    }
    
}

-(void)setIndex:(NSInteger)index
{
    if (index == _index) {
        return;
    }
    NSInteger beforeIndex = _index;
    _index = index;
    if (_index<0) {
        _index = 0;
    }
    if (_itemsArr && _index >= _itemsArr.count) {
        _index = 0;
    }
    NSIndexPath *beforePath = [NSIndexPath indexPathForRow:beforeIndex inSection:0];
    NSIndexPath *nowPath = [NSIndexPath indexPathForRow:_index inSection:0];
    if (beforeIndex < _itemsArr.count) {
        [self.collectionView reloadItemsAtIndexPaths:@[beforePath,nowPath]];
    }else{
        [self.collectionView reloadItemsAtIndexPaths:@[nowPath]];
    }
}

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 7;
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 38);
        
        [_collectionView registerClass:[CMPSegScrollViewCell class] forCellWithReuseIdentifier:@"cellid432424242"];
        
    }
    
    return _collectionView;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.itemsArr.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CMPSegScrollViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid432424242" forIndexPath:indexPath];
    if (indexPath.row < self.itemsArr.count) {
        CMPSegScrollViewItem *model = [self.itemsArr objectAtIndex:indexPath.row];
        [cell setTitle:model.title];
        [cell setIsSelected:_index == indexPath.row];
    }
    return cell;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.itemsArr.count) {
        self.index = indexPath.row;
        if (_delegate && [_delegate respondsToSelector:@selector(cmpSegScrollView:didClickItem:)]) {
            
            [_delegate cmpSegScrollView:self didClickItem:[self.itemsArr objectAtIndex:indexPath.row]];
        }
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMPSegScrollViewItem *model = [self.itemsArr objectAtIndex:indexPath.row];
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize  size = [model.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return CGSizeMake(size.width+30, 45);
}

@end
