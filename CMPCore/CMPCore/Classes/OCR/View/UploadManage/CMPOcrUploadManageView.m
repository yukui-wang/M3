//
//  CMPOcrUploadManageView.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import "CMPOcrUploadManageView.h"
#import "CMPOcrUploadManagePhotoCell.h"
#import "CMPOcrUploadManageCardCell.h"
#import <CMPLib/CMPActionSheet.h>
#import "CMPOcrAddPhotoOrCameraOrFileTool.h"
#import "CMPOcrPickPackageViewController.h"
#import "CMPOcrPickFileTool.h"
#import "CMPOcrPackageModel.h"
#import <CMPLib/YBImageBrowser.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPQuickLookPreviewController.h>

static NSString *kCMPOcrUploadManagePhotoCell = @"CMPOcrUploadManagePhotoCell";
static NSString *kCMPOcrUploadManageCardCell = @"CMPOcrUploadManageCardCell";
@interface CMPOcrUploadManageView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CMPOcrPickFileTool *pickFileTool;

@property (nonatomic, strong) NSArray<CMPOcrFileModel *> *fileArray;
@property (nonatomic, assign) BOOL forbidCreatePackage;

@property (nonatomic, strong) CMPOcrPackageModel *selectedPackage;

@property (nonatomic, copy) void(^PickedFilesCompletion)(NSArray *pickedFileArray);

@end

@implementation CMPOcrUploadManageView

- (void)setup{
    
    _tableView = [[UITableView alloc]init];
    [_tableView registerClass:CMPOcrUploadManagePhotoCell.class forCellReuseIdentifier:kCMPOcrUploadManagePhotoCell];
    [_tableView registerClass:CMPOcrUploadManageCardCell.class forCellReuseIdentifier:kCMPOcrUploadManageCardCell];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

//刷新报销包
- (void)refreshWithPackage:(CMPOcrPackageModel *)package{
    _selectedPackage = package;
    [self.tableView reloadData];
}

//加载数据
- (void)reloadDataWithFileArray:(NSArray *)fileArray forbidCreatePackage:(BOOL)forbidCreatePackage completion:(void (^)(NSArray *))completion{
    self.PickedFilesCompletion = completion;
    self.fileArray = fileArray;
    self.forbidCreatePackage = forbidCreatePackage;
    
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:fileArray];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return [CMPOcrUploadManagePhotoCell heightWithCount:self.dataSource.count+1];
    }
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _forbidCreatePackage?1:2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        CMPOcrUploadManagePhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCMPOcrUploadManagePhotoCell forIndexPath:indexPath];
        cell.backgroundColor = UIColor.clearColor;
        
        __weak typeof(self) weakSelf = self;
        [cell reloadDataWith:self.dataSource completion:^{
            [weakSelf.tableView reloadData];
        }];
        
        cell.ClickedAddPhotoCollectionCell = ^{
            [weakSelf.pickFileTool showSheetForPickToVC:weakSelf.viewController Completion:^(NSArray<CMPOcrFileModel *> *fileArray) {
                //添加选择后的图片
                //imageFileIdentifier相册图片/fileId我的收藏/localUrl手机文件
                if(fileArray.count){
                    NSMutableArray *uniqueArr = [NSMutableArray new];
                    for (CMPOcrFileModel *sourceFile in self.dataSource) {
                        if (sourceFile.imageFileIdentifier) {
                            [uniqueArr addObject:sourceFile.imageFileIdentifier];
                        }else if (sourceFile.fileId){
                            [uniqueArr addObject:sourceFile.fileId];
                        }else if (sourceFile.localUrl){
                            [uniqueArr addObject:sourceFile.localUrl];
                        }
                    }
                    BOOL hasRepeat = NO;
                    NSMutableArray *validArr = [NSMutableArray new];
                    for (CMPOcrFileModel *file in fileArray) {
                        if ([uniqueArr containsObject:file.imageFileIdentifier]
                            ||[uniqueArr containsObject:file.fileId]
                            ||[uniqueArr containsObject:file.localUrl]) {
                            hasRepeat = YES;
                            continue;
                        }else{
                            [validArr addObject:file];
                        }
                    }
                    if (validArr.count) {
                        [weakSelf.dataSource addObjectsFromArray:validArr];
                        [weakSelf.tableView reloadData];
                        if(weakSelf.PickedFilesCompletion){
                            weakSelf.PickedFilesCompletion(weakSelf.dataSource);
                        }
                    }
                    if (hasRepeat) {
                        [weakSelf cmp_showHUDWithText:@"存在重复文件，已为您删除"];
                    }
                }
            }];
        };

        //点击cell查看图片orPDF
        cell.ClickedPhotoCollectionCell = ^(id obj){
            if ([obj isKindOfClass:CMPOcrFileModel.class]) {
                CMPOcrFileModel *fileModel = obj;
                if ([fileModel.fileType containsString:@"pdf"]) {//pdf
                    if (fileModel.localUrl.length>0) {
                        AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
                        aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
                        aParam.fileName = fileModel.originalName;
                        aParam.fileType = fileModel.fileType;
                        CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
                        aViewController.attReaderParam = aParam;
                        aParam.url = fileModel.localUrl;
                        [weakSelf.viewController.navigationController pushViewController:aViewController animated:YES];
                    }else if(fileModel.fileId.length>0){
                        AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
                        aParam.fileId = fileModel.fileId;
                        CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
                        aParam.url = [CMPCore fullUrlForPathFormat:@"/rest/attachment/file/%@", fileModel.fileId];
                        aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
                        aParam.fileName = fileModel.originalName;
                        aParam.fileType = fileModel.fileType;
                        aViewController.attReaderParam = aParam;
                        [weakSelf.viewController.navigationController pushViewController:aViewController animated:YES];
                    }
                }else{
                    NSURL *URL;
                    if (fileModel.localUrl.length>0) {
                        URL = [NSURL URLWithString:fileModel.localUrl];
                        fileModel.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fileModel.localUrl]];
                    }else if(fileModel.fileId.length>0){//在线图片
                        NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/commonImage/showImage?size=source&id=%@", fileModel.fileId];
                        URL = [NSURL URLWithString:url];
                    }
                    YBImageBrowseCellData *cellData;
                    if(fileModel.image){
                        cellData = [[YBImageBrowseCellData alloc]init];
                        cellData.imageBlock = ^__kindof UIImage * _Nullable{
                            YBImage *ybImage = [YBImage imageWithData:UIImageJPEGRepresentation(fileModel.image,1)];
                            return ybImage;
                        };
                    }else if (URL) {
                        cellData = [[YBImageBrowseCellData alloc]init];
                        cellData.url = URL;
                        cellData.extraData = @{
                            @"originImageURL":URL
                        };
                    }
                    if (cellData) {
                        YBImageBrowser *browser = [YBImageBrowser new];
                        browser.toolBars = @[];
                        browser.dataSourceArray = @[cellData];
                        browser.allDataSourceArray = @[cellData];
                        browser.currentIndex = 0;
                        browser.showCheckAllPicsBtn = NO;
                        [browser show];
                    }
                }
            }
        };
        
        return cell;
    }else if (indexPath.row == 1) {
        CMPOcrUploadManageCardCell *cell = [tableView dequeueReusableCellWithIdentifier:kCMPOcrUploadManageCardCell forIndexPath:indexPath];
        cell.packageNameLabel.text = self.selectedPackage.name?:@"";
        return cell;
    }
    return UITableViewCell.new;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_canClickCreatePackage && !_forbidCreatePackage && indexPath.row == 1) {
        if (_PickPackageSectionBlock) {
            _PickPackageSectionBlock();
        }
    }
}

- (CMPOcrPickFileTool *)pickFileTool{
    if (!_pickFileTool) {
        _pickFileTool = [CMPOcrPickFileTool new];
    }
    return _pickFileTool;
}
- (NSMutableArray *)dataSource{
    if(!_dataSource){
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
@end
