//
//  ShareViewController.m
//  CMPSharePublish
//
//  Created by MacBook on 2019/10/30.
//

#import "ShareViewController.h"

#if DEBUG
#define kShareGroupID @"group.com.seeyon.m3.inhousedis"
#endif

#if RELEASE
#define kShareGroupID @"group.com.seeyon.m3.inhousedis"
#endif

#if APPSTORE
#define kShareGroupID @"group.com.seeyon.m3.appstore.new.phone.CallDirectory"
#endif


@interface ShareViewController ()

@property (nonatomic,copy) NSString *appGroupId;
@end

@implementation ShareViewController

- (void)dealloc {
    NSLog(@"----------------------------------------------");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.hidden = YES;
    
#if CUSTOM
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"CusParams" ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(dic && !err)
    {
        _appGroupId = dic[@"appGroupId"];
    }
    NSLog(@"%s\n%@\n%@\n%@\n%@",__func__,aPath,jsonString,dic,_appGroupId);
#else
    _appGroupId = kShareGroupID;
#endif
    
    //获取分享链接
    [self handleShareData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)handleShareData {
    __weak typeof(self) weakSelf = self;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        [obj.attachments enumerateObjectsUsingBlock:^(NSItemProvider *  _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            //public.movie
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"])
            {
                [itemProvider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]])
                    {
                        [weakSelf saveDataWithUrl:(NSURL *)item];
                    }
                    
                    if ([(NSObject *)item isKindOfClass:[UIImage class]]) {
                        [weakSelf saveDataWithImage:(UIImage *)item];
                    }

                }];
            }
            
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.movie"])
            {
                [itemProvider loadItemForTypeIdentifier:@"public.movie" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]])
                    {
                        [weakSelf saveDataWithUrl:(NSURL *)item];
                    }

                }];
            }

        }];

    }];
    
    
}

- (void)saveDataWithUrl:(NSURL *)urlItem {
    __weak typeof(self) wSelf  = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:wSelf.appGroupId];
        NSURL *fileURL = [groupURL URLByAppendingPathComponent:[urlItem lastPathComponent]];
        NSData *data = [NSData dataWithContentsOfURL:urlItem];
        BOOL succ = [data writeToURL:fileURL atomically:YES];
        if (succ) {
            [self handleShareFilesWithFileUrl:fileURL.absoluteString];
        }
    });
}

- (void)saveDataWithImage:(UIImage *)imageItem {
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int y = (arc4random() % 10000000000);
        NSString *fileName = [[NSString stringWithFormat:@"%d",y] stringByAppendingString:@".jpg"];
        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:wSelf.appGroupId];
        NSURL *fileURL = [groupURL URLByAppendingPathComponent:fileName];
        NSData *data = UIImageJPEGRepresentation(imageItem, 1.f);
        BOOL succ = [data writeToURL:fileURL atomically:YES];
        if (succ) {
            [self handleShareFilesWithFileUrl:fileURL.absoluteString];
        }
    });
}

- (void)handleShareFilesWithFileUrl:(NSString *)fileUrl {
    dispatch_async(dispatch_get_main_queue(), ^{
        /* 记录文件解析个数 */
        static int count = 0;
        /* 多文件分享时的fileurl */
        static NSString *urlString = @"";
        urlString = [urlString stringByAppendingFormat:@"%@",fileUrl];
        
        count++;
        NSArray *arr = self.extensionContext.inputItems;
        NSExtensionItem *item = arr.firstObject;
        NSDictionary *userInfo = item.userInfo;
        NSArray *shareItems = userInfo[@"NSExtensionItemAttachmentsKey"];
        if (count == shareItems.count) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"seeyonM3Phone://CMPSharePublish/%@",urlString]];
            UIApplication *app = [UIApplication performSelector:@selector(sharedApplication)];
            [app performSelector:@selector(openURL:) withObject:url];
            
            count = 0;
            urlString = @"";
            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
            
        }
        
    });
    
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
