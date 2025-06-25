//
//  CMPOcrInvoiceFolderViewController.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import "CMPOcrInvoiceFolderViewController.h"
#import "CMPOcrInvoiceFolderItemCell.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPOcrPackageViewModel.h"
#import "CMPOcrNotificationKey.h"
#import <CMPLib/CMPAlertView.h>

@interface CMPOcrInvoiceFolderViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView       *backView;
@property (nonatomic, strong) UIView       *containerView;

@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIButton      *cancelButton;
@property (nonatomic, strong) UIButton      *doneButton;
@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) CMPOcrPackageViewModel *packageViewModel;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSArray *invoiceArr;
@property (nonatomic, copy) NSString *selectedPackageId;
@property (nonatomic, copy) NSString *selectedPackageName;
@property (nonatomic, copy) NSString *originPackageId;
@property (nonatomic, copy) void(^CompletionBlock)(NSArray *invoiceIdArray);

@end


@implementation CMPOcrInvoiceFolderViewController

- (void)dealloc{
    NSLog(@"%@-delloc",self.class);
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

- (void)hiddenViewAnimate {
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.frameY = kScreenHeight;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.backView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }];
}

- (instancetype)initWithInvoiceArr:(NSArray *)invoiceArr selectdPackageId:(NSString *)packageId completion:(void(^)(NSArray *))completion{
    if (self = [super init]) {
        self.invoiceArr = invoiceArr;
        self.originPackageId = packageId;
        self.selectedPackageId = packageId;
        self.CompletionBlock = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self loadData:nil];
}

- (void)loadData:(NSNotification *)noti{
    if (noti.object) {
        NSDictionary *dict = noti.object;
        self.selectedPackageId = dict[@"id"];
        _selectedPackageName = dict[@"name"];
    }
    [self.packageViewModel getPackageClassifyListCompletion:^(NSArray<CMPOcrPackageClassifyModel *> *classifyArr, NSError *err) {
        if (err) {
            [self cmp_showHUDError:err];
        }else{
            [self.dataSource removeAllObjects];
            CMPOcrPackageClassifyModel *classify = CMPOcrPackageClassifyModel.new;
            classify.templateName = @"";
            CMPOcrPackageModel *p1 = CMPOcrPackageModel.new;
            p1.pid = @"-2";
            p1.name = @"+ 新建包";
            CMPOcrPackageModel *p2 = CMPOcrPackageModel.new;
            NSString *cmp_ocr_defaultPackageId = [[NSUserDefaults standardUserDefaults] stringForKey:@"cmp_ocr_defaultPackageId"];
            p2.pid = cmp_ocr_defaultPackageId;
            p2.name = @"默认票夹";
            classify.rPackageList = @[p1,p2];
            [self.dataSource addObject:classify];
            [self.dataSource addObjectsFromArray:classifyArr];
            [self.collectionView reloadData];
        }
    }];

}

- (void)backViewAction {
    [self hiddenViewAnimate];
}

- (void)setupViews {
    [self setHideBannerNavBar:YES];
    [self.view addSubview:self.backView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.doneButton];
    [self.containerView addSubview:self.cancelButton];
    
    [self.containerView addSubview:self.collectionView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(55);
    }];
    [_titleLabel addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight radii:CGSizeMake(12, 12) rect:CGRectMake(0, 0, kCMPOcrScreenWidth, 55)];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.containerView).offset(-5);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.width.height.mas_equalTo(55);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(5);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.width.height.mas_equalTo(55);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.bottom.mas_equalTo(self.containerView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.containerView);
    }];
}

- (void)cancelButtonAction {
    [self hiddenViewAnimate];
}

- (void)doneButtonAction {
    if([_selectedPackageId isEqual:_originPackageId]){
        [self cmp_showHUDWithText:@"不能添加到当前报销包"];
        return;
    }
    
    NSString *tipStr = [NSString stringWithFormat:@"确定将所选票据移动至“%@”？",_selectedPackageName];// self.invoiceArr.count>1?@"包内发票将一并移动哦，请确定是否移动？":@"确认要移动该发票？";
    CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:nil message:tipStr cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] callback:^(NSInteger buttonIndex) {
        if(buttonIndex == 1){
            //完成操作
            NSString *pid = self.selectedPackageId;
            
            if (pid.integerValue != -2) {
                __weak typeof(self) weakSelf = self;
                [self.packageViewModel moveInvoice:self.invoiceArr toPackage:pid completion:^(BOOL success, NSError *err) {
                    if (err) {
                        [weakSelf cmp_showHUDError:err];
                    }
                    if (success) {
                        [weakSelf cmp_showHUDWithText:@"添加成功"];
                        [weakSelf hiddenViewAnimate];
                        if(weakSelf.CompletionBlock){
                            weakSelf.CompletionBlock(weakSelf.invoiceArr);
                        }
                    }else{
                        [weakSelf cmp_showHUDWithText:@"操作失败，未知原因"];
                    }
                }];
            }
        }
    }];
    [alert show];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceFolderItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CMPOcrInvoiceFolderItemCell" forIndexPath:indexPath];
    CMPOcrPackageClassifyModel *classify = self.dataSource[indexPath.section];
    CMPOcrPackageModel *package = classify.rPackageList[indexPath.row];
    cell.title = package.name;
    cell.createFolder = [package.pid isEqual:@"-2"];
    cell.selected = [package.pid isEqual:self.selectedPackageId];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CMPOcrPackageClassifyModel *classify = self.dataSource[section];
    return classify.rPackageList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CMPOcrInvoiceFolderHeaderCell *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"kLiveInfoShopwindowHeader" forIndexPath:indexPath];
        CMPOcrPackageClassifyModel *classify = self.dataSource[indexPath.section];
        header.title = classify.templateName;
        return header;
    }
    return UICollectionReusableView.new;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CMPOcrPackageClassifyModel *classify = self.dataSource[section];
    if (classify.templateName.length>0) {
        return CGSizeMake(kCMPOcrScreenWidth, 35);
    } else {
        return CGSizeMake(kCMPOcrScreenWidth, 0.1);
    }
    return CGSizeMake(0, 0);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrPackageClassifyModel *classify = self.dataSource[indexPath.section];
    CMPOcrPackageModel *package = classify.rPackageList[indexPath.row];
    self.selectedPackageId = package.pid;
    _selectedPackageName = package.name;
    if ([package.pid isEqual:@"-2"]) {
        [self creatPackage];
    }
//    else{
        [self.collectionView reloadData];
//    }
    
}

- (void)creatPackage{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData:) name:kNotificationCreateBagCall object:nil];
    
    CMPBannerWebViewController *webCtrl = [[CMPBannerWebViewController alloc] init];
    NSString *href = @"http://ocr.v5.cmp/v1.0.0/html/createOcr.html";
    href = [href urlCFEncoded];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    if ([NSString isNotNull:localHref]) {
        href = localHref;
    }
    webCtrl.hideBannerNavBar = NO;
    webCtrl.startPage = href;
    [self presentViewController:webCtrl animated:YES completion:^{}];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = (kCMPOcrScreenWidth-32-16)/2;
        CGFloat itemHeight = 32;
        CGFloat margin = 15;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.headerReferenceSize = CGSizeMake(kCMPOcrScreenWidth, 35);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, margin, margin, margin);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerNib:[UINib nibWithNibName:@"CMPOcrInvoiceFolderItemCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CMPOcrInvoiceFolderItemCell"];
        [_collectionView registerClass:CMPOcrInvoiceFolderHeaderCell.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"kLiveInfoShopwindowHeader"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor cmp_specColorWithName:@"theme-bdc"] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
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
        _titleLabel.text = @"将发票移至";
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

- (CMPOcrPackageViewModel *)packageViewModel{
    if (!_packageViewModel) {
        _packageViewModel = [[CMPOcrPackageViewModel alloc]init];
    }
    return _packageViewModel;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

//ks fix -- V5-38233【智能报销】iOS 移动发票，选择新建包又取消，移动提示有误
-(void)setSelectedPackageId:(NSString *)selectedPackageId
{
    _selectedPackageId = selectedPackageId;
    BOOL enable = ![_selectedPackageId isEqualToString:@"-2"];
    [self.doneButton setEnabled:enable];
    [_doneButton setTitleColor:enable ? [UIColor cmp_specColorWithName:@"theme-bdc"] : [[UIColor grayColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
}

@end
