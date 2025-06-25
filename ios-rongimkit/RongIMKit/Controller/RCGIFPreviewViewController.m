//
//  RCGIFPreviewViewController.m
//  RongIMKit
//
//  Created by liyan on 2018/12/24.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCGIFPreviewViewController.h"
#import "RCGIFImage.h"
#import "RCKitUtility.h"
#import "RCKitCommonDefine.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCGIFUtility.h"
#import <RongIMLib/RongIMLib.h>
#import "RCIM.h"

@interface RCGIFPreviewViewController ()

@property (nonatomic, strong) NSData *gifData;

// 展示GIF的view
@property (nonatomic, strong) RCGIFImageView *gifView;

@end

@implementation RCGIFPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RCDYCOLOR(0xf0f0f6, 0x000000);
    [self setNav];
    [self addSubViews];
    [self configModel];
    [self registerNotificationCenter];
}

- (void)setNav {
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
}

- (void)addSubViews {
    [self.view addSubview:self.gifView];
    //长按可选择是否保存图片
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)configModel {
    if (!self.messageModel) {
        return;
    }
    RCGIFMessage *gifMessage =
        (RCGIFMessage *)[[RCIMClient sharedRCIMClient] getMessage:self.messageModel.messageId].content;
    if (gifMessage && gifMessage.localPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakSelf.gifData = [NSData dataWithContentsOfFile:[RCUtilities getCorrectedFilePath:gifMessage.localPath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.gifData) {
                    weakSelf.gifView.animatedImage = [RCGIFImage animatedImageWithGIFData:weakSelf.gifData];
                }
            });
        });
    }
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        UIAlertAction *cancelAction =
            [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
                                     style:UIAlertActionStyleCancel
                                   handler:nil];
        UIAlertAction *saveAction =
            [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"RongCloudKit", nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *_Nonnull action) {
                                       [self saveGIF];
                                   }];
        [RCKitUtility showAlertController:nil
                                  message:nil
                           preferredStyle:UIAlertControllerStyleActionSheet
                                  actions:@[ cancelAction, saveAction ]
                         inViewController:self];
    }
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

#pragma mark - Private Method
- (void)showAlertController:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action){
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)saveGIF {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        [self showAlertController:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil)
                          message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil)
                      cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
        return;
    }
    if (self.gifData) {
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary
            writeImageDataToSavedPhotosAlbum:self.gifData
                                    metadata:nil
                             completionBlock:^(NSURL *assetURL, NSError *error) {
                                 if (error != NULL) {
                                     DebugLog(@" save image fail");
                                     [self showAlertController:nil
                                                       message:NSLocalizedStringFromTable(@"SavePhotoFailed",
                                                                                          @"RongCloudKit", nil)
                                                   cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
                                 } else {
                                     DebugLog(@"save image suceed");
                                     [self showAlertController:nil
                                                       message:NSLocalizedStringFromTable(@"SavePhotoSuccess",
                                                                                          @"RongCloudKit", nil)
                                                   cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
                                 }
                             }];
    }
}

- (RCGIFImageView *)gifView {
    if (!_gifView) {
        CGRect viewFrame = self.view.bounds;
        CGFloat homeBarHeight = [self getIphonexHomeBarHeight];
        CGFloat NavBarHeight = [self getDeviceNavBarHeight];
        _gifView = [[RCGIFImageView alloc]
            initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height - NavBarHeight - homeBarHeight)];
        _gifView.userInteractionEnabled = YES;
        _gifView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _gifView;
}
- (CGFloat)getIphonexHomeBarHeight {
    static CGFloat height = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            height = [RCKitUtility getWindowSafeAreaInsets].bottom;
        }
    });
    return height;
}

- (CGFloat)getDeviceNavBarHeight {
    static CGFloat height = 64;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            UIWindow *mainWindow = [RCKitUtility getKeyWindow];
            if (mainWindow.safeAreaInsets.bottom > 0.0) {
                height = 88;
            }
        }
    });
    return height;
}
@end
