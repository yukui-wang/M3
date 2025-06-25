//
//  SyLocalOfflineFilesListViewController.m
//  M1Core
//
//  Created by chenquanwei on 14-3-14.
//
//

#import "SyLocalOfflineFilesListViewController.h"
#import "SyFileProvider.h"
#import "SyFilePage.h"
#import "SySearchLocalOfflineFilesListViewController.h"
#import <CMPLib/CMPFileTypeHandler.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPQuickLookPreviewController.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPRecordView.h>
#import <CMPLib/MJRefresh.h>
#import "CMPSegmentControl.h"
#import <CMPLib/FCFileManager.h>
#import "CMPFileManagementManager.h"

#define kC_iPageType_Refresh 1
#define kC_iPageType_LoadMore 2

@interface SyLocalOfflineFilesListViewController ()<SySearchLocalOfflineFilesListViewControllerDelegate,UIDocumentPickerDelegate>
{
    NSInteger focusRow;
    NSInteger focusSection;
    BOOL       isLongPress;
    UIButton    *searchButton;
    NSMutableArray *_listArray;
    NSInteger               _pageIndex; // 页索引
    NSInteger               _startIndex; // 获取条数的起始索引，默认为0
    NSInteger               _pageType; // 列表获取方式
    NSInteger               _totalCount; // 总数
}
@property (strong, nonatomic) CMPSegmentedControl *segmentedControl;

@end

@implementation SyLocalOfflineFilesListViewController
@synthesize delegate = _delegate;

- (void)dealloc
{
    
    SY_RELEASE_SAFELY(_listArray);
    SY_RELEASE_SAFELY(_segmentedControl);
    [super dealloc];
}


- (void)setInitValue:(NSDictionary *)initValue
{

}

- (void)backBarButtonAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(localOfflineFilesListViewControllerDidCancel:)]) {
        [_delegate localOfflineFilesListViewControllerDidCancel:self];
    }
    [super backBarButtonAction:sender];
}

- (void)createSearchButton
{
    self.bannerNavigationBar.leftViewsMargin = 0.0f;
    self.bannerNavigationBar.rightViewsMargin = 10.0f;
    self.bannerNavigationBar.leftMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 0.0f;
    searchButton =  [self bannerSearchButton];
    [searchButton addTarget:self action:@selector(pushSearchView) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems: [NSArray arrayWithObjects:searchButton, nil]];
}

- (void)pushSearchView
{
    SySearchLocalOfflineFilesListViewController *searchOfflineFilesViewController = [[SySearchLocalOfflineFilesListViewController alloc] init];
    searchOfflineFilesViewController.delegate = _delegate;
    searchOfflineFilesViewController.searchDelegate = self;
    searchOfflineFilesViewController.maxFileSize = self.maxFileSize;
    [self.navigationController pushViewController:searchOfflineFilesViewController animated:YES];
    SY_RELEASE_SAFELY(searchOfflineFilesViewController);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowRotation = NO;
   
    if (@available(iOS 11.0,*)) {
        [self.bannerNavigationBar addSubview:self.segmentedControl];
    }
    else  {
        [self setTitle:self.bannerViewTitle];
    }

    [self createSearchButton];
    _localOfflineFilesListView = (SyLocalOfflineFilesListView *)self.mainView;
    _localOfflineFilesListView.offlineFilesTableView.dataSource = self;
    _localOfflineFilesListView.offlineFilesTableView.delegate = self;
    self.backBarButtonItemHidden = NO;
    if (!_listArray) {
        _listArray = [[NSMutableArray alloc] init];
    }
    __weak SyLocalOfflineFilesListViewController* weakSelf = self;
    _localOfflineFilesListView.offlineFilesTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf tableViewHeaderReresh];
    }];
    
    _localOfflineFilesListView.offlineFilesTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf tableviewFooterRefresh];
   
    }];
    _localOfflineFilesListView.offlineFilesTableView.mj_header.automaticallyChangeAlpha = YES;
    _localOfflineFilesListView.offlineFilesTableView.mj_footer.automaticallyHidden = YES;
    [self request];
}


- (void)request
{
    if (_pageType == kC_iPageType_Refresh) {
        [_listArray removeAllObjects];
        
    }
    SyFilePage  * aFilePage = [[SyFileProvider instance] findOfflineFilesWithStartIndex:_startIndex rowCount:20];
    _totalCount = aFilePage.totalCount;
    [_listArray addObjectsFromArray:aFilePage.fileList];
    
    
    [_localOfflineFilesListView.offlineFilesTableView reloadDataWithTotalCount:_totalCount currentCount:_listArray.count];
    
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
    [_localOfflineFilesListView.offlineFilesTableView.mj_header endRefreshing];
}

- (void)tableviewFooterRefresh
{
    [self setupForLoadMore];
    [self request];

}

- (BOOL)isInPopoverController
{
    return YES;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"offlineFilesViewCellIdentifier";
    SyLocalOfflineFilesListViewCell *cell = (SyLocalOfflineFilesListViewCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[[SyLocalOfflineFilesListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier] autorelease];
        cell.delegate = self;
    }
    if (indexPath.row < _listArray.count) {
        CMPOfflineFileRecord *downloadFile = [_listArray objectAtIndex:indexPath.row];
        cell.downloadFile = downloadFile;
        [cell setOfflineFilesListItem:downloadFile];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMPOfflineFileRecord *file = [_listArray objectAtIndex:indexPath.row] ;
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
    [self backBarButtonAction:nil];
}


- (void)closeSearchOfflineFilesView:(id)sender
{
}


- (NSString *)keyWithAttachment:(CMPOfflineFileRecord *)file
{
    NSString *aKey = [NSString stringWithFormat:@"_%@", file.fileId];
    return aKey;
}

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
    AttachmentReaderParam *aParam = [[[AttachmentReaderParam alloc] init] autorelease];
    aParam.filePath = aPath;
    aParam.canDownload = NO;
    controller.attReaderParam = aParam;
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

- (void)searchLocalOfflineFilesListViewControllerDidSelectValue {
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:NO];
    if (!viewController) {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (NSString *)bannerViewTitle {
    if (self.isFromChatViewController) {
        return SY_STRING(@"offlineFiles_myfile");
    }
    else{
        return SY_STRING(@"offlineFiles_offlineFiles");
    }
}

- (CMPSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        NSArray *titles = @[[self bannerViewTitle],SY_STRING(@"file_management_localfile")];
        _segmentedControl = [[CMPSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 170.f, 30.f) titles:titles];
        _segmentedControl.center = CGPointMake(self.bannerNavigationBar.width/2.f, self.bannerNavigationBar.height/2.f);
        [_segmentedControl addValueChangedEventWithTarget:self action:@selector(segmentedClicked:)];
    }
    return _segmentedControl;
}
- (void)layoutSubviewsWithFrame:(CGRect)frame
{
    [super layoutSubviewsWithFrame:frame];
    if (_segmentedControl) {
        _segmentedControl.center = CGPointMake(self.bannerNavigationBar.width/2.f, self.bannerNavigationBar.height/2.f);
    }
}


- (void)segmentedClicked:(UIButton *)btn {
    if (btn.tag == 1) {
        [_segmentedControl selectIndex:0];
        NSMutableArray *documentTypes = [NSMutableArray new];
        if (_acceptFormatArray.count) {
            NSMutableSet *mSet = [NSMutableSet new];
            for (NSString *type in _acceptFormatArray) {
                [mSet addObjectsFromArray:[CMPFileManagementManager getAcceptFileByType:type]];
            }
            [documentTypes addObjectsFromArray:[mSet allObjects]];
        }else{

            [documentTypes addObjectsFromArray:@[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt", @"public.item", @"public.composite-content", @"public.archive", @"public.data", @"public.plain-text", @"public.executable", @"public.script", @"public.shell-script", @"public.xml", @"public.script", @"org.gnu.gnu-tar-archive", @"org.gnu.gnu-zip-archve", @"public.audiovisual-​content", @"public.movie", @"public.mpeg4"]];
        }
        UIDocumentPickerViewController *documentPicker = [[[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen] autorelease];
        documentPicker.delegate = self;
        if (@available(iOS 11.0, *)) {
            documentPicker.allowsMultipleSelection = YES;
        }
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    DDLogInfo(@"%s",__func__);
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    DDLogInfo(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(localOfflineFilesListViewController:didPickDocumentsAtURLs:)]) {
//        static NSInteger i = 0;
        NSMutableArray *fileArray = [NSMutableArray array];
        for (NSURL *url in urls) {
            BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
            if(fileUrlAuthozied){
                NSFileCoordinator *fileCoordinator = [[[NSFileCoordinator alloc] init] autorelease];
                NSError *error;
                [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
                    NSString *filePath = newURL.absoluteString;
                    filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    NSString *tmpPath = filePath.stringByRemovingPercentEncoding;
                    if (tmpPath) {
                        filePath = tmpPath;
                    }
                    //拷贝到我们APP。才能进行发送操作
                    NSString *newPath = [FCFileManager copyFileToTempWithPath:filePath];
                   /* NSNumber *index = [NSNumber numberWithInteger:i];
                    Class cls = NSClassFromString(@"RCFileMessage");
                    id message = [cls performSelector:@selector(messageWithFile:) withObject:newPath];
                    
                    id size = [message valueForKeyPath:@"size"];
                    id type = [message valueForKeyPath:@"type"];
                    NSDictionary *aItem = [NSDictionary dictionaryWithObjectsAndKeys:newPath, @"filepath", size, @"fileSize",  type, @"type",index,@"index", nil];*/
                    [fileArray addObject:newPath];
//                    i++;
                }];
                [url stopAccessingSecurityScopedResource];
            }
        }
        [self.delegate localOfflineFilesListViewController:self didPickDocumentsAtURLs:fileArray];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [self backBarButtonAction:nil];
}
- (void)setHideSegmentedView:(BOOL)isHidden {
    _segmentedControl.hidden = isHidden;
}
@end
