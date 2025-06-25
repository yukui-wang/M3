//
//  CMPReviewImagesTool.m
//  CMPLib
//
//  Created by 程昆 on 2019/7/4.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPReviewImagesTool.h"
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/CMPPicListViewController.h>
#import <CMPLib/NSArray+CMPArray.h>

@implementation CMPReviewImagesTool

+(NSObject <YBImageBrowserCellDataProtocol> *)browseCellDataWithDataModel:(CMPImageBrowseCellDataModel *)model {
    NSString *filePath = model.showUrlStr;
    NSString *originFilePath = model.originUrlStr;
    id thumbObject = model.thumbObject;
    NSString *lowerPathExtension = filePath.pathExtension.lowercaseString;
    if (model.filenName.length) {
        lowerPathExtension = model.filenName.lowercaseString;
    }
    NSObject <YBImageBrowserCellDataProtocol> *cellData = nil;
    
    if (   [lowerPathExtension hasSuffix:@"mp4"]
        || [lowerPathExtension hasSuffix:@"avi"]
        || [lowerPathExtension hasSuffix:@"rmvb"]
        || [lowerPathExtension hasSuffix:@"3gp"]
        | [lowerPathExtension hasSuffix:@"mov"]) {
        
        YBVideoBrowseCellData *data = [YBVideoBrowseCellData new];
        
        NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
        filePath = model.videoLocalPath;
        NSURL *originImageURL = [NSURL URLWithPathString:originFilePath];
        if (!originImageURL) {
            originImageURL = [[NSURL alloc] init];
            NSLog(@"CMPReviewImagesTool  UrlError = %@",originFilePath);
        }
        [extraDic setObject:originImageURL forKey:@"originImageURL"];
        [extraDic setObject:[NSNumber numberWithBool:NO] forKey:@"isOriginImage"];
        data.extraData = extraDic;
        
        data.url = [NSURL URLWithPathString:model.showUrlStr];
        data.imgName = model.filenName;
        data.from = model.from;
        data.fromType = model.fromType;
        data.time = model.time;
        data.fileId = model.fileId;
        data.videoPath = filePath;
        data.thumbImg = thumbObject;
        data.fileSize = model.fileSize;
        cellData = data;
        
    } else  {
        YBImageBrowseCellData *data = [YBImageBrowseCellData new];
        data.url = [NSURL URLWithPathString:filePath];
        if ([thumbObject isKindOfClass:[NSString class]]) {
             data.thumbUrl = [NSURL URLWithString:thumbObject];
        } else if ([thumbObject isKindOfClass:[UIImage class]]) {
            data.thumbImage = thumbObject;
        }
       
        NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
        NSURL *originImageURL = [NSURL URLWithPathString:originFilePath];
        if (!originImageURL) {
            originImageURL = [[NSURL alloc] init];
            NSLog(@"CMPReviewImagesTool  UrlError = %@",originFilePath);
        }
        [extraDic setObject:originImageURL forKey:@"originImageURL"];
        [extraDic setObject:[NSNumber numberWithBool:NO] forKey:@"isOriginImage"];
        [extraDic setObject:[NSNumber numberWithBool:model.canNotAutoSave] forKey:@"canNotAutoSave"];
        data.extraData = extraDic;
        data.imgName = model.filenName;
        data.from = model.from;
        data.fromType = model.fromType;
        data.time = model.time;
        data.fileId = model.fileId;
        cellData = data;
    }
    
    return cellData;
}

+(NSArray *)yb_cellDataArrFromCMPBrowserModelArr:(NSArray *)brModels
{
    NSMutableArray *browserDataArr = [NSMutableArray array];
    if (brModels) {
        [brModels enumerateObjectsUsingBlock:^(CMPImageBrowseCellDataModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject <YBImageBrowserCellDataProtocol> *data = [self browseCellDataWithDataModel:model];
            [browserDataArr addObject:data];
        }];
    }
    return browserDataArr;
}

+(YBImageBrowser *)showBrowserForMixedCaseWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray currentIndex:(NSInteger)index fromControllerIsAllowRotation:(BOOL)isAllowRotation canSave:(BOOL)canSave canPrint:(BOOL)canPrint isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn  {
    if (!dataArray || dataArray.count==0) {
        return nil;
    }
    NSMutableArray *browserDataArr = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(CMPImageBrowseCellDataModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject <YBImageBrowserCellDataProtocol> *data = [self browseCellDataWithDataModel:model];
        [browserDataArr addObject:data];
    }];
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.isFromControllerAllowRotation = isAllowRotation;
    browser.canSave = canSave;
    browser.canPrint = canPrint;
    browser.dataSourceArray = browserDataArr;
    browser.currentIndex = index;
    browser.showCheckAllPicsBtn = isShowCheckAllPicsBtn;
    //ks fix 不是uc的无法显示 8.1 jira V5-8530 M3在图片/视频管理页面收藏的图片，在我的收藏里打开显示空白
    browser.isFromUC = isShowCheckAllPicsBtn;
//    browser.isFromUC = YES;
    [browser show];
    return browser;
}

+ (void)showBrowserForMixedCaseWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray rcImgModels:(NSArray *)rcImgModels index:(NSInteger)index allDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)allDataArray allRcImgModels:(NSArray *)allRcImgModels fromControllerIsAllowRotation:(BOOL)isAllowRotation canSave:(BOOL)canSave canPrint:(BOOL)canPrint isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn  {
    
    NSMutableArray *browserDataArr = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(CMPImageBrowseCellDataModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject <YBImageBrowserCellDataProtocol> *data = [self browseCellDataWithDataModel:model];
        [browserDataArr addObject:data];
    }];
    
    NSMutableArray *allBrowserDataArr = [NSMutableArray array];
       [allDataArray enumerateObjectsUsingBlock:^(CMPImageBrowseCellDataModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
           NSObject <YBImageBrowserCellDataProtocol> *data = [self browseCellDataWithDataModel:model];
           [allBrowserDataArr addObject:data];
       }];
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.isFromControllerAllowRotation = isAllowRotation;
    browser.canSave = canSave;
    browser.canPrint = canPrint;
    browser.dataSourceArray = browserDataArr;
    browser.allDataSourceArray = allBrowserDataArr;
    browser.currentIndex = index;
    browser.rcImgModels = rcImgModels;
    browser.allRcImgModels = allRcImgModels;
    browser.showCheckAllPicsBtn = isShowCheckAllPicsBtn;
    //ks fix 不是uc的无法显示 8.1 jira V5-8530 M3在图片/视频管理页面收藏的图片，在我的收藏里打开显示空白
    browser.isFromUC = isShowCheckAllPicsBtn;
//    browser.isFromUC = YES;
    [browser show];
}


+ (void)showBrowserForMixedCaseWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray rcImgModels:(NSArray *)rcImgModels index:(NSInteger)index fromControllerIsAllowRotation:(BOOL)isAllowRotation canSave:(BOOL)canSave canPrint:(BOOL)canPrint isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn isUC:(BOOL)isUC  {
    
    NSMutableArray *browserDataArr = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(CMPImageBrowseCellDataModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject <YBImageBrowserCellDataProtocol> *data = [self browseCellDataWithDataModel:model];
        [browserDataArr addObject:data];
    }];
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.isFromControllerAllowRotation = isAllowRotation;
    browser.canSave = canSave;
    browser.canPrint = canPrint;
    browser.dataSourceArray = browserDataArr;
    browser.currentIndex = index;
    browser.rcImgModels = rcImgModels;
    browser.showCheckAllPicsBtn = isShowCheckAllPicsBtn;
    //ks fix 不是uc的无法显示 8.1 jira V5-8530 M3在图片/视频管理页面收藏的图片，在我的收藏里打开显示空白
//    browser.isFromUC = isUC;
    browser.isFromUC = isShowCheckAllPicsBtn;
//    browser.isFromUC = YES;
    [browser show];
}

+ (void)showBrowserForMixedCaseWithDataModelArray:(NSArray<id<YBImageBrowserCellDataProtocol>> *)dataArray  index:(NSInteger)index fromControllerIsAllowRotation:(BOOL)isAllowRotation canSave:(BOOL)canSave isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn {
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.isFromControllerAllowRotation = isAllowRotation;
    browser.showCheckAllPicsBtn = isShowCheckAllPicsBtn;
    browser.dataSourceArray = dataArray;
    browser.currentIndex = index;
    browser.canSave = canSave;
    //ks fix 不是uc的无法显示 8.1 jira V5-8530 M3在图片/视频管理页面收藏的图片，在我的收藏里打开显示空白
    browser.isFromUC = isShowCheckAllPicsBtn;
//    browser.isFromUC = YES;
    [browser show];
}

+ (void)showPicListViewControllerWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray rcImgModels:(NSArray *)rcImgModels canSave:(BOOL)canSave {
    
    NSMutableArray *browserDataArr = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(CMPImageBrowseCellDataModel *_Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject <YBImageBrowserCellDataProtocol> *data = [self browseCellDataWithDataModel:model];
        [browserDataArr addObject:data];
    }];
    
    NSArray *dataArr = [CMPPicListViewController groupDataArray:browserDataArr];
    CMPPicListViewController *picListVc = CMPPicListViewController.alloc.init;
    picListVc.originalDataArray = [browserDataArr.cmp_convertArrar mutableCopy];
    picListVc.dataArray = [dataArr mutableCopy];
    picListVc.canSave = canSave;
    picListVc.rcImgModels = [rcImgModels.cmp_convertArrar mutableCopy];
    [[UIViewController currentViewController] presentViewController:picListVc animated:YES completion:nil];
}

@end
