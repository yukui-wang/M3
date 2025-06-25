//
//  CMPShareView.m
//  M3
//
//  Created by MacBook on 2019/10/24.
//

#import "CMPShareView.h"
#import "CMPShareCellModel.h"
#import "CMPShareCollectionView.h"
#import "CMPMessageManager.h"
#import "CMPShareFileModel.h"
#import "CMPShareToOtherAppKit.h"
#import "CMPShareManager.h"

#import <CMPLib/YBIBUtilities.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/YYModel.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPBannerWebViewController+Create.h>
#import <CMPLib/CMPFileManagementRecord.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPPopFromBottomViewController.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/CMPFileManager.h>



static CGFloat const kIphoneXFitMargin = 10.f;
static CGFloat const kSeperatorLineH = 0.5f;
static CGFloat const kDefaultCornerRadius = 14.f;
static CGFloat const kTitleLabelH = 36.f;

static NSString * const CMPShareCollectionCellTopListPlist = @"CMPShareCollectionCellTopList.plist";
static NSString * const CMPShareCollectionCellBottomListPlist = @"CMPShareCollectionCellBottomList.plist";

/**
tell_meeting  //电话会议
uc //致信
qq //QQ
wechat //微信
collect //收藏
print //打印
screen_display //屏幕镜像
qr_code //生成二维码
qiyeWechat //企业微信
dingding //钉钉
other //其他应用
download //下载
*/
static NSString * const kTopKeyList = @"tell_meeting,uc,qq,wechat,wechatMoments,qiyeWechat,dingding,other,OSystem,top_screen";
static NSString * const kBottomKeyList = @"collect,print,screen_display,download";

@interface CMPShareView()<CMPShareCollectionViewDelegate,UIDocumentInteractionControllerDelegate>
{
    NSArray *_topDataArr;
    NSArray *_bottomDataArr;
}
/* topCollectionView */
@property (strong, nonatomic) CMPShareCollectionView *topCollectionView;
/* bottomCollectionView */
@property (strong, nonatomic) CMPShareCollectionView *bottomCollectionView;

/* 底部的取消view */
@property (strong, nonatomic) UIView *cancelView;
/* 适配x系列手机时底部的marginView */
@property (strong, nonatomic) UIView *marginView;
/* 取消文字 */
@property (strong, nonatomic) UILabel *cancelLabel;

/* bottomCover */
@property (strong, nonatomic) UIView *bottomCover;
/* titleCoverBtn */
@property (strong, nonatomic) UIButton *titleCoverBtn;
/* titleLabel */
@property (strong, nonatomic) UILabel *titleLabel;
/* 分割线 */
@property (strong, nonatomic) UIView *separatorLine;
/* 分割线 */
@property (strong, nonatomic) UIView *bottomSeparatorLine;
/* 当前view的高度 */
@property (assign, nonatomic) CGFloat viewH;

@property (nonatomic, strong) NSDictionary *ksCommonParams;
@property (nonatomic, copy) void(^ksCommonRsltBlk)(NSInteger step,NSDictionary *actInfo, NSError *err, __nullable id ext);

@end

@implementation CMPShareView

#pragma mark - lazy loading

- (UIView *)cancelView {
    if (!_cancelView) {
        CGFloat cancelLabelH = 50.f;
        UIView *cancelView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.width, cancelLabelH)];
        cancelView.backgroundColor = UIColor.clearColor;
        if (YBIBUtilities.isIphoneX) {
            cancelView.cmp_height += kIphoneXFitMargin;
            [cancelView addSubview:self.marginView];
        }
        cancelView.cmp_y = self.height - cancelView.height;
        _cancelView = cancelView;
    }
    return _cancelView;
}

- (UILabel *)cancelLabel {
    if (!_cancelLabel) {
        /// 取消按钮
        UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 50.f)];
        cancelLabel.backgroundColor = [UIColor cmp_colorWithName:@"gray-bgc"];
        cancelLabel.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
        cancelLabel.text = SY_STRING(@"common_cancel");
        cancelLabel.textAlignment = NSTextAlignmentCenter;
        cancelLabel.font = [UIFont systemFontOfSize:16.f];
        _cancelLabel = cancelLabel;
    }
    return _cancelLabel;
}

- (UIView *)marginView {
    if (!_marginView) {
        UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, 50.f, self.width, kIphoneXFitMargin)];
        marginView.backgroundColor = [UIColor cmp_colorWithName:@"gray-bgc"];
        _marginView = marginView;
    }
    return _marginView;
}

- (UIView *)bottomCover {
    if (!_bottomCover) {
        //这个是x系列手机的填充view，不然下面的那个部分的颜色显示会和取消按钮的颜色不一致
        CGFloat y = CGRectGetMaxY(self.cancelView.frame);
        UIView *bottomCover = [UIView.alloc initWithFrame:CGRectMake(0, y, self.cancelView.width, self.height - y)];
        bottomCover.backgroundColor = self.cancelView.backgroundColor;
        _bottomCover = bottomCover;
    }
    return _bottomCover;
}

- (UIButton *)titleCoverBtn {
    if (!_titleCoverBtn) {
        UIButton *titleCoverBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, self.width, 36.f)];
        titleCoverBtn.backgroundColor = UIColor.clearColor;
        [titleCoverBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _titleCoverBtn = titleCoverBtn;
    }
    return _titleCoverBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat titleH = 22.f;
        UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(0, self.titleCoverBtn.height - titleH, self.titleCoverBtn.width, titleH)];
        titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = SY_STRING(@"forward_sendto");
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (CMPShareCollectionView *)topCollectionView {
    if (!_topCollectionView) {
        /// 计算collectionview高度
        CGFloat collectionViewH = (self.height - self.cancelView.height - kSeperatorLineH - kTitleLabelH)/2.f;
        if (YBIBUtilities.isIphoneX) {
            collectionViewH -= kIphoneXFitMargin/2.f;
        }
        
        /// 上面第一个collectionview
        CMPShareCollectionView *topCollectionView = [[CMPShareCollectionView alloc] initWithFrame:CGRectMake(0, kTitleLabelH, self.width, collectionViewH)];
        topCollectionView.delegate = self;
        _topCollectionView = topCollectionView;
    }
    return _topCollectionView;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topCollectionView.frame), self.width, kSeperatorLineH)];
        separatorLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-bdc"];
        _separatorLine = separatorLine;
    }
    return _separatorLine;
}

- (UIView *)bottomSeparatorLine {
    if (!_bottomSeparatorLine) {
        UIView *bottomSeparatorLine = [[UIView alloc] init];
        bottomSeparatorLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-bdc"];
        _bottomSeparatorLine = bottomSeparatorLine;
    }
    return _bottomSeparatorLine;
}

- (CMPShareCollectionView *)bottomCollectionView {
    if (!_bottomCollectionView) {
        /// 计算collectionview高度
        CGFloat collectionViewH = (self.height - self.cancelView.height - kSeperatorLineH - kTitleLabelH)/2.f;
        if (YBIBUtilities.isIphoneX) {
            collectionViewH -= kIphoneXFitMargin/2.f;
        }
        
        CMPShareCollectionView *bottomCollectionView = [[CMPShareCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.separatorLine.frame), self.width, collectionViewH)];
        bottomCollectionView.delegate = self;
        bottomCollectionView.backgroundColor = self.topCollectionView.backgroundColor;
        _bottomCollectionView = bottomCollectionView;
    }
    return _bottomCollectionView;
}

#pragma mark - view initializing

- (void)dealloc {
    DDLogDebug(@"---%s---",__func__);
}


/// 工厂方法，返回一个此类的对象
/// @param frame frame
/// @param shareFileModel 其他地方调用分享组件时传过来的参数，为空的话就显示默认设置的分享列表
+ (instancetype)shareViewWithFrame:(CGRect)frame shareFileModel:(CMPShareFileModel *)shareFileModel {
    CMPShareView *shareView = [CMPShareView.alloc initWithFrame:frame];
    shareView.shareFileModel = shareFileModel;
    if (shareView) {
        if (shareView.shareFileModel) {
            [shareView handleShareFileModel];
        }else {
            shareView.isDefaultList = YES;
            [shareView loadPlistData];
        }
    }
    return shareView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (YBIBUtilities.isIphoneX) {
        frame.size.height += kIphoneXFitMargin;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.customBgColor = [UIColor cmp_colorWithName:@"gray-bgc"];
        self.cornerRadius = kDefaultCornerRadius;
        self.viewH = frame.size.height;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CMP_IPAD_MODE) {
        [self configSubViews];
    }
}

/// 配置要显示的view
- (void)configSubViews {
    
    self.cmp_height = self.viewH;
    
    CGFloat cancelLabelH = 50.f;
    CGFloat titleH = 22.f;
    
    [self addSubview:self.cancelView];
    [self.cancelView addSubview:self.cancelLabel];
    
    self.cancelView.frame = CGRectMake(0, 0, self.width, cancelLabelH);
    self.cancelLabel.frame = CGRectMake(0, 0, self.width, cancelLabelH);
    
    if (YBIBUtilities.isIphoneX) {
        self.marginView.frame = CGRectMake(0, cancelLabelH, self.width, kIphoneXFitMargin);
        [self addSubview:self.bottomCover];
        self.bottomCover.frame = CGRectMake(0, CGRectGetMaxY(self.cancelView.frame), self.cancelView.width, self.height - CGRectGetMaxY(self.cancelView.frame));
        self.cancelView.cmp_height += kIphoneXFitMargin;
        [self.cancelView addSubview:self.marginView];
        
    }
    self.cancelView.cmp_y = self.height - self.cancelView.height;
    //title
    [self addSubview:self.titleCoverBtn];
    self.titleCoverBtn.frame = CGRectMake(0, 0, self.width, 36.f);
    
    [self.titleCoverBtn addSubview:self.titleLabel];
    self.titleLabel.frame = CGRectMake(0, self.titleCoverBtn.height - titleH, self.titleCoverBtn.width, titleH);
    
    
    [self addSubview:self.topCollectionView];
    /// 计算collectionview高度
    CGFloat collectionViewH = (self.height - self.cancelView.height - kSeperatorLineH - kTitleLabelH)/2.f;
    if (YBIBUtilities.isIphoneX) {
        collectionViewH -= kIphoneXFitMargin/2.f;
    }
    
    self.topCollectionView.frame = CGRectMake(0, kTitleLabelH, self.width, collectionViewH);
    
    /// 分割线
    [self addSubview:self.separatorLine];
    self.separatorLine.frame = CGRectMake(0, CGRectGetMaxY(self.topCollectionView.frame), self.width, kSeperatorLineH);
    
    [self addSubview:self.bottomCollectionView];
    self.bottomCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.separatorLine.frame), self.width, collectionViewH);
    
    [self addSubview:self.bottomSeparatorLine];
    self.bottomSeparatorLine.frame = CGRectMake(0, self.bottomCollectionView.cmp_bottom, self.width, kSeperatorLineH);
    
    if (CMP_IPAD_MODE && _bottomDataArr.count < kRowCount && _topDataArr.count < kRowCount) {
        NSInteger count = MAX(_topDataArr.count, _bottomDataArr.count);
        
        CGFloat rowWidth = self.width/kRowCount;
        CGFloat collectionViewW = rowWidth * count;
        self.topCollectionView.cmp_width = collectionViewW;
        self.bottomCollectionView.cmp_width = collectionViewW;
        
    }
    
    [self setTopDataArray:_topDataArr.copy];
    [self setBottomDataArray:_bottomDataArr.copy];
}


/// 设置topview要显示的数据
/// @param topDataArray 要显示的数据的数组
- (void)setTopDataArray:(NSArray *)topDataArray {
    if (topDataArray.count > 0) {
        if (self.isDefaultList) {
           self.topCollectionView.dataArray = [self handleDefaultDataArray:topDataArray].copy;
        }else {
            self.topCollectionView.dataArray = topDataArray.copy;
        }
        self.topCollectionView.isDefaultList = self.isDefaultList;
        [self.topCollectionView reloadData];
    }
    
    if (self.topCollectionView.dataArray.count) return;
    
    //进行界面的重新安排，因为有时上部的collectionView或者下部的collectionView没数据，那么就不需要显示
    self.cmp_height = self.viewH;
    if (self.topCollectionView) {
        [self.topCollectionView removeFromSuperview];
        
        self.cmp_height -= self.topCollectionView.height;
        self.bottomCollectionView.cmp_y = self.topCollectionView.cmp_y;
        self.cancelView.cmp_y = self.height - self.cancelView.height;
        self.separatorLine.hidden = YES;
        self.topCollectionView = nil;
    }
    
    if (!self.topCollectionView && !self.bottomCollectionView) {
        self.cmp_height = 0;
    }
}


/// 设置底部显示的数据
/// @param bottomDataArray 要显示的数据数组
- (void)setBottomDataArray:(NSArray *)bottomDataArray {
    if (bottomDataArray.count > 0) {
        if (self.isDefaultList) {
            self.bottomCollectionView.dataArray = [self handleDefaultDataArray:bottomDataArray].copy;
        }else {
            self.bottomCollectionView.dataArray = bottomDataArray.copy;
        }
        self.bottomCollectionView.isDefaultList = self.isDefaultList;
        [self.bottomCollectionView reloadData];
    }
    
    if (self.bottomCollectionView.dataArray.count) return;
    
    //进行界面的重新安排，因为有时上部的collectionView或者下部的collectionView没数据，那么就不需要显示
    if (self.bottomCollectionView) {
        [self.bottomCollectionView removeFromSuperview];
        
        self.cmp_height -= self.bottomCollectionView.height;
        self.cancelView.cmp_y = self.height - self.cancelView.height;
        self.separatorLine.hidden = YES;
        self.bottomCollectionView = nil;
    }
    
    if (!self.topCollectionView && !self.bottomCollectionView) {
        self.cmp_height = 0;
    }
    
}

/// 设置默认的显示数据
/// @param dataArray 要显示的数据数组
- (NSArray *)handleDefaultDataArray:(NSArray *)dataArray {
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    dataArray = [CMPShareManager filterShareTypeWithAppId:@"93" keys:dataArray];
    NSInteger count = dataArray.count;
    NSString *notShowIcons = @"";
    for (NSString *notShowIcon in self.mfr.notShowShareIcons) {
        notShowIcons = [notShowIcons stringByAppendingFormat:@"%@,",notShowIcon];
    }
    
    for (NSInteger i = 0; i < count; i++) {
        NSDictionary *dic = dataArray[i];
        CMPShareCellModel *model = [CMPShareCellModel yy_modelWithDictionary:dic];
        //显示icon的过滤筛选
        if ([notShowIcons containsString:model.key]) continue;
        if ([model.key isEqualToString:CMPShareComponentWechatString] && !WXApi.isWXAppInstalled) continue;
        if ([model.key isEqualToString:CMPShareComponentQQString] && !QQApiInterface.isQQInstalled) continue;
        if ([model.key isEqualToString:CMPShareComponentUCString] &&  !CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) continue;
        
        [tmpArr addObject:model];
    }
    return tmpArr;
}

#pragma mark - 加载数据

/**
 tell_meeting  //电话会议
 uc //致信
 qq //QQ
 wecaht //微信
 qiyeWechat //企业微信
 dingding //钉钉
 other //其他应用
 
 screen_display //屏幕镜像
 qr_code //生成二维码
 collect //收藏
 print //打印
 download //下载
 */
- (void)handleShareFileModel {
    NSMutableArray *topDataArr = [NSMutableArray array];
    NSMutableArray *bottomDataArr = [NSMutableArray array];
    NSArray *shareBtnList = self.shareFileModel.shareBtnList.copy;
    NSInteger count = shareBtnList.count;
    for (NSInteger i = 0; i < count; i++) {
        CMPShareBtnModel *m = shareBtnList[i];
        if ([kTopKeyList containsString:m.key]) {
            if ([m.key isEqualToString:CMPShareComponentTopScreenString]) {
                //负一屏
                if(!m.img && !m.img){
                    m.img = @"share_icon_rect_topScreen";
                }
                if (!m.title && !m.title.length) {
                    m.title = SY_STRING(@"my_second_floor");//@"我的二楼";
                }
            }else
            if ([m.key isEqualToString:CMPShareComponentUCString]) {
                //致信
                if (!CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) continue;
                
                m.img = @"share_icon_zhixin";
                m.title = SY_STRING(@"share_btn_my_colleague");
            }else if ([m.key isEqualToString:CMPShareComponentQQString]) {
                //qq
                if (!QQApiInterface.isQQInstalled) continue;
                
                m.img = @"share_icon_QQ";
                m.title = SY_STRING(@"share_btn_qq");
            }else if ([m.key isEqualToString:CMPShareComponentWechatString]) {
                //微信
                if (!CMPCommonTool.isInstalledWechat) continue;
                
                m.img = @"share_icon_wechat";
                m.title = SY_STRING(@"share_btn_wechat");
            }else if ([m.key isEqualToString:CMPShareComponentWWechatString]) {
                //企业维信
                if (!WWKApi.isAppInstalled) continue;
                
                m.img = @"share_icon_wwechat";
                m.title = SY_STRING(@"share_btn_wwechat");
            }else if ([m.key isEqualToString:CMPShareComponentDingtalkString]) {
                //钉钉
                if (!DTOpenAPI.isDingTalkInstalled) continue;
                
                m.img = @"share_icon_dingtalk";
                m.title = SY_STRING(@"share_btn_dingtalk");
            }else if ([m.key isEqualToString:CMPShareComponentOtherString]) {
                //其他应用
                m.img = @"share_icon_other_apps";
                m.title = SY_STRING(@"share_btn_other_app");
            }else if ([m.key isEqualToString:CMPShareComponentTelConfString]) {
                //电话会议
                m.img = @"share_icon_tel_confe";
                m.title = SY_STRING(@"share_btn_tel_confe");
            }
            
            if (m.title) {
                [topDataArr addObject:m];
            }
        }else {
            
            if ([m.key isEqualToString:CMPShareComponentScreenMirroringString]) {
                //无线投屏
                m.img = @"share_icon_screenMirrioring";
                m.title = SY_STRING(@"share_btn_screen_mirrioring");
            }else if ([m.key isEqualToString:CMPShareComponentQRCodeString]) {
                //二维码
                m.img = @"share_icon_qr_code";
                m.title = SY_STRING(@"share_btn_generate_qrcode");
            }else if ([m.key isEqualToString:CMPShareComponentCollectString]) {
                //收藏
                m.img = @"share_icon_collect";
                m.title = SY_STRING(@"share_btn_collect");
            }else if ([m.key isEqualToString:CMPShareComponentPrintString]) {
                //打印
                m.img = @"share_icon_print";
                m.title = SY_STRING(@"share_btn_print");
            }else if ([m.key isEqualToString:CMPShareComponentDownloadString]) {
                //下载
                m.img = @"share_icon_download";
                m.title = SY_STRING(@"share_btn_download");
            }
            
            if (m.title) {
                [bottomDataArr addObject:m];
            }
        }
    }
    
    _topDataArr = topDataArr.copy;
    _bottomDataArr = bottomDataArr.copy;
}


- (void)loadPlistData {
    NSString *path = [NSBundle.mainBundle pathForResource:CMPShareCollectionCellTopListPlist ofType:nil];
    if (path) {
        _topDataArr = [NSArray arrayWithContentsOfFile:path];
    }
    
    path = [NSBundle.mainBundle pathForResource:CMPShareCollectionCellBottomListPlist ofType:nil];
    if (path) {
        _bottomDataArr = [NSArray arrayWithContentsOfFile:path];
    }
    
}

#pragma mark - CMPShareCollectionViewDelegate

- (void)shareCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath shareCellModel:(CMPShareCellModel *)shareCellModel shareBtnModel:(CMPShareBtnModel *)shareBtnModel {
    DDLogDebug(@"");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isDefaultList) {
            NSString *filePath0 = self.mfr.filePath.copy;
            if (!filePath0) {
                return;
            }
            CMPShareManager *shareMgr = CMPShareManager.sharedManager;
            NSString *type = shareCellModel.key;
            if ([type isEqualToString:CMPShareComponentQQString]) {
                //qq
                [shareMgr shareToQQWithFilePath:filePath0];
            }else if ([type isEqualToString:CMPShareComponentWechatString]) {
                //微信
                [shareMgr shareToWechatWithFilePath:filePath0];
            }else if ([type isEqualToString:CMPShareComponentUCString]) {
                //致信
                [shareMgr shareToUcWithFilePaths:@[filePath0] commandDelegate:nil callbackId:nil showVc:self.pushVC];
            }else if ([type isEqualToString:CMPShareComponentWWechatString]) {
                //企业微信
                [shareMgr shareToWWechatWithFilePath:filePath0];
            }else if ([type isEqualToString:CMPShareComponentDingtalkString]) {
                //钉钉
                [shareMgr shareToDingtalkWithFilePath:filePath0];
            }else if ([type isEqualToString:CMPShareComponentOtherString]) {
                //打开系统分享
                [shareMgr shareToOtherWithFilePath:filePath0 showVc:self.pushVC];
            }else if ([type isEqualToString:CMPShareComponentDownloadString]) {
                //下载
                [shareMgr shareToDownloadWithFilePath:filePath0 from:self.mfr.from fromType:self.mfr.fromType fileId:self.mfr.fileId origin:self.mfr.origin];
            }else if ([type isEqualToString:CMPShareComponentCollectString]) {
                //收藏
                [shareMgr shareToCollectWithFilePath:filePath0 fileId:self.mfr.fileId isUc:self.isUc];
            }else if ([type isEqualToString:CMPShareComponentQRCodeString]) {
                //二维码
                
            }else if ([type isEqualToString:CMPShareComponentScreenMirroringString]) {
                //无线投屏
                [shareMgr shareToOpenScreenMirroring];
            }else if ([type isEqualToString:CMPShareComponentPrintString]) {
                //打印
                [shareMgr shareToPrintFileWithPath:filePath0 webview:self.webview];
                QK_AttchmentType type = [CMPFileManager getFileType:filePath0];
                if (type == QK_AttchmentType_Image
                    || type == QK_AttchmentType_Gif) {
                    return;//图片和gif的打印不退出分享页面，不然打印页面不能唤起
                }
            }
        }else if (self.ksCommonParams){
            if (self.ksCommonRsltBlk) {
                self.ksCommonRsltBlk(1, [shareBtnModel yy_modelToJSONObject], nil, nil);
            }
        }else {
            NSString *key = shareBtnModel.key;
            NSString *callbackId = self.shareFileModel.commandId;
            NSDictionary *dic = @{@"key" : key};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
            [self.shareFileModel.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
        //退出分享界面
        [self.viewController hideViewWithoutAnimation];
    });
}

#pragma mark - 外部方法

- (void)setMfr:(CMPFileManagementRecord *)mfr {
    _mfr = mfr;
    [self configSubViews];
}

-(instancetype)initWithFrame:(CGRect)frame ksCommonParams:(NSDictionary *)params ksCommonRsltBlk:(void(^)(NSInteger step,NSDictionary *actInfo, NSError *err, __nullable id ext))rsltBlk
{
    if (YBIBUtilities.isIphoneX) {
        frame.size.height += kIphoneXFitMargin;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.customBgColor = [UIColor cmp_colorWithName:@"gray-bgc"];
        self.cornerRadius = kDefaultCornerRadius;
        self.viewH = frame.size.height;
        _ksCommonRsltBlk = rsltBlk;
        self.ksCommonParams = params;
    }
    return self;
}
-(void)setKsCommonParams:(NSDictionary *)ksCommonParams
{
    _ksCommonParams = ksCommonParams;
    if (!_ksCommonParams) {
        if (_ksCommonRsltBlk) {
            _ksCommonRsltBlk(0,nil,[NSError errorWithDomain:@"params nil" code:-1 userInfo:nil],nil);
        }
        return;
    }
    NSArray *configs = _ksCommonParams[@"configs"];
    if (!configs || ![configs isKindOfClass:NSArray.class]) {
        if (_ksCommonRsltBlk) {
            _ksCommonRsltBlk(0,nil,[NSError errorWithDomain:@"params err" code:-2 userInfo:nil],nil);
        }
        return;
    }
    [self _ksHandleCommonConfigs:configs];
    [self removeAllSubviews];
    [self configSubViews];
}

- (void)_ksHandleCommonConfigs:(NSArray *)configs {
    NSMutableArray *topDataArr = [NSMutableArray array];
    NSMutableArray *bottomDataArr = [NSMutableArray array];
    NSArray *shareBtnList = configs.copy;
    NSInteger count = shareBtnList.count;
    for (NSInteger i = 0; i < count; i++) {
        id obj = shareBtnList[i];
        CMPShareBtnModel *m;
        if ([obj isKindOfClass:CMPShareBtnModel.class]) {
            m = obj;
        }else if ([obj isKindOfClass:NSDictionary.class]) {
            m = [CMPShareBtnModel yy_modelWithJSON:obj];
            if (!m) {
                //
            }
        }
        if (!m) {
            continue;
        }
        if ([kTopKeyList containsString:m.key]) {
            
            if ([m.key isEqualToString:CMPShareComponentTopScreenString]) {
                //负一屏
                m.img = @"share_icon_rect_topScreen";
                m.title = @"我的二楼";
            }else
            if ([m.key isEqualToString:CMPShareComponentUCString]) {
                //致信
                if (!CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) continue;
                
                m.img = @"share_icon_zhixin";
                m.title = SY_STRING(@"share_btn_my_colleague");
            }else if ([m.key isEqualToString:CMPShareComponentQQString]) {
                //qq
                if (!QQApiInterface.isQQInstalled) continue;
                
                m.img = @"share_icon_QQ";
                m.title = SY_STRING(@"share_btn_qq");
            }else if ([m.key isEqualToString:CMPShareComponentWechatString]) {
                //微信
                if (!CMPCommonTool.isInstalledWechat) continue;
                
                m.img = @"share_icon_wechat";
                m.title = SY_STRING(@"share_btn_wechat");
            }else if ([m.key isEqualToString:CMPShareComponentWechatTimelineString]) {
                //微信朋友圈
                if (!CMPCommonTool.isInstalledWechat) continue;
                
                m.img = @"share_icon_wechattimeline";
                m.title = SY_STRING(@"share_btn_wechattimeline");
            }else if ([m.key isEqualToString:CMPShareComponentWWechatString]) {
                //企业维信
                if (!WWKApi.isAppInstalled) continue;
                
                m.img = @"share_icon_wwechat";
                m.title = SY_STRING(@"share_btn_wwechat");
            }else if ([m.key isEqualToString:CMPShareComponentDingtalkString]) {
                //钉钉
                if (!DTOpenAPI.isDingTalkInstalled) continue;
                
                m.img = @"share_icon_dingtalk";
                m.title = SY_STRING(@"share_btn_dingtalk");
            }else if ([m.key isEqualToString:CMPShareComponentOtherString]) {
                //其他应用
                m.img = @"share_icon_other_apps";
                m.title = SY_STRING(@"share_btn_other_app");
            }else if ([m.key isEqualToString:CMPShareComponentTelConfString]) {
                //电话会议
                m.img = @"share_icon_tel_confe";
                m.title = SY_STRING(@"share_btn_tel_confe");
            }
            
            [topDataArr addObject:m];
        }else {
            
            if ([m.key isEqualToString:CMPShareComponentScreenMirroringString]) {
                //无线投屏
                m.img = @"share_icon_screenMirrioring";
                m.title = SY_STRING(@"share_btn_screen_mirrioring");
            }else if ([m.key isEqualToString:CMPShareComponentQRCodeString]) {
                //二维码
                m.img = @"share_icon_qr_code";
                m.title = SY_STRING(@"share_btn_generate_qrcode");
            }else if ([m.key isEqualToString:CMPShareComponentCollectString]) {
                //收藏
                m.img = @"share_icon_collect";
                m.title = SY_STRING(@"share_btn_collect");
            }else if ([m.key isEqualToString:CMPShareComponentPrintString]) {
                //打印
                m.img = @"share_icon_print";
                m.title = SY_STRING(@"share_btn_print");
            }else if ([m.key isEqualToString:CMPShareComponentDownloadString]) {
                //下载
                m.img = @"share_icon_download";
                m.title = SY_STRING(@"share_btn_download");
            }
            
            [bottomDataArr addObject:m];
        }
    }
    
    _topDataArr = topDataArr.copy;
    _bottomDataArr = bottomDataArr.copy;
}

@end
