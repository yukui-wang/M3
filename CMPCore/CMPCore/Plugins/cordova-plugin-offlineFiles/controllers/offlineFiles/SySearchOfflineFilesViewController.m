//
//  SySearchOfflineFilesViewController.m
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//
#define kC_iPageType_Refresh 1
#define kC_iPageType_LoadMore 2
#define kC_sSearchMethod_Time 2
#define kC_sSearchMethod_Subject 3

#import "SySearchOfflineFilesViewController.h"
#import "SyOfflineFilesViewCell.h"
#import "SyFileProvider.h"
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPQuickLookPreviewController.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPRecordView.h>
#import <CMPLib/MJRefresh.h>
#import <CMPLib/UIColor+Hex.h>

static NSString* const kCancel_button_color = @"00BCF7"; // 取消按钮颜色值

@interface SySearchOfflineFilesViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UILongPressGestureRecognizer *gestureLongPress;
    BOOL       isLongPress;
    NSInteger focusRow;
    NSInteger focusSection;
    UIButton    *cancelButton;
    NSMutableArray *_selectedFileList;
}
// 为列表刷新配置变量
- (void)setupForRefresh;
// 为加载更多数据配置变量
- (void)setupForLoadMore;
//搜索
- (void)searchOfflineFiles;
- (void)requestSearchOfflineFiles;

@end

@implementation SySearchOfflineFilesViewController

@synthesize spaceType = _spaceType;
@synthesize typeID = _typeID;
@synthesize returnDelegate = _returnDelegate;

- (void)dealloc
{
    SY_RELEASE_SAFELY(_searchList);
    SY_RELEASE_SAFELY(_titles);
    SY_RELEASE_SAFELY(gestureLongPress);
//    SY_RELEASE_SAFELY(cancelButton);
    SY_RELEASE_SAFELY(_selectedFileList);
    [super dealloc];
}

- (void)setupBannerButtons
{
    self.bannerNavigationBar.leftViewsMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 10.0f;
    self.bannerNavigationBar.leftMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    self.backBarButtonItemHidden = YES;
    UIButton *returnButon = [self bannerCloseButton];
    [returnButon addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setLeftBarButtonItems:[NSMutableArray arrayWithObjects:returnButon, nil]];
    _titles = [[NSArray alloc]initWithObjects:SY_STRING(@"common_search_subject"), nil];
    [self setTitle:SY_STRING(@"common_search")];
}

- (void)createCancelButton
{
    self.bannerNavigationBar.leftViewsMargin = 0.0;
    self.bannerNavigationBar.leftMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 0.0;
    self.bannerNavigationBar.rightMargin = 10.0f;
    cancelButton = [UIButton transparentButtonWithFrame:CGRectMake(0, 0, 60, 38) title:SY_STRING(@"common_cancel")];
    [cancelButton setTitleColor:[UIColor colorWithHexString:kCancel_button_color] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems: [NSMutableArray arrayWithObjects:cancelButton, nil]];
    
}

- (void)cancelButton:(id)sender
{
    isLongPress = NO;
    [self setTitle:SY_STRING(@"common_search")];
    _searchOfflineFilesView.isLongPress = isLongPress;
    [_selectedFileList removeAllObjects];
    [self.bannerNavigationBar setRightBarButtonItems: nil];
    [_searchOfflineFilesView layoutSubviews];
    [_searchOfflineFilesView.searchTableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowRotation = NO;
    _canRequest= NO;
    _searchOfflineFilesView = (SySearchOfflineFilesView *)self.mainView;
    [_searchOfflineFilesView.searchItem.searchButton addTarget:self
                                                        action:@selector(searchOfflineFiles)
                                              forControlEvents:UIControlEventTouchUpInside];
    _searchOfflineFilesView.searchItem.searchButton.enabled = NO;
    _searchOfflineFilesView.searchItem.keyTextField.delegate = self;
    _searchOfflineFilesView.searchTableView.delegate = self;
    _searchOfflineFilesView.searchTableView.dataSource = self;
    if (!_selectedFileList) {
        _selectedFileList = [[NSMutableArray alloc] init];
    }
    if (!_searchList) {
        _searchList = [[NSMutableArray alloc] init];
    }
    _searchMethod = kC_sSearchMethod_Subject;
    gestureLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureLongPress:)];
    [_searchOfflineFilesView addGestureRecognizer:gestureLongPress];
    [_searchOfflineFilesView.deleteButton addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    __weak SySearchOfflineFilesViewController* weakSelf = self;

    _searchOfflineFilesView.searchTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf tableViewHeaderReresh];
    }];
    _searchOfflineFilesView.searchTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf tableviewFooterRefresh];
    }];
    
    _searchOfflineFilesView.searchTableView.mj_footer.automaticallyHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [self setupForRefresh];
    //    [self requestSearchNews];
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
    _startIndex = _searchList.count;
    _pageType = kC_iPageType_LoadMore;
}

- (void)tableViewHeaderReresh
{
    [self setupForRefresh];
    [self requestSearchOfflineFiles];
    [_searchOfflineFilesView.searchTableView.mj_header endRefreshing];
}

- (void)tableviewFooterRefresh
{
    [self setupForLoadMore];
    [self requestSearchOfflineFiles];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newString deleteBothSidesWhitespaces].length > 0) {
        _canRequest = YES;
    }
    else{
        _canRequest = NO;
        
    }
    _searchOfflineFilesView.searchItem.searchButton.enabled = _canRequest;
    NSLog(@"textField :newString = %@ ",newString);
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_canRequest) {
        [self searchOfflineFiles];
        return YES;
    }
    return NO;
}


//搜索
- (void)searchOfflineFiles
{
    [self setupForRefresh];
    [self requestSearchOfflineFiles];
    
}

//返回
- (void)backBarButtonAction:(id)sender
{
    if (self.returnDelegate && [self.returnDelegate respondsToSelector:@selector(searchOfflineFilesViewControllerDidReturn:)]) {
        [self.returnDelegate performSelector:@selector(searchOfflineFilesViewControllerDidReturn:) withObject:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)titleViewTapAction:(id)sender
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *collaborationListCellIdentifier = @"offlineFilesViewCellIdentifier";
    SyOfflineFilesViewCell *cell = (SyOfflineFilesViewCell *)[tableView dequeueReusableCellWithIdentifier:collaborationListCellIdentifier];
    if (!cell) {
        cell = [[[SyOfflineFilesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collaborationListCellIdentifier] autorelease];
        cell.delegate = self;
    }
    if (indexPath.row < _searchList.count) {
        cell.isLongPress = isLongPress;
        CMPOfflineFileRecord *downloadFile = [_searchList objectAtIndex:indexPath.row];
        cell.downloadFile = downloadFile;
        if ([_selectedFileList containsObject:downloadFile]) {
            [_searchOfflineFilesView.searchTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            cell.isSelecte = YES;
        }else{
            cell.isSelecte = NO;
        }
        [cell setOfflineFilesListItem:downloadFile];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _searchList.count) {
        if (isLongPress) {
            SyOfflineFilesViewCell *cell = (SyOfflineFilesViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            cell.isLongPress = isLongPress;
            [cell setSelectedCell:YES animated:YES];
        }else{
            CMPOfflineFileRecord *downloadFile = [_searchList objectAtIndex:indexPath.row];
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
            param.canDownload = NO; // 如果是离线文档进来，不显示保存入口
            controller.attReaderParam = param;
            [self.navigationController pushViewController:controller animated:YES];
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

#pragma mark- request
- (void)requestSearchOfflineFiles
{
    if (_pageType == kC_iPageType_Refresh) {
        [_searchList removeAllObjects];
        
    }
    NSString *condition1 = nil;
    if(_searchMethod == kC_sSearchMethod_Subject){
        condition1 = [_searchOfflineFilesView.searchItem titleKeyWords];
    }
    SyFilePage  * aFilePage = [[SyFileProvider instance] searchOfflineFilesWithKeyWord:condition1 startIndex:_startIndex rowCount:20];
    _totalCount = aFilePage.totalCount;
    [_searchList addObjectsFromArray:aFilePage.fileList];
    
    
    [_searchOfflineFilesView.searchItem hiddenKeyBorder];
    [_searchOfflineFilesView showSearchTableView];
    [_searchOfflineFilesView.searchTableView reloadDataWithTotalCount:_totalCount currentCount:_searchList.count];
}

- (void)gestureLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint tmpPointTouch = [gestureRecognizer locationInView:_searchOfflineFilesView.searchTableView];
    if (!isLongPress) {
        NSIndexPath *indexPath = [_searchOfflineFilesView.searchTableView indexPathForRowAtPoint:tmpPointTouch];
        if (indexPath == nil) {
            NSLog(@"not tableView");
        }else{
            focusRow = [indexPath row];
            focusSection = [indexPath section];
            isLongPress = YES;
            [self createCancelButton];
            [_searchOfflineFilesView.searchTableView reloadData];
            _searchOfflineFilesView.isLongPress = isLongPress;
            [_searchOfflineFilesView layoutSubviews];
            SyOfflineFilesViewCell *cell = (SyOfflineFilesViewCell*)[_searchOfflineFilesView.searchTableView cellForRowAtIndexPath:indexPath];
            cell.isLongPress = isLongPress;
            [cell setSelectedCell:YES animated:YES];
            [_searchOfflineFilesView.searchTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)deleteButton:(id)sender
{
    [[SyFileProvider instance] deleteFilesWithOfflineFiles:_selectedFileList];
    [_selectedFileList removeAllObjects];
    isLongPress = NO;
    [self.bannerNavigationBar setRightBarButtonItems: nil];
    _searchOfflineFilesView.isLongPress = isLongPress;
    [_searchOfflineFilesView layoutSubviews];
    [self setupForRefresh];
    [self requestSearchOfflineFiles];
    [self setTitle:SY_STRING(@"common_search")];
    
}

#pragma mark- SyOfflineFilesViewCellDelegate

- (void)offlineFilesSelecte:(SyOfflineFilesViewCell*)aCell
{
    NSIndexPath *indexpath =  [_searchOfflineFilesView.searchTableView indexPathForCell:aCell];
    if (aCell.isSelecte) {
        if (indexpath.row < _searchList.count) {
            CMPOfflineFileRecord *file = [_searchList objectAtIndex:indexpath.row];
            if (![_selectedFileList containsObject:file]) {
                [_selectedFileList addObject:file];
            }
            
        }
    }else{
        if (indexpath.row < _searchList.count) {
            CMPOfflineFileRecord *file = [_searchList objectAtIndex:indexpath.row];
            if ([_selectedFileList containsObject:file]){
                [_selectedFileList removeObject:file];        }
            
        }
    }
    if (_selectedFileList.count >0) {
        _searchOfflineFilesView.deleteButton.enabled = YES;
    }else{
        _searchOfflineFilesView.deleteButton.enabled = NO;
    }
    if (isLongPress) {
        [self setTitle:[NSString stringWithFormat:SY_STRING(@"offlineFiles_haveBeenSelect_xx"),_selectedFileList.count]];
        
    }else{
        [self setTitle:SY_STRING(@"common_search")];
        
    }
}

- (void)showRecordView:(NSString *)path
{
    CMPRecordView *recordView = [[[CMPRecordView alloc] initWithDelegate:nil type:CMPRecordViewTypePlay] autorelease];
    [recordView show];
    [recordView playWithFilePath:path];
}

@end
