//
//  CMPOcrModulesManageCollectionView.m
//  M3
//
//  Created by Kaku Songu on 12/21/21.
//

#import "CMPOcrModulesManageCollectionView.h"
#import <CMPLib/KSLabel.h>
#import "CMPOcrInvoiceFolderItemCell.h"

@interface CMPOcrModulesManageCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) CMPOcrModulesManageCollectionViewModel *viewModel;

@end

@implementation CMPOcrModulesManageCollectionView

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        self.viewModel;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

    }
    return self;
}

-(void)setEdit:(BOOL)edit
{
    _edit = edit;
    self.viewModel.state = edit ? 1 : 0;
    if (!edit) {
        self.viewModel.itemsArr = [NSArray arrayWithArray:self.viewModel.itemsEditArr];
        if (self.actBlk) {
            self.actBlk(1, self.viewModel.itemsEditArr, self.viewController);
        }
    }
    [self.collectionView reloadData];
}

-(void)setItems:(NSArray *)items
{
    if (items) {
        self.viewModel.itemsArr = items;
        self.viewModel.itemsEditArr = [[NSMutableArray alloc] initWithArray:items];
        [self.collectionView reloadData];
    }
}

-(CMPOcrModulesManageCollectionViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPOcrModulesManageCollectionViewModel alloc] init];
    }
    return _viewModel;
}

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 18;
        layout.minimumInteritemSpacing = 7;
        layout.sectionHeadersPinToVisibleBounds = YES;
//        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
//        layout.headerReferenceSize = CGSizeMake(kCMPOcrScreenWidth, 35);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];

        [_collectionView registerClass:[CMPOcrModulesManageCollectionViewCell class] forCellWithReuseIdentifier:@"cellid4354332424"];
        [_collectionView registerClass:CMPOcrInvoiceFolderHeaderCell.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ide523452353453"];
        
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longGes:)];
        [_collectionView addGestureRecognizer:longGes];
    }
    
    return _collectionView;
}

-(void)_longGes:(UILongPressGestureRecognizer *)ges
{
    if (!_edit) {
        return;
    }
    CGPoint p = [ges locationInView:self.collectionView];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
            if (!indexPath) {
                break;;
            }
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self.collectionView updateInteractiveMovementTargetPosition:p];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.collectionView endInteractiveMovement];
        }
            break;
            
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.viewModel toShowArr].count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ((NSArray *)([self.viewModel toShowArr][section])).count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CMPOcrInvoiceFolderHeaderCell *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ide523452353453" forIndexPath:indexPath];
        [header setTitle:indexPath.section == 0 ? @"常用分类" : @"更多分类"];
        if (indexPath.section == 1) {
            header.descLabel.text = @"";
        }else{
            header.descLabel.text =_edit?@"可拖拽排序":@"";
        }
        [header remakeTitleConstraint];
        return header;
    }
    return nil;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CMPOcrModulesManageCollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid4354332424" forIndexPath:indexPath];
    NSArray *items = [self.viewModel toShowArr][indexPath.section];
    if (indexPath.row < items.count) {
        CMPOcrModulesManageCollectionItem *model = [items objectAtIndex:indexPath.row];
        cell.indexPath = indexPath;
        [cell setItem:model];
        NSInteger editType = 0;
        if (_edit) {
            switch (indexPath.section) {
                case 0:
                    editType = 1;
                    break;
                case 1:
                    editType = 2;
                    break;
                    
                default:
                    break;
            }
        }
        [cell setEditType:editType];
        __weak typeof(self) wSelf = self;
        cell.actBlk = ^(NSInteger act, id  _Nonnull ext,NSIndexPath *indexPath) {
            switch (act) {
                case 0:
                    break;
                case 1://jian
                {
                    if (self.viewModel.itemsEditArr.count>=2) {
                        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:self.viewModel.itemsEditArr[0]];
                        if (arr1.count<=1) {
                            return;
                        }
                        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:self.viewModel.itemsEditArr[1]];
                        [arr1 removeObjectAtIndex:indexPath.row];
                        [arr2 addObject:ext];
                        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
                        [set addIndex:0];
                        [set addIndex:1];
                        [self.viewModel.itemsEditArr replaceObjectsAtIndexes:set withObjects:@[arr1,arr2]];
                        [wSelf.collectionView reloadData];
                    }
                }
                    break;
                case 2://jia
                    if (self.viewModel.itemsEditArr.count>=2) {
                        NSMutableArray *arr1 = [NSMutableArray arrayWithArray:self.viewModel.itemsEditArr[0]];
                        NSMutableArray *arr2 = [NSMutableArray arrayWithArray:self.viewModel.itemsEditArr[1]];
                        [arr2 removeObjectAtIndex:indexPath.row];
                        [arr1 addObject:ext];
                        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
                        [set addIndex:0];
                        [set addIndex:1];
                        [self.viewModel.itemsEditArr replaceObjectsAtIndexes:set withObjects:@[arr1,arr2]];
                        [wSelf.collectionView reloadData];
                    }
                    break;
                    
                default:
                    break;
            }
        };
    }
    return cell;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_edit) {
        return;
    }
    if (self.actBlk) {
        self.actBlk(0, indexPath, self.viewController);
    }
}


-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_edit) {
        return NO;
    }
    if (indexPath.section == 0 && ((NSArray *)[self.viewModel toShowArr][0]).count<=1) {
        return NO;
    }
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath == sourceIndexPath) {
        return;
    }
    NSMutableArray *sourceArr = [NSMutableArray arrayWithArray:self.viewModel.itemsEditArr[sourceIndexPath.section]];
    if (destinationIndexPath.section == sourceIndexPath.section) {
        [sourceArr exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        self.viewModel.itemsEditArr[sourceIndexPath.section] = sourceArr;
        [self.collectionView reloadData];
        return;
    }
    id sourceObj = sourceArr[sourceIndexPath.row];
    NSMutableArray *destArr = [NSMutableArray arrayWithArray:self.viewModel.itemsEditArr[destinationIndexPath.section]];
    [destArr insertObject:sourceObj atIndex:destinationIndexPath.row];
    [sourceArr removeObjectAtIndex:sourceIndexPath.row];
    [self.viewModel.itemsEditArr replaceObjectAtIndex:sourceIndexPath.section withObject:sourceArr];
    [self.viewModel.itemsEditArr replaceObjectAtIndex:destinationIndexPath.section withObject:destArr];
    [self.collectionView reloadData];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.bounds.size.width, 30);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.bounds.size.width, 50);
}

@end



@interface CMPOcrModulesManageCollectionViewCell()
{
    UIButton *_funcBtn;
    CMPOcrModulesManageCollectionItem *_item;
    UIView *_baseV;
}
@end

@implementation CMPOcrModulesManageCollectionViewCell

-(KSLabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[KSLabel alloc] init];
        _titleLb.textColor = [UIColor blackColor];
        _titleLb.font = [UIFont systemFontOfSize:12];
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
                
        _baseV = [[UIView alloc] init];
        _baseV.backgroundColor = UIColorFromRGB(0xF4F4F4);
        _baseV.layer.cornerRadius = 15;
        _baseV.layer.masksToBounds = YES;
        _baseV.clipsToBounds = YES;
        [self.contentView addSubview:_baseV];
        [_baseV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        [_baseV addSubview:self.titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(25);
            make.right.offset(-25);
            make.top.bottom.offset(0);
        }];
        
        _funcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_funcBtn setBackgroundColor:[UIColor clearColor]];
        [_funcBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_funcBtn addTarget:self action:@selector(_funcBtnAct:) forControlEvents:UIControlEventTouchUpInside];
        [_funcBtn sizeToFit];
        [_baseV addSubview:_funcBtn];
        [_funcBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.left.offset(5);
        }];
    }
    return self;
}
- (void)setHighlighted:(BOOL)highlighted{
    if (highlighted) {
        _baseV.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bgc"];
        self.titleLb.textColor = UIColor.whiteColor;
    }else{
        _baseV.backgroundColor = UIColorFromRGB(0xF4F4F4);
        self.titleLb.textColor = UIColor.blackColor;
    }
}

-(void)setTitle:(NSString *)title
{
    self.titleLb.text = title;
}

-(void)setIsSelected:(BOOL)isSelected
{
    self.titleLb.textColor = isSelected ? [UIColor cmp_specColorWithName:@"main-fc"] : [UIColor cmp_specColorWithName:@"desc-fc"];
}

-(void)setItem:(CMPOcrModulesManageCollectionItem *)item
{
    _item = item;
    if (item) {
        [self setTitle:item.title];
    }
}

-(void)setEditType:(NSInteger)editType
{
    _editType = editType;
    switch (_editType) {
        case 1:
        {
            [_funcBtn setTitle:@"-" forState:UIControlStateNormal];
            _funcBtn.hidden = NO;
        }
            break;
        case 2:
        {
            [_funcBtn setTitle:@"+" forState:UIControlStateNormal];
            _funcBtn.hidden = NO;
        }
            break;
            
        default:
        {
            [_funcBtn setImage:IMAGE(@"") forState:UIControlStateNormal];
            _funcBtn.hidden = YES;
        }
            break;
    }
}

-(void)_funcBtnAct:(UIButton *)btn
{
    if (_actBlk) {
        _actBlk(_editType,_item,_indexPath);
    }
}

@end


@implementation CMPOcrModulesManageCollectionViewCellHeaderView

-(void)setTitle:(NSString *)title
{
    
}

@end
