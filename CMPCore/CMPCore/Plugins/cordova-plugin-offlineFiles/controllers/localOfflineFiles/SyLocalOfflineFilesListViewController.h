//
//  SyLocalOfflineFilesListViewController.h
//  M1Core
//
//  Created by chenquanwei on 14-3-14.
//
//

#import <CMPLib/CMPBannerViewController.h>
#import "SyLocalOfflineFilesListView.h"
#import "SyLocalOfflineFilesListViewCell.h"
#import <CMPLib/CMPOfflineFileRecord.h>

@protocol SyLocalOfflineFilesListViewControllerDelegate;

@interface SyLocalOfflineFilesListViewController : CMPBannerViewController<UITableViewDataSource,UITableViewDelegate,SyLocalOfflineFilesListViewCellDelegate>
{
    SyLocalOfflineFilesListView *_localOfflineFilesListView;
}

@property (nonatomic, assign)id <SyLocalOfflineFilesListViewControllerDelegate >delegate;
@property (nonatomic, assign) NSInteger maxFileSize;//图片大小限制，默认5M
/* 传入的展示的格式，如果空则不限制 */
@property (nonatomic, strong) NSArray *acceptFormatArray;
@property (nonatomic, assign) NSInteger maxFileCount;

@property (nonatomic, assign)BOOL isFromChatViewController;

- (void)setInitValue:(NSDictionary *)initValue;
- (void)setHideSegmentedView:(BOOL)isHidden;
@end

@protocol SyLocalOfflineFilesListViewControllerDelegate <NSObject>

- (void)localOfflineFilesListViewController:(id)aLocalOfflineFilesListViewController didFinishedSelected:(NSArray<CMPOfflineFileRecord*> *)result;
- (void)localOfflineFilesListViewController:(id)aLocalOfflineFilesListViewController didPickDocumentsAtURLs:(NSArray<NSString*> *)result;

- (void)localOfflineFilesListViewControllerDidCancel:(id)aLocalOfflineFilesListViewController;
@optional


@end
