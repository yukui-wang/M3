//
//  RCBurnSightViewController.m
//  RongIMKit
//
//  Created by Zhaoqianyu on 2018/5/12.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCBurnSightViewController.h"
#import "RCIM.h"
#import "RCMessageModel.h"
#import "RCSightCollectionView.h"
#import "RCSightCollectionViewCell.h"
#import "RCKitCommonDefine.h"
#import "RCActiveWheel.h"
#import "RCBurnCountDownButton.h"
#import "RCIMClient+Destructing.h"

extern NSString *const RCKitDispatchDownloadMediaNotification;

@interface RCSightPlayerOverlayView : UIView
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationTimeLabel;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *centerPlayBtn;
@end

@interface RCBurnSightViewController () <UIScrollViewDelegate, RCSightCollectionViewCellDelegate,
                                         UICollectionViewDataSource, UICollectionViewDelegate,
                                         UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableArray<RCMessageModel *> *messageModelArray;

@property (nonatomic, strong) RCSightCollectionView *collectionView;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, assign) BOOL autoPlayFlag;

@end

@implementation RCBurnSightViewController {
    BOOL _statusBarHidden;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateDownloadMediaStatus:)
                                                     name:@"RCKitSightDownloadComplete"
                                                   object:nil];
    }
    return self;
}

#pragma mark - properties

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor blackColor];
    }
    return _imageView;
}

- (RCSightCollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        _collectionView = [[RCSightCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[RCSightCollectionViewCell class] forCellWithReuseIdentifier:@"RCSightCell"];
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.delegate = self;
        [_collectionView setPagingEnabled:YES];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}

- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
    }
    return _backView;
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    ////设置导航条透明
    self.autoPlayFlag = YES;
    [self getMessageFromModel:self.messageModel];

    self.backView.frame = self.view.bounds;
    [self.view addSubview:self.backView];
    [self.view addSubview:self.collectionView];
    [self strechToSuperview:self.collectionView];

    self.navigationController.navigationBarHidden = YES;
    [self performSelector:@selector(setStatusBarHidden:) withObject:@(YES) afterDelay:0.6];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[RCIMClient sharedRCIMClient]
        messageStopDestruct:[[RCIMClient sharedRCIMClient] getMessage:self.messageModel.messageId]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageDestructing:)
                                                 name:RCKitMessageDestructingNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setStatusBarHidden:@(YES)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    _statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[RCIMClient sharedRCIMClient]
        messageBeginDestruct:[[RCIMClient sharedRCIMClient] getMessage:self.messageModel.messageId]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.collectionView.contentInset = UIEdgeInsetsZero;
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
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)updateDownloadMediaStatus:(NSNotification *)notify {
    //    RCSightMessage *sightMessage = (RCSightMessage *)self.messageModel.content;
}

#pragma mark - collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messageModelArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCSightCollectionViewCell *cell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:@"RCSightCell" forIndexPath:indexPath];
    RCMessageModel *model = self.messageModelArray[indexPath.row];
    [cell setDataModel:model];
    cell.delegate = self;
    cell.autoPlay = YES;
    UIView *contentView = cell.contentView.subviews.firstObject;
    Class playerType = NSClassFromString(@"RCSightPlayerOverlayView");
    if (playerType) {
        for (UIView *view in contentView.subviews) {
            if ([view isKindOfClass:playerType.class]) {
                RCSightPlayerOverlayView *overlayView = ((RCSightPlayerOverlayView *)view);
                overlayView.playBtn.hidden = YES;
                overlayView.slider.userInteractionEnabled = NO;
                overlayView.centerPlayBtn.hidden = YES;
                NSArray<NSLayoutConstraint *> *constraints = overlayView.slider.superview.constraints;
                for (NSLayoutConstraint *constraint in constraints) {
                    if (constraint.firstItem == overlayView.currentTimeLabel &&
                        constraint.secondItem == overlayView.playBtn) {
                        constraint.constant = -22;
                    }
                    if (constraint.firstItem == overlayView.durationTimeLabel.superview &&
                        constraint.secondItem == overlayView.durationTimeLabel) {
                        constraint.constant = 22;
                    }
                }
                break;
            }
        }
    }
    UITapGestureRecognizer *sightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSight)];
    [cell addGestureRecognizer:sightTap];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = self.messageModelArray[indexPath.row];
    RCSightCollectionViewCell *sightCell = (RCSightCollectionViewCell *)cell;

    if (self.messageModel == model && self.autoPlayFlag) {
        sightCell.autoPlay = YES;
        self.autoPlayFlag = NO;
    } else {
        sightCell.autoPlay = NO;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size;
}

#pragma mark - helper

- (void)strechToSuperview:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *formats = @[ @"H:|[view]|", @"V:|[view]|" ];
    for (NSString *each in formats) {
        NSArray *constraints =
            [NSLayoutConstraint constraintsWithVisualFormat:each options:0 metrics:nil views:@{
                @"view" : view
            }];
        [view.superview addConstraints:constraints];
    }
}

- (void)getMessageFromModel:(RCMessageModel *)model {
    if (model) {
        self.messageModelArray = [[NSMutableArray alloc] initWithObjects:model, nil];
    }
}

- (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)tapSight {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onMessageDestructing:(NSNotification *)notification {
}

#pragma mark - RCSightPlayerControllerDelegate

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeSight {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playEnd {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
