//
//  CMPOcrMyFilesViewController.m
//  M3
//
//  Created by 张艳 on 2021/12/20.
//

#import "CMPOcrMyFilesViewController.h"
#import "CMPSegmentControl.h"
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPCachedUrlParser.h>

@interface CMPOcrMyFilesViewController ()<UIDocumentPickerDelegate>
/* segmentControl */
@property (strong, nonatomic) CMPSegmentedControl *segmentedControl;

@end

@implementation CMPOcrMyFilesViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    NSString *href = @"http://my.m3.cmp/v1.0.0/layout/privacy/my-collection.html";
    href = [href urlCFEncoded];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    if ([NSString isNotNull:localHref]) {
        href = localHref;
    }
    self.startPage = href;
    [super viewDidLoad];
}
#pragma mark - 初始化方法

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)init {
    if (self = [super init]) {
        [self setHideBannerNavBar:NO];
    }
    return self;
}

#pragma mark - lazy loading
- (CMPSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        NSArray *titles =@[SY_STRING(@"我的收藏"),SY_STRING(@"file_management_localfile")];
        
        _segmentedControl = [[CMPSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 170.f, 30.f) titles:titles];
        _segmentedControl.center = CGPointMake(self.bannerNavigationBar.width/2.f, self.bannerNavigationBar.height/2.f);
        [_segmentedControl addValueChangedEventWithTarget:self action:@selector(segmentedClicked:)];
    }
    return _segmentedControl;
}


#pragma mark - 点击方法

- (void)segmentedClicked:(UIButton *)btn {
    if (btn.tag == 1) {
        [_segmentedControl selectIndex:0];
        NSArray *documentTypes = @[@"public.image", @"com.adobe.pdf"];
//        NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt", @"public.item", @"public.composite-content", @"public.archive", @"public.data", @"public.plain-text", @"public.executable", @"public.script", @"public.shell-script", @"public.xml", @"public.script", @"org.gnu.gnu-tar-archive", @"org.gnu.gnu-zip-archve", @"public.audiovisual-​content", @"public.movie", @"public.mpeg4"];
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
        documentPicker.delegate = self;
        if (@available(iOS 11.0, *)) {
            documentPicker.allowsMultipleSelection = YES;
        }
        [self presentViewController:documentPicker animated:YES completion:nil];
    }
}


@end
