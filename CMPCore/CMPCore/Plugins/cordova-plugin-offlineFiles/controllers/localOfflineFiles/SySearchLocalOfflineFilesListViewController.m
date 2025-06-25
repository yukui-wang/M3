//
//  SySearchLocalOfflineFilesListViewController.m
//  M1Core
//
//  Created by chenquanwei on 14-3-16.
//
//
#define kC_sSearchMethod_Time 2
#define kC_sSearchMethod_Subject 3
#define kC_iPageType_Refresh 1
#define kC_iPageType_LoadMore 2

#import "SySearchLocalOfflineFilesListViewController.h"
#import "SyLocalOfflineFilesListViewCell.h"
#import "SyFileProvider.h"
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPQuickLookPreviewController.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPRecordView.h>
#import <CMPLib/MJRefresh.h>

@interface SySearchLocalOfflineFilesListViewController ()<UITableViewDelegate, UITableViewDataSource>
// 为列表刷新配置变量
- (void)setupForRefresh;
// 为加载更多数据配置变量
- (void)setupForLoadMore;
//搜索
- (void)searchOfflineFiles;
- (void)requestSearchOfflineFiles;
@end

@implementation SySearchLocalOfflineFilesListViewController

@synthesize spaceType = _spaceType;
@synthesize typeID = _typeID;

- (void)dealloc
{
    SY_RELEASE_SAFELY(_searchList);
    SY_RELEASE_SAFELY(_titles);
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
    [self.bannerNavigationBar setLeftBarButtonItems:[NSArray arrayWithObjects:returnButon, nil]];
    _titles = [[NSArray alloc]initWithObjects:SY_STRING(@"common_search_subject"), nil];
    [self setTitle:SY_STRING(@"common_search")];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowRotation = NO;
    _canRequest= NO;
    _searchOfflineFilesView = (SySearchLocalOfflineFilesListView *)self.mainView;
    [_searchOfflineFilesView.searchItem.searchButton addTarget:self
                                                        action:@selector(searchOfflineFiles)
                                              forControlEvents:UIControlEventTouchUpInside];
    _searchOfflineFilesView.searchItem.searchButton.enabled = NO;
    _searchOfflineFilesView.searchItem.keyTextField.delegate = self;
    _searchOfflineFilesView.searchTableView.delegate = self;
    _searchOfflineFilesView.searchTableView.dataSource = self;
    if (!_searchList) {
        _searchList = [[NSMutableArray alloc] init];
    }
    _searchMethod = kC_sSearchMethod_Subject;
    
    
    __weak SySearchLocalOfflineFilesListViewController* weakSelf = self;

    _searchOfflineFilesView.searchTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf tableViewHeaderReresh];
    }];
    _searchOfflineFilesView.searchTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf tableviewFooterRefresh];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    [self setupForRefresh];
    //    [self requestSearchNews];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchOfflineFilesView.searchItem.keyTextField becomeFirstResponder];
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
    [_searchOfflineFilesView.searchItem.keyTextField resignFirstResponder];
    [self setupForRefresh];
    [self requestSearchOfflineFiles];
    
}

//返回
- (void)backBarButtonAction:(id)sender
{
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

- (BOOL)isInPopoverController
{
    return YES;
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
    SyLocalOfflineFilesListViewCell *cell = (SyLocalOfflineFilesListViewCell *)[tableView dequeueReusableCellWithIdentifier:collaborationListCellIdentifier];
    if (!cell) {
        cell = [[[SyLocalOfflineFilesListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collaborationListCellIdentifier] autorelease];
        cell.delegate = self;
    }
    if (indexPath.row < _searchList.count) {
        CMPOfflineFileRecord *downloadFile = [_searchList objectAtIndex:indexPath.row];
        cell.downloadFile = downloadFile;
        [cell setOfflineFilesListItem:downloadFile];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMPOfflineFileRecord *file = [_searchList objectAtIndex:indexPath.row] ;
    if ([file.fileSize longLongValue] > kUploadAttachmentMaxSize) {
        [self showToastWithText:SY_STRING(@"common_uploadAttachmentLimit")];
        return;
    }
    if (self.maxFileSize>0 && self.maxFileSize < [file.fileSize integerValue]) {
        NSInteger f = self.maxFileSize/1024/1024;
        NSString *title =[NSString stringWithFormat:SY_STRING(@"atta_limitsize"),f] ;
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:SY_STRING(@"common_isee") otherButtonTitles:nil, nil];
        [alertView show];
        SY_RELEASE_SAFELY(alertView);
        
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:file];
    if ([_delegate respondsToSelector:@selector(localOfflineFilesListViewController:didFinishedSelected:)]) {
        [_delegate localOfflineFilesListViewController:self didFinishedSelected:array];
    }
    
    //返回界面 直接返回离线文件上一界面，在横屏显示搜索界面，在竖屏，选中后会crash，所以使用代理
    [self.navigationController popViewControllerAnimated:NO];
    if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(searchLocalOfflineFilesListViewControllerDidSelectValue)]) {
        [self.searchDelegate searchLocalOfflineFilesListViewControllerDidSelectValue];
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
    
    [_searchOfflineFilesView showSearchTableView];
    [_searchOfflineFilesView.searchTableView reloadDataWithTotalCount:_totalCount currentCount:_searchList.count];
}

- (NSString *)keyWithAttachment:(CMPOfflineFileRecord *)file
{
    NSString *aKey = [NSString stringWithFormat:@"_%@", file.fileId];
    return aKey;
}

#pragma mark- SyLocalOfflineFilesListViewCellDelegate

- (void)attachmentButtonAction:(CMPOfflineFileRecord *)file
{
    CMPOfflineFileRecord *downloadFile = file;
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
    param.canDownload = NO; 
    controller.attReaderParam = param;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    controller = nil;
}

- (void)showRecordView:(NSString *)path
{
    CMPRecordView *recordView = [[[CMPRecordView alloc] initWithDelegate:nil type:CMPRecordViewTypePlay] autorelease];
    [recordView show];
    [recordView playWithFilePath:path];
}
@end
