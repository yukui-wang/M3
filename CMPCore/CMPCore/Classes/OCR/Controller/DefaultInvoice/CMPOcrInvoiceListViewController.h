//
//  CMPOcrInvoiceListViewController.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrBaseViewController.h"
#import <CMPLib/CMPBannerViewController.h>
#import "CMPOcrInvoiceModel.h"


@class CMPOcrInvoiceItemModel, CMPOcrInvoiceListViewController,CMPOcrPackageTipModel;
@protocol CMPOcrInvoiceListViewControllerDelegate <NSObject>

@optional

- (void)updateCategoryWithDict:(NSArray *)modelDictArr;

/// 选中当前模型
/// @param listVC 列表vc
/// @param model 模型
- (void)invoiceListViewController:(CMPOcrInvoiceListViewController *)listVC selectedItem:(NSArray *)models;

/// 取消选中
/// @param listVC 列表vc
/// @param model 模型
- (void)invoiceListViewController:(CMPOcrInvoiceListViewController *)listVC deselectedItem:(NSArray *)models;

//返回当前列表数据
- (void)backInvoiceListWithArray:(NSArray*)modes;

@end

@class CMPOcrDefaultInvoiceCategoryModel;
@interface CMPOcrInvoiceListViewController : CMPBannerViewController

@property (nonatomic, assign) NSInteger selectIndex;//vc对应的index
@property (nonatomic, copy) NSString *condition;//搜索名称关键字
@property (nonatomic, strong) NSArray *formInvoiceIdList;//表单已选中的发票集合
@property (nonatomic, weak) id<CMPOcrInvoiceListViewControllerDelegate> delegate;


//获取当前页面所有发票数量
- (NSInteger)getTotalCountOfItem;
- (void)setSelectedModels:(NSArray *)models;
//搜索
- (void)searchInvoiceListByCondition:(NSString *)condition;
- (void)reloadInvoiceListWithRemoved:(NSArray*)array;

@property (nonatomic, strong) CMPOcrDefaultInvoiceCategoryModel *categoryModel;

//ext=1默认票夹,ext=2包详情,ext=4我的
-(instancetype)initWithCategoryModel:(CMPOcrDefaultInvoiceCategoryModel *)categoryModel ext:(id)ext canEdit:(BOOL)canEdit fromForm:(BOOL)isFromForm;

@property (nonatomic, copy) void(^ReturnTipModelBlock)(CMPOcrPackageTipModel *);

@property (nonatomic, copy) void(^ScrollViewWillBeginDraggingBlock)(void);
@end

