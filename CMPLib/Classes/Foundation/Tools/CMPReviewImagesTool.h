//
//  CMPReviewImagesTool.h
//  CMPLib
//
//  Created by 程昆 on 2019/7/4.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>
#import "YBImageBrowser.h"
#import "CMPImageBrowseCellDataModel.h"


@interface CMPReviewImagesTool : CMPObject

+ (void)showBrowserForMixedCaseWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray rcImgModels:(NSArray *)rcImgModels index:(NSInteger)index allDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)allDataArray allRcImgModels:(NSArray *)allRcImgModels fromControllerIsAllowRotation:(BOOL)isAllowRotation canSave:(BOOL)canSave canPrint:(BOOL)canPrint isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn;
+ (void)showBrowserForMixedCaseWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray
                                      rcImgModels:(NSArray *)rcImgModels
                                            index:(NSInteger)index
                    fromControllerIsAllowRotation:(BOOL)isAllowRotation
                                          canSave:(BOOL)canSave
                                         canPrint:(BOOL)canPrint
                            isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn
                                             isUC:(BOOL)isUC;
+ (void)showBrowserForMixedCaseWithDataModelArray:(NSArray<id<YBImageBrowserCellDataProtocol>> *)dataArray  index:(NSInteger)index fromControllerIsAllowRotation:(BOOL)isAllowRotation canSave:(BOOL)canSave isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn;
+ (void)showPicListViewControllerWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray rcImgModels:(NSArray *)rcImgModels canSave:(BOOL)canSave;

+(YBImageBrowser *)showBrowserForMixedCaseWithDataModelArray:(NSArray <CMPImageBrowseCellDataModel *>*)dataArray currentIndex:(NSInteger)index fromControllerIsAllowRotation:(BOOL)isAllowRotation canSave:(BOOL)canSave canPrint:(BOOL)canPrint isShowCheckAllPicsBtn:(BOOL)isShowCheckAllPicsBtn;
+(NSArray *)yb_cellDataArrFromCMPBrowserModelArr:(NSArray *)brModels;

@end


