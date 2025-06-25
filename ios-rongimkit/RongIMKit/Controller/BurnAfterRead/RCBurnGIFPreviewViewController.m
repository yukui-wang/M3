//
//  RCBurnGIFPreviewViewController.m
//  RongIMKit
//
//  Created by Zhaoqianyu on 2019/9/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCBurnGIFPreviewViewController.h"
#import "RCGIFImage.h"
#import "RCKitUtility.h"
#import "RCKitCommonDefine.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCGIFUtility.h"
#import "RCIMClient+Destructing.h"
#import "RCBurnCountDownButton.h"
#import "RCActiveWheel.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGTH [UIScreen mainScreen].bounds.size.height

@interface RCBurnGIFPreviewViewController ()

@property (nonatomic, strong) NSData *gifData;

// 展示GIF的view
@property (nonatomic, strong) RCGIFImageView *gifView;

@property (nonatomic, strong) RCBurnCountDownButton *rightTopButton;

@end

@implementation RCBurnGIFPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RCDYCOLOR(0xf0f0f6, 0x000000);
    [self setNav];
    [self addSubViews];
    [self configModel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageDestructing:)
                                                 name:RCKitMessageDestructingNotification
                                               object:nil];
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

    [self.view addSubview:self.rightTopButton];
    self.rightTopButton.frame = CGRectMake(15, ISX ? 76 : 20, 32, 32);
    NSNumber *duration = [[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.messageModel.messageUId];
    if (duration != nil && [duration integerValue] < 30) {
        [self.rightTopButton setBurnCountDownButtonHighlighted];
    }
    [self.rightTopButton messageDestructing:[duration integerValue]];
}

- (void)configModel {
    if (!self.messageModel) {
        return;
    }
    RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:self.messageModel.messageId];
    RCGIFMessage *gifMessage = (RCGIFMessage *)msg.content;
    [[RCIMClient sharedRCIMClient] messageBeginDestruct:msg];
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
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (error != NULL) {
                                         DebugLog(@" save image fail");
                                         [self showAlertController:nil
                                                           message:NSLocalizedStringFromTable(@"SavePhotoFailed",
                                                                                              @"RongCloudKit", nil)
                                                       cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit",
                                                                                              nil)];
                                     } else {
                                         DebugLog(@"save image suceed");
                                         [self showAlertController:nil
                                                           message:NSLocalizedStringFromTable(@"SavePhotoSuccess",
                                                                                              @"RongCloudKit", nil)
                                                       cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit",
                                                                                              nil)];
                                     }
                                 });
                             }];
    }
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

- (void)onMessageDestructing:(NSNotification *)notification {
    NSDictionary *dataDict = notification.userInfo;
    RCMessage *message = dataDict[@"message"];
    NSInteger duration = [dataDict[@"remainDuration"] integerValue];
    if (![message.messageUId isEqualToString:self.messageModel.messageUId]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (duration >= 0 && duration <= 30) {
            if (self.rightTopButton.isBurnCountDownButtonHighlighted == NO) {
                [self.rightTopButton setBurnCountDownButtonHighlighted];
            }
            [self.rightTopButton messageDestructing:duration];
            if (duration == 0) {
                [self onMessageBurnDestory:message];
            }
        }
    });
}

- (void)onMessageBurnDestory:(RCMessage *)message {
    if (![message.messageUId isEqualToString:self.messageModel.messageUId]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (UIButton *)rightTopButton {
    if (!_rightTopButton) {
        _rightTopButton = [[RCBurnCountDownButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    }
    return _rightTopButton;
}

@end
