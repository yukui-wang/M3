//
//  RCFilePreviewViewController.m
//  RongIMKit
//
//  Created by Jue on 16/7/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCFilePreviewViewController.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import <WebKit/WebKit.h>
extern NSString *const RCKitDispatchDownloadMediaNotification;

@interface RCFilePreviewViewController ()

@property (nonatomic, strong) RCFileMessage *fileMessage;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIImageView *typeIconView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *openInOtherAppButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation RCFilePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RCDYCOLOR(0xf0f0f6, 0x000000);
    self.title = NSLocalizedStringFromTable(@"PreviewFile", @"RongCloudKit", nil);
    // self.view.frame是从navigationBar下面开始计算
    self.edgesForExtendedLayout = UIRectEdgeNone;

    //设置右键
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17.5, 17.5)];
    UIImage *rightImage = [RCKitUtility imageNamed:@"forwardIcon" ofBundle:@"RongCloud.bundle"];
    [rightBtn setImage:rightImage forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];

    //设置左键
    UIView *backBtn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 87, 23)];
    UIImageView *backImage = [[UIImageView alloc] initWithImage:IMAGE_BY_NAMED(@"navigator_btn_back")];
    backImage.frame = CGRectMake(-6, 3, 10, 17);
    [backBtn addSubview:backImage];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 85, 23)];
    backText.text = NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
    [backBtn addSubview:backText];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackBtn:)];
    [backBtn addGestureRecognizer:tap];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadMediaStatus:)
                                                 name:RCKitDispatchDownloadMediaNotification
                                               object:nil];

    if ([self isFileDownloaded] && [self isFileSupported]) {
        [self layoutAndPreviewFile];
    } else {
        [self layoutForShowFileInfo];
    }
    [self.view bringSubviewToFront:_cancelButton];
    [self registerNotificationCenter];
}

- (void)layoutForShowFileInfo {
    self.webView.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    self.typeIconView.hidden = NO;
    self.nameLabel.hidden = NO;
    self.sizeLabel.hidden = NO;
    self.cancelButton.hidden = YES;
    self.progressView.hidden = YES;
    self.progressLabel.hidden = YES;
    if ([self isFileDownloaded]) {
        self.downloadButton.hidden = YES;
        self.openInOtherAppButton.hidden = NO;
    } else {
        self.downloadButton.hidden = NO;
        self.openInOtherAppButton.hidden = YES;
    }
}

- (void)layoutForDownloading {
    self.webView.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    self.typeIconView.hidden = NO;
    self.nameLabel.hidden = NO;
    self.sizeLabel.hidden = YES;
    self.downloadButton.hidden = YES;
    self.openInOtherAppButton.hidden = YES;
    self.cancelButton.hidden = NO;
    self.progressView.hidden = NO;
    self.progressLabel.hidden = NO;
}

- (void)layoutAndPreviewFile {
    self.webView.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;

    self.typeIconView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.sizeLabel.hidden = YES;
    self.downloadButton.hidden = YES;
    self.openInOtherAppButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.progressView.hidden = YES;
    self.progressLabel.hidden = YES;

    if ([self.fileMessage.type isEqualToString:@"txt"]) {
        [self transformEncodingFromFilePath:self.fileMessage.localPath];
    }
    if (self.fileMessage.localPath) {
        NSURL *fileURL = [NSURL fileURLWithPath:self.fileMessage.localPath];
        //打开文件兼容 iOS 8
        if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
            return;
        }
        if ([self.fileMessage.type isEqualToString:@"txt"]) {
            NSData *data = [NSData dataWithContentsOfURL:fileURL];
            // 加载二进制文件
            [self.webView loadData:data
                             MIMEType:@"text/plain"
                characterEncodingName:@"UTF-8"
                              baseURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
        } else {
            [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        }
    }
}

- (WKWebView *)webView {
    if (!_webView) {
        //获取状态栏的rect
        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
        //获取导航栏的rect
        CGRect navRect = self.navigationController.navigationBar.frame;
        //那么导航栏+状态栏的高度
        CGFloat totalHeight = statusRect.size.height + navRect.size.height;
        CGRect webViewRect = self.view.bounds;
        if (webViewRect.size.height > ([UIScreen mainScreen].bounds.size.height - totalHeight)) {
            webViewRect.size.height -= totalHeight;
        }
        _webView = [[WKWebView alloc] initWithFrame:webViewRect];
        _webView.scrollView.contentInset = (UIEdgeInsets){8, 8, 8, 8};
        [_webView sizeToFit];
        _webView.backgroundColor =
            [UIColor colorWithRed:242.f / 255.f green:242.f / 255.f blue:243.f / 255.f alpha:1.f];
        [_webView setOpaque:NO];
        [self.view addSubview:_webView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidBecomeKeyNotification)
                                                     name:UIWindowDidBecomeKeyNotification
                                                   object:nil];
    }
    return _webView;
}

- (UIImageView *)typeIconView {
    if (!_typeIconView) {
        _typeIconView =
            [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 75) / 2, 30, 75, 75)];
        NSString *fileTypeIcon = [RCKitUtility getFileTypeIcon:self.fileMessage.type];
        _typeIconView.image = [RCKitUtility imageNamed:fileTypeIcon ofBundle:@"RongCloud.bundle"];

        [self.view addSubview:_typeIconView];
    }

    return _typeIconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 122, self.view.bounds.size.width - 10 * 2, 21)];
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
        _nameLabel.text = self.fileMessage.name;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = RCDYCOLOR(0x343434, 0x9f9f9f);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.view addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 151, self.view.bounds.size.width, 12)];
        _sizeLabel.font = [UIFont systemFontOfSize:13.0f];
        _sizeLabel.text = [RCKitUtility getReadableStringForFileSize:self.fileMessage.size];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        _sizeLabel.textColor = RCDYCOLOR(0xa8a8a8, 0x666666);
        [self.view addSubview:_sizeLabel];
    }
    return _sizeLabel;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 151, self.view.bounds.size.width - 10 * 2, 21)];
        _progressLabel.textColor = HEXCOLOR(0xa8a8a8);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.view addSubview:_progressLabel];
    }
    return _progressLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView =
            [[UIProgressView alloc] initWithFrame:CGRectMake(10, 184, self.view.bounds.size.width - 10 * 3, 8)];
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 4.0f);
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.progressTintColor = HEXCOLOR(0x0099ff);
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 10 - 24, 173, 24, 24)];
        [_cancelButton setImage:[RCKitUtility imageNamed:@"cancelButton" ofBundle:@"RongCloud.bundle"]
                       forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                          action:@selector(cancelFileDownload)
                forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelButton];
    }
    return _cancelButton;
}

- (UIButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton =
            [[UIButton alloc] initWithFrame:CGRectMake(10, 197, self.view.bounds.size.width - 10 * 2, 40)];
        _downloadButton.backgroundColor = HEXCOLOR(0x0099ff);
        _downloadButton.layer.cornerRadius = 5.0f;
        _downloadButton.layer.borderWidth = 0.5f;
        _downloadButton.layer.borderColor = [HEXCOLOR(0x0181dd) CGColor];
        [_downloadButton setTitle:NSLocalizedStringFromTable(@"StartDownloadFile", @"RongCloudKit", nil)
                         forState:UIControlStateNormal];
        [_downloadButton addTarget:self
                            action:@selector(startFileDownLoad)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_downloadButton];
    }
    return _downloadButton;
}

- (UIButton *)openInOtherAppButton {
    if (!_openInOtherAppButton) {
        _openInOtherAppButton =
            [[UIButton alloc] initWithFrame:CGRectMake(10, 197, self.view.bounds.size.width - 10 * 2, 40)];
        _openInOtherAppButton.backgroundColor = HEXCOLOR(0x0099ff);
        _openInOtherAppButton.layer.cornerRadius = 5.0f;
        _openInOtherAppButton.layer.borderWidth = 0.5f;
        _openInOtherAppButton.layer.borderColor = [HEXCOLOR(0x0181dd) CGColor];
        [_openInOtherAppButton setTitle:NSLocalizedStringFromTable(@"OpenFileInOtherApp", @"RongCloudKit", nil)
                               forState:UIControlStateNormal];
        [_openInOtherAppButton addTarget:self
                                  action:@selector(openCurrentFileInOtherApp)
                        forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:_openInOtherAppButton];
    }
    return _openInOtherAppButton;
}

- (void)moreAction {
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
                                 style:UIAlertActionStyleCancel
                               handler:nil];
    UIAlertAction *openAction =
        [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OpenFileInOtherApp", @"RongCloudKit", nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   [self openInOtherApp:self.fileMessage.localPath];
                               }];
    [RCKitUtility showAlertController:nil
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, openAction ]
                     inViewController:self];
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openInOtherApp:(NSString *)localPath {
    if(!localPath){
        NSLog(@"localPath 不允许是 nil");
        return;
    }
    UIActivityViewController *activityVC =
        [[UIActivityViewController alloc] initWithActivityItems:@[ [NSURL fileURLWithPath:localPath] ]
                                          applicationActivities:nil];
    activityVC.modalPresentationStyle = UIModalPresentationFullScreen;
    if ([RCKitUtility currentDeviceIsIPad]) {
        UIPopoverPresentationController *popPresenter = [activityVC popoverPresentationController];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        popPresenter.sourceView = window;
        popPresenter.sourceRect = CGRectMake(window.frame.size.width / 2, window.frame.size.height / 2, 0, 0);
        popPresenter.permittedArrowDirections = 0;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)openCurrentFileInOtherApp {
    [self openInOtherApp:self.fileMessage.localPath];
}

- (void)startFileDownLoad {
    [self downloading:0];
    [[RCIM sharedRCIM] downloadMediaMessage:self.messageModel.messageId
        progress:^(int progress) {

        }
        success:^(NSString *mediaPath) {

        }
        error:^(RCErrorCode errorCode) {

        }
        cancel:^{

        }];
}

- (void)cancelFileDownload {
    [[RCIM sharedRCIM] cancelDownloadMediaMessage:self.messageModel.messageId];
    _progressView.progress = 0;
}

- (void)updateDownloadMediaStatus:(NSNotification *)notify {
    NSDictionary *statusDic = notify.userInfo;
    if (self.messageModel.messageId == [statusDic[@"messageId"] longValue]) {
        if ([statusDic[@"type"] isEqualToString:@"progress"]) {
            float progress = (float)[statusDic[@"progress"] intValue] / 100.0f;
            [self downloading:progress];
        } else if ([statusDic[@"type"] isEqualToString:@"success"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.fileMessage.localPath = statusDic[@"mediaPath"];
                if ([self isFileSupported]) {
                    [self layoutAndPreviewFile];
                } else {
                    [self layoutForShowFileInfo];
                }
            });
        } else if ([statusDic[@"type"] isEqualToString:@"error"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self layoutForShowFileInfo];
                if ([statusDic[@"errorCode"] intValue] == RC_NETWORK_UNAVAILABLE) {
                    [self showAlertController:NSLocalizedStringFromTable(@"ConnectionIsNotReachable", @"RongCloudKit",
                                                                         nil)];
                } else {
                    [self showAlertController:NSLocalizedStringFromTable(@"FileDownloadFailed", @"RongCloudKit", nil)];
                }
            });
        } else if ([statusDic[@"type"] isEqualToString:@"cancel"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self layoutForShowFileInfo];
                [self showAlertController:NSLocalizedStringFromTable(@"FileDownloadCanceled", @"RongCloudKit", nil)];
            });
        }
    }
}

- (void)showAlertController:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action){
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (RCFileMessage *)fileMessage {
    if (!_fileMessage) {
        if ([self.messageModel.content isKindOfClass:[RCReferenceMessage class]]) {
            RCReferenceMessage *refer = (RCReferenceMessage *)self.messageModel.content;
            return (RCFileMessage *)refer.referMsg;
        }
        return (RCFileMessage *)self.messageModel.content;
    }
    return _fileMessage;
}

- (void)downloading:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutForDownloading];
        [self.progressView setProgress:progress animated:YES];
        self.progressLabel.text = [NSString
            stringWithFormat:@"%@(%@/%@)", NSLocalizedStringFromTable(@"FileIsDownloading", @"RongCloudKit", nil),
                             [RCKitUtility getReadableStringForFileSize:progress * self.fileMessage.size],
                             [RCKitUtility getReadableStringForFileSize:self.fileMessage.size]];
    });
}

- (BOOL)isFileDownloading {
    // todo
    return NO;
}

- (BOOL)isFileDownloaded {
    if (self.fileMessage.localPath.length > 0 && [RCFileUtility isFileExist:self.fileMessage.localPath]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isFileSupported {
    if (![[RCKitUtility getFileTypeIcon:self.fileMessage.type] isEqualToString:@"OtherFile"]) {
        return YES;
    } else {
        return NO;
    }
}
#pragma txtg格式乱码问题解决方法

- (NSString *)examineTheFilePathStr:(NSString *)str {
    NSStringEncoding *useEncodeing = nil; //带编码头的如utf-8等，这里会识别出来
    NSString *body = [NSString
        stringWithContentsOfFile:str
                    usedEncoding:useEncodeing
                           error:
                               nil]; //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug
    if (!body) {
        body = [NSString stringWithContentsOfFile:str encoding:0x80000632 error:nil];

    } //还是识别不到，按GB18030编码再解码一次.
    if (!body) {
        body = [NSString stringWithContentsOfFile:str encoding:0x80000631 error:nil];
    } //有值代表需要转换  为空表示不需要转换
    return body;
}

- (void)transformEncodingFromFilePath:(NSString *)filePath {       //调用上述转码方法获取正常字符串
    NSString *body = [self examineTheFilePathStr:filePath];        //转换为二进制
    NSData *data = [body dataUsingEncoding:NSUTF16StringEncoding]; //覆盖原来的文件
    [data writeToFile:filePath atomically:YES];                    //此时在读取该文件，就是正常格式啦
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidBecomeKeyNotification {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - Notification
- (void)registerNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRecallMessageNotification:)
                                                 name:RCKitDispatchRecallMessageNotification
                                               object:nil];
}

- (void)didReceiveRecallMessageNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        long recalledMsgId = [notification.object longValue];
        //产品需求：当前正在查看的图片被撤回，dismiss 预览页面，否则不做处理
        if (recalledMsgId == self.messageModel.messageId) {
            UIAlertController *alertController = [UIAlertController
                alertControllerWithTitle:nil
                                 message:NSLocalizedStringFromTable(@"MessageRecallAlert", @"RongCloudKit", nil)
                          preferredStyle:UIAlertControllerStyleAlert];
            [alertController
                addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Confirm", @"RongCloudKit", nil)
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                     [self.navigationController popViewControllerAnimated:YES];
                                                 }]];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
    });
}

@end
