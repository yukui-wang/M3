//
//  CMPMyFilesViewController.h
//  M3
//
//  Created by MacBook on 2019/10/11.
//

#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPFileManagementRecord.h>

@class CMPFileManagementManager;

NS_ASSUME_NONNULL_BEGIN

@protocol CMPMyFilesViewControllerDelegate <NSObject>

@optional

/// 自带的documentVC选中文件后的回调
/// @param controller documentVC
/// @param urls 选中文件的url数组
- (void)myFilesVCDocumentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSString *> *)urls;

/// 发送按钮点击
/// @param selectedFiles 选中的文件
- (void)myFilesVCSendClicked:(NSArray <CMPFileManagementRecord *>*)selectedFiles;
/// 取消按钮点击
- (void)myFilesVCCancelClicked;

@end

@interface CMPMyFilesViewController : CMPBannerWebViewController

/* 传入的展示的格式，如果空则不限制 */
@property (nonatomic, strong) NSArray *acceptFormatArray;
@property (nonatomic, assign) NSInteger maxFileCount;
@property (nonatomic, assign) NSInteger maxFileSize;
/* 代理 */
@property (weak, nonatomic) id<CMPMyFilesViewControllerDelegate> delegate;
/* bottomView是否在显示中 */
@property (assign, nonatomic,readonly,getter=isBottomViewShowing) BOOL bottomViewShowing;
/* fileManager */
@property (weak, nonatomic) CMPFileManagementManager *fileManager;

- (void)setSelectedCount:(NSInteger)count;

- (void)setHideSegmentedView:(BOOL)isHidden;

#pragma mark - 显示、隐藏底部view
- (void)showBottomView;

- (void)hideBottomView;

#pragma mark 屏蔽segmentedControl的某个按钮点击
- (void)disableBtnAtIndex:(int)index disable:(BOOL)disable;
@end

NS_ASSUME_NONNULL_END
