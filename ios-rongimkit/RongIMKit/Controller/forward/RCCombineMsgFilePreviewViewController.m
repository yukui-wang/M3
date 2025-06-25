//
//  RCCombineMsgFilePreviewViewController.m
//  RongIMKit
//
//  Created by Jue on 16/7/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCCombineMsgFilePreviewViewController.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import <WebKit/WebKit.h>
@interface RCCombineMsgFilePreviewViewController ()

@property (nonatomic, copy) NSString *remoteURL;
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, assign) long long fileSize;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIImageView *typeIconView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *openInOtherAppButton;

@property (nonatomic, assign) int extentLayoutForY;

@end

@implementation RCCombineMsgFilePreviewViewController

- (instancetype)initWithRemoteURL:(NSString *)remoteURL
                 conversationType:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                         fileSize:(long long)fileSize
                         fileName:(NSString *)fileName
                         fileType:(NSString *)fileType {
    if (self = [super init]) {
        self.remoteURL = remoteURL;
        self.conversationType = conversationType;
        self.targetId = targetId;
        self.fileSize = fileSize;
        self.fileName = fileName;
        self.fileType = fileType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0xffffff)
                                                         darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = NSLocalizedStringFromTable(@"PreviewFile", @"RongCloudKit", nil);

    //根据导航栏透明度来设置布局
    if (self.navigationController.navigationBar.translucent) {
        self.extentLayoutForY = 64;
    } else {
        self.extentLayoutForY = 0;
    }
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

    if ([self isFileDownloaded] && [self isFileSupported]) {
        [self layoutAndPreviewFile];
    } else {
        [self layoutForShowFileInfo];
    }
}

- (void)startFileDownLoad {
    [self layoutForDownloading];
    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] downloadMediaFile:self.fileName
        mediaUrl:self.remoteURL
        progress:^(int progress) {
            [weakSelf downloading:progress * 0.01];
        }
        success:^(NSString *mediaPath) {
            weakSelf.localPath = mediaPath;
            if ([weakSelf isFileSupported]) {
                [weakSelf layoutAndPreviewFile];
            } else {
                [weakSelf layoutForShowFileInfo];
            }
        }
        error:^(RCErrorCode errorCode) {
            [weakSelf layoutForShowFileInfo];
            UIAlertController *alertController = [UIAlertController
                alertControllerWithTitle:nil
                                 message:NSLocalizedStringFromTable(@"FileDownloadFailed", @"RongCloudKit", nil)
                          preferredStyle:UIAlertControllerStyleAlert];
            [alertController
                addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action){
                                                 }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        cancel:^{
    }];
}

- (void)downloading:(float)progress {
    [self.progressView setProgress:progress animated:YES];
    self.progressLabel.text =
        [NSString stringWithFormat:@"%@(%@/%@)", NSLocalizedStringFromTable(@"FileIsDownloading", @"RongCloudKit", nil),
                                   [RCKitUtility getReadableStringForFileSize:progress * self.fileSize],
                                   [RCKitUtility getReadableStringForFileSize:self.fileSize]];
}

- (BOOL)isFileDownloaded {
    NSString *fileLocalPath;
    if (self.localPath) {
        fileLocalPath = self.localPath;
    } else {
        fileLocalPath = [RCFileUtility getFileLocalPath:self.remoteURL];
    }
    if ([RCFileUtility isFileExist:fileLocalPath]) {
        self.localPath = fileLocalPath;
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isFileSupported {
    if (![[RCKitUtility getFileTypeIcon:self.fileType] isEqualToString:@"OtherFile"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)layoutForShowFileInfo {
    self.webView.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    self.typeIconView.hidden = NO;
    self.nameLabel.hidden = NO;
    self.sizeLabel.hidden = NO;
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
    self.progressView.hidden = YES;
    self.progressLabel.hidden = YES;

    [self transformEncodingFromFilePath:self.localPath];
    if (self.localPath) {
        NSURL *fileURL = [NSURL fileURLWithPath:self.localPath];
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    }
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
                                   [self openInOtherApp:self.localPath];
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
    if (!localPath) {
        return;
    }
    UIActivityViewController *activityVC =
        [[UIActivityViewController alloc] initWithActivityItems:@[ [NSURL fileURLWithPath:localPath] ]
                                          applicationActivities:nil];
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
    [self openInOtherApp:self.localPath];
}

#pragma mark txt格式乱码问题解决方法
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

#pragma mark subView
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc]
            initWithFrame:CGRectMake(0, self.extentLayoutForY, [UIScreen mainScreen].bounds.size.width,
                                     [UIScreen mainScreen].bounds.size.height - self.extentLayoutForY)];
        _webView.scrollView.contentInset = (UIEdgeInsets){8, 8, 8, 8};
        _webView.backgroundColor =
            [UIColor colorWithRed:242.f / 255.f green:242.f / 255.f blue:243.f / 255.f alpha:1.f];
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIImageView *)typeIconView {
    if (!_typeIconView) {
        _typeIconView = [[UIImageView alloc]
            initWithFrame:CGRectMake((self.view.bounds.size.width - 75) / 2, 30 + self.extentLayoutForY, 75, 75)];
        NSString *fileTypeIcon = [RCKitUtility getFileTypeIcon:self.fileType];
        _typeIconView.image = [RCKitUtility imageNamed:fileTypeIcon ofBundle:@"RongCloud.bundle"];

        [self.view addSubview:_typeIconView];
    }

    return _typeIconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]
            initWithFrame:CGRectMake(10, 122 + self.extentLayoutForY, self.view.bounds.size.width - 10 * 2, 21)];
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
        _nameLabel.text = self.fileName;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = RCDYCOLOR(0x343434, 0x9f9f9f);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.view addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 151 + self.extentLayoutForY, self.view.bounds.size.width, 12)];
        _sizeLabel.font = [UIFont systemFontOfSize:13.0f];
        _sizeLabel.text = [RCKitUtility getReadableStringForFileSize:self.fileSize];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        _sizeLabel.textColor = RCDYCOLOR(0xa8a8a8, 0x666666);
        [self.view addSubview:_sizeLabel];
    }
    return _sizeLabel;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]
            initWithFrame:CGRectMake(10, 151 + self.extentLayoutForY, self.view.bounds.size.width - 10 * 2, 21)];
        _progressLabel.textColor = HEXCOLOR(0xa8a8a8);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.view addSubview:_progressLabel];
    }
    return _progressLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]
            initWithFrame:CGRectMake(10, 184 + self.extentLayoutForY, self.view.bounds.size.width - 10 * 3, 8)];
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 4.0f);
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.progressTintColor = HEXCOLOR(0x0099ff);
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (UIButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton = [[UIButton alloc]
            initWithFrame:CGRectMake(10, 197 + self.extentLayoutForY, self.view.bounds.size.width - 10 * 2, 40)];
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
        _openInOtherAppButton = [[UIButton alloc]
            initWithFrame:CGRectMake(10, 197 + self.extentLayoutForY, self.view.bounds.size.width - 10 * 2, 40)];
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

@end
