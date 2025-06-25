//
//  CMPVideoSelectView.m
//  CMPLib
//
//  Created by MacBook on 2019/12/23.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPVideoSelectView.h"

#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/YBImageBrowserSheetView.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/CMPCommonDataProviderTool.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPUploadFileTool.h>
#import <CMPLib/SyFileManager.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/YBImageBrowserTipView.h>


static NSString * const kIdentityOfYBImageBrowserSheetCell = @"kIdentityOfYBImageBrowserSheetCell";

@interface CMPVideoSelectView()<UITableViewDelegate,UITableViewDataSource>

/* tableView */
@property (strong, nonatomic) UITableView *tableView;
/* dataArray */
@property (strong, nonatomic) NSArray *dataArray;

/* 是否能分享,默认NO */
@property (assign, nonatomic) BOOL canNotShare;
/* 是否能收藏,默认NO */
@property (assign, nonatomic) BOOL canNotCollect;
/* 是否能保存,默认NO */
@property (assign, nonatomic) BOOL canNotSave;

/* 是否来自uc */
@property (assign, nonatomic) BOOL isUc;

@end

@implementation CMPVideoSelectView
#pragma mark - initialise view
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView.alloc initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.rowHeight = 50.f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:YBImageBrowserSheetCell.class forCellReuseIdentifier:kIdentityOfYBImageBrowserSheetCell];
    }
    return _tableView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.customBgColor = [UIColor cmp_colorWithName:@"white-bg"];
        [self addSubview:self.tableView];
        [self configDataArrayWithCanNotShare:NO canNotCollect:NO canNotSave:NO];
    }
    return self;
}

- (void)configDataArrayWithCanNotShare:(BOOL)canNotShare canNotCollect:(BOOL)canNotCollect canNotSave:(BOOL)canNotSave {
    self.canNotShare = canNotShare;
    self.canNotCollect = canNotCollect;
    self.canNotSave = canNotSave;
    NSMutableArray *dataArr = NSMutableArray.array;
    NSMutableArray *subArray0 = NSMutableArray.array;
    if (!canNotShare) {
        NSMutableDictionary *dic = NSMutableDictionary.dictionary;
        dic[@"title"] = SY_STRING(@"share_btn_share");
        dic[@"index"] = @0;
        [subArray0 addObject:dic];
    }
    if (!canNotCollect) {
        NSMutableDictionary *dic = NSMutableDictionary.dictionary;
        dic[@"title"] = SY_STRING(@"share_btn_collect");
        dic[@"index"] = @1;
        [subArray0 addObject:dic];
    }
    if (!canNotSave) {
        NSMutableDictionary *dic = NSMutableDictionary.dictionary;
        dic[@"title"] = SY_STRING(@"common_save");
        dic[@"index"] = @2;
        [subArray0 addObject:dic];
    }
    
    if (subArray0.count) {
        NSMutableDictionary *dic = NSMutableDictionary.dictionary;
        dic[@"title"] = SY_STRING(@"common_cancel");
        dic[@"index"] = @0;
        NSArray *subArray1 = @[dic];
        [dataArr addObject:subArray0];
        [dataArr addObject:subArray1];
        self.dataArray = dataArr.copy;
        [self.tableView reloadData];
    }
}

- (void)setCanNotShare:(BOOL)canNotShare canNotCollect:(BOOL)canNotCollect canNotSave:(BOOL)canNotSave isUc:(BOOL)isUc {
    self.isUc = isUc;
    [self configDataArrayWithCanNotShare:canNotShare canNotCollect:canNotCollect canNotSave:canNotSave];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *subDataArr = self.dataArray[section];
    return subDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YBImageBrowserSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentityOfYBImageBrowserSheetCell];
    
    NSArray *subDataArr = self.dataArray[indexPath.section];
    NSDictionary *data = subDataArr[indexPath.row];
    cell.textLabel.text = data[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = UIColor.clearColor;
    if (indexPath.section == 1) {
        cell.line.hidden = YES;
        cell.textLabel.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
    }else {
        cell.line.hidden = NO;
        cell.textLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    }
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return UIView.new;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 0;
    
    return 14.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)  return UIView.new;
    
    UIView *header = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 14.f)];
    header.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_cancelClicked) {
        _cancelClicked();
    }
    
    if (indexPath.section != 0) return;
    NSArray *subDataArr = self.dataArray[indexPath.section];
    NSDictionary *data = subDataArr[indexPath.row];
    switch ([data[@"index"] intValue]) {
        case 0:
        {
            //分享
            [self shareMsg];
        }
            break;
        case 1:
        {
            //收藏
            [self collectMsg];
        }
            break;
        case 2:
        {
            //保存
            [self saveVideo];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark  - 点击事件
/// 分享视频消息
- (void)shareMsg {
    NSString *url = self.url;
    NSString *fileId = self.fileId;
    if (!fileId.length) {
        fileId = [CMPCommonTool getSourceIdWithUrl:url];
    }
    
    NSString *fileName = self.fileName;
    if (!fileName.length) {
        fileName = self.url.lastPathComponent;
    }
    NSString *filePath = url;
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    long long aLen = [CMPFileManager fileSizeAtPath:filePath];
    
    //分享中不显示qq
    NSMutableArray *notShowArr = NSMutableArray.array;
    [notShowArr addObject:CMPShareComponentQQString];
    if (!self.canNotSave) {
        [notShowArr addObject:CMPShareComponentPrintString];
    } else {
        [notShowArr addObject:CMPShareComponentPrintString];
        [notShowArr addObject:CMPShareComponentDownloadString];
    }
    
    CMPFileManagementRecord *mfr = CMPFileManagementRecord.alloc.init;
    mfr.filePath = filePath;
    mfr.fileSize = [NSString stringWithLongLong:aLen];
    mfr.fileId = fileId;
    mfr.fileName = fileName;
    mfr.fileUrl = url;
    mfr.lastModify = [NSDate.date timeIntervalSince1970]*1000;
    mfr.from = self.from;
    mfr.fromType = self.fromType;
    mfr.origin = self.fileId;
    mfr.isUc = self.isUc;
    mfr.notShowShareIcons = notShowArr;
    NSDictionary *obj = @{@"mfr" : mfr,@"pushVC" : self.vc};
    [NSNotificationCenter.defaultCenter postNotificationName:CMPAttachReaderShareClickedNoti object:obj];
}

/// 收藏消息
- (void)collectMsg {
    id content = [self.msgModel performSelector:@selector(content)];
    NSString *url = [content performSelector:@selector(remoteUrl)];
    NSString *sourceId = [CMPCommonTool getSourceIdWithUrl:url];
    BOOL isUc = self.isUc;
    BOOL isUploading = NO;
    if (self.fileId.length) {
        if (!self.fileId.justContainsNumber) {
            //这里需要做上传操作
            [CMPUploadFileTool.sharedTool requestToUploadFileWithFilePath:self.url startBlock:^{
                [MBProgressHUD cmp_showProgressHUD];
            } successBlock:^(NSString * _Nonnull fileId) {
                
                [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:fileId isUc:isUc filePath:nil];
            } failedBlock:nil];
            
            isUploading = YES;
        }else {
            sourceId = self.fileId.copy;
        }
        
    }
    
    NSString *filePath = self.url;
    if (sourceId.length ) {
        [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:sourceId isUc:isUc filePath:filePath];
    }else if(!isUploading) {
        
        [CMPUploadFileTool.sharedTool requestToUploadFileWithFilePath:filePath startBlock:^{
            [MBProgressHUD cmp_showProgressHUD];
        } successBlock:^(NSString * _Nonnull fileId) {
            
            [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:fileId isUc:isUc filePath:nil];
        } failedBlock:nil];
        
        
    }
    
    
}

/// 保存视频
/// videoPath为视频下载到本地之后的本地路径
- (void)saveVideo {
    if (!self.url) return;
    
    NSString *path = [self.url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    path = [path stringByRemovingPercentEncoding];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        //保存相册
        //[MBProgressHUD zl_showMessage:@""];
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}


/// 保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        CMPLog(@"保存视频到相册失败%@", error.localizedDescription);
        [[UIApplication sharedApplication].keyWindow yb_showForkTipView:SY_STRING(@"review_image_saveToPhotoAlbumFailed")];
    }
    else {
        CMPLog(@"保存视频到相册成功");
        [[UIApplication sharedApplication].keyWindow yb_showHookTipView:SY_STRING(@"review_image_saveToPhotoAlbumSuccess")];
    }
  
}

@end
