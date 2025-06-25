//
//  SyOfflineFilesListViewController.m
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyOfflineFilesListViewController.h"
#import "SyOfflineFilesViewCell.h"
#import "SyFileProvider.h"
#import "SyFilePage.h"
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPQuickLookPreviewController.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPRecordView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/MJRefresh.h>
#include <CMPLib/CMPSplitViewController.h>

#define kC_iPageType_Refresh 1
#define kC_iPageType_LoadMore 2

static NSString* const kCancel_button_color = @"00BCF7"; // 取消按钮颜色值

@interface SyOfflineFilesListViewController ()<SySearchOfflineFilesViewControllerDelegate>
{
    NSInteger focusRow;
    NSInteger focusSection;
    BOOL       isLongPress;
    UIButton    *searchButton;
    UIButton    *cancelButton;
    NSMutableArray *_listArray;
    NSInteger               _pageIndex; // 页索引
    NSInteger               _startIndex; // 获取条数的起始索引，默认为0
    NSInteger               _pageType; // 列表获取方式
    NSInteger               _totalCount; // 总数
    UILongPressGestureRecognizer *gestureLongPress;
    NSMutableArray *_selectedFileList;
}

// 为列表刷新配置变量
- (void)setupForRefresh;
// 为加载更多数据配置变量
- (void)setupForLoadMore;
@end

@implementation SyOfflineFilesListViewController

- (void)dealloc
{
    SY_RELEASE_SAFELY(_listArray);
    SY_RELEASE_SAFELY(gestureLongPress);
    SY_RELEASE_SAFELY(_selectedFileList);
    SY_RELEASE_SAFELY(_bannerTitle);    
    [super dealloc];
}

- (void)createSearchButton
{
    self.bannerNavigationBar.leftViewsMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 0.0f;
    self.bannerNavigationBar.leftMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    searchButton =  [self bannerSearchButton];
    [searchButton addTarget:self action:@selector(pushSearchView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:searchButton, nil]];
}

- (void)createCancelButton
{
    self.bannerNavigationBar.leftViewsMargin = 0.0;
    self.bannerNavigationBar.leftMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 0.0;
    self.bannerNavigationBar.rightMargin = 0.0f;
    cancelButton = [UIButton transparentButtonWithFrame:CGRectMake(0, 0, 60, 38) title:SY_STRING(@"common_cancel")];
    [cancelButton setTitleColor:[UIColor colorWithHexString:kCancel_button_color] forState:UIControlStateNormal];
    
    [cancelButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:cancelButton, nil]];
}

- (void)pushSearchView
{
    SySearchOfflineFilesViewController *searchOfflineFilesViewController = [[SySearchOfflineFilesViewController alloc] init];
    searchOfflineFilesViewController.typeID = 0;
    searchOfflineFilesViewController.returnDelegate = self;
    [self.navigationController pushViewController:searchOfflineFilesViewController animated:YES];
    SY_RELEASE_SAFELY(searchOfflineFilesViewController);
}

- (void)cancelButton:(id)sender
{
    isLongPress = NO;
    [self createSearchButton];
    _offlineFilesListView.isLongPress = isLongPress;
    [_selectedFileList removeAllObjects];
    [_offlineFilesListView layoutSubviews];
    [_offlineFilesListView.offlineFilesTableView reloadData];
    if ([NSString isNull:self.bannerTitle]) {
        [self setTitle:SY_STRING(@"offlineFiles_myfile")];
    } else {
        [self setTitle:self.bannerTitle];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowRotation = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    if ([NSString isNull:self.bannerTitle]) {
        [self setTitle:SY_STRING(@"offlineFiles_myfile")];
    } else {
        [self setTitle:self.bannerTitle];
    }
    [self createSearchButton];
    _offlineFilesListView = (SyOfflineFilesListView *)self.mainView;
    _offlineFilesListView.offlineFilesTableView.dataSource = self;
    _offlineFilesListView.offlineFilesTableView.delegate = self;
    gestureLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureLongPress:)];
    [_offlineFilesListView addGestureRecognizer:gestureLongPress];
    
    [_offlineFilesListView.deleteButton addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
    if (!_listArray) {
        _listArray = [[NSMutableArray alloc] init];
    }
    if (!_selectedFileList) {
        _selectedFileList = [[NSMutableArray alloc] init];
    }
    
    
    __weak SyOfflineFilesListViewController* weakSelf = self;

    _offlineFilesListView.offlineFilesTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf tableViewHeaderReresh];
    }];
    _offlineFilesListView.offlineFilesTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf tableviewFooterRefresh];
    }];
    _offlineFilesListView.offlineFilesTableView.mj_header.automaticallyChangeAlpha = YES;
    _offlineFilesListView.offlineFilesTableView.mj_footer.automaticallyHidden =YES;
    [self request];
}

- (void)request
{
    if (_pageType == kC_iPageType_Refresh) {
        [_listArray removeAllObjects];
        
    }
    SyFilePage  * aFilePage = [[SyFileProvider instance] findOfflineFilesWithStartIndex:_startIndex rowCount:20 ];
    _totalCount = aFilePage.totalCount;
    [_listArray addObjectsFromArray:aFilePage.fileList];
    
    [_offlineFilesListView.offlineFilesTableView reloadDataWithTotalCount:_totalCount currentCount:_listArray.count];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [_offlineFilesListView.offlineFilesTableView reloadData];
}

- (void)setupForRefresh
{
    _pageIndex = 0;
    _startIndex = 0;
    _pageType = kC_iPageType_Refresh;
}

- (void)setupForLoadMore
{
    _pageIndex +=1;
    _startIndex = _listArray.count;
    _pageType = kC_iPageType_LoadMore;
}


- (void)tableViewHeaderReresh
{
    [self setupForRefresh];
    [self request];
}

- (void)tableviewFooterRefresh
{
    [self setupForLoadMore];
    [self request];
}


- (void)deleteButton:(id)sender
{
    [[SyFileProvider instance] deleteFilesWithOfflineFiles:_selectedFileList];
    [_selectedFileList removeAllObjects];
    isLongPress = NO;
    [self createSearchButton];
    _offlineFilesListView.isLongPress = isLongPress;
    [_offlineFilesListView layoutSubviews];
    [self setupForRefresh];
    [self request];
    if ([NSString isNull:self.bannerTitle]) {
        [self setTitle:SY_STRING(@"offlineFiles_myfile")];
    } else {
        [self setTitle:self.bannerTitle];
    }
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"offlineFilesViewCellIdentifier";
    SyOfflineFilesViewCell *cell = (SyOfflineFilesViewCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[[SyOfflineFilesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier] autorelease];
        cell.delegate = self;
    }
    if (indexPath.row < _listArray.count) {
        cell.isLongPress = isLongPress;
        CMPOfflineFileRecord *downloadFile = [_listArray objectAtIndex:indexPath.row];
        cell.downloadFile = downloadFile;
        if ([_selectedFileList containsObject:downloadFile]) {
            [_offlineFilesListView.offlineFilesTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            cell.isSelecte = YES;
            
        }else{
            cell.isSelecte = NO;
        }
        [cell setOfflineFilesListItem:downloadFile];
        
        if (indexPath.row == _listArray.count - 1) {
            cell->_separatorLine.hidden = YES;
        } else {
            cell->_separatorLine.hidden = NO;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isLongPress) {
        SyOfflineFilesViewCell *cell = (SyOfflineFilesViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.isLongPress = isLongPress;
        [cell setSelectedCell:YES animated:YES];
    }else{
        if (indexPath.row < _listArray.count) {
            CMPOfflineFileRecord *downloadFile = [_listArray objectAtIndex:indexPath.row];
            NSString *aPath = downloadFile.fullLocalPath;
            aPath = [CMPFileManager unEncryptFile:aPath fileName:downloadFile.localName];
            NSInteger attType = [CMPFileManager getFileType:aPath];
            if (attType == QK_AttchmentType_AUDIO) {
                [self showRecordView:aPath];
                return;
            }
            CMPQuickLookPreviewController *controller = [[CMPQuickLookPreviewController alloc] init];
            AttachmentReaderParam *param = [[[AttachmentReaderParam alloc] init] autorelease];
            param.filePath = aPath;
            param.fileName = downloadFile.fileName;
            param.canDownload = NO; // 如果是离线文档进来，不显示保存入口
            controller.attReaderParam = param;
            if (CMP_IPAD_MODE &&
                [self.navigationController.topViewController cmp_canPushInDetail]) {
                [self.navigationController.topViewController cmp_showDetailViewController:controller];
            } else {
                [self.navigationController pushViewController:controller animated:YES];
            }
            [controller release];
            controller = nil;
        }
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLongPress) {
        SyOfflineFilesViewCell *cell = (SyOfflineFilesViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.isLongPress = isLongPress;
        [cell setSelectedCell:NO animated:YES];
    }
}

- (void)gestureLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint tmpPointTouch = [gestureRecognizer locationInView:_offlineFilesListView.offlineFilesTableView];
    if (!isLongPress) {
        NSIndexPath *indexPath = [_offlineFilesListView.offlineFilesTableView indexPathForRowAtPoint:tmpPointTouch];
        if (indexPath == nil) {
            NSLog(@"not tableView");
        }else{
            focusRow = [indexPath row];
            focusSection = [indexPath section];
            isLongPress = YES;
            [self createCancelButton];
            [_offlineFilesListView.offlineFilesTableView reloadData];
            _offlineFilesListView.isLongPress = isLongPress;
            [_offlineFilesListView layoutSubviews];
            SyOfflineFilesViewCell *cell = (SyOfflineFilesViewCell*)[_offlineFilesListView.offlineFilesTableView cellForRowAtIndexPath:indexPath];
            cell.isLongPress = isLongPress;
            [cell setSelectedCell:YES animated:YES];
            [_offlineFilesListView.offlineFilesTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}


#pragma mark- SyOfflineFilesViewCellDelegate

- (void)offlineFilesSelecte:(SyOfflineFilesViewCell*)aCell
{
    NSIndexPath *indexpath =  [_offlineFilesListView.offlineFilesTableView indexPathForCell:aCell];
    if (aCell.isSelecte) {
        if (indexpath.row < _listArray.count) {
            CMPOfflineFileRecord *file = [_listArray objectAtIndex:indexpath.row];
            if (![_selectedFileList containsObject:file]) {
                [_selectedFileList addObject:file];
            }
            
        }
    }else{
        if (indexpath.row < _listArray.count) {
            CMPOfflineFileRecord *file = [_listArray objectAtIndex:indexpath.row];
            if ([_selectedFileList containsObject:file]){
                [_selectedFileList removeObject:file];
            }
            
        }
    }
    if (_selectedFileList.count >0) {
        _offlineFilesListView.deleteButton.enabled = YES;
    }else{
        _offlineFilesListView.deleteButton.enabled = NO;
    }
    if (isLongPress) {
        [self setTitle:[NSString stringWithFormat:SY_STRING(@"offlineFiles_haveBeenSelect_xx"),_selectedFileList.count]];
        
    }else{
        if ([NSString isNull:self.bannerTitle]) {
            [self setTitle:SY_STRING(@"offlineFiles_myfile")];
        } else {
            [self setTitle:self.bannerTitle];
        }
    }
}
#pragma mark- SySearchOfflineFilesViewControllerDelegate

- (void)searchOfflineFilesViewControllerDidReturn:(SySearchOfflineFilesViewController *)aViewController
{
    [self setupForRefresh];
    [self request];
}



- (void)showRecordView:(NSString *)path
{
    CMPRecordView *recordView = [[[CMPRecordView alloc] initWithDelegate:nil type:CMPRecordViewTypePlay] autorelease];
    [recordView show];
    [recordView playWithFilePath:path];
}

@end
