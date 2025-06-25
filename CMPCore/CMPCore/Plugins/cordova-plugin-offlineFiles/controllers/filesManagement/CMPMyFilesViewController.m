//
//  CMPMyFilesViewController.m
//  M3
//
//  Created by MacBook on 2019/10/11.
//

#import "CMPMyFilesViewController.h"
#import "CMPSegmentControl.h"
#import "CMPMyFilesBottomView.h"
#import "CMPFileManagementManager.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPCachedResManager.h>
#import <CMPLib/FCFileManager.h>
#import <UniformTypeIdentifiers/UTType.h>

static CGFloat const kTimeInterval = 0.3f;

@interface CMPMyFilesViewController ()<UIDocumentPickerDelegate>

/* segmentControl */
@property (strong, nonatomic) CMPSegmentedControl *segmentedControl;
/* 底部view */
@property (strong, nonatomic) CMPMyFilesBottomView *bottomView;
/* bottomView是否在显示中 */
@property (assign, nonatomic,getter=isBottomViewShowing) BOOL bottomViewShowing;

@property (nonatomic, assign) CGFloat kBottomViewH;

@end

@implementation CMPMyFilesViewController

#pragma mark - lazy loading
- (CMPSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        NSArray *titles = @[SY_STRING(@"offlineFiles_myfile")];
        if (@available(iOS 11.0,*)) {
            titles = @[SY_STRING(@"offlineFiles_myfile"),SY_STRING(@"file_management_localfile")];
        }
        _segmentedControl = [[CMPSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 170.f, 30.f) titles:titles];
        _segmentedControl.center = CGPointMake(self.bannerNavigationBar.width/2.f, self.bannerNavigationBar.height/2.f);
        [_segmentedControl addValueChangedEventWithTarget:self action:@selector(segmentedClicked:)];
    }
    return _segmentedControl;
}

- (CMPMyFilesBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [CMPMyFilesBottomView bottomViewWithFrame:CGRectMake(0, self.view.height, self.webView.width, _kBottomViewH)];
        __weak typeof(self) weakSelf = self;
        _bottomView.myFilesBottomViewSendClicked = ^{
            [weakSelf hideBottomView];
            if ([weakSelf.delegate respondsToSelector:@selector(myFilesVCSendClicked:)]) {
                [weakSelf.delegate myFilesVCSendClicked:weakSelf.fileManager.getCurrentSelectedFiles];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        _bottomView.myFilesBottomViewCancelClicked = ^{
            [weakSelf hideBottomView];
            [weakSelf addH5Listener];
            [weakSelf disableBtnAtIndex:1 disable:NO];
            if ([weakSelf.delegate respondsToSelector:@selector(myFilesVCCancelClicked)]) {
                [weakSelf.delegate myFilesVCCancelClicked];
            }
        };
    }
    return _bottomView;
}

#pragma mark - 初始化方法

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)init {
    if (self = [super init]) {
        [self setHideBannerNavBar:NO];
        _kBottomViewH = (IS_IPHONE_X_LATER)?60.f:50.f;
        NSString *urlString = [CMPAppManager appIndexPageWithAppId:@"93" version:@"3.1.0" serverId:kCMP_ServerID];
        if (urlString) {
            self.startPage = urlString;
        }
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bannerNavigationBar.bannerTitleView.hidden = YES;
    [self.bannerNavigationBar addSubview:self.segmentedControl];
    [self.view addSubview:self.bottomView];
}


/// view布局
- (void)layoutSubviewsWithFrame:(CGRect)frame {
    if (CMP_IPAD_MODE) {
        self.bottomView.cmp_width = frame.size.width;
        self.bottomView.cmp_y = CMP_SCREEN_HEIGHT;
        if (self.isBottomViewShowing) {
            self.bottomView.cmp_y -= _kBottomViewH - self.bannerNavigationBar.height - 20.f;
            [self showBottomView];
        }
        
        self.segmentedControl.cmp_centerX = frame.size.width/2.f;
    }
    [super layoutSubviewsWithFrame:frame];
}

///取消按钮点击后，通知给H5
- (void)addH5Listener {
    NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('filemanageCancelAll', document, {message:'%@'})",@(YES)];
    [self.commandDelegate evalJs:js];
}

#pragma mark - 显示、隐藏底部view
- (void)showBottomView {
    self.bottomViewShowing = YES;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kTimeInterval animations:^{
        weakSelf.bottomView.cmp_y = weakSelf.view.height - weakSelf.bottomView.height;
        weakSelf.webView.cmp_height -= weakSelf.bottomView.height;
    }];
}

- (void)hideBottomView {
    self.bottomViewShowing = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kTimeInterval animations:^{
        weakSelf.bottomView.cmp_y = weakSelf.view.height;
        weakSelf.webView.cmp_height += weakSelf.bottomView.height;
    }];
}

#pragma mark - 点击方法

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
            [documentTypes addObjectsFromArray:@[@"public.content",
                                                 @"public.text",
                                                 @"public.source-code",
                                                 @"public.image",
                                                 @"public.audiovisual-content",
                                                 @"com.adobe.pdf",
                                                 @"com.apple.keynote.key",
                                                 @"com.microsoft.word.doc",
                                                 @"com.microsoft.excel.xls",
                                                 @"com.microsoft.powerpoint.ppt",
                                                 @"public.item",
                                                 @"public.composite-content",
                                                 @"public.archive",
                                                 @"public.data",
                                                 @"public.plain-text",
                                                 @"public.executable",
                                                 @"public.script",
                                                 @"public.shell-script",
                                                 @"public.xml",
                                                 @"public.script",
                                                 @"org.gnu.gnu-tar-archive",
                                                 @"org.gnu.gnu-zip-archve",
                                                 @"public.audiovisual-​content",
                                                 @"public.movie",
                                                 @"public.mpeg4"]];
        }
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
//        if (@available(iOS 14.0, *)) {
//            UTType *pdfType = [UTType typeWithFilenameExtension:@"ofd"];
//            documentPicker = [[UIDocumentPickerViewController alloc]initForOpeningContentTypes:@[pdfType]];
//        } else {
//            documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
//        }
        documentPicker.delegate = self;
        if (@available(iOS 11.0, *)) {
            documentPicker.allowsMultipleSelection = YES;
        }
        [self.navigationController presentViewController:documentPicker animated:YES completion:nil];
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    DDLogInfo(@"%s",__func__);
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    DDLogInfo(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(myFilesVCDocumentPicker:didPickDocumentsAtURLs:)]) {
//        static NSInteger i = 0;
        NSMutableArray *fileArray = [NSMutableArray array];
        for (NSURL *url in urls) {
            BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
            if(fileUrlAuthozied){
                NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
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
                    if (newPath && newPath.length >0){//容错处理，有的文件没有权限操作，会返回nil
                        [fileArray addObject:newPath];
                    }
//                    i++;
                }];
                [url stopAccessingSecurityScopedResource];
            }
        }
        [self.delegate myFilesVCDocumentPicker:controller didPickDocumentsAtURLs:fileArray];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 外部方法

/// 设置选中个数
/// @param count 选中的个数
- (void)setSelectedCount:(NSInteger)count {
    if (_bottomView) {
        [_bottomView setNumOfSelectedFielsWithNum:count];
    }
}

/// 设置是否隐藏segmentedView
/// @param isHidden 是否隐藏
- (void)setHideSegmentedView:(BOOL)isHidden {
    _segmentedControl.hidden = isHidden;
}

#pragma mark 屏蔽segmentedControl的某个按钮点击
- (void)disableBtnAtIndex:(int)index disable:(BOOL)disable {
    [_segmentedControl disableBtnWithIndex:index disable:disable];
}

@end
