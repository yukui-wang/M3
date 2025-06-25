//
//  CMPOcrInvoiceDetailListViewController.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/13.
//

#import "CMPOcrInvoiceDetailListViewController.h"
#import "CMPOcrDetailListCell.h"
#import "CMPOcrAssociatedInvoiceViewController.h"
#import <CMPLib/JXCategoryView.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/UIImageView+WebCache.h>
#import "CMPOcrInvoiceDetailModel.h"
#import "CMPOcrInvoiceDetailDataProvider.h"
#import "CMPOcrDetailTableViewController.h"
#import <CMPLib/CMPDatePicker.h>
#import <CMPLib/CMPCustomAlertView.h>
#import <CMPLib/YBImageBrowser.h>
#import <CMPLib/CMPQuickLookPreviewController.h>
#import "CMPOcrNotificationKey.h"
#import "NSArray+MutableCopyCatetory.h"
#import "CMPOcrInvoiceDetailExpandCell.h"
#import <CMPLib/KSActionSheetView.h>

@interface CMPOcrInvoiceDetailListViewController ()<JXCategoryListContentViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (nonatomic ,strong) UITableView           *myTableView;

@property (nonatomic ,strong) NSMutableArray        *contentArray;//section1
@property (nonatomic ,strong) NSMutableArray        *content2Array;//section2

@property (nonatomic ,strong) NSArray        *originArray;

@property (nonatomic, strong) CMPOcrInvoiceDetailDataProvider *dataProvider;

@property (nonatomic, strong) CMPOcrInvoiceDetailModel * detailModel;

@property (nonatomic, assign) BOOL twoSection;//是否两个section
@property (nonatomic, assign) BOOL hasMore;//是否有展开【更多】
@property (nonatomic, assign) BOOL expanded;//是否展开
@property (nonatomic, assign) NSInteger maxShowNums;//最多显示数量

@end

@implementation CMPOcrInvoiceDetailListViewController

- (void)dealloc{
    NSLog(@"%@-delloc",self.class);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _maxShowNums = 6;
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    
    [self.view addSubview:self.myTableView];
        
    [self fetchInvoiceDetail];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.myTableView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:kNotificationUpdatedAssociateInvoice object:nil];
    
}

- (void)refreshData:(NSNotification *)noti{
    [self fetchInvoiceDetail];
}

#pragma mark - 键盘编辑管理
- (BOOL)canEdit{//我的页面进入不允许编辑
    return self.rdv_tabBarController.selectedIndex != 2;
}

- (void)closeKeyboard{
    [self.myTableView endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (fabs(scrollView.contentOffset.y)>50) {
        [self.myTableView endEditing:YES];
    }
}

-(void)_refreshListWithRespData:(NSDictionary *)respData
{
    if (!respData) {
        return;
    }
    CMPOcrInvoiceDetailModel *model = [CMPOcrInvoiceDetailModel yy_modelWithDictionary:respData[@"data"]];
    if (!model) {
        return;
    }
    self.detailModel = model;
    NSDictionary *dict = model.details;
    
    weakify(self);
    void(^aBlk)(NSArray *,id) = ^(NSArray *consumeTypes, id ext){
        strongify(self);
        //组装数据
        [self.contentArray removeAllObjects];
        //ks add -- 判断发票验真状态，如果 一验真：发票类型、发票号码、发票代码、校验码、发票金额、开票日期。不可编辑
        //未验真，无需验真，查无此票：都可编辑
        //已作废：发票类型、发票号码、发票代码、校验码、发票金额、开票日期。不可编辑
        BOOL invoiceTypeCanEdit = NO;
        if ([self canEdit]) {
            invoiceTypeCanEdit = (model.verifyStatus == InvoiceVerifyResult_HasNotVerify || model.verifyStatus == InvoiceVerifyResult_NoNeedVerify || model.verifyStatus == InvoiceVerifyResult_CheckHasNoInfo)?YES:NO;
        }
        
        [self.contentArray addObject:@{@"ocr_local_key_invoice_kind":@{
            @"value":model.modelName?:@"",
            @"type":@4,
            @"desc":@"发票类型",
            @"sort":@-1,
            @"validUsedFlag":@(!invoiceTypeCanEdit),
            @"canEdit":@(invoiceTypeCanEdit),
            @"showNext":@NO
        }}];
        
        __block BOOL needMatchErr = NO;
        NSString *infoMsg, *fileId;
        if (model.verifyStatus == InvoiceVerifyResult_HasNotVerify && model.verifyInfo) {
            infoMsg = model.verifyInfo[@"msg"];
            if ([NSString isNotNull:infoMsg]) {
                fileId = model.verifyInfo[@"field"];
                if ([NSString isNotNull:fileId]) {
                    needMatchErr = YES;
                }
                if (!needMatchErr) {
                    [self cmp_showHUDWithText:infoMsg];
                }
            }
        }

        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:obj];

            if (needMatchErr && fileId && infoMsg) {
                if ([key isEqualToString:fileId]) {
                    mDict[@"tipMsg"] = infoMsg;
                    needMatchErr = NO;
                }
            }
            
            if (model.validInfo && [model.validInfo isKindOfClass:NSDictionary.class]) {
                NSString *validMsg = [model.validInfo objectForKey:key];
                if (validMsg && validMsg.length) {
                    NSString *a = mDict[@"tipMsg"] ? [mDict[@"tipMsg"] stringByAppendingFormat:@"\n%@",validMsg] : validMsg;
                    mDict[@"tipMsg"] = a;
                }
            }
            
            if ([self canEdit]) {
                NSString *edit = [NSString stringWithFormat:@"%@",obj[@"edit"]];
                mDict[@"canEdit"] = @([edit isEqualToString:@"1"]);
                mDict[@"showNext"] = @NO;
            }else{
                mDict[@"canEdit"] = @NO;
                mDict[@"showNext"] = @NO;
            }
            
            //把原来的精确时间替换掉，不然没法和重新获取的时间比较
            NSInteger type = [[mDict objectForKey:@"type"] integerValue];
            if (type == 6 || type == 7) {
                NSTimeInterval time = [[mDict objectForKey:@"value"] longLongValue]/1000;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
                NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
                [mDict setValue:[NSString stringWithFormat:@"%.0f",timestamp] forKey:@"value"];
            }
            
            if ([@"kind" isEqualToString:key]) {
                if (consumeTypes && consumeTypes.count) {
                    NSString *curCode = [NSString stringWithFormat:@"%@",[mDict objectForKey:@"value"]];
                    [consumeTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *aCode = [NSString stringWithFormat:@"%@",[obj objectForKey:@"code"]];
                        if ([curCode isEqualToString:aCode]) {
                            NSString *aDesc = [NSString stringWithFormat:@"%@",[obj objectForKey:@"desc"]];
                            mDict[@"localName"] = aDesc;
                            *stop = YES;
                        }
                    }];
                }
            }
            
            [self.contentArray addObject:@{
                key:mDict
            }];
        }];
        //排序
        [self.contentArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
            id value1 = obj1.allValues.firstObject[@"sort"];
            id value2 = obj2.allValues.firstObject[@"sort"];
            NSNumber *n1 = [value1 isKindOfClass:NSNull.class]?[NSNumber numberWithInteger:9999]:value1;
            NSNumber *n2 = [value2 isKindOfClass:NSNull.class]?[NSNumber numberWithInteger:9999]:value2;
            n1 = n1?:[NSNumber numberWithInteger:9999];
            n2 = n2?:[NSNumber numberWithInteger:9999];
            return [n1 compare:n2];
        }];
        
        self.hasMore = self.contentArray.count > self.maxShowNums;
        
        //section2
        [self.content2Array removeAllObjects];
        if (model.hasSchedule) {//明细表
            [self.content2Array addObject:@{@"ocr_local_key_detail_table":@{@"value":@"",@"type":@4,@"desc":@"查看明细表",@"validUsedFlag":@YES,@"canEdit":@NO,@"showNext":@YES}}];
        }
        //屏蔽关联发票入口
    //        NSString *associateNum = [NSString stringWithFormat:@"%ld",model.deputyInvoiceNum];
    //        if (model.mainDeputyTag != 2) {//关联发票
    //            [weakSelf.content2Array addObject:@{@"ocr_local_key_associate_invoice":@{@"value":associateNum,@"type":@4,@"desc":@"关联发票"}}];
    //        }
        //查看原票据
        [self.content2Array addObject:@{@"ocr_local_key_origin_invoice":@{@"value":@"",@"type":@4,@"desc":@"查看原票据",@"validUsedFlag":@YES,@"canEdit":@NO,@"showNext":@YES}}];
        if (self.content2Array.count > 0) {
            self.twoSection = YES;
        }
        
        self.originArray = [self.contentArray mutableArrayDeeoCopy];
        [self.myTableView reloadData];
    };
    
    NSArray *consumeTypes = self.allInvoiceConsumeTypesBlk(nil);
    if (dict[@"kind"]) {
        if (!consumeTypes || consumeTypes.count == 0) {
            //消费类型
            [self.dataProvider fetchAllInvoiceConsumeTypesWithSuccess:^(NSDictionary * _Nonnull data) {
                if (data) {
                    NSString *code = [NSString stringWithFormat:@"%@",data[@"code"]];
                    if (code && [code isEqualToString:@"0"]) {
                        id types = data[@"data"];
                        if (types && [types isKindOfClass:NSArray.class]) {
                            aBlk(types,nil);
                        }
                    }
                }
                        } fail:^(NSError * _Nonnull error) {
                            aBlk(consumeTypes,nil);
                        }];
            return;
        }
    }
    aBlk(consumeTypes,nil);
}

#pragma mark - 获取详情数据
- (void)fetchInvoiceDetail {
    __weak typeof(self) weakSelf = self;
    [self.dataProvider fetchInvoiceDetail:self.itemModel.invoiceId success:^(NSDictionary * _Nonnull data) {
        [weakSelf _refreshListWithRespData:data];
        
    } fail:^(NSError * _Nonnull error) {
        [weakSelf cmp_showHUDError:error];
    }];
}

//比较变更
- (BOOL)compareIfChanged{
    BOOL changed = NO;
    for (int i=0; i<self.originArray.count; i++) {
        NSDictionary *originDict = [self.originArray objectAtIndex:i];
        NSDictionary *arrDict = [self.contentArray objectAtIndex:i];
        changed = ![originDict isEqualToDictionary:arrDict];
        if (changed) {
            break;
        }
    }
    return changed;
}
//恢复变更
- (void)restoreChange{
    self.contentArray = [self.originArray mutableCopy];
    self.originArray = [self.contentArray mutableArrayDeeoCopy];
    [self.myTableView reloadData];
}

//确认变更
- (void)comfirmActionCompletion:(void(^)(void))completion{
    //遍历添加userOverrideFlag
    for (int i=0; i<self.originArray.count; i++) {
        NSDictionary *originDict = [self.originArray objectAtIndex:i];
        NSDictionary *arrDict = [self.contentArray objectAtIndex:i];
        BOOL changed = ![originDict isEqualToDictionary:arrDict];
        if (changed) {
            NSDictionary * tmpDict = arrDict.allValues.firstObject;
            [tmpDict setValue:@"true" forKey:@"userOverrideFlag"];
        }
    }
    
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    [self.contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *param = obj;
        NSString *key = param.allKeys.firstObject;
        NSDictionary *value = [param objectForKey:key];
        NSInteger type = [[value objectForKey:@"type"] integerValue];
        if (type < 4) {
            NSString *_val = value[@"value"];
            if (_val && _val.length>0) {
                BOOL _isNumber = [CMPOcrInvoiceDetailListViewController isNumber:_val];
                if (!_isNumber) {
                    NSString *desc = [value objectForKey:@"desc"];
                    [self cmp_showHUDWithText:[NSString stringWithFormat:@"%@:输入的字符类型有误",desc]];
                    return;
                }
            }
        }
        NSMutableDictionary *tmpValue = [NSMutableDictionary dictionaryWithDictionary:value];
        [tmpValue removeObjectForKey:@"canEdit"];
        [tmpValue removeObjectForKey:@"showNext"];
//        if ([[value objectForKey:@"canEdit"] boolValue]) {
            [mDict setObject:tmpValue forKey:key];
//        }
    }];
    
    [mDict setObject:(self.detailModel.modelId?:@"") forKey:@"modelId"];
    [mDict setObject:(self.detailModel.type?:@"") forKey:@"type"];
    __weak typeof(self) weakSelf = self;
    [self.dataProvider updateInvoiceDetailsByInvoiceId:self.itemModel.invoiceId details:mDict success:^(NSDictionary * _Nonnull data) {
        NSDictionary *result = data[@"data"];
        NSString *msg = [result objectForKey:@"message"];
        if ([[result objectForKey:@"code"] integerValue] == 0) {
            msg = msg?:@"保存成功";
            [weakSelf cmp_showHUDWithText:msg];
            weakSelf.originArray = [weakSelf.contentArray copy];
            [weakSelf fetchInvoiceDetail];
            if (completion) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        }else{
            msg = msg?:@"确认失败";
            [weakSelf cmp_showHUDWithText:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [weakSelf cmp_showHUDError:error];
    }];
}

#pragma mark - UITableViewDelegate/DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _twoSection?2:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (_expanded?self.contentArray.count:MIN(_maxShowNums, self.contentArray.count))+(_hasMore?1:0);
    }else if (section == 1){
        return self.content2Array.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSInteger max = _expanded?self.contentArray.count:MIN(_maxShowNums, self.contentArray.count);
        if (_hasMore && max == indexPath.row) {
            CMPOcrInvoiceDetailExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(CMPOcrInvoiceDetailExpandCell.class) forIndexPath:indexPath];
            cell.expand = self.expanded;
            [cell updateOffsetYConstraint:-2.5];
            return cell;
        }
        NSString *cellID = @"CMPOcrDetailListCell";
        CMPOcrDetailListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[CMPOcrDetailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *param = [self.contentArray objectAtIndex:indexPath.row];
        if ([self canEdit]) {
            [cell setParam:param canEdit:YES];
            cell.DidEditBlock = ^(NSDictionary * newParam) {
                [self.contentArray replaceObjectAtIndex:indexPath.row withObject:newParam];
            };
        }else{
            [cell setParam:param canEdit:NO];
            cell.DidEditBlock = nil;
        }
        
        [cell updateOffsetYConstraint:0];
        
        return cell;
    }else if (indexPath.section == 1){
        NSString *cellID1 = @"CMPOcrDetailListCell1";
        CMPOcrDetailListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID1];
        if (!cell) {
            cell = [[CMPOcrDetailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *param = [self.content2Array objectAtIndex:indexPath.row];
        [cell setParam:param canEdit:NO];
        
        //阴影造成的偏移
        if (indexPath.row == 0) {
            [cell updateOffsetYConstraint:2.5];
        }else if (indexPath.row == self.content2Array.count - 1) {
            [cell hideLine];
            [cell updateOffsetYConstraint:-2.5];
        }else{
            [cell updateOffsetYConstraint:0];
        }
        if (self.content2Array.count == 1) {
            [cell hideLine];
        }
        return cell;
    }
    return UITableViewCell.new;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger rowNum = [tableView numberOfRowsInSection:indexPath.section];
//    if (rowNum == 1) {
//        return 55;
//    }else {
//        if (indexPath.row == 0) {
//            return 55;
//        }else if (indexPath.row == rowNum - 1) {
//            return 55;
//        }else {
//            return 50;
//        }
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 110;
    }
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        return UIView.new;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCMPOcrScreenWidth, 110)];
    
    UIImageView *bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ocr_card_invoice_detail_header1"]];
    bgView.frame = CGRectMake(-10, 0, kCMPOcrScreenWidth+2, 110);
    bgView.contentMode = UIViewContentModeScaleToFill;
    [headerView addSubview:bgView];
    
    UIImageView *headImage = [[UIImageView alloc] init];
    headImage.contentMode = UIViewContentModeScaleAspectFill;
    headImage.image = [UIImage imageNamed:@"ocr_card_invoice_red_bg"];
    [headerView addSubview:headImage];
    [headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerView);
        make.width.mas_equalTo(94);
        make.height.mas_equalTo(53);
    }];
        
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.textColor = k16RGBColor(0x9D241D);
    titleLab.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
    [headImage addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headImage);
    }];
    titleLab.text = self.detailModel.modelName.length>0?self.detailModel.modelName:@"未知发票";
    
    UIView *verifyStatusBgV = [[UIView alloc] init];
    verifyStatusBgV.backgroundColor = [UIColor clearColor];
    verifyStatusBgV.clipsToBounds = YES;
    [bgView addSubview:verifyStatusBgV];
    [verifyStatusBgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(68, 68));
        make.right.offset(-14);
        make.top.offset(10);
    }];
    
    UILabel *_verifyStatusLb = [[UILabel alloc] init];
    _verifyStatusLb.font = [UIFont systemFontOfSize:12];
    _verifyStatusLb.textAlignment = NSTextAlignmentCenter;
    [verifyStatusBgV addSubview:_verifyStatusLb];
    [_verifyStatusLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(10);
        make.centerY.offset(-10);
        make.height.equalTo(28);
        make.width.equalTo(68*1.8);
    }];
    _verifyStatusLb.transform =CGAffineTransformMakeRotation(M_PI_4);
    
    if (self.detailModel) {
        NSString *titleStr = self.detailModel.verifyStatusDisplay;
        UIColor *textColor = [UIColor cmp_specColorWithName:@"app-bgc5"];
        switch (self.detailModel.verifyStatus) {
            case InvoiceVerifyResult_Valid:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"已验真";
                }
                textColor = UIColorFromRGB(0x61B109);
            }
                break;
            case InvoiceVerifyResult_Invalid:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"已作废";
                }
                textColor = UIColorFromRGB(0x666666);
            }
                break;
            case InvoiceVerifyResult_HasNotVerify:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"未验真";
                }
                textColor = UIColorFromRGB(0xFF9900);
            }
                break;
            case InvoiceVerifyResult_NoNeedVerify:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"无需验真";
                }
                textColor = UIColorFromRGB(0x297FFB);
            }
                break;
            case InvoiceVerifyResult_CheckHasNoInfo:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"查无此票";
                }
                textColor = UIColorFromRGB(0xFF4141);
            }
                break;

            default:
            {
                if ([NSString isNull:titleStr]) {
                    titleStr = @"未知";
                }
            }
                break;
        }
        _verifyStatusLb.text = titleStr;
        _verifyStatusLb.textColor = textColor;
        _verifyStatusLb.backgroundColor = [textColor colorWithAlphaComponent:0.1];
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSDictionary *param = [self.content2Array objectAtIndex:indexPath.row];
        NSString *key = param.allKeys.firstObject;
        if ([key containsString:@"ocr_local_key_detail_table"]) {//查看明细表
            CMPOcrDetailTableViewController *tableVC = [[CMPOcrDetailTableViewController alloc]init];
            tableVC.invoiceId = self.itemModel.invoiceId;
            [self.navigationController pushViewController:tableVC animated:YES];
        }else if ([key containsString:@"ocr_local_key_associate_invoice"]){//关联发票
            CMPOcrAssociatedInvoiceViewController *invoiceVC = [[CMPOcrAssociatedInvoiceViewController alloc] init];
            invoiceVC.rPackageId = self.packageId;
            invoiceVC.mainInvoiceId = self.itemModel.invoiceId;
            [self.navigationController pushViewController:invoiceVC animated:YES];
        }else if ([key containsString:@"ocr_local_key_origin_invoice"]){//查看原票据
            if ([self.itemModel.type containsString:@"pdf"]) {
                AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
                aParam.fileId = self.itemModel.fileId;
                CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
                NSString *aFileUrl = [CMPCore fullUrlForPathFormat:@"/rest/attachment/file/%@", self.itemModel.fileId];
                aParam.url = aFileUrl;
                aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
                aParam.fileName = self.itemModel.filename;
                aParam.fileType = self.itemModel.type;
                aViewController.attReaderParam = aParam;
                [self.navigationController pushViewController:aViewController animated:YES];
            }else{
                NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/commonImage/showImage?size=source&id=%@", self.itemModel.fileId];
                NSURL *URL = [NSURL URLWithString:url];
                if (URL) {
                    YBImageBrowseCellData *cellData = [[YBImageBrowseCellData alloc]init];
                    cellData.url = URL;
                    cellData.extraData = @{
                        @"originImageURL":URL
                    };
                    YBImageBrowser *browser = [YBImageBrowser new];
                    browser.dataSourceArray = @[cellData];
                    browser.allDataSourceArray = @[cellData];
                    browser.currentIndex = 0;
                    browser.showCheckAllPicsBtn = NO;
                    [browser show];
                }
            }
        }
    }else if (indexPath.section == 0) {
        NSInteger max = _expanded?self.contentArray.count:MIN(_maxShowNums, self.contentArray.count);
        if (_hasMore && max == indexPath.row) {
            _expanded = !_expanded;
            [tableView reloadData];
            return;
        }
        if (![self canEdit]) {
            return;
        }

        NSDictionary *param = [self.contentArray objectAtIndex:indexPath.row];
        NSString *key = param.allKeys.firstObject;
        NSDictionary *value = [param objectForKey:key];
        BOOL subCanEdit = [value[@"canEdit"] boolValue];
        if (!subCanEdit) {
            return;
        }
        NSInteger type = [value[@"type"] integerValue];
        if (type == 6) {//日期
            UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(10, 20, UIScreen.mainScreen.bounds.size.width - 20, 160)];
            datePicker.datePickerMode = UIDatePickerModeDate;
            NSTimeInterval time = [value[@"value"] doubleValue];
            datePicker.date = [NSDate dateWithTimeIntervalSince1970:time/1000];
            if (time<=0) {
                datePicker.date = [NSDate date];
            }
            if (@available(iOS 13.4, *)) {
                datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            }
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n" message:@"" preferredStyle:(UIAlertControllerStyleActionSheet)];
            alertVC.modalPresentationStyle = UIModalPresentationPopover;
            [alertVC.view addSubview:datePicker];
            [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(alertVC.view);
            }];
            UIAlertAction *sureAtion = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                NSDate *lastDate = datePicker.date;
                NSTimeInterval timestamp = [lastDate timeIntervalSince1970] * 1000;
                
                NSDictionary *param = [self.contentArray objectAtIndex:indexPath.row];
                NSMutableDictionary *newParam = [NSMutableDictionary dictionaryWithDictionary:[param mutableDicDeepCopy]];
                NSString *key = newParam.allKeys.firstObject;
                [newParam objectForKey:key][@"value"] = [NSString stringWithFormat:@"%.0f",timestamp];
                [self.contentArray replaceObjectAtIndex:indexPath.row withObject:newParam];
                
                CMPOcrDetailListCell *cell = (CMPOcrDetailListCell *)[tableView cellForRowAtIndexPath:indexPath];
                [cell setParam:newParam canEdit:YES];
            }];
            [alertVC addAction:sureAtion];
            UIAlertAction *cancelAtion = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertVC addAction:cancelAtion];
            [self presentViewController:alertVC animated:YES completion:^{}];
        }else if(type == 7){//时间
            UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(10, 20, UIScreen.mainScreen.bounds.size.width - 20, 160)];//date216
            datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//            datePicker.datePickerMode = UIDatePickerModeTime;
            NSTimeInterval time = [value[@"value"] doubleValue];
            datePicker.date = [NSDate dateWithTimeIntervalSince1970:time/1000];
            if (time<=0) {
                datePicker.date = [NSDate date];
            }
            if (@available(iOS 13.4, *)) {
                datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            }
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n" message:@"" preferredStyle:(UIAlertControllerStyleActionSheet)];
            alertVC.modalPresentationStyle = UIModalPresentationPopover;
            [alertVC.view addSubview:datePicker];
            [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(alertVC.view);
            }];
            UIAlertAction *sureAtion = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                NSDate *lastDate = datePicker.date;
                NSTimeInterval timestamp = [lastDate timeIntervalSince1970] * 1000;
                
                NSDictionary *param = [self.contentArray objectAtIndex:indexPath.row];
                NSMutableDictionary *newParam = [NSMutableDictionary dictionaryWithDictionary:[param mutableDicDeepCopy]];
                NSString *key = newParam.allKeys.firstObject;
                [newParam objectForKey:key][@"value"] = [NSString stringWithFormat:@"%.0f",timestamp];
                [self.contentArray replaceObjectAtIndex:indexPath.row withObject:newParam];
                
                CMPOcrDetailListCell *cell = (CMPOcrDetailListCell *)[tableView cellForRowAtIndexPath:indexPath];
                [cell setParam:newParam canEdit:YES];
            }];
            [alertVC addAction:sureAtion];
            UIAlertAction *cancelAtion = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertVC addAction:cancelAtion];
            [self presentViewController:alertVC animated:YES completion:^{}];
        }else if ([key isEqualToString:@"ocr_local_key_invoice_kind"]) {
            NSArray *types = self.allInvoiceTypesBlk(nil);
            if (types && types.count) {
                NSMutableArray *tmpArr = [NSMutableArray array];
                for (id obj in types) {
                    NSString *name = [NSString stringWithFormat:@"%@",obj[@"typeName"]];
                    NSString *ide = [NSString stringWithFormat:@"%@",obj[@"type"]];
                    KSActionSheetViewItem *item = [[[[KSActionSheetViewItem alloc] init] setIdentifier:ide] setTitle:name];
                    item.ext = obj;
                    [tmpArr addObject:item];
                }
                weakify(self);
                KSActionSheetView *actionSheet = [KSActionSheetView showActionSheetWithTitle:@"选择发票类型" cancelButtonTitle:@"取消" destructiveButtonTitle:NULL otherButtonTitleItems:tmpArr handler:^(KSActionSheetView *actionSheetView, KSActionSheetViewItem *actionItem, id ext) {
                    
                    if (actionItem.key == -1) {
                        return;
                    }
                    strongify(self);
                    NSString *modelId = @"";
                    if (actionItem.ext) {
                        modelId = [NSString stringWithFormat:@"%@",actionItem.ext[@"modelId"]];
                    }
                    NSDictionary *params = @{@"type":actionItem.identifier,
                                             @"invoiceId":self.detailModel.invoiceID?:@"",
                                             @"modelId":modelId
                    };
                    
                    [self.dataProvider updateInvoiceTypeWithParams:params success:^(NSDictionary * _Nonnull data) {
                        [self _refreshListWithRespData:data];
                                        } fail:^(NSError * _Nonnull error) {
                                            [self cmp_showHUDError:error];
                                        }];
                }];
                [actionSheet show];
            }
        }else if ([key isEqualToString:@"kind"]) {
            NSArray *types = self.allInvoiceConsumeTypesBlk(nil);
            if (types && types.count) {
                NSMutableArray *tmpArr = [NSMutableArray array];
                for (id obj in types) {
                    NSString *name = [NSString stringWithFormat:@"%@",obj[@"desc"]];
                    NSString *ide = [NSString stringWithFormat:@"%@",obj[@"code"]];
                    KSActionSheetViewItem *item = [[[[KSActionSheetViewItem alloc] init] setIdentifier:ide] setTitle:name];
                    item.ext = obj;
                    [tmpArr addObject:item];
                }
                weakify(self);
                KSActionSheetView *actionSheet = [KSActionSheetView showActionSheetWithTitle:@"选择发票消费类型" cancelButtonTitle:@"取消" destructiveButtonTitle:NULL otherButtonTitleItems:tmpArr handler:^(KSActionSheetView *actionSheetView, KSActionSheetViewItem *actionItem, id ext) {
                    
                    if (actionItem.key == -1) {
                        return;
                    }
                    strongify(self);
                    NSDictionary *param = [self.contentArray objectAtIndex:indexPath.row];
                    NSMutableDictionary *newParam = [NSMutableDictionary dictionaryWithDictionary:[param mutableDicDeepCopy]];
                    NSString *key = newParam.allKeys.firstObject;
                    [newParam objectForKey:key][@"value"] = [NSString stringWithFormat:@"%@",actionItem.identifier];
                    [newParam objectForKey:key][@"localName"] = [NSString stringWithFormat:@"%@",actionItem.title];
                    [self.contentArray replaceObjectAtIndex:indexPath.row withObject:newParam];
                    
                    CMPOcrDetailListCell *cell = (CMPOcrDetailListCell *)[tableView cellForRowAtIndexPath:indexPath];
                    [cell setParam:newParam canEdit:YES];
                    
                }];
                [actionSheet show];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 圆角角度
    CGFloat radius = 8.f;
    // 设置cell 背景色为透明
    cell.backgroundColor = UIColor.clearColor;
    // 创建两个layer
    CAShapeLayer *normalLayer = [[CAShapeLayer alloc] init];
    CAShapeLayer *selectLayer = [[CAShapeLayer alloc] init];
    // 获取显示区域大小
    CGRect bounds = CGRectInset(cell.bounds,4, 0);
    // cell的backgroundView
    UIView *normalBgView = [[UIView alloc] initWithFrame:bounds];
    // 获取每组行数
    NSInteger rowNum = [tableView numberOfRowsInSection:indexPath.section];
    // 贝塞尔曲线
    UIBezierPath *bezierPath = nil;
    
    if (rowNum == 1) {
        // 一组只有一行（四个角全部为圆角）
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
        normalBgView.clipsToBounds = NO;
    }else {
        normalBgView.clipsToBounds = YES;
        if (indexPath.row == 0) {
            normalBgView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(-5, 0, 0, 0));
            if (indexPath.section == 0) {
                bezierPath = [UIBezierPath bezierPathWithRect:bounds];
            }else{
                CGRect rect = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(5, 0, 0, 0));
                // 每组第一行（添加左上和右上的圆角）
                bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(radius, radius)];
            }
        }else if (indexPath.row == rowNum - 1) {
            normalBgView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, -5, 0));
            CGRect rect = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, 5, 0));
            // 每组最后一行（添加左下和右下的圆角）
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) cornerRadii:CGSizeMake(radius, radius)];
            
        }else {
            // 每组不是首位的行不设置圆角
            bezierPath = [UIBezierPath bezierPathWithRect:bounds];
        }
    }
    
    // 阴影
    normalLayer.shadowColor = [UIColor lightGrayColor].CGColor;
    normalLayer.shadowOpacity = 0.2;
    normalLayer.shadowOffset = CGSizeMake(0, 0);
    normalLayer.path = bezierPath.CGPath;
    normalLayer.shadowPath = bezierPath.CGPath;
    
    // 把已经绘制好的贝塞尔曲线路径赋值给图层，然后图层根据path进行图像渲染render
    normalLayer.path = bezierPath.CGPath;
    selectLayer.path = bezierPath.CGPath;
    
    // 设置填充颜色
    normalLayer.fillColor = [UIColor whiteColor].CGColor;
    // 添加图层到nomarBgView中
    [normalBgView.layer insertSublayer:normalLayer atIndex:0];
    normalBgView.backgroundColor = UIColor.clearColor;
    cell.backgroundView = normalBgView;
    
    // 替换cell点击效果
    UIView *selectBgView = [[UIView alloc] initWithFrame:bounds];
    selectLayer.fillColor = [UIColor colorWithWhite:0.95 alpha:1.0].CGColor;
    [selectBgView.layer insertSublayer:selectLayer atIndex:0];
    selectBgView.backgroundColor = UIColor.clearColor;
    cell.selectedBackgroundView = selectBgView;
}

#pragma mark - Lazy

- (UITableView *)myTableView {
    if (!_myTableView) {
        CGFloat tbWidth = kCMPOcrScreenWidth-18;
        CGFloat tbHeight = kScreenHeight-IKBottomSafeEdge-kNavHeight-80-50;
        if (![self canEdit]) {
            tbHeight += 50 + IKBottomSafeEdge;
        }
//        tbHeight = tbHeight - 10;
        
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(9, 0, tbWidth, tbHeight) style:UITableViewStyleGrouped];
        _myTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.tableFooterView = UIView.new;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.showsHorizontalScrollIndicator = NO;
        _myTableView.showsVerticalScrollIndicator = NO;
        _myTableView.backgroundColor = [UIColor clearColor];//k16RGBColor(0xffffff);
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        _myTableView.separatorInset = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            _myTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_myTableView setLayerShadowRadius:3 color:[UIColor blackColor] offset:CGSizeMake(0, 0) opacity:0];
        [_myTableView registerClass:CMPOcrInvoiceDetailExpandCell.class forCellReuseIdentifier:NSStringFromClass(CMPOcrInvoiceDetailExpandCell.class)];
    }
    return _myTableView;
}
- (NSMutableArray *)contentArray{
    if (!_contentArray) {
        _contentArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _contentArray;
}
- (NSMutableArray *)content2Array{
    if (!_content2Array) {
        _content2Array = [NSMutableArray arrayWithCapacity:0];
    }
    return _content2Array;
}

- (UIView *)listView {
    return self.view;
}

- (CMPOcrInvoiceDetailDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrInvoiceDetailDataProvider alloc] init];
    }
    return _dataProvider;
}



+ (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}


@end
