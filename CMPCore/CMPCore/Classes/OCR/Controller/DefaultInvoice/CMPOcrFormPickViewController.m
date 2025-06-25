//
//  CMPOcrFormPickViewController.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/14.
//

#import "CMPOcrFormPickViewController.h"
#import "CMPOcrInvoiceFolderItemCell.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>
#import "CMPOcrNotificationKey.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrMainViewModel.h"
#import "CMPOcrInvoiceCategoryEditViewModel.h"

@interface CMPOcrFormPickViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView       *backView;
@property (nonatomic, strong) UIView       *containerView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIButton      *cancelButton;
@property (nonatomic, strong) UIButton      *doneButton;
@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) CMPOcrMainViewModel *mainViewModel;
@property (nonatomic, strong) CMPOcrInvoiceCategoryEditViewModel *editViewModel;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) CMPOcrModuleItemModel *selectedModel;

@property (nonatomic, copy) void(^CompletionBlock)(CMPOcrModuleItemModel *);


@end

@implementation CMPOcrFormPickViewController

- (void)dealloc{
    NSLog(@"%@-delloc",self.class);
}

- (instancetype)initWithCompletion:(void(^)(CMPOcrModuleItemModel *))completion{
    if (self = [super init]) {
        self.CompletionBlock = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self loadData];
}

- (void)loadData{
    __weak typeof(self) weakSelf = self;
    [self.editViewModel fetchAllModulesToDefaultInvoiceWithParams:@{@"auth":@(YES)} completion:^(NSArray * _Nonnull modules, NSError * _Nonnull error, id  _Nonnull ext) {
        if (error) {
            [weakSelf cmp_showHUDError:error];
        }else{
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.dataSource addObjectsFromArray:modules];
            [weakSelf.collectionView reloadData];
        }
    }];
}

- (void)setupViews {
    [self setHideBannerNavBar:YES];
    
    [self.view addSubview:self.backView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.titleLabel];
    [self.titleLabel addSubview:self.doneButton];
    [self.titleLabel addSubview:self.cancelButton];
    [self.containerView addSubview:self.collectionView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.containerView);
        make.height.mas_equalTo(55);
    }];
    
    [_titleLabel addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight radii:CGSizeMake(12, 12) rect:CGRectMake(0, 0, kCMPOcrScreenWidth, 55)];

    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.titleLabel).offset( -15);
        make.top.mas_equalTo(self.titleLabel);
        make.width.height.mas_equalTo(55);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel).offset(15);
        make.top.mas_equalTo(self.titleLabel);
        make.width.height.mas_equalTo(55);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.bottom.mas_equalTo(self.containerView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.containerView);
    }];
}
#pragma mark - collectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceFolderItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CMPOcrInvoiceFolderItemCell" forIndexPath:indexPath];
    CMPOcrModuleItemModel *moudle = [self.dataSource objectAtIndex:indexPath.item];
    cell.title = moudle.templateName;
    cell.createFolder = NO;
    cell.selected = [self.selectedModel.oid isEqual:moudle.oid];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedModel = [self.dataSource objectAtIndex:indexPath.item];
    [self.collectionView reloadData];
}

#pragma mark - action
- (void)backViewAction {
    [self hiddenViewAnimate:nil];
}

- (void)cancelButtonAction {
    [self hiddenViewAnimate:nil];
}

- (void)doneButtonAction {
    if (!self.selectedModel) {
        [self cmp_showHUDWithText:@"请选择表单"];
        return;
    }
    if (self.CompletionBlock) {
        [self hiddenViewAnimate:^{
            self.CompletionBlock(self.selectedModel);
        }];
    }
}

- (void)showTargetVC:(UIViewController *)viewController {
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.view.backgroundColor = [UIColor clearColor];
    viewController.definesPresentationContext = YES;
    [viewController presentViewController:self animated:NO completion:^{
        [self showViewAnimate];
    }];
}

- (void)showViewAnimate {
    [UIView animateWithDuration:0.1 animations:^{
        self.backView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.containerView.frameY = kScreenHeight - kScreenHeight*0.6;
        }];
    }];
}

- (void)hiddenViewAnimate:(void(^)(void))completion{
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.frameY = kScreenHeight;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.backView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:completion];
        }];
    }];
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = kCMPOcrScreenWidth - 32;
        CGFloat itemHeight = 32;
        CGFloat margin = 15;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, margin, margin, margin);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsMake(3, 0, 0, 0);
        [_collectionView registerNib:[UINib nibWithNibName:@"CMPOcrInvoiceFolderItemCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CMPOcrInvoiceFolderItemCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = ESFontPingFangMedium(14);
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor cmp_specColorWithName:@"theme-bdc"] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = ESFontPingFangMedium(14);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = ESBoldFont(16);
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"请选择表单";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.userInteractionEnabled = YES;
    }
    return _titleLabel;
}

- (UIView *)containerView {
    if (!_containerView) {
        CGFloat offsetY = kScreenHeight;
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, kCMPOcrScreenWidth, kScreenHeight * 0.6)];
    }
    return _containerView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCMPOcrScreenWidth, kScreenHeight)];
        _backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _backView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewAction)];
        [_backView addGestureRecognizer:tap];
        [self.view addSubview:_backView];
    }
    return _backView;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(CMPOcrMainViewModel *)mainViewModel
{
    if (!_mainViewModel) {
        _mainViewModel = [[CMPOcrMainViewModel alloc] init];
    }
    return _mainViewModel;
}

- (CMPOcrInvoiceCategoryEditViewModel *)editViewModel{
    if (!_editViewModel) {
        _editViewModel = [[CMPOcrInvoiceCategoryEditViewModel alloc]init];
    }
    return _editViewModel;
}

@end
