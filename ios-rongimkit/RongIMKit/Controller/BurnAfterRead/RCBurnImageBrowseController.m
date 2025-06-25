//
//  RCBurnImageBrowseController.m
//  RongIMKit
//
//  Created by Zhaoqianyu on 2018/5/14.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCBurnImageBrowseController.h"
#import "RCIM.h"
#import "RCImageMessageProgressView.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import "RCMessageModel.h"
#import "RCloudImageLoader.h"
#import "RCloudImageView.h"
#import "RCActiveWheel.h"
#import "RCBurnCountDownButton.h"
#import "RCIMClient+Destructing.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGTH [UIScreen mainScreen].bounds.size.height

@interface RCBurnImageBrowseController () <UIScrollViewDelegate, RCloudImageViewDelegate>

// scrollView
@property (nonatomic, strong) UIScrollView *scrollView;
//背景黑色
@property (nonatomic, strong) UIView *backView;
// timeButton
@property (nonatomic, strong) RCBurnCountDownButton *rightTopButton;
//当前图片消息的数据模型
@property (nonatomic, strong) NSMutableArray<RCMessageModel *> *imageArray;
//当前图片消息的index
@property (nonatomic, assign) NSInteger currentIndex;
//图片列表
@property (nonatomic, strong) NSMutableArray<RCloudImageView *> *imageViewList;
@property (nonatomic, strong) NSMutableArray<RCImageMessage *> *imagemessageList;
@property (nonatomic, strong) NSMutableDictionary *imageProgressList;

@end

@implementation RCBurnImageBrowseController {
    BOOL _statusBarHidden;
}

#pragma mark - lazy load

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_scrollView setBackgroundColor:[UIColor blackColor]];
        [_scrollView setDelegate:self];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setContentSize:CGSizeMake([self.imageArray count] * self.view.bounds.size.width, 0)];
    }
    return _scrollView;
}

- (UIButton *)rightTopButton {
    if (!_rightTopButton) {
        _rightTopButton = [[RCBurnCountDownButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    }
    return _rightTopButton;
}

- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
    }
    return _backView;
}

#pragma mark - life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageProgressList = [NSMutableDictionary new];
    //取当前界面中一定数量的图片
    [self getMessageFromModel:self.messageModel];
    self.imageViewList = [NSMutableArray new];
    self.imagemessageList = [NSMutableArray new];
    //添加图片到scroll子视图
    [self refreshimage:self.imageArray];
    [self refreshScrollView:self.imageViewList];

    self.backView.frame = self.view.bounds;
    [self.view addSubview:self.backView];

    self.scrollView.contentOffset = CGPointMake(self.currentIndex * self.view.frame.size.width, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.scrollView];

    [self.view addSubview:self.rightTopButton];
    self.rightTopButton.frame = CGRectMake(15, ISX ? 76 : 20, 32, 32);
    NSNumber *duration = [[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.messageModel.messageUId];
    if (duration != nil && [duration integerValue] < 30) {
        [self.rightTopButton setBurnCountDownButtonHighlighted];
    }
    [self.rightTopButton messageDestructing:[duration integerValue]];

    [self performSelector:@selector(setStatusBarHidden:) withObject:@(YES) afterDelay:0.4];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageDestructing:)
                                                 name:RCKitMessageDestructingNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)setStatusBarHidden:(NSNumber *)hidden {
    _statusBarHidden = [hidden boolValue];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self setNeedsStatusBarAppearanceUpdate];
                     }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (void)beginDestructing {
    RCImageMessage *imageMessage = (RCImageMessage *)self.messageModel.content;
    if (self.messageModel.messageDirection == MessageDirection_RECEIVE && imageMessage.destructDuration > 0) {
        [[RCIMClient sharedRCIMClient]
            messageBeginDestruct:[[RCIMClient sharedRCIMClient] getMessage:self.messageModel.messageId]];
        ;
    }
}

#pragma make - NSNotifacation

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
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - target Action

- (void)singleTap:(UITapGestureRecognizer *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doubleTap:(UITapGestureRecognizer *)sender {
    if (self.scrollView.subviews.count > self.currentIndex) {
        UIScrollView *subview = self.scrollView.subviews[self.currentIndex];
        if (subview.contentSize.width > self.view.frame.size.width) {
            [subview setZoomScale:1.0 animated:YES];
        } else {
            CGPoint touchPoint = [sender locationInView:subview];
            CGFloat newZoomScale = subview.maximumZoomScale;
            CGFloat xsize = self.view.frame.size.width / newZoomScale;
            CGFloat ysize = self.view.frame.size.height / newZoomScale;
            [subview zoomToRect:CGRectMake(touchPoint.x - xsize / 2, touchPoint.y - ysize / 2, xsize, ysize) animated:YES];
        }
    }
}

- (void)backButtonAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - refresh scrollView

- (void)getMessageFromModel:(RCMessageModel *)model {
    if (!model) {
        NSLog(@"传入的参数不允许是 nil");
        return;
    }
    self.imageArray = [[NSMutableArray alloc] initWithObjects:model, nil];
    self.currentIndex = [self.imageArray indexOfObject:model];
}

- (void)refreshimage:(NSMutableArray *)imagearray {
    [self.imageViewList removeAllObjects];
    [self.imagemessageList removeAllObjects];

    for (int i = 0; i < imagearray.count; i++) {
        RCMessageModel *model = imagearray[i];
        RCImageMessage *imageMessage = (RCImageMessage *)model.content;
        if (imageMessage) {
            [self.imagemessageList addObject:imageMessage];
            RCloudImageView *imageView = [[RCloudImageView alloc] init];
            imageView.delegate = self;
            //判断图片路径
            if (imageMessage.localPath.length > 0 &&
                [[NSFileManager defaultManager] fileExistsAtPath:imageMessage.localPath]) {
                imageView.PlaceholderImage = imageMessage.thumbnailImage;
                [imageView setImageURL:[NSURL URLWithString:imageMessage.localPath]];
            } else {

                if ([imageMessage.imageUrl hasPrefix:@"http"]) {
                    RCImageMessageProgressView *imageProressView =
                        [[RCImageMessageProgressView alloc] initWithFrame:CGRectMake(0, 0, 135, 135)];
                    imageProressView.label.hidden = YES;
                    imageProressView.indicatorView.color = [UIColor blackColor];
                    imageProressView.backgroundColor = [UIColor clearColor];
                    [imageProressView
                        setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
                    [imageView addSubview:imageProressView];
                    if (imageMessage.imageUrl) {
                        [self.imageProgressList setObject:imageProressView forKey:imageMessage.imageUrl];
                    }
                    //判断是否已加载
                    if ([[RCloudImageLoader sharedImageLoader]
                            hasLoadedImageURL:[NSURL URLWithString:imageMessage.imageUrl]]) {
                        [imageView setImageURL:[NSURL URLWithString:imageMessage.imageUrl]];
                    } else {
                        imageView.delegate = self;
                        imageView.PlaceholderImage = imageMessage.thumbnailImage;
                        [imageProressView startAnimating];
                    }
                } else {
                    imageView.PlaceholderImage = imageMessage.thumbnailImage;
                    [imageView setImageURL:[NSURL URLWithString:imageMessage.imageUrl]];
                }
            }

            imageView.tag = i + 1;
            [self resizeSubviews:imageView];

            [self.imageViewList addObject:imageView];
        }
    }
}

- (void)refreshScrollView:(NSMutableArray *)imageViewList {

    while (self.scrollView.subviews.count > 0) {
        [self.scrollView.subviews[0] removeFromSuperview];
    }

    for (int i = 0; i < imageViewList.count; i++) {
        // scrollView
        UIScrollView *imagesrcoll =
            [[UIScrollView alloc] initWithFrame:CGRectMake(i * self.view.frame.size.width, 0,
                                                           self.view.frame.size.width, self.view.frame.size.height)];
        [imagesrcoll setContentSize:CGSizeMake(self.view.bounds.size.width, 0)];
        imagesrcoll.delegate = self;

        UIImageView *imageView = imageViewList[i];
        RCloudImageView *newImageView = [[RCloudImageView alloc]
            initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        newImageView.contentMode = UIViewContentModeScaleAspectFit;
        newImageView.PlaceholderImage = self.imagemessageList[i].thumbnailImage;
        newImageView.delegate = self;
        if (self.imagemessageList[i].localPath.length > 0) {
            newImageView.PlaceholderImage = self.imagemessageList[i].thumbnailImage;
            [newImageView setImageURL:[NSURL URLWithString:self.imagemessageList[i].localPath]];
            [self beginDestructing];
        } else {

            if ([self.imagemessageList[i].imageUrl hasPrefix:@"http"]) {
                RCImageMessageProgressView *imageProressView =
                    [[RCImageMessageProgressView alloc] initWithFrame:CGRectMake(0, 0, 135, 135)];
                imageProressView.label.hidden = YES;
                imageProressView.indicatorView.color = [UIColor blackColor];
                imageProressView.backgroundColor = [UIColor clearColor];
                [imageProressView
                    setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
                if (self.imagemessageList[i].imageUrl) {
                    [self.imageProgressList setObject:imageProressView forKey:self.imagemessageList[i].imageUrl];
                }

                [newImageView addSubview:imageProressView];
                //判断是否已加载
                if ([[RCloudImageLoader sharedImageLoader]
                        hasLoadedImageURL:[NSURL URLWithString:self.imagemessageList[i].imageUrl]]) {
                    [newImageView setImageURL:[NSURL URLWithString:self.imagemessageList[i].imageUrl]];
                    [self beginDestructing];
                } else {
                    newImageView.PlaceholderImage = self.imagemessageList[i].thumbnailImage;
                    [imageProressView startAnimating];
                    [newImageView setImageURL:[NSURL URLWithString:self.imagemessageList[i].imageUrl]];
                }
            } else {

                newImageView.image = imageView.image;
            }
        }
        [self resizeSubviews:newImageView];
        [imagesrcoll addSubview:newImageView];
        UITapGestureRecognizer *singleTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [imagesrcoll addGestureRecognizer:singleTap];

        //双击放大或缩小
        UITapGestureRecognizer *doubleTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        doubleTap.numberOfTapsRequired = 2;
        imagesrcoll.userInteractionEnabled = YES;
        [imagesrcoll addGestureRecognizer:doubleTap];

        [self.scrollView addSubview:imagesrcoll];

        imagesrcoll.minimumZoomScale = 1.0;
        imagesrcoll.maximumZoomScale = 4.0;
        [imagesrcoll setZoomScale:1.0];
    }
}

//调整图片大小
- (void)resizeSubviews:(RCloudImageView *)ImageView {
    ImageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat imageWidth = self.view.frame.size.width;
    CGFloat imageHeight = self.view.frame.size.height;
    [ImageView setFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
}

#pragma mark - RCloudImageViewDelegate

- (void)imageViewLoadedImage:(RCloudImageView *)imageView {
    //图片加载成功后，去掉加载中的标识
    RCImageMessageProgressView *imageProressView = self.imageProgressList[imageView.imageURL.absoluteString];
    if (imageProressView) {
        [imageProressView stopAnimating];
        [imageProressView setHidden:YES];
    }
    [self beginDestructing];
}

- (void)imageViewFailedToLoadImage:(RCloudImageView *)imageView error:(NSError *)error {
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(action:) userInfo:imageView repeats:NO];
}

- (void)action:(NSTimer *)scheduledTimer {
    RCloudImageView *imageView = (RCloudImageView *)(scheduledTimer.userInfo);
    NSString *imageUrl = [imageView.imageURL absoluteString];
    RCImageMessageProgressView *imageProressView = self.imageProgressList[imageUrl];
    if (imageProressView) {
        [imageProressView stopAnimating];
        [imageProressView setHidden:YES];
    }

    if ([imageUrl hasPrefix:@"http"]) {
        UIImage *image = [RCKitUtility imageNamed:@"broken" ofBundle:@"RongCloud.bundle"];
        imageView.image = nil;
        UIImageView *imageViewTip = [[UIImageView alloc] initWithImage:image];
        [imageViewTip setFrame:CGRectMake(0, 0, 81, 60)];
        [imageViewTip setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
        [imageView addSubview:imageViewTip];
        UILabel *failLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75,
                                                                       self.view.frame.size.height / 2 + 44, 150, 30)];
        failLabel.text = NSLocalizedStringFromTable(@"ImageLoadFailed", @"RongCloudKit", nil);
        failLabel.textAlignment = NSTextAlignmentCenter;
        failLabel.textColor = HEXCOLOR(0x999999);
        [imageView addSubview:failLabel];
    } else {
        UIImage *image = [RCKitUtility imageNamed:@"exclamation" ofBundle:@"RongCloud.bundle"];
        imageView.image = nil;
        UIImageView *imageViewTip = [[UIImageView alloc] initWithImage:image];
        [imageViewTip setFrame:CGRectMake(0, 0, 71, 71)];
        [imageViewTip setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
        [imageView addSubview:imageViewTip];
        UILabel *failLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75,
                                                      self.view.frame.size.height / 2 + 49.5, 150, 30)];
        failLabel.text = NSLocalizedStringFromTable(@"ImageHasBeenDeleted", @"RongCloudKit", nil);
        failLabel.textAlignment = NSTextAlignmentCenter;
        failLabel.textColor = HEXCOLOR(0x999999);
        [imageView addSubview:failLabel];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([scrollView.subviews count] > 0) {
        return scrollView.subviews[0];
    } else {
        return nil;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setImageCenter:scrollView];
}

- (void)setImageCenter:(UIScrollView *)scrollView {
    UIScrollView *subview = self.scrollView.subviews[self.currentIndex];
    CGFloat offsetX = (subview.frame.size.width > subview.contentSize.width)
                          ? (subview.frame.size.width - subview.contentSize.width) * 0.5
                          : 0.0;
    CGFloat offsetY = (subview.frame.size.height > subview.contentSize.height)
                          ? (subview.frame.size.height - subview.contentSize.height) * 0.5
                          : 0.0;
    self.imageViewList[self.currentIndex].center =
        CGPointMake(subview.contentSize.width * 0.5 + offsetX, subview.contentSize.height * 0.5 + offsetY);
}

@end
