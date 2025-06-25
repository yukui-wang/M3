//
//  CMPCopDrawerView.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/7.
//

#import "CMPCopDrawerView.h"
#import "CustomIconTiltleTableViewCell.h"
#import "CMPCopDrawerCollectionCell.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/MJExtension.h>
#import <CMPLib/Masonry.h>
#import "CMPSharePlugin.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/UIImage+CMPImage.h>
@interface CMPCopDrawerView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate, UITableViewDataSource>


@property (nonatomic,strong) NSArray *cDataArr;
@property (nonatomic,strong) NSArray *tDataArr;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *indicatorView;//拖动条形


@end

@implementation CMPCopDrawerView

- (instancetype)initViewWithCollectionData:(NSArray *)cDataArr tableData:(NSArray *)tDataArr withFrame:(CGRect)frame showIndicator:(BOOL)show{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 12.f;
        self.layer.masksToBounds = YES;
        
        self.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
        
        NSMutableArray *mCDataArr = [NSMutableArray new];
        [cDataArr enumerateObjectsUsingBlock:^(CMPCopDrawerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj mapModel];//根据key
            if (obj.title.length) {//有标题的才显示
                [mCDataArr addObject:obj];
            }
        }];
        
        NSMutableArray *mTDataArr = [NSMutableArray new];
        [tDataArr enumerateObjectsUsingBlock:^(CMPCopDrawerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj mapModel];
            if (obj.title.length) {//有标题的才显示
                [mTDataArr addObject:obj];
            }
        }];

        self.cDataArr = mCDataArr;//collection data
        self.tDataArr = mTDataArr;//list data
                
        //标题、取消等按钮
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 52)];
        [self addSubview:titleView];
        [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.width.mas_equalTo(self);
            make.height.mas_equalTo(52);
        }];
        
        //条形拖动view
        if (show) {
            _indicatorView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 36)/2, 6, 36, 4)];
            _indicatorView.layer.cornerRadius = 2.f;
            _indicatorView.layer.masksToBounds = YES;
            _indicatorView.backgroundColor = [[UIColor colorWithHexString:@"#92A4B5"] colorWithAlphaComponent:0.5];
            [self addSubview:_indicatorView];
            [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(6);
                make.width.mas_equalTo(36);
                make.height.mas_equalTo(4);
                make.centerX.mas_equalTo(self);
            }];
        }
        
        //关闭按钮
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(0, 10, 52, 42);
//        [closeBtn setImage:[UIImage imageNamed:@"ic_banner_close"] forState:(UIControlStateNormal)];
        
        UIImage *closeImg = [[UIImage imageNamed:@"ic_banner_close"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"icon-color"]];
        
        [closeBtn setImage:closeImg forState:(UIControlStateNormal)];
        
        [titleView addSubview:closeBtn];
        [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:(UIControlEventTouchUpInside)];
        
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.width.mas_equalTo(52);
            make.height.mas_equalTo(42);
            make.left.mas_equalTo(0);
        }];
        //标题
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((titleView.frame.size.width - 240)/2, 20, 240, 22)];
        titleLabel.text = SY_STRING(@"more_operations");// @"更多操作";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [titleView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.width.mas_equalTo(240);
            make.height.mas_equalTo(22);
            make.centerX.mas_equalTo(self);
        }];
        
        [self initCollectionView];
        
        if (tDataArr.count) {
            [self initTableView];
        }
        
        //增加某个item改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChanged:) name:kNotifyCMPCopDrawerItemChanged object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)itemChanged:(NSNotification *)notify{
    NSDictionary *param = notify.object;
    CMPCopDrawerModel *pDm = [CMPCopDrawerModel mj_objectWithKeyValues:param];
    if (pDm.key.length) {
        //下部分table
        __block CMPCopDrawerModel *dm;
        __block NSInteger dmIdx;
        
        [self.tDataArr enumerateObjectsUsingBlock:^(CMPCopDrawerModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.key isEqualToString:pDm.key]) {
                if (pDm.statusText) {
                    obj.statusText = pDm.statusText;
                }
                if (pDm.statusTextColor) {
                    obj.statusTextColor = pDm.statusTextColor;
                }
                obj.title = pDm.title;
                obj.stayIn = pDm.stayIn;
                obj.thumbImage = pDm.thumbImage;
                
                dm = obj;
                dmIdx = idx;
                *stop = YES;
            }
        }];
        //顶部collection
        if (dm) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dmIdx inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
        }else{
            [self.cDataArr enumerateObjectsUsingBlock:^(CMPCopDrawerModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.key isEqualToString:pDm.key]) {
                    if (pDm.statusText) {
                        obj.statusText = pDm.statusText;
                    }
                    if (pDm.statusTextColor) {
                        obj.statusTextColor = pDm.statusTextColor;
                    }
                    
                    dm = obj;
                    dmIdx = idx;
                    *stop = YES;
                }
            }];
            if (dm) {
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:dmIdx inSection:0]]];
            }
        }
    }
    
}

- (void)hideDragIndicator{
    self.indicatorView.hidden = YES;
}

- (void)closeAction{
    if (_CloseDrawerBlock) {
        _CloseDrawerBlock();
    }
}

#pragma mark - 上部分-横排列表
//创建collectionView
- (void)initCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 52+11, self.frame.size.width, 80) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[CMPCopDrawerCollectionCell class] forCellWithReuseIdentifier:@"CMPCopDrawerCollectionCell"];
    
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(52+11);
        make.height.mas_equalTo(80);
        make.left.right.mas_equalTo(0);
    }];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 14, 0, 0); // 上，左，下，右
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(76, 76);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat leftPadding = 20;
    CGFloat rightPadding = 30; // 最大留白
    CGFloat itemWidth = 76;
    CGFloat minimumSpacing = 8;
    CGFloat maximumSpacing = 12;
    // 计算一行可以完全显示的元素数量
    NSInteger itemCount = (self.frame.size.width - leftPadding - rightPadding + maximumSpacing) / (itemWidth + maximumSpacing);
    // 计算元素间距
    CGFloat itemSpacing = (self.frame.size.width - leftPadding - rightPadding - itemWidth * itemCount) / (itemCount + 1);
    // 如果计算出的间距小于最小间距或大于最大间距，就使用最小间距或最大间距
    itemSpacing = MAX(minimumSpacing, MIN(itemSpacing, maximumSpacing));
    return itemSpacing;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cDataArr.count; // 你可以根据你的需求修改这个值
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPCopDrawerModel *dm = self.cDataArr[indexPath.row];
    
    CMPCopDrawerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CMPCopDrawerCollectionCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    cell.layer.cornerRadius = 6.f;
    cell.layer.masksToBounds = YES;
    
//    cell.iconImageView.image = [UIImage imageNamed:dm.img];
    cell.nameLabel.text = dm.title?:@"";
    
    if (dm.img) {
        UIImage *img = [[UIImage imageNamed:dm.img] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"icon-color"]];
        cell.iconImageView.image = img;
    }else if(dm.localPath){
        UIImage *img = [[UIImage imageWithContentsOfFile:dm.localPath] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"icon-color"]];
        cell.iconImageView.image = img;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_ItemDidSelectedBlock) {
        CMPCopDrawerModel *dm = self.cDataArr[indexPath.row];
        if (!dm.stayIn) {
            [self closeAction];
        }
        _ItemDidSelectedBlock(dm);
    }
}

#pragma mark - 下部分table列表
//创建table
- (void)initTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(14, CMPCopDrawerView_TableY, self.frame.size.width - 28, self.frame.size.height - CMPCopDrawerView_TableY) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    [self.tableView registerClass:[CustomIconTiltleTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(CMPCopDrawerView_TableY);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
    }];
    
    self.tableView.layer.cornerRadius = 10.f;
    self.tableView.layer.masksToBounds = YES;
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)setTableViewHeight:(CGFloat)height{
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tDataArr.count; // 返回你的数据数量
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomIconTiltleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    
    CMPCopDrawerModel *dm = self.tDataArr[indexPath.row];
    
    if (dm.img) {
        UIImage *img = [[UIImage imageNamed:dm.img] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"icon-color"]];
        cell.iconImageView.image = img;
    }else if(dm.localPath){
        UIImage *img = [[UIImage imageWithContentsOfFile:dm.localPath] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"icon-color"]];
        cell.iconImageView.image = img;
    }
    
    //状态
    cell.statusLabel.text = dm.statusText.length?dm.statusText:@"";
    if (dm.statusTextColor.length) {
        cell.statusLabel.textColor = [UIColor colorWithHexString:dm.statusTextColor];
    }else{
        cell.statusLabel.textColor = UIColor.clearColor;
    }
    
    cell.titleLabel.text = dm.title?:@"";
    
    // 判断是否是最后一个cell，如果是就隐藏分割线
//    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
//        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
//    } else {
//        cell.separatorInset = UIEdgeInsetsMake(0, 14, 0, 0);
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50; // 设置单元格高度
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_ItemDidSelectedBlock) {
//        CMPSharePlugin *p = [CMPSharePlugin new];
//        [p moreShareUI_ChangeItem:nil];
        
        CMPCopDrawerModel *dm = self.tDataArr[indexPath.row];
        if (!dm.stayIn) {
            [self closeAction];
        }
        _ItemDidSelectedBlock(dm);
    }
}


@end
