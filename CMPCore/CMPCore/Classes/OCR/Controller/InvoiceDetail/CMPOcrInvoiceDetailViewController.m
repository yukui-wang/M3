//
//  CMPOcrInvoiceDetailViewController.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrInvoiceDetailViewController.h"
#import "CMPOcrInvoiceDetailListViewController.h"
#import <CMPLib/JXCategoryImageView.h>
#import <CMPLib/JXCategoryView.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>
#import "CMPOcrInvoiceDetailDataProvider.h"
#import "CMPOcrInvoiceDetailModel.h"
#import <CMPLib/UIImageView+WebCache.h>
#import "CMPOcrInvoiceModel.h"
#import <CMPLib/CMPAlertView.h>

@interface CMPOcrInvoiceDetailViewController ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate>
{
    UILabel *numLab;
}
@property (nonatomic, strong) CMPOcrInvoiceDetailListModel *detailModel;

@property (nonatomic, strong) NSMutableArray *imageNames;

@property (nonatomic, strong) JXCategoryImageView *myCategoryView;

@property (nonatomic, strong) CMPOcrInvoiceDetailDataProvider *dataProvider;

@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic,strong) NSMutableArray *invoiceTypesArr;
@property (nonatomic,strong) NSMutableArray *invoiceConsumeTypesArr;

@end

@implementation CMPOcrInvoiceDetailViewController
- (void)dealloc{
    NSLog(@"%@-dealloc",self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"票据详情";
    [self configCategoryView];
    [self setHeader];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.myCategoryView.frame = CGRectMake(0, IKNavAreaHeight, self.view.bounds.size.width, [self preferredCategoryViewHeight]);
    CGFloat offsetY = [self preferredCategoryViewHeight] + IKNavAreaHeight;
    self.listContainerView.frame = CGRectMake(0, offsetY, self.view.bounds.size.width, self.view.bounds.size.height - offsetY);
    
    if ([self canEdit]) {
        CGFloat footerHeight = 50+IKBottomSafeEdge;
        CGFloat footerOffsetY = self.view.height - footerHeight;
        self.footerView.frame = CGRectMake(0, footerOffsetY, kCMPOcrScreenWidth, footerHeight);
    }
}
//我的页面进入不允许编辑
- (BOOL)canEdit{
    return self.rdv_tabBarController.selectedIndex != 2;
}
- (void)configCategoryView {
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [self.view addSubview:self.myCategoryView];
    [self.view addSubview:self.listContainerView];
    if ([self canEdit]) {
        [self.view addSubview:self.footerView];
    }
    self.myCategoryView.imageZoomEnabled = NO;
    self.myCategoryView.imageCornerRadius = 8;
    self.myCategoryView.averageCellSpacingEnabled = NO;
    self.myCategoryView.imageSize = CGSizeMake(52, 52);
}

- (void)fetchInvoiceData {
    [self.dataProvider fetchInvoiceFiles:self.packageId success:^(NSDictionary * _Nonnull data) {
        self.detailModel = (CMPOcrInvoiceDetailListModel *)[CMPOcrInvoiceDetailListModel yy_modelWithDictionary:data];
        [self.imageNames removeAllObjects];
        
        NSMutableArray *localImageNames = [NSMutableArray new];
        for (CMPOcrInvoiceDetailItemModel *item in self.detailModel.data) {
            if ([item.type.lowercaseString containsString:@"pdf"]) {
                [self.imageNames addObject:[NSURL URLWithString:@"file://pdf"]];
                [localImageNames addObject:@"ocr_card_pdf_placeholder"];
            }else{
                NSString *url = [CMPCore fullUrlForPathFormat:@"/commonimage.do?method=showImage&id=%@&createDate=&size=custom&w=60&h=60&igonregif=1&option.n_a_s=1",item.fileId];
                [self.imageNames addObject:[NSURL URLWithString:url]];
                [localImageNames addObject:@"ocr_card_image_placeholder"];
            }
        }
        
        self.myCategoryView.imageURLs = self.imageNames;
        self.myCategoryView.loadImageCallback = ^(UIImageView *imageView, NSURL *imageURL) {
            if ([imageURL.absoluteString isEqualToString:@"file://pdf"]) {
                imageView.image = [UIImage imageNamed:@"ocr_card_pdf_placeholder"];
            }else{
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ocr_card_image_placeholder"]];
            }
        };
        
        self.myCategoryView.defaultSelectedIndex = self.selectIdx;
        [self.myCategoryView reloadData];
        [self refreshCountWithIndex:self.selectIdx];
        [self.myCategoryView layoutIfNeeded];
        [self refreshCategorySelectedStatus:self.selectIdx];
        
    } fail:^(NSError * _Nonnull error) {
        [self cmp_showHUDError:error];
    }];
}

- (void)setHeader{
    [self.imageNames removeAllObjects];
    NSMutableArray *localImageNames = [NSMutableArray new];
    for (CMPOcrInvoiceItemModel *item in self.invoiceArr) {
        if ([item.fileType.lowercaseString containsString:@"pdf"]) {
            [self.imageNames addObject:[NSURL URLWithString:@"file://pdf"]];
            [localImageNames addObject:@"ocr_card_pdf_placeholder"];
        }else{
            NSString *url = [CMPCore fullUrlForPathFormat:@"/commonimage.do?method=showImage&id=%@&createDate=&size=custom&w=60&h=60&igonregif=1&option.n_a_s=1",item.fileId];
            [self.imageNames addObject:[NSURL URLWithString:url]];
            [localImageNames addObject:@"ocr_card_image_placeholder"];
        }
    }
    
    self.myCategoryView.imageURLs = self.imageNames;
    self.myCategoryView.loadImageCallback = ^(UIImageView *imageView, NSURL *imageURL) {
        if ([imageURL.absoluteString isEqualToString:@"file://pdf"]) {
            imageView.image = [UIImage imageNamed:@"ocr_card_pdf_placeholder"];
        }else{
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ocr_card_image_placeholder"]];
        }
    };
    
    self.myCategoryView.defaultSelectedIndex = self.selectIdx;
    [self.myCategoryView reloadData];
    
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.myCategoryView selectItemAtIndex:self.selectIdx];
        
        [self.dataProvider fetchAllInvoiceTypesWithSuccess:^(NSDictionary * _Nonnull data) {
            if (data) {
                NSString *code = [NSString stringWithFormat:@"%@",data[@"code"]];
                if (code && [code isEqualToString:@"0"]) {
                    id types = data[@"data"];
                    if (types && [types isKindOfClass:NSArray.class]) {
                        [wSelf.invoiceTypesArr removeAllObjects];
                        [wSelf.invoiceTypesArr addObjectsFromArray:types];
                    }
                }
            }
        } fail:^(NSError * _Nonnull error) {
            
        }];
        
        [self.dataProvider fetchAllInvoiceConsumeTypesWithSuccess:^(NSDictionary * _Nonnull data) {
            if (data) {
                NSString *code = [NSString stringWithFormat:@"%@",data[@"code"]];
                if (code && [code isEqualToString:@"0"]) {
                    id types = data[@"data"];
                    if (types && [types isKindOfClass:NSArray.class]) {
                        [wSelf.invoiceConsumeTypesArr removeAllObjects];
                        [wSelf.invoiceConsumeTypesArr addObjectsFromArray:types];
                    }
                }
            }
        } fail:^(NSError * _Nonnull error) {
            
        }];
    });
    
}

//索引label
- (void)refreshCountWithIndex:(NSInteger)index {
    if (![self canEdit]) {
        return;
    }
    NSString *indexStr = [NSString stringWithFormat:@"%ld",index+1];
    NSString *titleStr = [NSString stringWithFormat:@"%ld",self.imageNames.count];
    numLab.text = [NSString stringWithFormat:@"%@/%ld",indexStr,self.imageNames.count];
    
    NSMutableAttributedString *numStr = [[NSMutableAttributedString alloc] initWithString:numLab.text];
    [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor cmp_specColorWithName:@"theme-fc"] range:NSMakeRange(0,indexStr.length)];
    [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor cmp_specColorWithName:@"desc-fc"] range:NSMakeRange(indexStr.length,titleStr.length+1)];
    numLab.attributedText = numStr;
    
    //是否禁用确认按钮
    CMPOcrInvoiceItemModel *item = self.invoiceArr[index];
    self.sureBtn.backgroundColor = self.sureBtn.enabled?[UIColor cmp_specColorWithName:@"theme-bdc"]:[UIColor cmp_specColorWithName:@"sup-fc1"];//#999999
}

//顶部图片选中状态
- (void)refreshCategorySelectedStatus:(NSInteger)index{
    NSArray *array = self.myCategoryView.collectionView.visibleCells;
    for (int i = 0; i < array.count; i ++) {
        JXCategoryImageCell *cell = array[i];
        NSIndexPath *indexPath = [self.myCategoryView.collectionView indexPathForCell:cell];
        if (indexPath.row == index) {
            cell.selected = YES;
        }else{
            cell.selected = NO;
        }
        BOOL isSelected = cell.isSelected;
        cell.imageView.layer.cornerRadius = 8;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.borderColor = isSelected ? [UIColor cmp_specColorWithName:@"theme-bdc"].CGColor : [UIColor whiteColor].CGColor;
        cell.imageView.layer.borderWidth = isSelected ? 2 : 0;
    }
}

#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.invoiceArr.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    CMPOcrInvoiceDetailListViewController *listVC = [CMPOcrInvoiceDetailListViewController new];
    CMPOcrInvoiceItemModel *item = self.invoiceArr[index];
    CMPOcrInvoiceDetailItemModel *model = CMPOcrInvoiceDetailItemModel.new;
    model.fileId = item.fileId;
    model.type = item.fileType;
    model.invoiceId = item.invoiceID;
    model.filename = item.filename;
    listVC.itemModel = model;
    listVC.packageId = self.packageId;
    weakify(self);
    listVC.allInvoiceTypesBlk = ^NSArray *(id obj) {
        strongify(self);
        return self.invoiceTypesArr.mutableCopy;
    };
    listVC.allInvoiceConsumeTypesBlk = ^NSArray *(id obj) {
        strongify(self);
        return self.invoiceConsumeTypesArr.mutableCopy;
    };
    return (id<JXCategoryListContentViewDelegate>)listVC;
}

- (void)listContainerViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"listContainerViewWillBeginDragging");
    [self judgeChangedAction];
}

- (BOOL)judgeChangedAction{
    JXCategoryListContainerView *view = (JXCategoryListContainerView *)_myCategoryView.listContainer;
    NSDictionary *dict = view.validListDict;
    
    CMPOcrInvoiceDetailListViewController *listVC = [dict objectForKey:@(self.myCategoryView.selectedIndex)];
    BOOL changed = [listVC compareIfChanged];
    if (changed) {
        self.listContainerView.scrollView.scrollEnabled = NO;
        [[[CMPAlertView alloc]initWithTitle:@"" message:@"当前发票信息已修改，确认是否保存？" cancelButtonTitle:@"取消修改" otherButtonTitles:@[@"确认保存"] callback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                __weak typeof(self) weakSelf = self;
                [listVC comfirmActionCompletion:^{
                    weakSelf.listContainerView.scrollView.scrollEnabled = YES;
                    if (weakSelf.myCategoryView.selectedIndex < weakSelf.invoiceArr.count - 1) {
                        [weakSelf.myCategoryView selectItemAtIndex:weakSelf.myCategoryView.selectedIndex+1];
                    }
                }];
            }else{
                self.listContainerView.scrollView.scrollEnabled = YES;
                //取消后，恢复变更
                [listVC restoreChange];
            }
        }] show];
    }else{
        self.listContainerView.scrollView.scrollEnabled = YES;
    }
    return changed;
}

#pragma mark - Category Delegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    [self refreshCountWithIndex:index];
    [self refreshCategorySelectedStatus:index];
}
- (BOOL)categoryView:(JXCategoryBaseView *)categoryView canClickItemAtIndex:(NSInteger)index{
    return ![self judgeChangedAction];
}
#pragma mark - Custom Accessors
- (CGFloat)preferredCategoryViewHeight {
    return 80;
}

- (JXCategoryImageView *)myCategoryView {
    if (!_myCategoryView) {
        _myCategoryView = [[JXCategoryImageView alloc] init];
        _myCategoryView.listContainer = self.listContainerView;
        _myCategoryView.delegate = self;
        _myCategoryView.defaultSelectedIndex = 0;
        _myCategoryView.cellSpacing = 14.f;
        _myCategoryView.backgroundColor = [UIColor whiteColor];
    }
    return _myCategoryView;
}

- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    return _listContainerView;
}

- (NSMutableArray *)imageNames {
    if (!_imageNames) {
        _imageNames = [[NSMutableArray alloc] init];
    }
    return _imageNames;
}

- (NSMutableArray *)invoiceTypesArr {
    if (!_invoiceTypesArr) {
        _invoiceTypesArr = [[NSMutableArray alloc] init];
    }
    return _invoiceTypesArr;
}

- (NSMutableArray *)invoiceConsumeTypesArr {
    if (!_invoiceConsumeTypesArr) {
        _invoiceConsumeTypesArr = [[NSMutableArray alloc] init];
    }
    return _invoiceConsumeTypesArr;
}

- (CMPOcrInvoiceDetailDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrInvoiceDetailDataProvider alloc] init];
    }
    return _dataProvider;
}

- (UIView *)footerView {
    if (!_footerView) {
        CGFloat footerOffsetY = self.listContainerView.bottom;
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, footerOffsetY, kCMPOcrScreenWidth, 50+IKBottomSafeEdge)];
        _footerView.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:_footerView];

//        UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCMPOcrScreenWidth, 1)];
//        lineLab.backgroundColor = k16RGBColor(0xf2f2f2);
//        [_footerView addSubview:lineLab];

        numLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 30)];
        numLab.text = [NSString stringWithFormat:@"%@/%ld",@"1",self.imageNames.count];
        numLab.font = [UIFont systemFontOfSize:13];
        numLab.textAlignment = NSTextAlignmentLeft;
        [_footerView addSubview:numLab];
        
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame = CGRectMake((kCMPOcrScreenWidth-158)/2, 6, 158, 36);
        _sureBtn.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _sureBtn.layer.cornerRadius = 18;
        _sureBtn.layer.masksToBounds = YES;
        [_sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_footerView addSubview:_sureBtn];
        [_sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _footerView;
}

#pragma mark - 底部确认
- (void)sureBtnAction{
    JXCategoryListContainerView *view = (JXCategoryListContainerView *)_myCategoryView.listContainer;
    NSDictionary *dict = view.validListDict;
    CMPOcrInvoiceDetailListViewController *listVC = [dict objectForKey:@(self.myCategoryView.selectedIndex)];
    self.listContainerView.scrollView.scrollEnabled = NO;
    __weak typeof(self) weakSelf = self;
    [listVC comfirmActionCompletion:^{
        weakSelf.listContainerView.scrollView.scrollEnabled = YES;
        if (weakSelf.myCategoryView.selectedIndex < weakSelf.invoiceArr.count - 1) {
            [weakSelf.myCategoryView selectItemAtIndex:weakSelf.myCategoryView.selectedIndex+1];
        }
    }];
}
@end
