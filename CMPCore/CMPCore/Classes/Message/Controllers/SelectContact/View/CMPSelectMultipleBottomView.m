//
//  CMPSelectMultipleBottomView.m
//  M3
//
//  Created by Shoujian Rao on 2023/8/31.
//

#import "CMPSelectMultipleBottomView.h"
#import "CMPSelectContactCollectionCell.h"
#import <CMPLib/UIColor+Hex.h>
#import "CMPSelectContactManager.h"
#import "CMPSelectContactViewController.h"

@interface CMPSelectMultipleBottomView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic ,strong) UICollectionView *collectionView;
@property(nonatomic ,strong) UIButton *cancelBtn;
@property(nonatomic ,strong) UIButton *confirmBtn;
@property(nonatomic ,strong) UIView *line;

@property(nonatomic ,strong) NSMutableArray *selectedContatArray;
@end

@implementation CMPSelectMultipleBottomView

+(CGFloat)defaultHeight{
    if ([CMPSelectContactManager sharedInstance].selectedCidArr.count>0) {
        return 100.f;
    }else{
        return 50.f;
    }
}

- (void)setup
{
    _line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5f)];
    _line.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    [self addSubview:_line];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10.f;
    layout.minimumLineSpacing = 10.f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_collectionView];
    
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    _collectionView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    
    // 注册UICollectionViewCell
    [_collectionView registerClass:[CMPSelectContactCollectionCell class] forCellWithReuseIdentifier:@"CMPSelectContactCollectionCell"];
    
    //取消按钮
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_cancelBtn];
    
    _cancelBtn.layer.cornerRadius = 19.f;
    _cancelBtn.layer.borderColor = [UIColor cmp_colorWithName:@"theme-bgc"].CGColor;
    _cancelBtn.layer.borderWidth = 1.f;
    [_cancelBtn setTitle:SY_STRING(@"common_cancel") forState:(UIControlStateNormal)];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancelBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:(UIControlStateNormal)];
    
    [_cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    //确定按钮
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_confirmBtn];
    
    _confirmBtn.layer.cornerRadius = 19.f;
    _confirmBtn.backgroundColor = [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.5];
    [_confirmBtn setTitle:SY_STRING(@"common_ok") forState:(UIControlStateNormal)];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [_confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)cancelBtnAction{
    if (_cancelBtnBlcok) {
        _cancelBtnBlcok();
    }
    if(self.viewController){
        NSArray *vcs = self.viewController.navigationController.viewControllers;
        for (UIViewController *vc in vcs) {
            if([vc isKindOfClass:NSClassFromString(@"CMPSelectContactViewController")]){
                CMPSelectContactViewController *contactVC = (CMPSelectContactViewController *)vc;
                [self.viewController.navigationController popToViewController:contactVC animated:YES];
            }
        }
    }
}

- (void)confirmBtnAction{
    if (![CMPSelectContactManager sharedInstance].selectedCidArr.count) {
        return;
    }
    
    if(self.confirmBtnBlcok){
        self.confirmBtnBlcok();
    }
    
    if([CMPSelectContactManager sharedInstance].sendView){
        return;
    }
    
    NSMutableArray *targetArr = [NSMutableArray new];
    [[CMPSelectContactManager sharedInstance].selectedCidArr enumerateObjectsUsingBlock:^(NSString *  _Nonnull cid, NSUInteger idx, BOOL * _Nonnull stop) {
        [targetArr addObject:[[CMPSelectContactManager sharedInstance].selectedContact objectForKey:cid]];
    }];
    if (targetArr.count>0) {
        [[CMPSelectContactManager sharedInstance]showForwardView:targetArr toView:self.viewController.view inVC:self.viewController];
    }    
}

- (void)refreshData{
    [self.selectedContatArray removeAllObjects];
    NSArray *arr = [CMPSelectContactManager sharedInstance].selectedCidArr;
    
    for (NSString *cid in arr) {
        NSDictionary *contact = [[CMPSelectContactManager sharedInstance].selectedContact objectForKey:cid];
        [self.selectedContatArray addObject:contact];
    }
    [_collectionView reloadData];
    
    NSString *btnTitle = SY_STRING(@"common_ok");
    if (self.selectedContatArray.count > 0) {
        btnTitle = [NSString stringWithFormat:@"%@(%ld)",SY_STRING(@"common_ok"),self.selectedContatArray.count];
    }
    [_confirmBtn setTitle:btnTitle forState:(UIControlStateNormal)];
    
    if(self.selectedContatArray.count){
        _confirmBtn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    }else{
        _confirmBtn.backgroundColor = [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.5];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedContatArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPSelectContactCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CMPSelectContactCollectionCell" forIndexPath:indexPath];
    cell.textLabel.backgroundColor = [UIColor colorWithHexString:@"#F3F4F9"];//#F3F4F9
    NSDictionary *dict = [self.selectedContatArray objectAtIndex:indexPath.item];
    cell.textLabel.text = dict[@"name"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.selectedContatArray objectAtIndex:indexPath.item];
    NSString *cid = dict[@"cid"];
    
    [[CMPSelectContactManager sharedInstance] delSelectContact:cid];
    
    [self refreshData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [self.selectedContatArray objectAtIndex:indexPath.item];
    NSString *contentText = dict[@"name"];
    CGSize textSize = [contentText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    CGSize cellSize = CGSizeMake(MAX(textSize.width + 20, 50) , 30); // 添加一些额外的间距 textSize.height + 10
    return cellSize;
}

- (void)customLayoutSubviews{
    NSArray *arr = [CMPSelectContactManager sharedInstance].selectedCidArr;
    CGFloat collectionH = arr.count>0?50.f:1.f;
    
    _line.frame = CGRectMake(0, 0, self.bounds.size.width, 0.5f);
    _collectionView.frame = CGRectMake(0, 0.5f, self.bounds.size.width, collectionH);
    CGFloat y = CGRectGetMaxY(_collectionView.frame) + 6;
    CGFloat w = (self.bounds.size.width - 20*2 - 20)/2;
    _cancelBtn.frame = CGRectMake(20, y, w, 38);
    CGFloat x = CGRectGetMaxX(_cancelBtn.frame) + 20;
    _confirmBtn.frame = CGRectMake(x, y, w, 38);
}

- (NSMutableArray *)selectedContatArray{
    if(!_selectedContatArray){
        _selectedContatArray = [NSMutableArray new];
    }
    return _selectedContatArray;
}

@end
