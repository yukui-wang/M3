//
//  CMPRCChatViewController.m
//  CMPCore
//
//  Created by wujiansheng on 2017/6/22.
//
//

#import "CMPRCChatViewController.h"
#import "CMPChatManager.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPRCImageSlideController.h"
#import "RCMessageModel+Type.h"
#import "CMPUCSystemMessage.h"
#import "SyLocalOfflineFilesListViewController.h"
#import "SyFileProvider.h"
#import <CMPLib/CMPQuickLookPreviewController.h>
#import "CMPMessageManager.h"
#import <CMPLib/CMPPersonInfoUtils.h>
#import "AppDelegate.h"
#import "CMPTabBarViewController.h"
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/UIColor+Hex.h>
#import "CMPReadedMessage.h"
#import "RCTipLabel+Custom.h"
#import "CMPTipMessageCell.h"
#import "RCMessageContent+Custom.h"
#import "CMPFileStatusReceiptMessage.h"
#import "CMPFileStatusProvider.h"
#import "CMPRCUserListViewController.h"
#import "CMPRCGroupMemberObject.h"
#import "CMPRCV5Message.h"
#import "CMPSelectContactViewController.h"
#import <CMPLib/CMPWaterMarkUtil.h>
#import <CMPLib/CMPStringConst.h>
#import "CMPLoginConfigInfoModel.h"

#import "CMPChatSentFile.h"
#import "CMPRCTransmitMessage.h"
#import "CMPRCTransmitMessageCell.h"
#import "CMPRCGroupPrivilegeProvider.h"
#import "CMPCheckUpdateManager.h"
#import "CMPRCSystemImMessage.h"
#import "CMPRCConvertMissionCell.h"
#import "CMPRCShakeWinMessageCell.h"
#import "CMPRCShakeWinMessage.h"
#import "CMPRCUrgeMessageCell.h"
#import "CMPRCUrgeMessage.h"
#import "CMPTransferDataPlugin.h"
#import "CMPRCMissionHelper.h"
#import "CMPMyFilesViewController.h"
#import <CMPLib/CMPBannerWebViewController+Create.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/NSObject+FBKVOController.h>
#include <CMPLib/CMPReviewImagesTool.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPBannerNavigationBar.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/NSDate+CMPDate.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/RTL.h>
#import <CMPLib/CMPHorizontalMenuView.h>
#import <RongIMKit/RongIMKit.h>
#import "CMPCombineMessageCell.h"
#import "CMPBusinessCardMessageCell.h"
#import "CMPSignInMessageCell.h"
#import "CMPGeneralBusinessMessageCell.h"
#import <CMPLib/CMPChatChooseMemberViewController.h>
#import "CMPBusinessCardMessage.h"
#import "M3-Swift.h"
#import "RCForwardManager+SendProvider.h"
#import "CMPGeneralBusinessMessage.h"
#import <RongCallKit/RongCallKit.h>
#import <CMPLib/CMPActionSheet.h>
#import <CMPLib/CMPRuntimeUtils.h>
#import "CMPUnknownFolderMessageTipCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPSegmentView.h>
#import <AVFoundation/AVFoundation.h>
#import<MobileCoreServices/MobileCoreServices.h>
#import <CMPLib/CMPCameraViewController.h>
#import "CMPVideoMessage.h"
#import "CMPVideoMessageCell.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/NSData+Base64.h>
#import <CMPLib/CMPAVPlayerViewController.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import <CMPLib/CMPImagePickerController.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/FLAnimatedImage.h>
#import "RCIM+MediaMessages.h"
#import <CMPLib/CMPBannerBackButton.h>
#import <CMPLib/CMPAVPlayerDownloadView.h>
#import <CMPLib/CMPFeatureSupportControlHeader.h>
#import "CMPImageMessageCell.h"
#import "CMPRCGroupNotificationObject.h"
#import "RCIM+InfoCache.h"
#import <CMPLib/CMPScreenshotControlProtocol.h>
#import "CMPKanbanWebViewController.h"
#import <CMPLib/CMPSegScrollView.h>
#import "CMPQuoteMessageCell.h"
#import "CMPRCQuotingShowView.h"
#import "CMPShareManager.h"
#import "CMPLocationMapViewController.h"
#import "RCMessageCell+CMP.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPUnkonwnMessageTypeCell.h"

#import "CMPRobotMessageCell.h"
#import "CMPRobotMsg.h"
#import "CMPRobotAtMsg.h"
#import "CMPClearMsg.h"

#import "CMPMessageFilterManager.h"
#import "CMPAttachmentHelper.h"
#import "CMPRCChatViewModel.h"
#import "CMPMeetingManager.h"
#import "CustomDefine.h"
#import "CMPCommonManager.h"
#import <CMPLib/CMPThreadSafeMutableArray.h>

static NSInteger const kPluginBoardItemFile = 10000; // 文件tag
static NSInteger const kPluginBoardItemCollection = 10002; //收藏tag
static NSInteger const kPluginBoardItemAssociatedDocument = 10003; //关联文档tag
static NSInteger const kPluginBoardItemBusinessCard = 10004; //名片tag
static NSInteger const kPluginBoardItemPicture = 10005; //图片tag,包括相册,拍照
static NSInteger const kPluginBoardItemVoiceAndVideoCall = 10006; //音视频通话tag,包括语音,视频通话

static NSInteger const kPluginBoardItemQuickColl = 10007; //新建协同tag
static NSInteger const kPluginBoardItemFormTemplate = 10008; //表单模板tag
static NSInteger const kPluginBoardItemQuickMeetting = 10009; //新建会议tag
static NSInteger const kPluginBoardItemQuickTask = 10010; //新建任务tag
static NSInteger const kPluginBoardItemQuickSchedule = 10011; //新建日程tag
static NSInteger const kPluginBoardItemQuickZhumuMeetting = 10012; //瞩目会议tag

static NSInteger const kPluginVoiceCall = 1101;//语音通话
static NSInteger const kPluginVideoCall = 1102;//视频通话


@interface CMPRCChatViewController ()<CMPDataProviderDelegate, SyLocalOfflineFilesListViewControllerDelegate, RCSelectingUserDataSource,RCIMGroupMemberDataSource,UIDocumentPickerDelegate,CMPMyFilesViewControllerDelegate,CMPChatChooseBusinessControllerDelegate,CMPScreenshotControlProtocol,CMPSegScrollViewDelegate,YBImageBrowserDelegate>
{
    BOOL _pushView;
    BOOL _isClearMessage; // 标记是否需要清空消息记录
    BOOL _isSendMessage; // 标记是否发送过消息
    BOOL _isReceiveMessage; // 标记是否收到过消息
    NSMutableDictionary *_listenerMap; // 存储上传图片监听器RCUploadMediaStatusListener，messageID为key
    CMPThreadSafeMutableArray *_uploadRequestIDs;
    NSMutableDictionary *_uploadRequestMap; // 消息UID与requestId的对应map
    NSString *_deleteRequestID;
    NSString *_checkFileRequestID;
    RCMessageModel * _quotedMessageModel;
    CMPRCQuotingShowView *_quotingShowView;
    id _currentReeditModel;
    /** 是否显示群主岗 **/
    __block BOOL _isShowMemberPost;
    CMPSegScrollView *_segScrollView;
    BOOL _isServerLater8_1;
}

//
@property(nonatomic, strong) RCMessageModel *curSelectedModel;
@property (strong, nonatomic) CMPRCGroupPrivilegeProvider *groupPrivilegeProvider;
@property (strong, nonatomic) CMPRCGroupPrivilegeModel *filePrivilege;

@property (strong, nonatomic) CMPBannerNavigationBar *bannerNavigationBar;
@property (strong, nonatomic) UIView *statusBar;

@property (copy, nonatomic) NSString *getTargetPersonalVoIPPermissionRequestID;//音视频权限
@property (copy, nonatomic) NSString *getTargetGroupVoIPPermissionRequestID;
@property (copy, nonatomic) NSString *getGroupKanbanInfoRequestID;
@property (copy, nonatomic) NSString *getZhumuPluginPermissionRequestID;
@property (copy, nonatomic) NSArray  *haveVoIPPermissionUserIdlist;

@property (assign, nonatomic)CGFloat inputTextViewPreX;
@property (assign, nonatomic)CGFloat inputTextViewPreWidth;

@property (nonatomic,strong) CMPHorizontalMenuView *messageSelectionMenuView;
@property (nonatomic,weak) CMPActionSheet *actionSheet;

/* 发送文件数组 */
@property (strong, nonatomic) NSMutableArray *sentFiles;

@property (nonatomic, assign) BOOL isUpdatedPluginBoardItem;

/*
 获取应用消息权限
 */
@property (strong, nonatomic) NSCache<NSString *,NSOperation*> *requestBusinessMessagesPermissionCache;
@property (strong, nonatomic)NSOperationQueue *requestBusinessMessagesPermissionCacheQueue;
@property (strong,nonatomic)NSMutableDictionary *quickProcessCacheDic;

@property (copy, nonatomic) NSString *titleContent;

@property (strong,nonatomic) CMPDownloadAttachmentTool *downloadTool;

@property (assign,nonatomic) BOOL isUcGroupBoardSettingDidChanged;
@property (weak,nonatomic) CMPSegmentView *segmentView;
@property (nonatomic, strong) NSMutableDictionary *currentChildVCs;

@property (nonatomic,strong) NSMutableDictionary *extendGroupMemberInfoDic;
@property (nonatomic,strong) CMPRCChatViewModel *viewModel;
@property (nonatomic,strong) UIButton *onlineButton;

@property (assign,nonatomic) NSInteger uploadImagesCount;
@property (assign,nonatomic) NSInteger sendImagesCount;

@end

@implementation CMPRCChatViewController

#pragma mark-

#pragma mark 懒加载

-(NSMutableDictionary *)extendGroupMemberInfoDic
{
    if (!_extendGroupMemberInfoDic) {
        _extendGroupMemberInfoDic = [[NSMutableDictionary alloc] init];
    }
    return _extendGroupMemberInfoDic;
}

- (NSMutableArray *)sentFiles {
    if (!_sentFiles) {
        _sentFiles = [NSMutableArray array];
    }
    return _sentFiles;
}

- (CMPDownloadAttachmentTool *)downloadTool {
    if (!_downloadTool) {
        _downloadTool = [[CMPDownloadAttachmentTool alloc] init];
    }
    return _downloadTool;
}


#pragma mark-Life Cycle

- (void)dealloc {
    CMPFuncLog;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [CMPSelectContactViewController cleanStatic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCellClasses];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    // 当收到的消息超过一个屏幕时，进入会话之后，在右上角提示上方存在的未读消息数
    self.enableUnreadMessageIcon = YES;
    // 当前阅读区域的下方收到消息时，在会话页面的右下角提示下方存在未读消息
    self.enableNewComingMessageIcon = YES;
    _isServerLater8_1 = [CMPServerVersionUtils serverIsLaterV8_1];
    // 文件助手关闭阅读回执显示
    if ([CMPCore sharedInstance].serverIsLaterV7_1 && [self.targetId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        
        [[RCIM sharedRCIM] setEnabledReadReceiptConversationTypeList:nil];
        
    }else{
        
         [[RCIM sharedRCIM] setEnabledReadReceiptConversationTypeList:@[@(ConversationType_PRIVATE)]];
    }
    
    [self addNotis];
    
    [self setupNaviBar];
    [self addRightBarButton];
    [self setBackButton];
    
    [self setupGroupKanbanTool];
    
//    [self registerClass:[CMPTipMessageCell class] forMessageClass:[RCGroupNotificationMessage class]];
    
    if (!_uploadRequestIDs) {
        _uploadRequestIDs = [[CMPThreadSafeMutableArray alloc] init];
    }
    if (!_uploadRequestMap) {
        _uploadRequestMap = [[NSMutableDictionary alloc] init];
    }
    [CMPChatManager sharedManager].currentGroupId = self.targetId;
    // 刷新群组人员信息（获取跨单位人员名字）
    
   // [[CMPChatManager sharedManager] refreshGroupUserInfo:self.targetId];
    
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
    self.conversationMessageCollectionView.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
    
    [[CMPMessageManager sharedManager] addWaterMarkToView:self.conversationMessageCollectionView];
    
    [[RCIM sharedRCIM] setGroupMemberDataSource:self];
    
    [self checkTargetVoIPPermission];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*融云需关闭小致，以修复 OA-161007（致信）开着小致的时候致信语音发不出去，一直提示时间过短*/
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_RCChatWillShow object:nil];
    [self setValue:@YES forKey:@"isConversationAppear"];
    //[super viewWillAppear:animated];
    
    CMPAppDelegate *aAppDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
    //aAppDelegate.onlyPortrait = YES;
    aAppDelegate.allowRotation = NO;
    if (!aAppDelegate.allowRotation) {
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
    
    //防止焦点丢失
    [self becomeFirstResponder];
    self.navigationController.navigationBarHidden = YES;
    _pushView = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    // 在群设置页面点击了清空聊天记录清空消息
    if (_isClearMessage) {
        [self clearMsg];
    }
    
    if (self.unReadMessage > 0) {
        //#pragma clang diagnostic push
        //#pragma clang diagnostic ignored "-Wundeclared-selector"
        //        if ([self respondsToSelector:@selector(syncReadStatus)] &&
        //            [self respondsToSelector:@selector(sendReadReceipt)]) {
        //            [self performSelector:@selector(syncReadStatus)];
        //            [self performSelector:@selector(sendReadReceipt)];
        //        }
        //#pragma clang diagnostic pop
        [[CMPChatManager sharedManager] sendReadedMessageWithType:self.conversationType targetId:self.targetId];
    }
    
    if (self.isUcGroupBoardSettingDidChanged) {
        self.isUcGroupBoardSettingDidChanged = NO;
        [self setupGroupKanbanTool];
    }
    
    //发送多文件分享过来的文件
    [self sendFiesWtihFilePaths];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    RCTextView *inputTextView = self.chatSessionInputBarControl.inputTextView;
    if (self.inputTextViewPreX != inputTextView.cmp_x || self.inputTextViewPreWidth !=inputTextView.cmp_width) {
        [inputTextView resetFrameToFitRTL];
        self.inputTextViewPreX = inputTextView.cmp_x;
        self.inputTextViewPreWidth = inputTextView.cmp_width;
    }
    
    //修复iPad在系统为暗黑模式时融云cell内容宽度超过cell宽度的bug
    if (INTERFACE_IS_PAD) {
       [self.conversationMessageCollectionView reloadItemsAtIndexPaths:[self.conversationMessageCollectionView indexPathsForVisibleItems]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isUpdatedPluginBoardItem) {
        self.isUpdatedPluginBoardItem = YES;
        [self updatePluginBoardItem];
        [self checkFilePrivilege];
        [self checkQuickNewEntryPrivilege];
        //[self checkZhumuPermission];
    }
    [self _updateGroupInfo];
    [self _actOnlineStatusTask];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = YES;
        
//    CMPAppDelegate *aAppDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
//    aAppDelegate.onlyPortrait = NO;
    
    if (_isSendMessage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    /*融云需关闭小致，以修复 OA-161007（致信）开着小致的时候致信语音发不出去，一直提示时间过短*/
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_RCChatWillHide object:nil];
}

- (void)addNotis {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(setClearMessageFlag)
                                                  name:kNotificationName_ClearRCGroupMsg
                                                object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(groupNameChanged:)
                                                  name:kNotificationName_ChangeGroupName
                                                object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(receiveMessageNotification:)
                                                  name:RCKitDispatchMessageNotification
                                                object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(membersChanged:)
                                                  name:CMPRCGroupNotificationNameMembersChanged
                                                object:nil];

     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(deleteMessageNotification:)
                                                  name:@"RC_DeleteMsg"
                                                object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageBaseCellUpdateSendingStatus:) name:KNotificationMessageBaseCellUpdateSendingStatus
                                               object:nil];
    
    //图片组件  删除图片消息
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(delteSelectedRcImgModelsPicNoti:)
                                               name:CMPDelteSelectedRcImgModelsPicNoti
                                             object:nil];
    //图片组件 转发
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(ybImageBrowserForwardNoti:)
                                               name:CMPYBImageBrowserForwardNoti
                                             object:nil];
    //群看板设置发生变化u
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(ucGroupBoardSettingDidChangedNoti:)
                                               name:CMPUcGroupBoardSettingDidChanged
                                             object:nil];
    
    //刷新页面
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(willReloadTabBarClearViewNotificationAction:)
                                               name:CMPWillReloadTabBarClearViewNotification
                                             object:nil];
    
    //ks add -- 监听输入板的状态变化,V5-44093【客户端安全】M3移动客户端聊天文件管控绕过
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(bottomBarStatusWillChange:)
                                               name:@"kNotificationName_rcBottomBarStatusWillChange"
                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidUpdate:) name:kNotificationName_MessageUpdate object:nil];
    
}

- (void)registerCellClasses {
    //转发业务消息
    [self registerClass:[CMPRCTransmitMessageCell class] forMessageClass:[CMPRCTransmitMessage class]];
    //消息转为任务
    [self registerClass:[CMPRCConvertMissionCell class] forMessageClass:[CMPRCSystemImMessage class]];
    //窗口抖动消息
    [self registerClass:[CMPRCShakeWinMessageCell class] forMessageClass:[CMPRCShakeWinMessage class]];
    //催办任务消息
    [self registerClass:[CMPRCUrgeMessageCell class] forMessageClass:[CMPRCUrgeMessage class]];
    //自定义合并消息转发
    [self registerClass:[CMPCombineMessageCell class] forMessageClass:[CMPCombineMessage class]];
    //自定义人员卡片消息
    [self registerClass:[CMPBusinessCardMessageCell class] forMessageClass:[CMPBusinessCardMessage class]];
    //自定义业务卡片消息
    [self registerClass:[CMPGeneralBusinessMessageCell class] forMessageClass:[CMPGeneralBusinessMessage class]];
    //自定义文件夹提示消息
    [self registerClass:[CMPUnknownFolderMessageTipCell class] forMessageClass:[CMPFolderMessage class]];
    [self registerClass:[CMPUnknownFolderMessageTipCell class] forMessageClass:[CMPRCFolderMessage class]];
    //机器人消息
    [self registerClass:[CMPRobotMessageCell class] forMessageClass:[CMPRobotMsg class]];
    //删除消息（自定义类型）
    [self registerClass:[CMPRobotMessageCell class] forMessageClass:[CMPClearMsg class]];
    
    //机器人@消息
    [self registerClass:[CMPTextMessageCell class] forMessageClass:[CMPRobotAtMsg class]];
    //自定义视频消息
    [self registerClass:[CMPVideoMessageCell class] forMessageClass:[CMPVideoMessage class]];
    //自定义签到消息
    [self registerClass:[CMPSignInMessageCell class] forMessageClass:[CMPSignMessage class]];
    //自定义图片消息,去掉箭头
    [self registerClass:[CMPImageMessageCell class] forMessageClass:[RCImageMessage class]];
    //引用回复消息
    [self registerClass:[CMPQuoteMessageCell class] forMessageClass:[CMPQuoteMessage class]];
    //文本消息
    [self registerClass:[CMPTextMessageCell class] forMessageClass:[RCTextMessage class]];
    
}
#pragma mark 通知相关

-(void)messageDidUpdate:(NSNotification *)noti
{
    id obj = noti.object;
    if (obj && [@"removeCon" isEqualToString:obj[@"action"]]) {
        NSString *targetId = [NSString stringWithFormat:@"%@",obj[@"cid"]];
        if ([targetId isEqualToString:self.targetId]) {
            [self clearMsg];
        }
        return;
    }
}

/// 删除选中图片通知处理
- (void)delteSelectedRcImgModelsPicNoti:(NSNotification *)noti {
    NSArray *arr = noti.object;
    if (![arr isKindOfClass: NSArray.class]) {
        NSLog(@"删除图片失败，传入的参数有误，不是数组");
        return;
    }
    
    for (RCMessageModel *model in arr) {
        [self deleteMessage:model];
    }
}

#pragma mark 图片组件转发图片
/// 图片组件转发图片
/// @param noti dic  { "dataArray" : 图片的消息数组, "vc" : 要显示在哪个vc上 }
- (void)ybImageBrowserForwardNoti:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    if (![dic isKindOfClass: NSDictionary.class]) {
        return;
    }
    
    NSArray *arr = dic[@"dataArray"];
    UIViewController *vc = dic[@"vc"];
    
    self.chatSessionInputBarControl.inputTextView.disableActionMenu = NO;
    NSArray *selectedMessage = [arr copy];
    CMPSelectContactViewController *selectVC = [[CMPSelectContactViewController alloc] init];
    selectVC.conversationType = self.conversationType;
    selectVC.targetId = self.targetId;
    selectVC.forwardSource = CMPForwardSourceTypeSingleMessages;
    selectVC.selectedMessages = selectedMessage;
    __weak typeof(self) weakSelf = self;
    selectVC.getSelectContactFinishBlock = ^(NSArray *conversationList) {
        if (conversationList) {
            NSMutableArray *mutableConversationList = [conversationList mutableCopy];
            [mutableConversationList removeLastObject];
            conversationList = [mutableConversationList copy];
                 
            [[RCForwardManager sharedInstance] doForwardMessageList:selectedMessage conversationList:conversationList isCombine:NO forwardConversationType:weakSelf.conversationType completed:^(BOOL success) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidOneByOneForwardSucess object:nil];
                    [vc dismissViewControllerAnimated:NO completion:^{
                        [MBProgressHUD cmp_showSuccessHUDWithText:SY_STRING(@"share_component_share_finished_tips")];
                    }];
                }
            }];
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            [weakSelf performSelector:@selector(forwardMessageEnd)];
            #pragma clang diagnostic pop
        }
    };
    
    selectVC.willForwardMsg = ^(NSString *targetId) {
        [weakSelf handleWillForwardMsg:targetId];
    };
    
    CMPNavigationController *nav = [CMPNavigationController.alloc initWithRootViewController:selectVC];
    [vc presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - 自定义多选底部菜单

- (CMPHorizontalMenuView *)messageSelectionMenuView {
    if (!_messageSelectionMenuView) {
        _messageSelectionMenuView = [[CMPHorizontalMenuView alloc] init];
        _messageSelectionMenuView.pageControlStyle = CMPHorizontalMenuViewPageControlStyleClassic;
        _messageSelectionMenuView.currentPageDotColor = [UIColor colorWithRed:41/255.0 green:127/255.0 blue:251/255.0 alpha:1.0];
        _messageSelectionMenuView.pageDotColor = [_messageSelectionMenuView.currentPageDotColor colorWithAlphaComponent:0.44];
        _messageSelectionMenuView.pageControlBottomOffset = 8;
        
        CMPHorizontalMenuItem *item1 = [[CMPHorizontalMenuItem alloc] initWithItemTile:SY_STRING(@"rc_single_messages_forward") itemIconTitle:@"single_forward" target:self action:@selector(singleForwardMessages)];
        CMPHorizontalMenuItem *item2 = [[CMPHorizontalMenuItem alloc] initWithItemTile:SY_STRING(@"rc_merge_message_forward") itemIconTitle:@"combine_forward" target:self action:@selector(combineForwardMessages)];
        CMPHorizontalMenuItem *item3 = [[CMPHorizontalMenuItem alloc] initWithItemTile:SY_STRING(@"rc_transfer_opinoin") itemIconTitle:@"turn_opinion" target:self action:@selector(turnOnOpinion)];
        CMPHorizontalMenuItem *item4 = [[CMPHorizontalMenuItem alloc] initWithItemTile:SY_STRING(@"share_btn_collect") itemIconTitle:@"selection_collection" target:self action:@selector(collectionChatRecord)];
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        CMPHorizontalMenuItem *item5 = [[CMPHorizontalMenuItem alloc] initWithItemTile:SY_STRING(@"common_delete") itemIconTitle:@"delete_messages" target:self action:@selector(deleteMessages)];
        #pragma clang diagnostic pop
        if([CMPFeatureSupportControl isSupportCollect]) {
            _messageSelectionMenuView.menuItems = @[item1,item2,item3,item4,item5];
        }
        else {
            _messageSelectionMenuView.menuItems = @[item1,item2,item3,item5];
        }
    }
    return _messageSelectionMenuView;
}

- (void)singleForwardMessages {
//    if ([self isSupportSingleForward]) {
//        [self forwardMessageType:0];
//        return;
//    }
//    [self cmp_showHUDWithText:SY_STRING(@"rc_msg_single_forward_tip")];
    
    [self forwardMessageType:0];
}

- (void)combineForwardMessages {
//    if ([self isSupportCombineForward]) {
//        [self forwardMessageType:1];
//        return;
//    }
//    [self cmp_showHUDWithText:SY_STRING(@"rc_msg_combine_forward_tip")];
    
    [self forwardMessageType:1];
}

- (void)turnOnOpinion {
//    if ([self isSupportCombineForward]) {
//        [self turnOnOpinionWithMessageList:[self.selectedMessages copy]];
//        return;
//    }
//    [self cmp_showHUDWithText:SY_STRING(@"rc_msg_turn_on_opinione_tip")];
    
    [self turnOnOpinionWithMessageList:[self.selectedMessages copy]];
}

- (void)collectionChatRecord {
//    if ([self isSupportCombineForward]) {
//        [self collectionChatRecordWithMessageList:[self.selectedMessages copy]];
//        return;
//    }
//    [self cmp_showHUDWithText:SY_STRING(@"rc_msg_collection_chat_record_tip")];
    
    [self collectionChatRecordWithMessageList:[self.selectedMessages copy]];
}

- (void)turnOnOpinionWithMessageList:(NSArray *)messageList {
    if (self.selectedMessages.count == 0) {
        return;
    }
    self.allowsMessageCellSelection = NO;
    [[RCForwardManager sharedInstance] turnOnOpinion:messageList targetId:self.targetId forwardConversationType:self.conversationType completion:^(NSString * _Nonnull chatContentId, NSError * _Nonnull error) {
        if ([NSString isNotNull:chatContentId]) {
            NSDictionary *paramDic = @{
                @"referType" : @"61",
                @"referId" : chatContentId
            };
            CMPBannerWebViewController *controller = [CMPBannerWebViewController bannerWebView1WithUrl:@"http://todo.m3.cmp/v1.0.0/layout/app-accDoc.html" params:paramDic];
            [self pushInDetailWithViewController:controller];
        }
    }];
}

- (void)collectionChatRecordWithMessageList:(NSArray *)messageList {
    if (self.selectedMessages.count == 0) {
        return;
    }
    self.allowsMessageCellSelection = NO;
//    if (messageList.count == 1) {
//        RCMessageModel *msgModel = messageList.firstObject;
//        if ([msgModel isFileMessage]) {
//            //ks add 走文件收藏逻辑
//            RCFileMessage *msg = (RCFileMessage *)msgModel.content;
//            [[CMPShareManager sharedManager] shareToCollectWithFilePath:((RCFileMessage *)msgModel.content).localPath fileId:msg.fileUrl isUc:YES];
//            return;
//        }
//    }
    [[RCForwardManager sharedInstance] collectionChatRecord:messageList targetId:self.targetId forwardConversationType:self.conversationType completion:^(NSString * _Nonnull chatContentId, NSError * _Nonnull error) {
        if ([NSString isNotNull:chatContentId]) {
            [self cmp_showSuccessHUDWithText:SY_STRING(@"rc_msg_collection_handel_success")];
        } else {
            [self cmp_showHUDWithText:SY_STRING(@"rc_msg_collection_handel_fail")];
        }
    }];
}

- (void)forwardMessageType:(NSInteger)type {
    if (self.selectedMessages.count == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self forwardMessage:type completed:^(NSArray<RCConversation *> *conversationList) {
        NSArray *selectedMessage = [NSArray arrayWithArray:weakSelf.selectedMessages];
        if (conversationList) {
            if (type == 0) {
                NSMutableArray *mutableConversationList = [conversationList mutableCopy];
                [mutableConversationList removeLastObject];
                conversationList = [mutableConversationList copy];
                
            }
            [[RCForwardManager sharedInstance] doForwardMessageList:selectedMessage conversationList:conversationList isCombine:type == 0 ? NO : YES forwardConversationType:weakSelf.conversationType completed:^(BOOL success) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
                }
            }];
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            [weakSelf performSelector:@selector(forwardMessageEnd)];
            #pragma clang diagnostic pop
            
            //ks fix V5-9969 iOS端M3的群文件，从A群转发到B群，B群的群文件里不显示该文件
            for (RCMessageModel *msgModel in selectedMessage) {
                if ([msgModel isFileMessage] || [msgModel isVideoMessage]) {
                    RCFileMessage *fileMsg = (RCFileMessage *)(msgModel.content);
                    [[CMPChatManager sharedManager] forwardFile:fileMsg.remoteUrl type:0 target:conversationList.firstObject.targetId completion:^(id result, NSError *error) {
                                            
                    }];
                }
            }
        }
    }];
}

- (void)forwardMessage:(NSInteger)index completed:(void (^)(NSArray<RCConversation *> *))completedBlock {
    [self showForwardMessageViewToForwardSelectMessageWithIsCombineForward:index == 1 ? YES : NO getSelectContactFinishBlock:^(NSArray *conversationList) {
        completedBlock(conversationList);
    }];
}

#pragma mark - RCIMGroupMemberDataSource

- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray<NSString *> *userIdList))resultBlock {
    if (!self.haveVoIPPermissionUserIdlist) {
        [self getTargetGroupVoIPPermission:^(NSArray *userList) {
            resultBlock([userList copy]);
        }];
        return;
    }
    resultBlock([self.haveVoIPPermissionUserIdlist copy]);
}

#pragma mark-
#pragma mark-按钮点击事件

- (void)showGroupDetail:(id)sender
{
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    [[CMPChatManager sharedManager] refreshGroupUserInfo:self.targetId];
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:@"http://uc.v5.cmp/v1.0.0/html/ucGroupInfoPage.html"]];
    localHref = [localHref appendHtmlUrlParam:@"targetGroupId" value:self.targetId];
    localHref = [localHref appendHtmlUrlParam:@"userId" value:[CMPCore sharedInstance].userID];
    aCMPBannerViewController.startPage = localHref;
    aCMPBannerViewController.hideBannerNavBar = YES;
    aCMPBannerViewController.backBarButtonItemHidden = YES;
    [self.navigationController pushViewController:aCMPBannerViewController animated:YES];
    
    [self.extendGroupMemberInfoDic removeAllObjects];
}

- (void)showPeopleDetail:(id)sender {
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:@"http://uc.v5.cmp/v1.0.0/html/ucChatDetailPage.html"]];
    localHref = [localHref appendHtmlUrlParam:@"targetId" value:self.targetId];
    localHref = [localHref appendHtmlUrlParam:@"userId" value:self.targetId];
    localHref = [localHref appendHtmlUrlParam:@"userName" value:self.title];
    
    aCMPBannerViewController.startPage = [localHref urlCFEncoded];
    aCMPBannerViewController.hideBannerNavBar = YES;
    aCMPBannerViewController.backBarButtonItemHidden = YES;
    [self.navigationController pushViewController:aCMPBannerViewController animated:YES];
}

-(void)ontimeMeetingAct:(UIButton *)btn
{
    weakify(self);
    void(^blk)(void) = ^{
        strongify(self);
        NSString *type = self.conversationType == ConversationType_GROUP ? MeetingOtmCreateFromZxType_Group : MeetingOtmCreateFromZxType_Personal;
        [[CMPMeetingManager shareInstance] otmBeginMeetingWithMids:@[self.targetId] onVC:self from:MeetingOtmCreateFrom_Zx ext:@{@"type":type,@"tid":self.targetId,@"tname":self.titleContent} completion:^(id  _Nonnull rslt, NSError * _Nonnull err, id  _Nonnull ext, NSInteger step) {
                
        }];
    };
//    CMPAlertViewController *ac = [CMPAlertViewController alertControllerWithTitle:nil message:@"您确定要发起即时会议吗?" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        blk();
//    }];
//    [ac addAction:cancel];
//    [ac addAction:sure];
//
//    [self presentViewController:ac animated:YES completion:^{
//
//    }];
}

- (void)backBarButtonPressed:(UIButton *)sender {

//    if (_isSendMessage) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
//    }
    [CMPChatManager sharedManager].currentGroupId = nil;
   
    UIViewController *viewcontroller = [self.navigationController popViewControllerAnimated:YES];
    if (!_pushView) {
        self.navigationController.navigationBarHidden = YES;
    }
    if (_isReceiveMessage) {
        [self clearUnread];
    }
    if (!viewcontroller) {
        if (self.navigationController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark-
#pragma mark-重载RCConversationViewController

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath byMessageModel:(RCMessageModel *)messageModel{
    [self getQuickProcessWithCell:cell atIndexPath:indexPath];
    [self handleReeditDisplayMessageCell:cell];
    
    //防止CMPVideoMessageCell重用,造成下载进度重用的问题,及重用问题导致的播放图标不显示
    if ([cell isMemberOfClass:[CMPVideoMessageCell class]]) {
        [cell setValue:@"CMPVideoMessageCell" forKey:@"reuseIdentifier"];
    }
    
    if (_isServerLater8_1) {
        if (self.conversationType == ConversationType_GROUP) {
            //开关设置状态
            BOOL isShowPost = _isShowMemberPost;
            if (isShowPost) {
                if ([cell isKindOfClass:[RCMessageCell class]]) {
                    NSString *senderId = messageModel.senderUserId;
                    __block id senderInfo = self.groupInfo.membersDic[senderId];
                    if (!senderInfo) {
                        senderInfo = self.extendGroupMemberInfoDic[senderId];
                        if (!senderInfo) {
                            //ks fix 为了节省性能还不愿意 那就改吧
    //                        if (self.conversationMessageCollectionView.dragging == NO && self.conversationMessageCollectionView.decelerating == NO)
    //                        {
                            [self _fetchMemberOrgStateByMid:senderId completion:^(id result, NSError *error) {
                                if (!error) {
                                    __weak typeof(self) wSelf = self;
                                    [UIView performWithoutAnimation:^{
                                        //ks fix 为了节省性能还不愿意 那就改吧
                                        [wSelf.conversationMessageCollectionView reloadData];
    //                                        [wSelf.conversationMessageCollectionView reloadItemsAtIndexPaths:wSelf.conversationMessageCollectionView.indexPathsForVisibleItems];
                                    }];
                                }
                            }];
    //                        }
                        }
                    }
                    if (senderInfo) {
                        ((RCMessageCell *)cell).serverSenderInfo = senderInfo;
                    }
                }
            }else{
                if ([cell isKindOfClass:[RCMessageCell class]]) {
                    ((RCMessageCell *)cell).serverSenderInfo = nil;
                }
            }
        }
    }
    
    [self handleAllowsSelectionWithMessageCell:cell model:messageModel];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _loadExtendInfoForVisibleCells];
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self _loadExtendInfoForVisibleCells];
    }
}

-(void)_loadExtendInfoForVisibleCells
{
    if (!_isServerLater8_1) {
        return;
    }
    __weak typeof(self) wSelf = self;
    [self dispatchSyncToMain:^{
        NSArray *visibleIndexPaths = (wSelf.conversationMessageCollectionView.indexPathsForVisibleItems).reverseObjectEnumerator.allObjects;
        if (visibleIndexPaths.count == 0) {
            return;
        }
        NSMutableSet *set1 = [NSMutableSet setWithArray:visibleIndexPaths];
//        NSIndexPath *fir = visibleIndexPaths.firstObject;
//        NSIndexPath *las = visibleIndexPaths.lastObject;
//        int sp = 10;
//        NSInteger firIndex = fir.row;
//        NSInteger limitStartIndex = (firIndex-(sp-1))>0?:0;
//        for (int i=limitStartIndex; i<firIndex; i++) {
//            [set1 addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//        }
//        NSInteger limitLastIndex = (((self.conversationDataRepository.count-1)-las.row)<sp)?(self.conversationDataRepository.count-1):(las.row+sp);
//        for (int i=las.row+1; i<=limitLastIndex; i++) {
//            [set1 addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//        }
        for (NSIndexPath *indexPath in set1.allObjects
             ) {
            UICollectionViewCell *cell = [wSelf.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
            if ([cell isKindOfClass:[RCMessageCell class]]&&![cell isKindOfClass:[RCTipMessageCell class]]) {
                RCMessageCell *rccell = (RCMessageCell *)cell;
                RCMessageModel *model = rccell.model;
                RCUserInfo *userInfo = model.userInfo;
                rccell.nicknameLabel.hidden = !model.isDisplayNickname;
                NSString *s1 = @""; NSString *s2 = @"";
                if (userInfo) {
                    s1 = userInfo.name;
                }
                if (self->_isShowMemberPost) {
                    NSString *senderId = model.senderUserId;
                    __block id senderInfo = wSelf.groupInfo.membersDic[senderId];
                    if (!senderInfo) {
                        senderInfo = self.extendGroupMemberInfoDic[senderId];
                        if (!senderInfo) {
                            [wSelf _fetchMemberOrgStateByMid:senderId completion:^(id result, NSError *error) {
                                if (!error) {
                                    [UIView performWithoutAnimation:^{
                                        //ks fix 为了节省性能还不愿意 那就改吧
                                        [wSelf.conversationMessageCollectionView reloadData];
//                                        [wSelf.conversationMessageCollectionView reloadItemsAtIndexPaths:wSelf.conversationMessageCollectionView.indexPathsForVisibleItems];
                                    }];
                                }
                            }];
                            return;
                        }
                    }
                    if (senderInfo && senderInfo[@"postName"]) {
                        s2 = senderInfo[@"postName"];
                     }
                }
                if (s1.length>10 && s2.length) {
                    s1 = [s1 substringToIndex:10];
                }
                if (s2.length>12 && s1.length) {
                    s2 = [s2 substringToIndex:12];
                }
                [rccell.nicknameLabel setText:[NSString stringWithFormat:@"%@ %@",s1,s2]];
            }
        }
    }];
}


-(void)_fetchMemberOrgStateByMid:(NSString *)mid completion:(void (^)(id result,NSError *error))completion
{
    if (!mid || mid.length == 0) {
        return;
    }
    __weak typeof(self) wSelf = self;
    [[CMPChatManager sharedManager] getMemberOrgStatusByMid:mid completion:^(id result, NSError *error) {
        if (!error) {
            NSString *state = result[@"state"],*mid = result[@"mid"];
            NSDictionary *infoDic =  @{@"postName":([state isEqualToString:@"2"] ? @"已离职":@"已退群"),@"id":mid};
            [wSelf.extendGroupMemberInfoDic setObject:infoDic forKey:mid];
        }
        if (completion) {
            completion(result,error);
        }
    }];
}

//处理重新加载点击事件
- (void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber model:(RCMessageModel *)model {
    
    NSDictionary *extraDic = [model.extra JSONValue];
    if (extraDic) {
        
        BOOL isNeedReedit = [extraDic[@"isCanReedit"] boolValue];
        if (isNeedReedit) {
            
            if ([phoneNumber hasPrefix:@"tel://"]) {
                
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"tel://" withString:@""];
                
            }
            self.chatSessionInputBarControl.inputTextView.text = phoneNumber;
            [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
            
            return;
        }
        
    }
    
    [super didTapPhoneNumberInMessageCell:phoneNumber model:model];

}

- (BOOL)pushOldMessageModel:(RCMessageModel *)model {
    BOOL isDisplay = [model.content isDisplayInChatView];
    if (!isDisplay) {
        return NO;
    }
    return [super pushOldMessageModel:model];
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message
{
    if (![message.content isDisplayInChatView]) { // 判断消息需要显示不
        return nil;
    }
    
    [self updateTitle:message]; // 更新群名
    
    if ([message.content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *content =  (RCImageMessage *)message.content;
        NSLog(@"presentImagePreviewController = %@",content.imageUrl);
    }
    
    if ([message.senderUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId] &&  message.conversationType == ConversationType_PRIVATE) {
        
    }

    return message;
}

- (void)presentLocationViewController:(RCLocationMessage *)locationMessageContent
{
    _pushView = YES;
//    [super presentLocationViewController:locationMessageContent];
    
    CMPLocationMapViewController *ctrl = [[CMPLocationMapViewController alloc] initWithLocationCoordinate:locationMessageContent.location locationName:locationMessageContent.locationName];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)presentFilePreviewViewController:(RCMessageModel *)model {
    if (self.conversationType == ConversationType_PRIVATE) {
        // 私聊在打开他人发送的文件时，给他人发一条下载成功消息
        if (![model.senderUserId isEqualToString:[CMPCore sharedInstance].userID]) {
//            NSString *extra = ((RCFileMessage *)model.content).extra;
//            NSDictionary *dic = [extra JSONValue];
//            if (!TYPE_CHECK(dic, NSDictionary)) {
//                NSString *msgId = dic[@"msgId"];
//                [self sendFileStatusReceiptMsgUId:model.messageUId
//                                            msgId:[NSString stringWithLongLong:model.messageId]
//                                           status:[NSString stringWithFormat:@"%ld", (long)CMPFileStatusReceiptOtherDownloadSuc]];
//            }
            [self sendFileStatusReceiptMsgUId:model.messageUId
                                        msgId:[NSString stringWithLongLong:model.messageId]
                                       status:[NSString stringWithFormat:@"%ld",(long)CMPFileStatusReceiptOtherDownloadSuc]];
        }
        if ([model.content isMemberOfClass:[RCFileMessage class]]) {
            RCFileMessage *fileMessage = ( RCFileMessage *)model.content;
            NSString *mineType = [CMPFileTypeHandler mineTypeWithPathExtension:fileMessage.name.pathExtension];
            NSInteger fileMineType = [CMPFileTypeHandler fileMineTypeWithMineType:mineType];
            if (fileMineType == CMPFileMineTypeAudio) {
                [self showAudioPlayerViewController:model];
            } else {
                [self showFileDownloadView:model];
            }
        }
        else if ([model.content isMemberOfClass:[CMPVideoMessage class]]) {
            RCMediaMessageContent *content = (RCMediaMessageContent *)model.content;
            NSString *remoteUrl = content.remoteUrl;
            if (!remoteUrl) {
                [self cmp_showHUDWithText:SY_STRING(@"msg_fileHaveDelete")];
                return;
            }
            [self showAVPlayerViewController:model];
        }
        
    } else {
        if ([model.content isKindOfClass:[CMPVideoMessage class]]){
            [self showAVPlayerViewController:model];
        }else{
            [self checkFileFromServer:model forward:NO];
        }
    }
}

- (void)showFileDownloadView:(RCMessageModel *)model
{
    if (!self.filePrivilege) {
        [self showAlertMessage:SY_STRING(@"msg_requestingFilePrivilege")];
        return;
    }
    if (!self.filePrivilege.receiveFile) {
        [self showAlertMessage:SY_STRING(@"msg_noFilePrivilege")];
        return;
    }

    RCFileMessage *content =  (RCFileMessage *)model.content;
    _pushView = YES;
    AttachmentReaderParam *aParam = [[AttachmentReaderParam alloc] init];
    aParam.fileId = content.fileUrl;
//    aParam.filePath = content.localPath;
    CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
    aViewController.canReceiveFile = self.filePrivilege.receiveFile;//可以查看文档

    NSString *aFileUrl = [CMPCore fullUrlForPathFormat:@"/rest/attachment/file/%@", content.fileUrl];
    aFileUrl = [aFileUrl appendHtmlUrlParam:@"ucFlag" value:@"yes"];
    aParam.url = aFileUrl;
    aParam.origin = [CMPCore sharedInstance].serverurlForSeeyon;
    aParam.lastModified = [NSString stringWithFormat:@"%lld", model.receivedTime];
    aParam.fileName = content.name;
    aParam.fileType = content.type;
    aParam.fileSize = [NSString stringWithFormat:@"%lld", content.size];
    aParam.isUc = YES;
    aParam.autoSave = [CMPFeatureSupportControl isAutoSaveFile];
    aParam.from = [self getFileFromWithMsgModel:model];
    aParam.fromType = [self getFileFromTypeWithMsgModel:model];
    aParam.extra = @{@"targetInfo":@{@"targetType":@(self.conversationType),
                                     @"targetId":self.targetId}};
    NSDictionary *logParams = @{@"targetType":@(self.conversationType),
                                @"targetName":self.navigationItem.title,
                                @"fileName":content.name
    };
    aParam.logParams = logParams;
    aViewController.attReaderParam = aParam;
    [self.navigationController pushViewController:aViewController animated:YES];
}

- (void)showAVPlayerViewController:(RCMessageModel *)model {
    NSDictionary *imagesDic = [[RCIM sharedRCIM] getPicAndVideoMessagesWithTargetId:self.targetId conversationType:self.conversationType currentMessageId:model.messageId];
    NSArray *mediaUrlArr = imagesDic[@"imageUrlArr"];
    NSArray *rcImgModels = imagesDic[@"rcMessageModels"];
    
    _pushView = YES;
    CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
    CMPVideoMessage *content =  (CMPVideoMessage *)model.content;
    NSString *videoLocalPath = content.localPath;
    playerVc.msgModel = model;
    playerVc.from = [self getFileFromWithMsgModel:model];
    playerVc.fromType = [self getFileFromTypeWithMsgModel:model];
    playerVc.fileName = content.name;
    playerVc.fileId = content.remoteUrl;
    playerVc.autoSave = YES;
    playerVc.isOnlinePlay = NO;
    playerVc.showAlbumBtn = [CMPFeatureSupportControl isShowCheckAllPicsBtn];
    playerVc.mediaUrlArr = mediaUrlArr;
    playerVc.rcImgModels = rcImgModels;
    playerVc.canNotCollect = ![CMPFeatureSupportControl isSupportCollect];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalPath]) {
       playerVc.url = [NSURL URLWithPathString:videoLocalPath];
       [self presentViewController:playerVc animated:YES completion:nil];
        return;
    }
    
    NSUInteger index = [self.conversationDataRepository indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CMPVideoMessageCell *cell = (CMPVideoMessageCell *)[self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
   
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:model.messageId];
    RCMediaMessageContent *content1 = (RCMediaMessageContent *)message.content;
    NSString *remoteUrl = content1.remoteUrl;
    NSString *fileId = nil;
    if ([remoteUrl.lowercaseString hasPrefix:@"https"] || [remoteUrl.lowercaseString hasPrefix:@"http"]) {
        fileId = [CMPCommonTool getSourceIdWithUrl:remoteUrl];
    } else {
        fileId = remoteUrl;
    }
    
    //如果fileId为空，则返回
    if ([NSString isNull:fileId] && [message.content isKindOfClass:CMPVideoMessage.class]) {
        CMPVideoMessage *videoMessage = (CMPVideoMessage *)message.content;
        fileId = videoMessage.fileUrl;
        if ([NSString isNull:fileId]) {
            [self cmp_showHUDWithText:SY_STRING(@"msg_fileHaveDelete")];
            return;
        }
    }
    
    [[RCIM sharedRCIM] downloadMediaMessage:model.messageId progress:^(int progress) {
         [cell updateDownloadProgressView:progress];
    } success:^(NSString *mediaPath) {
        
    } error:^(RCErrorCode errorCode) {
         [cell updateDownloadProgressView:100];
         [self cmp_showHUDWithText:NSLocalizedStringFromTable(@"FileDownloadFailed", @"RongCloudKit", nil)];
    } cancel:^{
        
    }];

}

- (void)showAudioPlayerViewController:(RCMessageModel *)model {
    _pushView = YES;
    RCFileMessage *content =  (RCFileMessage *)model.content;
    NSString *videoLocalPath = content.localPath;
    
    CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
    playerVc.fileName = content.name;
    playerVc.palyType = CMPAVPlayerPalyTypeAudio;
    playerVc.canNotSave = YES;
    playerVc.msgModel = model;
    playerVc.from = [self getFileFromWithMsgModel:model];
    playerVc.fromType = [self getFileFromTypeWithMsgModel:model];
    playerVc.fileId = content.remoteUrl;
    playerVc.autoSave = YES;
    playerVc.canNotCollect = ![CMPFeatureSupportControl isSupportCollect];

    if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalPath]) {
       playerVc.url = [NSURL URLWithPathString:videoLocalPath];
       [self presentViewController:playerVc animated:YES completion:nil];
        return;
    }
    
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    CMPAVPlayerDownloadView *downloadView = [[CMPAVPlayerDownloadView alloc] initWithFrame:keyWindow.bounds];
    downloadView.downloadType = CMPAVPlayerDownloadTypeAudio;
    [downloadView setFileSize:content.size];
    [keyWindow addSubview:downloadView];
    
    __weak typeof(downloadView) weakDownloadView = downloadView;
    downloadView.closeBtnClicked = ^{
        [[RCIM sharedRCIM] cancelDownloadMediaMessage:model.messageId];
        [weakDownloadView removeFromSuperview];
    };
   
    [downloadView setProgress:0];
    [[RCIM sharedRCIM] downloadMediaMessage:model.messageId progress:^(int progress) {
        [weakDownloadView setProgress:progress * 0.01];
        CMPLog(@"---下载进度----%f",progress * 0.01);
    } success:^(NSString *mediaPath) {
        [weakDownloadView setProgress:1.f];
        [weakDownloadView removeFromSuperview];
        
        playerVc.url = [NSURL URLWithPathString:mediaPath];
        [self presentViewController:playerVc animated:YES completion:nil];
    } error:^(RCErrorCode errorCode) {
         [self cmp_showHUDWithText:NSLocalizedStringFromTable(@"FileDownloadFailed", @"RongCloudKit", nil)];
    } cancel:^{
        
    }];

}

/// 获取文件来源
/// @param model msgModel
- (NSString *)getFileFromWithMsgModel:(RCMessageModel *)model {
    return [RCIM getFileFromWithMsgModel:model targetId:self.targetId conversationType:self.conversationType];
}

/// 获取文件来源类型
/// @param model msgModel
- (NSString *)getFileFromTypeWithMsgModel:(RCMessageModel *)model {
    return [RCIM getFileFromTypeWithMsgModel:model targetId:self.targetId conversationType:self.conversationType];
}

//发送消息
- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent
{
    _isSendMessage = YES;
    
    if ([messageContent respondsToSelector:@selector(setExtra:)]) {
        NSDictionary *dic = nil;
        
        dic = [NSDictionary dictionaryWithObjectsAndKeys:self.titleContent, @"toName", [NSString uuid], @"msgId", self.targetId, @"toId", [CMPCore sharedInstance].userID, @"userId", [CMPCore sharedInstance].currentUser.name, @"userName" ,nil];
        
        if (![messageContent performSelector:@selector(extra)]) {
            [messageContent performSelector:@selector(setExtra:) withObject:[dic JSONRepresentation]];
        }
        
    }
    
    if ([messageContent isKindOfClass:[RCImageMessage class]] ||
        [messageContent isKindOfClass:[RCFileMessage class]] ||
        [messageContent isKindOfClass:[RCGIFMessage class]]) {
        [self uploadImageToServer:messageContent];
        return nil;
    } else if ([messageContent isKindOfClass:[RCTextMessage class]]) { // 去掉文本消息的首尾回车
        NSString *content = [messageContent valueForKey:@"content"];
        content = [content stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        CMPMsgFilterResult *filterRslt = [CMPMessageFilterManager filterStr:content];
        content = filterRslt.rslt;
        [messageContent performSelector:@selector(setContent:) withObject:content];
    }
    if (messageContent.mentionedInfo && messageContent.mentionedInfo.userIdList) {
        for (int i = 0; i < messageContent.mentionedInfo.userIdList.count; i++) {
            NSString *userId = messageContent.mentionedInfo.userIdList[i];
            if ([userId isEqualToString:kRCUserId_AtAll]) {
                messageContent.mentionedInfo.type = RC_Mentioned_All;
                messageContent.mentionedInfo.userIdList = nil;
                break;
            }
        }
    }
    if (_currentReeditModel && [_currentReeditModel isMemberOfClass:[RCTextMessage class]] && [messageContent isKindOfClass:[RCTextMessage class]]) {
        RCMentionedInfo *oldMention = ((RCTextMessage *)_currentReeditModel).mentionedInfo;
        if (oldMention) {
            messageContent.mentionedInfo = [self _combineMentionInfo:oldMention extendMentionInfo:messageContent.mentionedInfo];
        }
    }
    
    if (_quotingShowView) {
        //如果有被引用消息信息，转换成引用消息
        if (_quotedMessageModel && [messageContent isKindOfClass:[RCTextMessage class]]) {
            CMPQuoteMessage *quoteMsg = [[CMPQuoteMessage alloc] initWithMessageContent:messageContent quotedMessageModel:_quotedMessageModel ext:nil];
            return quoteMsg;
        }
        
        if (_currentReeditModel && [_currentReeditModel isMemberOfClass:[CMPQuoteMessage class]] && [messageContent isKindOfClass:[RCTextMessage class]]) {
            CMPQuoteMessage *quoteMsg = (CMPQuoteMessage *)_currentReeditModel;
            quoteMsg.content = ((RCTextMessage *)messageContent).content;
            quoteMsg.mentionedInfo = [self _combineMentionInfo:quoteMsg.mentionedInfo extendMentionInfo:messageContent.mentionedInfo];
            return quoteMsg;
        }
    }
    
    
    return messageContent;
}

-(RCMentionedInfo *)_combineMentionInfo:(RCMentionedInfo *)baseMentionInfo extendMentionInfo:(RCMentionedInfo *)extendMentionInfo
{
    if (!baseMentionInfo && !extendMentionInfo) {
        return nil;
    }
    if (!baseMentionInfo) {
        return extendMentionInfo;
    }
    if (!extendMentionInfo) {
        return baseMentionInfo;
    }
    
    if (baseMentionInfo.type == RC_Mentioned_All) {
        return baseMentionInfo;
    }
    if (extendMentionInfo.type == RC_Mentioned_All) {
        return extendMentionInfo;
    }
    
    NSArray *list1 = baseMentionInfo.userIdList;
    NSArray *list2 = extendMentionInfo.userIdList;
    NSMutableSet *list = [[NSMutableSet alloc] init];
    if (list1.count) {
        [list addObjectsFromArray:list1];
    }
    if (list2.count) {
        [list addObjectsFromArray:list2];
    }
    RCMentionedInfo *tempMentionInfo = [[RCMentionedInfo alloc] initWithMentionedType:RC_Mentioned_Users userIdList:list.allObjects mentionedContent:baseMentionInfo.mentionedContent];
    return tempMentionInfo;
}

-(void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent {
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (CMP_IPAD_MODE && ![self.cmp_splitViewController cmp_isFullScreen]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
        }
        self->_currentReeditModel = nil;
        self->_quotedMessageModel = nil;
        [self->_quotingShowView removeFromSuperview];
        self->_quotingShowView = nil;
        CGFloat top = self->_segScrollView.itemsArr.count>0?50:0;
        wSelf.conversationMessageCollectionView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
        if (wSelf.conversationDataRepository.count > 0) {
            [wSelf.conversationMessageCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:wSelf.conversationDataRepository.count-1 inSection:0]]];
        }
//        if ([messageContent isKindOfClass:RCFileMessage.class]) {
//            NSString *localPath = ((RCFileMessage*)messageContent).localPath;
//            //ks fix -- h5转发过来的，localpath为nil， V5-40644 【风暴测试】iOS 转发群文件到本群，提示"文件路径已丢失"，但实际转发成功
//            if (localPath && [CMPFileManager fileSizeAtPath:localPath]<=0) {
//                [self.view cmp_showHUDWithText:@"文件路径已丢失"];
//            }
//        }
        
    });
}

-(void)didCancelMessage:(RCMessageContent *)messageContent {
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (CMP_IPAD_MODE && ![self.cmp_splitViewController cmp_isFullScreen]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
        }
        self->_currentReeditModel = nil;
        self->_quotedMessageModel = nil;
        [self->_quotingShowView removeFromSuperview];
        self->_quotingShowView = nil;
        wSelf.conversationMessageCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    });
}

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<YBImageBrowserCellDataProtocol>)data
{
    NSArray *currentDataSource = imageBrowser.dataSourceArray;
    NSArray *currentRcMsgModelArr = imageBrowser.rcImgModels;
    if (currentRcMsgModelArr && currentRcMsgModelArr.count) {
        if (index < currentRcMsgModelArr.count) {
            if (index<=1 || currentDataSource.count-index<=2){
                RCMessageModel *curMsgModel = currentRcMsgModelArr[index];
                NSArray *curTmpArr1 = [currentRcMsgModelArr subarrayWithRange:NSMakeRange(0, index)];
                NSArray *curTmpArr2 = [currentRcMsgModelArr subarrayWithRange:NSMakeRange(index+1, currentRcMsgModelArr.count-index-1)];
                
                NSArray *newTmpArr1 = curTmpArr1;
                NSArray *newTmpArr2 = curTmpArr2;
                if (index<=1) {//向前取
                    NSMutableArray *mArr = [NSMutableArray array];
                    NSArray *arrr = [RCIM getOlderMediaMessagesThanModel:curMsgModel count:10 times:0];
                    for (NSInteger j = [arrr count] - 1; j >= 0; j--) {
                        RCMessage *rcMsg = [arrr objectAtIndex:j];
                        if (rcMsg.content) {
                            RCMessageModel *modelindex = [RCMessageModel modelWithMessage:rcMsg];
                            [mArr addObject:modelindex];
                        }
                    }
                    newTmpArr1 = mArr;
                    //可以优化，后面的大于20了，可以删除掉
                }
                if (currentDataSource.count-index<=2) {//向后取
                    NSMutableArray *mArr = [NSMutableArray array];
                    NSArray *arrr = [RCIM getLaterMediaMessagesThanModel:curMsgModel count:10 times:0];
                    for (int i = 0; i < [arrr count]; i++) {
                        RCMessage *rcMsg = [arrr objectAtIndex:i];
                        if (rcMsg.content) {
                            RCMessageModel *modelindex = [RCMessageModel modelWithMessage:rcMsg];
                            [mArr addObject:modelindex];
                        }
                    }
                    newTmpArr2 = mArr;
                    //可以优化，前面的大于20了，可以删除掉
                }
                
                NSMutableArray *finalRcMsgArr = [NSMutableArray array];
                [finalRcMsgArr addObjectsFromArray:newTmpArr1];
                [finalRcMsgArr addObject:curMsgModel];
                [finalRcMsgArr addObjectsFromArray:newTmpArr2];
                
                NSInteger newIndex = newTmpArr1.count;
                
                if (newTmpArr1.count != curTmpArr1.count
                    || newTmpArr2.count != curTmpArr2.count) {
                    NSArray *broModelArr = [RCIM transferRcMediaMessageModelToMediaBrowseCellDataModel:finalRcMsgArr];
                    NSArray *ybDataSource = [CMPReviewImagesTool yb_cellDataArrFromCMPBrowserModelArr:broModelArr];
                    imageBrowser.dataSourceArray = ybDataSource;
                    imageBrowser.rcImgModels = finalRcMsgArr;
                    imageBrowser.currentIndex = newIndex;
                    [imageBrowser reloadData];
                }
            }
        }
    }
    
}

// 点击Cell中的消息内容的回调
- (void)didTapMessageCell:(RCMessageModel *)model {
    if ([model isImageMessage] || [model.content isKindOfClass:[RCGIFMessage class]]) {
        
        //ks fix --- 修改图片过多卡死问题
        NSArray *rcmodelArr = [RCIM getSomeMediaMessagesFromModel:model];
        NSArray *broModelArr = [RCIM transferRcMediaMessageModelToMediaBrowseCellDataModel:rcmodelArr];
        NSInteger index = [RCIM rcModel:model indexInArr:rcmodelArr];
        
        YBImageBrowser *browser = [CMPReviewImagesTool showBrowserForMixedCaseWithDataModelArray:broModelArr currentIndex:index fromControllerIsAllowRotation:NO canSave:YES canPrint:[CMPFeatureSupportControl isSupportPrint] isShowCheckAllPicsBtn:[CMPFeatureSupportControl isShowCheckAllPicsBtn]];
        browser.delegate = self;
        browser.rcImgModels = rcmodelArr;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *allImagesDic = [[RCIM sharedRCIM] getPicAndVideoMessagesWithTargetId:self.targetId conversationType:self.conversationType currentMessageId:model.messageId];
            NSArray *allRcImgModels = allImagesDic[@"rcMessageModels"];
            NSArray *allImageUrlArr = allImagesDic[@"imageUrlArr"];
            NSArray *allDataSource = [CMPReviewImagesTool yb_cellDataArrFromCMPBrowserModelArr:allImageUrlArr];

            browser.allDataSourceArray = allDataSource;
            browser.allRcImgModels = allRcImgModels;
        });

    }
    else if ([model isRobotMessage]) {
        //机器人消息点击
        CMPRobotMsg *message =  (CMPRobotMsg *)model.content;
//        if (message.actionType && message.actionType.integerValue == 0) {
//            //0：只读   1：可穿透
//            return;
//        }
        NSString *urlStr = message.pierceUrl;
        if ([NSString isNull:urlStr]) {
            return;
        }
        if (![NSURL URLWithString:urlStr]) {
            return;
        }
        CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc]init];
        urlStr = [urlStr URLDecodedString:urlStr];//反解码
//        NSURL *url = [NSURL URLWithString:urlStr];
//        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:url];
        viewController.startPage = urlStr;
        viewController.closeButtonHidden = YES;
        viewController.hideBannerNavBar = NO;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([model isFileMessage]) {
        if (!self.filePrivilege) {
            [self showAlertMessage:SY_STRING(@"msg_requestingFilePrivilege")];
        } else {
            RCFileMessage *content =  (RCFileMessage *)model.content;
            NSString *fileType = [content.name componentsSeparatedByString:@"."].lastObject;
            BOOL enable = [[CMPAttachmentHelper shareManager] isSupportOnlinePreviewWithFileExtension:fileType];
            if (enable) {
                if (content.size>=50*1024*1024) {
                    enable = NO;
                }
            }
            if (!enable && !self.filePrivilege.receiveFile) {
                [self showAlertMessage:SY_STRING(@"msg_noFilePrivilege")];
                return;
            }
            [super didTapMessageCell:model];
        }
    }
    else if ([model.content isKindOfClass:[CMPVideoMessage class]]) {
        if (!self.filePrivilege) {
            [self showAlertMessage:SY_STRING(@"msg_requestingFilePrivilege")];
        } else if (!self.filePrivilege.receiveFile) {
            [self showAlertMessage:SY_STRING(@"msg_noFilePrivilege")];
        } else {
            [self presentFilePreviewViewController:model];
        }
    }
    else if ([model isRCForwardMessage]) {
        if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
            [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
            return;
        }
        CMPRCTransmitMessage *message =  (CMPRCTransmitMessage *)model.content;
        if (message.actionType && message.actionType.integerValue == 0) {
            //0：只读   1：可穿透
            return;
        }
        NSString *urlStr = message.mobilePassURL;
        if ([NSString isNull:urlStr]) {
            return;
        }
        CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc]init];
        urlStr = [urlStr urlCFEncoded];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:url];
        viewController.startPage = localHref;
        viewController.closeButtonHidden = YES;
        viewController.hideBannerNavBar = NO;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([model isRCConvertMissionMessage]){
        CMPRCSystemImMessage *message =  (CMPRCSystemImMessage *)model.content;
        NSDictionary *extraDic = nil;
        if ([[message.extra JSONValue] isKindOfClass:[NSDictionary class]]) {
            extraDic = [message.extra JSONValue];
        }
        if (extraDic) {
            if ([[extraDic[@"message"] objectForKey:@"at"] integerValue] == 0) {
                //0：只读   1：可穿透
                return;
            }
            NSString *urlStr = [extraDic[@"message"] objectForKey:@"mMl"];
            if ([NSString isNull:urlStr]) {
                return;
            }
            CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc]init];
            urlStr = [urlStr urlCFEncoded];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:url];
            viewController.startPage = localHref;
            viewController.closeButtonHidden = YES;
            viewController.hideBannerNavBar = NO;
            [self.navigationController pushViewController:viewController animated:YES];
        }
        NSLog(@"点击文字转任务消息,%@",message.content);
    }
    else if ([model isRCUrgeMessage]){//催办类型消息
        
    }
    else if ([model.content isKindOfClass:[CMPBusinessCardMessage class]]){
        CMPBusinessCardMessage *businessCardMessage = (CMPBusinessCardMessage *)model.content;
        [CMPPersonInfoUtils showPersonInfoView:businessCardMessage.personnelId
                                          from:@"contacts"
                                    enableChat:YES
                         parentViewController:self
                                allowRotation:NO];
    }
    else if ([model.content isKindOfClass:[CMPCombineMessage class]]){
        CMPCombineMessage *combineMessage = (CMPCombineMessage *)model.content;
        [self viewMergeMessagePageWithChatContentId:combineMessage.chatContentId];
    }
    else if ([model.content isKindOfClass:[CMPGeneralBusinessMessage class]]){
        [self viewGeneralBusinessMessagePageWithMessageModel:model];
    }
    else if ([model.content isKindOfClass:[CMPSignMessage class]]){
        CMPSignMessage *signMessage = (CMPSignMessage *)model.content;
        NSString *mobileUrlParam = signMessage.mobileUrlParam;
        if ([NSString isNotNull:mobileUrlParam]) {
            id paramObject = [signMessage.mobileUrlParam JSONValue] ?: signMessage.mobileUrlParam;
            [self viewGeneralBusinessMessagePageWithMessageCategoryId:signMessage.messageCategory paramObject:paramObject];
        }
    }
    else {
        [super didTapMessageCell:model];
    }
}

- (void)didTapCellPortrait:(NSString *)userId {
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    [CMPPersonInfoUtils showPersonInfoView:userId from:@"contacts" enableChat:YES parentViewController:self allowRotation:NO];
}

- (BOOL)canForwardMsg:(RCMessageModel *)model {
    id content = model.content;
    if ([content isKindOfClass:[CMPGeneralBusinessMessage class]] ||
        [content isKindOfClass:[CMPBusinessCardMessage class]] ||
        [content isKindOfClass:[RCVoiceMessage class]]){
        return NO;
    }
    if ([content isKindOfClass:[RCFileMessage class]] ||
        [content isKindOfClass:[RCImageMessage class]]) {
        if (self.filePrivilege.sendFile) {
            return YES;
        }
        return NO;
    }
    return YES;
}


- (BOOL)canRecallMessageOfModel:(RCMessageModel *)model {
    long long cTime = [[NSDate date] timeIntervalSince1970] * 1000;
    long long ServerTime = cTime - [[RCIMClient sharedRCIMClient] getDeltaTime];
    long long interval = ServerTime - model.sentTime > 0 ? ServerTime - model.sentTime : model.sentTime - ServerTime;
    
    BOOL canBase1 = ([RCIM sharedRCIM].enableMessageRecall && model.sentStatus != SentStatus_SENDING &&
                    model.sentStatus != SentStatus_FAILED && model.sentStatus != SentStatus_CANCELED &&
                    (model.conversationType == ConversationType_PRIVATE || model.conversationType == ConversationType_GROUP ||
                     model.conversationType == ConversationType_DISCUSSION) &&
                    ![model.content isKindOfClass:NSClassFromString(@"JrmfRedPacketMessage")] &&
                    ![model.content isKindOfClass:NSClassFromString(@"RCCallSummaryMessage")]);
    if (!canBase1) {
        return NO;
    }
    
    BOOL canBase2 = (interval <= [RCIM sharedRCIM].maxRecallDuration * 1000);
    
    BOOL ifNeedBase2 = YES;
    if (model.conversationType == ConversationType_GROUP) {
        NSString *myid = [CMPCore sharedInstance].currentUser.userID;
        if ([self.groupInfo.adminIds containsString:myid] || [self.groupInfo.ownerId isEqualToString:myid]) {
            ifNeedBase2 = NO;
        }
    }
    
    if (ifNeedBase2) {
        if (!canBase2) {
            return NO;
        }
    }else{
        return YES;
    }

    if (model.messageDirection == MessageDirection_SEND) {
        return YES;
    }
    return NO;
}

// 屏蔽群文件撤回功能
- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    NSMutableArray *menuItems = [NSMutableArray arrayWithArray:[super getLongTouchMessageCellMenuList:model]];
    // 判断文件是否被对方下载了，如果被下载过屏蔽撤回功能
    //注释原因：BUG2023112780010 群主没有撤回按钮
//    BOOL isFileDownloaded = [CMPFileStatusProvider isFileDownloadedWithMsgUId:model.messageUId];
//    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    if (([model.content isKindOfClass:[RCFileMessage class]] &&
//         self.conversationType == ConversationType_GROUP) ||
//        isFileDownloaded) {
//        // 如果当前文件消息为视频类型,不删除recall操作
//        if (![model.content isKindOfClass:[CMPVideoMessage class]]) {
//            UIMenuItem *recallItem = nil;
//            for (UIMenuItem *item in menuItems) {
//                if (item.action == @selector(onRecallMessage:)) {
//                    recallItem = item;
//                }
//            }
//            [menuItems removeObject:recallItem];
//        }
//    }
    
    UIMenuItem *multiSelectMessageItem = nil;
    for (UIMenuItem *item in menuItems) {
        if (item.action == @selector(onMultiSelectMessageCell:)) {
            multiSelectMessageItem = item;
            multiSelectMessageItem.title = SY_STRING(@"picture_multi_select_btn_title");
        }
    }
    
    if (![CMPFeatureSupportControl isChatViewLongTouchMenuContainsMultiSelect]
        || (model.sentStatus == SentStatus_SENDING || model.sentStatus == SentStatus_FAILED || model.sentStatus == SentStatus_CANCELED)
        || [model.content isKindOfClass:[CMPCombineMessage class]]) {//ks fix V5-8973 V5-31104
        [menuItems removeObject:multiSelectMessageItem];
    }

#pragma clang diagnostic pop
	
	//统一出来转发的, 现支持文本和文件
    if (model) {
        if ([self canForwardMsg:model]){
            //融云基类私有属性，为了不改他的，自己保存一下，
            //同时也方便如果要支持，开线程同时发很多人的时候使用
            self.curSelectedModel = model;
            UIMenuItem *recallItem =
            [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"rc_Forward", @"RongCloudKit", nil)
                                        action:@selector(forwardMessage:)];
            [menuItems addObject:recallItem];

        }
        
        //文字转任务(单聊||群组)
        if ([model.content isKindOfClass:[RCTextMessage class]] &&
            [CMPMessageManager sharedManager].hasTask &&
            [CMPCore sharedInstance].serverIsLaterV2_5_0) {
            self.curSelectedModel = model;
            UIMenuItem *convertMissionItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"ConvertMission", @"Localizable", nil) action:@selector(convertMission:)];
            [menuItems addObject:convertMissionItem];
        }
        
    }
    
    
    if (([model.content isKindOfClass:[RCTextMessage class]]
         || [model.content isKindOfClass:[CMPQuoteMessage class]])) {
        
        //ks fix V5-11667
        if ([CMPFeatureSupportControl isSupportMessageQuote]) {
            if ((model.sentStatus == SentStatus_SENT || model.sentStatus == SentStatus_RECEIVED || model.sentStatus == SentStatus_READ)) {
                UIMenuItem *quoteItem =
                [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"rc_msg_quote", @"Localizable", nil)
                                           action:@selector(onLongPressQuoteMessageCell:)];
                [menuItems addObject:quoteItem];
            }
        }
        
    }else if ([model.content isKindOfClass:[RCFileMessage class]]
              ||[model.content isKindOfClass:[RCImageMessage class]]) {
        
        //ks fix V5-9163 M3发送的文件点击收藏提示附件拷贝出错
        if ([CMPFeatureSupportControl isSupportCollect]) {
            UIMenuItem *collectItem =
            [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"share_btn_collect", @"Localizable", nil)
                                       action:@selector(onLongPressMessageCellCollect:)];
            [menuItems addObject:collectItem];
        }
    }
	
    if (model.sentStatus == SentStatus_FAILED) {
        
        UIMenuItem *resendItem =
        [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"rc_msg_resend", @"Localizable", nil)
                                   action:@selector(onLongPressResendMessageCell:)];
        [menuItems addObject:resendItem];
    }
    
    if([model.objectName isEqual:@"OA:OARobotMsg"] || [model.objectName isEqual:@"OA:OARobotAtMsg"]){
        UIMenuItem *deleteItem = nil;
        for (UIMenuItem *item in menuItems) {
            if (item.action == @selector(onDeleteMessage:)) {
                deleteItem = item;
                break;
            }
        }
        [menuItems removeAllObjects];
        [menuItems addObject:deleteItem];
    }
    
    if ([model.content isKindOfClass:[RCFileMessage class]]){
        if (!self.filePrivilege.sendFile) {
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (UIMenuItem *item in menuItems) {
                if (item.action == @selector(onMultiSelectMessageCell:)) {
                    [tmpArr addObject:item];
                }else
                if (item.action == @selector(forwardMessage:)) {
                    [tmpArr addObject:item];
                }else
                if (item.action == @selector(onLongPressMessageCellCollect:)) {
                    [tmpArr addObject:item];
                }
            }
            [menuItems removeObjectsInArray:tmpArr];
        }
        //ks fix -- V5-39038
        if (!self.filePrivilege.receiveFile) {
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (UIMenuItem *item in menuItems) {
                if (item.action == @selector(onMultiSelectMessageCell:)) {
                    [tmpArr addObject:item];
                }else
                if (item.action == @selector(onLongPressMessageCellCollect:)) {
                    [tmpArr addObject:item];
                }
            }
            [menuItems removeObjectsInArray:tmpArr];
        }
    }else if ([model.content isKindOfClass:[CMPGeneralBusinessMessage class]]){
        CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)model.content;
        if ([@"109" isEqualToString:businessMessage.messageCategory]) {
            if ([[CMPMeetingManager shareInstance] otmIfServerOpen]) {
                if ([CMPMeetingManager isDateValidWithin30MinituesByTimestramp:model.sentTime]) {
                    UIMenuItem *inviteItem =
                    [[UIMenuItem alloc] initWithTitle:SY_STRING(@"zx_meeting_invite")
                                                action:@selector(onLongPressInviteOthers:)];
                    [menuItems insertObject:inviteItem atIndex:0];
                }
            }
        }
    }
    
    return [menuItems copy];
}

-(void)onLongPressInviteOthers:(id)sender
{
    RCMessageModel *model = [self longPressSelectMessageModel];
    CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)model.content;
    //ks add -- ontimemeet
    if ([@"109" isEqualToString:businessMessage.messageCategory]) {
        NSDictionary *info = businessMessage.messageCard;
        if (info) {
            NSString *sid = info[@"meetingSenderId"];
            if (sid) {
                NSString *link = info[@"meetingLink"];
                NSString *pwd = info[@"meetingPassword"];
                [[CMPMeetingManager shareInstance] otmBeginMeetingWithMids:nil onVC:self from:MeetingOtmCreateFrom_ZxInvite ext:@{@"type":MeetingOtmCreateFromZxType_Personal,@"sid":sid,@"link":link,@"pwd":pwd} completion:^(id  _Nonnull rslt, NSError * _Nonnull err, id  _Nonnull ext, NSInteger step) {
                        
                }];
            }
        }
    }
}

- (void)deleteMessage:(RCMessageModel *)model {
    [super deleteMessage:model];
    _isSendMessage = YES;
}

-(void)onLongPressResendMessageCell:(id)sender
{
    RCMessageModel *model = self.curSelectedModel;
    [self performSelector:@selector(didTapmessageFailedStatusViewForResend:) withObject:model];
}

-(void)onLongPressQuoteMessageCell:(id)sender
{
    _quotedMessageModel = self.curSelectedModel;
    
    [self.chatSessionInputBarControl addMentionedUser:_quotedMessageModel.userInfo];
    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    if (!_quotingShowView) {
        _quotingShowView = [[CMPRCQuotingShowView alloc] init];
        [_quotingShowView.funcBtn addTarget:self action:@selector(_quotingShowViewFuncBtnAct:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_quotingShowView];
        [_quotingShowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.chatSessionInputBarControl);
            make.bottom.equalTo(self.chatSessionInputBarControl.mas_top);
        }];
    }
    self.conversationMessageCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
    _quotingShowView.showLb.text = [NSString stringWithFormat:@"%@ %@: %@",@"回复",_quotedMessageModel.content.senderUserInfo.name,((RCTextMessage *)_quotedMessageModel.content).content];
    
}


-(void)_actionWithQuoteMessage:(CMPQuoteMessage *)quoteMessage
{
    if (quoteMessage && [quoteMessage isKindOfClass:[CMPQuoteMessage class]]) {
        
//        RCMentionedInfo *mentionInfo = quoteMessage.mentionedInfo;
//        if (mentionInfo.type == RC_Mentioned_Users) {
//            for (NSString *uid in mentionInfo.userIdList) {
//                [self.groupMemberList enumerateObjectsUsingBlock:^(RCUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if ([obj.userId isEqualToString:uid]) {
//                    [self.chatSessionInputBarControl addMentionedUser:obj];
//                        *stop = YES;
//                    }
//                }];
//            }
//        }else{
//            RCUserInfo *aUserInfo = [[RCUserInfo alloc] initWithUserId:kRCUserId_AtAll name:SY_STRING(@"msg_at_all") portrait:@""];
//            [self.chatSessionInputBarControl addMentionedUser:aUserInfo];
//        }
        
        NSString *ss = quoteMessage.content;
        if (ss.length) {
            NSString *s = self.chatSessionInputBarControl.inputTextView.text;
            self.chatSessionInputBarControl.inputTextView.text = [s stringByAppendingString:ss];
        }
        
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
        if (!_quotingShowView) {
            _quotingShowView = [[CMPRCQuotingShowView alloc] init];
            [_quotingShowView.funcBtn addTarget:self action:@selector(_quotingShowViewFuncBtnAct:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_quotingShowView];
            [_quotingShowView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.chatSessionInputBarControl);
                make.bottom.equalTo(self.chatSessionInputBarControl.mas_top);
            }];
        }
        self.conversationMessageCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
        _quotingShowView.showLb.text = quoteMessage.quotedShowStr;
    }
}

-(void)onLongPressMessageCellCollect:(id)sender
{
    RCMessageModel *msgModel = self.curSelectedModel;
    if ([msgModel.content isKindOfClass:[RCFileMessage class]]) {
        RCFileMessage *msg = (RCFileMessage *)msgModel.content;
        //ks fix -- V5-34763 移动端M3-已经删除的群文件，还能通过收藏查看该文件
        [self.viewModel checkChatFileIfExistById:msg.fileUrl groupId:self.targetId completion:^(BOOL ifExsit, NSError * _Nonnull error, id  _Nonnull ext) {
            if (ifExsit) {
                [[CMPShareManager sharedManager] shareToCollectWithFilePath:((RCFileMessage *)msgModel.content).localPath fileId:msg.fileUrl isUc:YES];
            }
        }];
    }else if ([msgModel.content isKindOfClass:[RCImageMessage class]]) {//V5-40537 iOS M3，长按聊天中的图片缺少收藏按钮
        RCImageMessage *msg = (RCImageMessage *)msgModel.content;
        [[CMPShareManager sharedManager] shareToCollectWithFilePath:msg.localPath fileId:msg.remoteUrl isUc:YES];
      }
}

//展示或隐藏消息多选状态下底部菜单
- (void)showToolBar:(BOOL)show{
    static CGFloat changeHeight = 0;
    if (show) {
        [self.messageSelectionMenuView showMenuFromView:self.view];
        [self.messageSelectionMenuView layoutIfNeeded];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (INTERFACE_IS_PHONE) {
                changeHeight = self.messageSelectionMenuView.cmp_height - self.chatSessionInputBarControl.cmp_height;
                self.conversationMessageCollectionView.cmp_height -= changeHeight;
                CGPoint contentOffset =  self.conversationMessageCollectionView.contentOffset;
                contentOffset.y += changeHeight;
                self.conversationMessageCollectionView.contentOffset = contentOffset;
            }else{
                //ks fix -- V5-22616 iOS 多选消息时，最下面的消息会被遮挡住，无法勾选
                //至今未解 ipad不行
                CGFloat h = self.messageSelectionMenuView.cmp_height;
                UIEdgeInsets edg = self.conversationMessageCollectionView.contentInset;
                edg.bottom = h;
                self.conversationMessageCollectionView.contentInset = edg;
            }
        });
    }else{
        [self.messageSelectionMenuView hideMenu];
        if (INTERFACE_IS_PHONE) {
            self.conversationMessageCollectionView.cmp_height += changeHeight;
        }else{
            
            UIEdgeInsets edg = self.conversationMessageCollectionView.contentInset;
            edg.bottom = 0;
            self.conversationMessageCollectionView.contentInset = edg;
        }
    }
}

- (void)notifyUpdateUnreadMessageCount {
    __weak typeof(self) weakself = self;
    if(self.allowsMessageCellSelection) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself setCancelButton];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself setBackButton];
        });
    }
}


#pragma mark-文字转任务

// 文字转为任务
- (void)convertMission:(id)sender {
    RCMessageModel *model = self.curSelectedModel;
    NSString *missionParam = [CMPRCMissionHelper paramForCovertMission:model];
    
    if ([NSString isNull:missionParam]) {
        NSLog(@"zl---[%s]消息转任务失败，参数为空", __FUNCTION__);
        return;
    }
    
    NSString *dataKey = saveData(missionParam);
    NSString *urlStr = [NSString stringWithFormat:@"http://commons.m3.cmp/v1.0.0/layout/penetration.html?key=%@&from=uc&appId=30", dataKey];
    [CMPBannerWebViewController pushWithUrl:urlStr toNavigation:self.navigationController];
}


//消息转发
- (void)forwardMessage:(id)sender {
    //V5-56765【UE应用检查】【转发多选】现状：进入选人后退回，转发那儿依然有文字显示
    if (@available(iOS 13.0, *)) {
        [[UIMenuController sharedMenuController] hideMenu];
    } else {
        [[UIMenuController sharedMenuController] setMenuItems:nil];
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
	//此函时是参照，撤回基类中的函数写法
    if (self.conversationType == ConversationType_GROUP && [_curSelectedModel.content isKindOfClass:[RCFileMessage class]]) {
        if ([_curSelectedModel.content isKindOfClass:[CMPVideoMessage class]]){
            //视频单独处理
            if (self.filePrivilege.sendFile) {
                [self showForwardMessageView];
                return;
            }
        }
        //文件需要先验证是否删除
        [self checkFileFromServer:_curSelectedModel forward:YES];
    }
    else {
        if (!self.filePrivilege.sendFile) {
            if ([_curSelectedModel.content isKindOfClass:[CMPCombineMessage class]]) {
                CMPCombineMessage *content = (CMPCombineMessage *)_curSelectedModel.content;
                NSArray *contModels = content.contentModels;
                for (ContentModel *aConModel in contModels) {
                    if ([aConModel.type isEqualToString:@"file"]) {
                        [self cmp_showHUDWithText:@"对不起，您没有文件发送权限!"];
                        return;
                    }
                }
            }
        }
        [self showForwardMessageView];
    }
}

- (void)showForwardMessageView {
    self.chatSessionInputBarControl.inputTextView.disableActionMenu = NO;
    CMPSelectContactViewController *selectVC = [[CMPSelectContactViewController alloc] init];
    selectVC.conversationType = self.conversationType;
    selectVC.msgModel = _curSelectedModel;
    selectVC.targetId = self.targetId;
    selectVC.forwardSource = CMPForwardSourceTypeOnlySingleMessage;
    __weak typeof(self) weakSelf = self;
    selectVC.willForwardMsg = ^(NSString *targetId) {
        [weakSelf handleWillForwardMsg:targetId];
    };
    
    __weak typeof(selectVC) weakSelectVC = selectVC;
    selectVC.forwardSucessWithMsgObj = ^(CMPMessageObject *msgObj, NSArray *fileList) {
        
        void(^closeBlk)(void) = ^{
            UIViewController *vc =  [weakSelectVC.navigationController popViewControllerAnimated:NO];
            if (vc == nil) {
                [weakSelectVC.navigationController dismissViewControllerAnimated:NO completion:nil];
            }
            [MBProgressHUD cmp_showSuccessHUDWithText:SY_STRING(@"share_component_share_finished_tips")];
        };
        
        //ks fix V5-9969 iOS端M3的群文件，从A群转发到B群，B群的群文件里不显示该文件
        if (weakSelf.curSelectedModel && ([weakSelf.curSelectedModel isFileMessage] || [weakSelf.curSelectedModel isVideoMessage])) {
            RCFileMessage *fileMsg = (RCFileMessage *)(weakSelf.curSelectedModel.content);
            NSString *targetId = msgObj.cId;
            void(^blk)(void) = ^{
                [[CMPChatManager sharedManager] forwardFile:fileMsg.remoteUrl type:0 target:targetId completion:^(id result, NSError *error) {
                                
                }];
            };
            //V5-40395【应用检查】关闭人员群内发送文件权限后，可以通过单聊转发到群内
            CMPRCConversationType subType = msgObj.subtype;
            if ([CMPServerVersionUtils serverIsLaterV8_2] && ConversationType_GROUP == subType) {
                NSMutableDictionary *pa = [NSMutableDictionary dictionary];
                [pa setObject:targetId forKey:@"groupId"];
                [self.viewModel fetchChatFileOperationPrivilegeByParams:pa completion:^(CMPRCGroupPrivilegeModel * _Nonnull privilege, NSError * _Nonnull error, id  _Nonnull ext) {
                    if (!privilege.sendFile || error) {
                        closeBlk();
                        [weakSelf cmp_showHUDWithText:@"对不起，此群组没有文件发送权限!"];
                        return;
                    }
                    closeBlk();
                    blk();
                }];
            }else{
                closeBlk();
                blk();
            }
        }else{
            closeBlk();
        }
    };
    if (INTERFACE_IS_PAD) {
        CMPNavigationController *nav = [CMPNavigationController.alloc initWithRootViewController:selectVC];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:selectVC animated:YES];
    }
}

- (void)showForwardMessageViewToForwardSelectMessageWithIsCombineForward:(BOOL)isCombineForward getSelectContactFinishBlock:(CompleteBlock)getSelectContactFinishBlock {
    self.chatSessionInputBarControl.inputTextView.disableActionMenu = NO;
    NSArray *selectedMessage = [self.selectedMessages copy];
    CMPSelectContactViewController *selectVC = [[CMPSelectContactViewController alloc] init];
    selectVC.conversationType = self.conversationType;
    selectVC.targetId = self.targetId;
    if (isCombineForward) {
        selectVC.forwardSource = CMPForwardSourceTypeMergeMessage;
        CMPCombineMessage *msg = [[CMPCombineMessage alloc] init];
        msg.title = [[RCForwardManager sharedInstance] getCombineMessageSummaryTitleWithSelectedMessages:self.selectedMessages forwardConversationType:self.conversationType targetId:self.targetId];
        RCMessageModel *msgModel = [[RCMessageModel alloc] init];
        msgModel.content = msg;
        selectVC.msgModel = msgModel;
        selectVC.selectedMessages = selectedMessage;
    } else {
        selectVC.forwardSource = CMPForwardSourceTypeSingleMessages;
        selectVC.selectedMessages = selectedMessage;
    }
    
    selectVC.getSelectContactFinishBlock = ^(NSArray *conversationList) {
        getSelectContactFinishBlock(conversationList);
    };
   
    __weak typeof(self) weakSelf = self;
    selectVC.willForwardMsg = ^(NSString *targetId) {
        [weakSelf handleWillForwardMsg:targetId];
    };
    __weak typeof(selectVC) weakSelectVC = selectVC;
    selectVC.forwardSucessWithMsgObj = ^(CMPMessageObject *msgObj, NSArray *fileList) {
        UIViewController *vc =  [weakSelectVC.navigationController popViewControllerAnimated:NO];
        if (vc == nil) {
            [weakSelectVC.navigationController dismissViewControllerAnimated:NO completion:nil];
        }
        [MBProgressHUD cmp_showSuccessHUDWithText:SY_STRING(@"share_component_share_finished_tips")];
    };
    if (INTERFACE_IS_PAD) {
        CMPNavigationController *nav = [CMPNavigationController.alloc initWithRootViewController:selectVC];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:selectVC animated:YES];
    }
}

- (void)handleWillForwardMsg:(NSString *)targetId {
    if ([self.targetId isEqualToString:targetId]) {
        _isSendMessage = YES;
    }
}

// 撤回消息回调
- (void)recallMessage:(long)messageId {
    
    [super recallMessage:messageId];
    
    _isSendMessage = YES;
    
    // 撤回图片、文件需要调用文件删除接口
    RCMessage *recallMessage = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    RCMessageContent *message = recallMessage.content;
    
    if ([message isKindOfClass:[RCImageMessage class]]) {
        
        RCImageMessage *imageMessage = (RCImageMessage *)message;
        [self deleteFileFromServer:imageMessage.imageUrl];
        
    } else if ([message isKindOfClass:[RCFileMessage class]]) {
        
        RCFileMessage *fileMessage = (RCFileMessage *)message;
        [self deleteFileFromServer:fileMessage.fileUrl];
        
    } else if([message isKindOfClass:[RCTextMessage class]]){
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *startDate =[NSDate date];
       
        NSString *startDateStr = [dateFormatter stringFromDate:startDate];
        NSString *messageStr = [(RCTextMessage *)message content];
        
        NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:@{
            
                                        @"time" : startDateStr,
                                        @"content" : messageStr,
                                        @"isCanReedit" : @(YES)
                                        
                                        }];
        
        //ks add 将原有消息信息存到extra里，后面会用到，融云撤回后丢掉了一些信息
        //新增字段 oriMsg{objectName,msg{content,extra,user,mentionedInfo}}
        
        NSMutableDictionary *oriMsgDic = [NSMutableDictionary dictionary];
        [oriMsgDic setObject:recallMessage.objectName forKey:@"objectName"];
        NSMutableDictionary *oriMsgInfo = [NSMutableDictionary dictionary];
        if (message.senderUserInfo) {
            [oriMsgInfo setObject:[message.senderUserInfo JSONRepresentation] forKey:@"user"];
        }
        if (message.mentionedInfo) {
            [oriMsgInfo setObject:[message.mentionedInfo JSONRepresentation] forKey:@"mentionedInfo"];
        }
        if (messageStr.length) {
            [oriMsgInfo setObject:messageStr forKey:@"content"];
        }
        
        NSString *extrStr = [(RCTextMessage *)message extra];
        if (extrStr.length) {
//            id ob = [extrStr JSONValue];
//            if (ob && [ob isKindOfClass:[NSDictionary class]]) {
                [oriMsgInfo setObject:extrStr forKey:@"extra"];
//            }
        }
        [oriMsgDic setObject:oriMsgInfo forKey:@"msg"];
        
        [extraDic setObject:oriMsgDic forKey:@"oriMsg"];
        
        NSString *jsonStr =  [extraDic JSONRepresentation];
        [[CMPChatManager sharedManager] setMessageExtra:messageId value:jsonStr];
        
    } else if ([message isKindOfClass:[CMPGeneralBusinessMessage class]]){
        CMPGeneralBusinessMessage *generalBusinessMessage = (CMPGeneralBusinessMessage *)message;
        [self recallGeneralBusinessMessageWithMessageId:generalBusinessMessage.messageId];
    }
}

- (void)didTapReedit:(RCMessageModel *)model {
    
    NSString *extraStr = model.extra;
    if (extraStr.length) {
        NSDictionary *extraDic = [extraStr JSONValue];
        if ([extraDic isKindOfClass:[NSDictionary class]]) {
            NSDictionary *oriMsgDic = extraDic[@"oriMsg"];
            if (oriMsgDic && [oriMsgDic isKindOfClass:[NSDictionary class]]) {
                NSString *objectName = oriMsgDic[@"objectName"];
                NSDictionary *msg = oriMsgDic[@"msg"];
                if (objectName.length && msg) {
                    if ([objectName isEqualToString:[CMPQuoteMessage getObjectName]]) {
                        CMPQuoteMessage *oriMsg = [[CMPQuoteMessage alloc] initWithDictionary:msg ext:nil];
                        [self _actionWithQuoteMessage:oriMsg];
                        _currentReeditModel = oriMsg;
                        return;
                    }
                    if ([objectName isEqualToString:[RCTextMessage getObjectName]]) {
                        id mentionedInfo = msg[@"mentionedInfo"];
                        if (mentionedInfo) {
                            if ([mentionedInfo isKindOfClass:[NSString class]]) {
                                mentionedInfo = [mentionedInfo JSONValue];
                            }
                            RCRecallNotificationMessage *recallMessage = (RCRecallNotificationMessage *)model.content;
                            NSString *content = recallMessage.recallContent;
                            RCTextMessage *msg = [RCTextMessage messageWithContent:content];
                            msg.mentionedInfo = [RCMentionedInfo yy_modelWithDictionary:mentionedInfo];
                            _currentReeditModel = msg;
                        }
                    }
                }
            }
        }
    }
    [super didTapReedit:model];
}


- (void)uploadImageToServer:(RCMessageContent *)message {
    [self sendMediaMessage:message pushContent:@"" appUpload:YES];
}

- (void)uploadMedia:(RCMessage *)message
     uploadListener:(RCUploadMediaStatusListener *)uploadListener {
    [self requestUpload:(RCMessage *)message.content listener:uploadListener];
}

// 取消上传
- (void)cancelUploadMedia:(RCMessageModel *)model {
    NSString *messageId = [NSString stringWithFormat:@"%ld", model.messageId];
    NSString *requestId = [_uploadRequestMap objectForKey:messageId];
    if ([NSString isNull:requestId]) {
        return;
    }
    [[CMPDataProvider sharedInstance] cancelWithRequestId:requestId];
    RCUploadMediaStatusListener *listener = [_listenerMap objectForKey:messageId];
    listener.cancelBlock();
    [_uploadRequestMap removeObjectForKey:messageId];
    [_listenerMap removeObjectForKey:messageId];
    [_uploadRequestIDs removeObject:requestId];
}

// 上传图片、文件
- (void)requestUpload:(RCMessage *)message  listener:(RCUploadMediaStatusListener *)listener{
    _isSendMessage = YES;
    NSString *messageId = [NSString stringWithFormat:@"%ld", listener.currentMessage.messageId];
    if (!_listenerMap) {
        _listenerMap = [[NSMutableDictionary alloc] init];
    }
    [_listenerMap setObject:listener forKey:messageId];
    
    NSString *tempLoadPath = nil;
    NSString *type = nil;
    
    if ([message isKindOfClass:[RCImageMessage class]]) {
        type = @"1";
        tempLoadPath = ((RCImageMessage *)message).localPath;
        NSData *originalData = ((RCImageMessage *)message).originalImageData;
        UIImage *originalImage = [UIImage imageWithData:originalData];
        if (![NSString isNull:tempLoadPath] &&[[NSFileManager defaultManager] fileExistsAtPath:tempLoadPath]) {
            
        }
        else if (originalImage) {
            tempLoadPath = [CMPFileManager imageMultiTempPath];
            [UIImagePNGRepresentation(originalImage) writeToFile:tempLoadPath atomically:YES];
        }
        else {
            listener.errorBlock(ERRORCODE_UNKNOWN);
            return;
        }
        
        // 处理图片旋转问题
        NSData *imageData = UIImageJPEGRepresentation([originalImage fixOrientation], 0.9);
        // 给图片加上后缀名
        tempLoadPath = [NSString stringWithFormat:@"%@.jpeg", tempLoadPath];
        BOOL result = [imageData writeToFile:tempLoadPath atomically:YES];
        if (!result) {
            listener.errorBlock(ERRORCODE_UNKNOWN);
            return;
        }
        imageData = nil;
    } else if ([message isKindOfClass:[RCFileMessage class]]) {
        tempLoadPath = ((RCFileMessage *)message).localPath;
        type = @"0";
    } else if ([message isKindOfClass:[RCGIFMessage class]]) {
        RCGIFMessage *GIFMessage = (RCGIFMessage *)message;
        tempLoadPath = GIFMessage.localPath;
        type = @"0";
    } else {
        listener.errorBlock(ERRORCODE_UNKNOWN);
        return;
    }
    
    long long size = [CMPFileManager fileSizeAtPath:tempLoadPath];
    
    if (size == 0) { // 防止路径错误出现崩溃问题
        listener.errorBlock(RC_NETWORK_UNAVAILABLE);
        return;
    }

    NSString *requestUrl = [CMPCore fullUrlForPath:@"/rest/attachment"];
    requestUrl = [requestUrl appendHtmlUrlParam:@"applicationCategory" value:@"61"];
    requestUrl = [requestUrl appendHtmlUrlParam:@"ucFlag" value:@"yes"];
    requestUrl = [requestUrl appendHtmlUrlParam:@"firstSave" value:@"true"];
    NSString *reference = self.targetId;
    requestUrl = [requestUrl appendHtmlUrlParam:@"reference" value:reference];
    requestUrl = [requestUrl appendHtmlUrlParam:@"type" value:type];
    requestUrl = [requestUrl appendHtmlUrlParam:@"isEncrypt" value:@"false"];
    NSString *maxSize = [NSString stringWithFormat:@"%lld",size];
    requestUrl = [requestUrl appendHtmlUrlParam:@"maxSize" value:maxSize];
   
    NSString *aFilePath = tempLoadPath;
    NSDictionary *logParams = @{@"targetType":@(self.conversationType),
                                @"targetName":self.navigationItem.title,
                                @"fileName":aFilePath?aFilePath.lastPathComponent:@""
    };
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.uploadFilePath = aFilePath;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:messageId,@"listener", message, @"message",logParams,@"logParams", nil];
    aDataRequest.requestType = kDataRequestType_FileUpload;
    [_uploadRequestIDs addObject:aDataRequest.requestID];
    [_uploadRequestMap setObject:aDataRequest.requestID forKey:messageId]; // 存储文件上传Request ID
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

// 删除文件
- (void)deleteFileFromServer:(NSString *)fileId {
    NSString *requestUrl = [CMPCore fullUrlForPathFormat:@"/rest/attachment/removeFile/%@", fileId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    _deleteRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

// 检查文件是否被删除了
- (void)checkFileFromServer:(RCMessageModel *)model forward:(BOOL)forward{
    RCFileMessage *content =  (RCFileMessage *)model.content;
    if ([NSString isNull:content.fileUrl]) {
        //没有下载文件的路径，无法检查
        [self cmp_showHUDWithText:SY_STRING(@"msg_fileHaveDelete")];
        return;
    }
    [self cmp_showProgressHUD];
    NSString *requestUrl = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/groups/checkFile/%@?groupId=%@",content.fileUrl, self.targetId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:model,@"message",[NSNumber numberWithBool:forward],@"forward", nil];
    aDataRequest.userInfo = userInfo;// @{@"message":model};
    _checkFileRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)showChooseUserViewController:(void (^)(RCUserInfo *))selectedBlock cancel:(void (^)(void))cancelBlock {
    CMPRCUserListViewController *userListController = [[CMPRCUserListViewController alloc] init];
    userListController.selectedBlock = selectedBlock;
    userListController.cancelBlock = cancelBlock;
    userListController.dataSource = self;
    userListController.hasPermissionAtAll = [self _canAtAll];
    CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:userListController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)checkTargetVoIPPermission {
    if (![CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        return;
    }
    
    if (self.isFileAssistant) {
        return;
    }
    
    if (self.conversationType == ConversationType_PRIVATE) {
        [self getTargetPersonalVoIPPermission];
    } else {
        [self getTargetGroupVoIPPermission:nil];
    }
}

#pragma mark-
#pragma mark-CMPRCUserListViewController Delegete

- (void)getSelectingUserList:(AllMembersOfGroupResultBlock)completion {
    __weak typeof(self) wSelf = self;
    [CMPChatManager.sharedManager getGroupUserListByGroupId:self.targetId completion:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList) {
        wSelf.groupInfo = groupInfo;
        if (completion) {
            completion(groupInfo,userList);
        }
    } fail:^(NSError *error, id ext) {}];
}

- (void)getTargetPersonalVoIPPermission {
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/video/personal/auth/%@", self.targetId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers =  [CMPDataProvider headers];;
    aDataRequest.timeout = 10;
    aDataRequest.requestType = kDataRequestType_Url;
    self.getTargetPersonalVoIPPermissionRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)getTargetGroupVoIPPermission:(void (^)(NSArray *userList))completion {
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.getTargetGroupVoIPPermissionRequestID];
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/video/group/auth/%@",self.targetId];

    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers =  [CMPDataProvider headers];;
    aDataRequest.timeout = 10;
    if (completion) {
        aDataRequest.userInfo = @{@"resultBlock" : [completion copy]};
    }
    aDataRequest.requestType = kDataRequestType_Url;
    self.getTargetGroupVoIPPermissionRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma -mark
#pragma -mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    if ([_uploadRequestIDs containsObject:aRequest.requestID]) {
        [_uploadRequestIDs removeObject:aRequest.requestID];
        [_uploadRequestMap removeObjectForKey:aRequest.requestID];
        NSString *aStr = aResponse.responseStr;
        NSDictionary *dic = [aStr JSONValue];
        RCUploadMediaStatusListener *listener = [_listenerMap objectForKey:[[aRequest userInfo] objectForKey:@"listener"]];
        if (dic) {
            NSString *codeStr = [NSString stringWithFormat:@"%@",dic[@"code"]];
            if ([codeStr isEqualToString:@"-11"]) {
                NSString *msg = [NSString stringWithFormat:@"%@",dic[@"message"]];
                [self cmp_showHUDWithText:msg];
                if (listener && listener.errorBlock) {
                    listener.errorBlock(RC_MSG_SIZE_OUT_OF_LIMIT);
                }
                return;
            }else if ([codeStr isEqualToString:@"1"]) {
                NSString *msg = [NSString stringWithFormat:@"%@",dic[@"message"]];
                [self cmp_showHUDWithText:msg];
                if (listener && listener.errorBlock) {
                    listener.errorBlock(RC_FILE_UPLOAD_FAILED);
                }
                return;
            }
        }
        NSArray *atts = [dic objectForKey:@"atts"];
        NSString *fileId = @"";
        for (NSDictionary *dic in atts) {
            id obj = [dic objectForKey:@"fileUrl"];
            if ([obj isKindOfClass:[NSNumber class]]) {
                fileId = [(NSNumber *)obj  stringValue];
            }
            else if (![NSString isNull:obj]) {
                fileId = obj;
            }
        }
        RCMessageContent *currentMessage = aRequest.userInfo[@"message"];
        if ([currentMessage isKindOfClass:[RCImageMessage class]]) {
            self.uploadImagesCount++;
            //sdk 1秒钟最多只允许发送5条消息，不然会提示20604错误（解决选多张图片发送总是会出现发送失败的问题）
            if (self.uploadImagesCount>5) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    RCImageMessage *content = (RCImageMessage *)currentMessage;
                    content.imageUrl = fileId;
                    listener.successBlock(content);
                    self.sendImagesCount--;
                    if (self.sendImagesCount <=0) {
                        [self cmp_hideProgressHUD];
                    }
                    [[NSFileManager defaultManager] removeItemAtPath:aRequest.uploadFilePath error:nil];
                });
            }else{
                RCImageMessage *content = (RCImageMessage *)currentMessage;
                content.imageUrl = fileId;
                listener.successBlock(content);
                self.sendImagesCount--;
                if (self.sendImagesCount <=0) {
                    [self cmp_hideProgressHUD];
                }
                [[NSFileManager defaultManager] removeItemAtPath:aRequest.uploadFilePath error:nil];
            }
        } else if ([currentMessage isKindOfClass:[RCFileMessage class]]) {
            RCFileMessage *content = (RCFileMessage *)currentMessage;
            content.fileUrl = fileId;
            listener.successBlock(content);
        } else if ([currentMessage isKindOfClass:[RCGIFMessage class]]) {
            RCGIFMessage *content = (RCGIFMessage *)currentMessage;
            content.remoteUrl = fileId;
            listener.successBlock(content);
        }
        
        NSDictionary *logParams = aRequest.userInfo[@"logParams"];
        [[CMPAttachmentHelper shareManager] shareAttaActionLogType:1 withParams:logParams completion:nil];
        
    } else if ([aRequest.requestID isEqualToString:_deleteRequestID]) {
        
    } else if ([aRequest.requestID isEqualToString:_checkFileRequestID]) { // 检查文件是否可以下载
        [self cmp_hideProgressHUDWithCompletionBlock:^{
            NSString *aStr = aResponse.responseStr;
            NSDictionary *dic = [aStr JSONValue];
            NSString *status = dic[@"status"];
            if ([status isEqualToString:@"ok"]) {
                NSDictionary *userInfo = aRequest.userInfo;
                RCMessageModel *messageModel = userInfo[@"message"];
                BOOL forward = [[userInfo objectForKey:@"forward"] boolValue];
                if (forward) {
                    [self showForwardMessageView];
                }
                else {
                    if ([messageModel.content isMemberOfClass:[RCFileMessage class]]) {
                        RCFileMessage *fileMessage = ( RCFileMessage *)messageModel.content;
                        
                        NSString *mineType = [CMPFileTypeHandler mineTypeWithPathExtension:fileMessage.name.pathExtension];
                        NSInteger fileMineType = [CMPFileTypeHandler fileMineTypeWithMineType:mineType];
                        if (fileMineType == CMPFileMineTypeAudio) {
                            [self showAudioPlayerViewController:messageModel];
                        } else {
                            [self showFileDownloadView:messageModel];
                        }
                    }
                    else if ([messageModel.content isMemberOfClass:[CMPVideoMessage class]]) {
                        [self showAVPlayerViewController:messageModel];
                    }
                }
            } else {
                NSDictionary *userInfo = aRequest.userInfo;
                BOOL forward = [[userInfo objectForKey:@"forward"] boolValue];
                NSString *showStr = forward ? SY_STRING(@"forward_fileHaveDelete"):SY_STRING(@"msg_fileHaveDelete");
                [self cmp_showHUDWithText:showStr];
            }
        }];
    } else if ([aRequest.requestID isEqualToString:self.getTargetPersonalVoIPPermissionRequestID]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        BOOL isHaveVoIPPermission = [responseDic[@"data"] boolValue];
        if (!isHaveVoIPPermission) {
            [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemVoiceAndVideoCall];
        }
    } else if ([aRequest.requestID isEqualToString:self.getTargetGroupVoIPPermissionRequestID]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSArray *haveVoIPPermissionUserIdlist = [responseDic[@"data"] copy];
        NSMutableArray *mutableArray = [NSMutableArray array];
        [haveVoIPPermissionUserIdlist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableArray addObject:[obj stringValue]];
        }];
        self.haveVoIPPermissionUserIdlist = [mutableArray copy];
        void (^completeBlock) (NSArray *userIdlist) = aRequest.userInfo[@"resultBlock"];
        if (completeBlock) {
            completeBlock(self.haveVoIPPermissionUserIdlist);
        }
        if (haveVoIPPermissionUserIdlist.count == 0) {
            //ks fix -- 主线程延迟1秒，不然移除失败
            __weak typeof(self) wSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemVoiceAndVideoCall];
            });
        }
    } else if ([aRequest.requestID isEqualToString:self.getGroupKanbanInfoRequestID]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSArray *datalist = [responseDic[@"data"] copy];
        void (^completeBlock) (NSArray *datalist) = aRequest.userInfo[@"resultBlock"];
        if (completeBlock) {
            completeBlock([datalist copy]);
        }
    } else if ([aRequest.requestID isEqualToString:self.getZhumuPluginPermissionRequestID]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSDictionary *dataDic = [responseDic[@"data"] copy];
        void (^completeBlock) (BOOL isHaveZhumuPlugin) = aRequest.userInfo[@"resultBlock"];
        if (completeBlock) {
            if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic) {
                NSNumber *meetingVideoEnable = dataDic[@"meetingVideoEnable"];
                if (meetingVideoEnable && [meetingVideoEnable isKindOfClass:[NSNumber class]]) {
                     completeBlock(meetingVideoEnable.boolValue);
                }
            } else {
                completeBlock(NO);
            }
          
        }
    }
}

- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt
{
    if ([_uploadRequestIDs containsObject:aRequest.requestID]) {
        CGFloat progress = [[aExt objectForKey:@"progress"] floatValue];
        RCUploadMediaStatusListener *listener = [_listenerMap objectForKey:[[aRequest userInfo] objectForKey:@"listener"]];
        listener.updateBlock(progress*100);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    if ([_uploadRequestIDs containsObject:aRequest.requestID]) {
        [self cmp_hideProgressHUD];
        [_uploadRequestIDs removeObject:aRequest.requestID];
        [_uploadRequestMap removeObjectForKey:aRequest.requestID];
        RCUploadMediaStatusListener *listener = [_listenerMap objectForKey:[[aRequest userInfo] objectForKey:@"listener"]];
        listener.errorBlock(RC_NETWORK_UNAVAILABLE);
    } else if ([aRequest.requestID isEqualToString:_checkFileRequestID]) { // 检查文件是否可以下载
        NSDictionary *userInfo = aRequest.userInfo;
        BOOL forward = [[userInfo objectForKey:@"forward"] boolValue];
        NSString *showStr = forward ? SY_STRING(@"forward_fileHaveDelete"):SY_STRING(@"msg_fileHaveDelete");
        [self cmp_hideProgressHUD];
        [self cmp_showHUDWithText:showStr];
    } else if ([aRequest.requestID isEqualToString:self.getTargetPersonalVoIPPermissionRequestID]) {
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemVoiceAndVideoCall];
    } else if ([aRequest.requestID isEqualToString:self.getTargetGroupVoIPPermissionRequestID]) {
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemVoiceAndVideoCall];
    } else if ([aRequest.requestID isEqualToString:self.getZhumuPluginPermissionRequestID]) {
         void (^completeBlock) (BOOL isHaveZhumuPlugin) = aRequest.userInfo[@"resultBlock"];
         if (completeBlock) {
             completeBlock(NO);
         }
    }
}


#pragma mark - SyLocalOfflineFilesListViewControllerDelegate

- (void)localOfflineFilesListViewController:(id)aLocalOfflineFilesListViewController didFinishedSelected:(NSArray<CMPOfflineFileRecord*> *)result {
    CMPOfflineFileRecord *file = [result lastObject];
   NSString *aPath = [CMPFileManager unEncryptFile:file.fullLocalPath fileName:file.localName];
    RCFileMessage *message = [RCFileMessage messageWithFile:aPath];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.title, @"toName", [NSString uuid], @"msgId", self.targetId, @"toId", [CMPCore sharedInstance].userID, @"userId", [CMPCore sharedInstance].currentUser.name, @"userName" ,nil];
    [message performSelector:@selector(setExtra:) withObject:[dic JSONRepresentation]];
    [self sendMediaMessage:message pushContent:@"" appUpload:YES];
}
- (void)localOfflineFilesListViewController:(id)aLocalOfflineFilesListViewController didPickDocumentsAtURLs:(NSArray<NSString*> *)result {
    for (NSString *filePath in result) {
         NSString *fileName = [filePath lastPathComponent];
         [self sendLocalFilesWithFileName:fileName filePath:filePath];
     }
}

- (void)localOfflineFilesListViewControllerDidCancel:(id)aLocalOfflineFilesListViewController {
    
}

#pragma mark -
#pragma mark -Navigation

- (CMPBannerNavigationBar *)bannerNavigationBar {
    if (!_bannerNavigationBar) {
        _bannerNavigationBar = [[CMPBannerNavigationBar alloc] init];
        _bannerNavigationBar.frame = CGRectMake(0, [UIView staticStatusBarHeight], self.view.width, 44);
        _bannerNavigationBar.leftMargin = 0.0f;
        _bannerNavigationBar.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
        [_bannerNavigationBar addBottomLine];
    }
    return _bannerNavigationBar;
}

- (void)setupNaviBar {
    self.statusBar = [[UIView alloc] init];
    self.statusBar.frame = CGRectMake(0, 0, self.view.width,[UIView staticStatusBarHeight]);
    self.statusBar.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
    [self.view addSubview:self.statusBar];
    
    [self.view addSubview:self.bannerNavigationBar];
    [self resetTitle:self.title];
}

- (void)addRightBarButton {
    NSMutableArray *arr = [NSMutableArray array];
    UIColor *themeColor = [CMPThemeManager sharedManager].iconColor;
    
    //ks add -- ontime meeting
    if (self.conversationType == ConversationType_GROUP
        ||(self.conversationType == ConversationType_PRIVATE && ![self.targetId isEqualToString:[CMPCore sharedInstance].userID] && ![CMPCommonManager isSeeyonRobotByUid:self.targetId])){
        if ([CMPMeetingManager otmIfServerSupport]) {
            if ([[CMPMeetingManager shareInstance] otmIfServerOpen]) {
                UIButton *meetingButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [meetingButton setFrame:kBannerImageButtonFrame];
                [meetingButton setImage:[[UIImage imageNamed:@"ontimelogo"] cmp_imageWithTintColor:themeColor] forState:UIControlStateNormal];
                [meetingButton addTarget:self action:@selector(ontimeMeetingAct:) forControlEvents:UIControlEventTouchUpInside];
                [arr addObject:meetingButton];
            }
        }
    }
    //end
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton setFrame:kBannerImageButtonFrame];
    
    if (self.conversationType == ConversationType_GROUP) {
        UIImage *image = [[UIImage imageNamed:@"group_detail.png"] cmp_imageWithTintColor:themeColor];
        [infoButton setImage:image forState:UIControlStateNormal];
        [infoButton addTarget:self action:@selector(showGroupDetail:) forControlEvents:UIControlEventTouchUpInside];
    } else if (self.conversationType == ConversationType_PRIVATE && ![self.targetId isEqualToString: [RCIMClient sharedRCIMClient].currentUserInfo.userId] ) {
        UIImage *image = [[UIImage imageNamed:@"people_detail.png"] cmp_imageWithTintColor:themeColor];
        [infoButton setImage:image forState:UIControlStateNormal];
        [infoButton addTarget:self action:@selector(showPeopleDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
    [arr addObject:infoButton];
    
    [self.bannerNavigationBar setRightBarButtonItems:arr];
    
}

- (void)setBackButton {
//    NSArray *viewControllers = self.navigationController.viewControllers;
//    
//    if (viewControllers.count < 1) {
//        return;
//    }
    
//    UIViewController *lastViewController = viewControllers[0];
//    NSString *title = lastViewController.title;
//
//    if (!title) {
//        title = @"";//SY_STRING(@"common_back");
//    }
    
    NSString *title = nil;
    if (CMPFeatureSupportControl.isBannarBackButtonShowText) {
        title = SY_STRING(@"common_back");;
    } else {
        title = @"";
    }
    
    CMPBannerBackButton *button =  [CMPBannerBackButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 70, 44);
    [button setImage:[[UIImage imageNamedAutoRTL:@"banner_return"] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor] forState:UIControlStateNormal];
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                   NSForegroundColorAttributeName : [CMPThemeManager sharedManager].iconColor};
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:title
                                                                      attributes:attributeDic];
    [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setLeftBarButtonItems:@[button]];
   
}

- (void)setCancelButton {
    NSString *title = SY_STRING(@"common_cancel");;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                   NSForegroundColorAttributeName : [CMPThemeManager sharedManager].iconColor};
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:title
                                                                      attributes:attributeDic];
    [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    [button addTarget:self action:@selector(onCancelMultiSelectEvent:) forControlEvents:UIControlEventTouchUpInside];
    #pragma clang diagnostic pop
    [self.bannerNavigationBar setLeftBarButtonItems:@[button]];
}

- (void)resetTitle:(NSString *)title {
    if ([self.targetId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {//文件助手聊天页标题国际化
        self.title = SY_STRING(self.title);
    } else {
        self.title = title?:self.navigationItem.title;
    }
    self.titleContent = self.title;
    [self.bannerNavigationBar updateBannerTitle:self.title];
    [self groupChatUpdateBannerTitle:self.title];
}

- (void)groupChatUpdateBannerTitle:(NSString *)title {
    CMPRCGroupMemberObject *groupInfo = self.groupInfo;
    if (self.conversationType == ConversationType_GROUP && groupInfo) {
        CMPBannerViewTitleLabel *bannerTitleView = self.bannerNavigationBar.bannerTitleView;
        bannerTitleView.text = nil;
        [bannerTitleView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        UIView *bannerTitleContentView = [[UIView alloc] init];
        bannerTitleContentView.backgroundColor = [UIColor clearColor];
        [bannerTitleView addSubview:bannerTitleContentView];
        
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.backgroundColor = [UIColor clearColor];
        titleLable.textColor = bannerTitleView.textColor;
        titleLable.font = bannerTitleView.font;
        titleLable.text = title;
        [bannerTitleContentView addSubview:titleLable];
        
        //ks fix -- v8.2 ue调整
        //ks fix bug -- V5-41860
        UILabel *membersCountLable = [self.bannerNavigationBar.titleExtContentView viewWithTag:11];
        if (!membersCountLable) {
            membersCountLable = [[UILabel alloc] init];
            membersCountLable.tag = 11;
            membersCountLable.backgroundColor = [UIColor clearColor];
            membersCountLable.textColor = UIColorFromRGB(0x666666);
            membersCountLable.font = [UIFont systemFontOfSize:10];
            membersCountLable.textAlignment = NSTextAlignmentCenter;
            [self.bannerNavigationBar.titleExtContentView addSubview:membersCountLable];
            [membersCountLable sizeToFit];
            [membersCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(-2);
                make.left.right.offset(0);
                make.bottom.offset(-5);
            }];
        }
        membersCountLable.text = [NSString stringWithFormat:@"(%lu)",(unsigned long)groupInfo.membersCount];
        
        BOOL isShowDepartmentTagLabel = (groupInfo.enumGroupType == CMPGroupTypeDepartment);
        UILabel *departmentTagLabel = nil;
        if (isShowDepartmentTagLabel) {
            departmentTagLabel = [[UILabel alloc] init];
            departmentTagLabel.backgroundColor = [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.2];
            departmentTagLabel.textColor = [UIColor cmp_colorWithName:@"theme-fc"];
            departmentTagLabel.textAlignment = NSTextAlignmentCenter;
            departmentTagLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
            departmentTagLabel.text = SY_STRING(@"common_dept");
            [bannerTitleContentView addSubview:departmentTagLabel];
            [departmentTagLabel sizeToFit];
        }
        
        [bannerTitleContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.centerX.equalTo(bannerTitleView);
            make.leading.equalTo(titleLable);
            if (isShowDepartmentTagLabel) {
                make.trailing.equalTo(departmentTagLabel);
             } else {
                make.trailing.equalTo(titleLable);
             }
            make.width.lessThanOrEqualTo(bannerTitleView);
        }];
        
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.equalTo(bannerTitleContentView);
            if (isShowDepartmentTagLabel) {
//                make.trailing.equalTo(departmentTagLabel.mas_leading);
             } else {
                make.trailing.equalTo(bannerTitleContentView);
             }
        }];
        
//        [membersCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.bottom.equalTo(bannerTitleContentView);
//            make.leading.equalTo(titleLable.mas_trailing);
//            if (isShowDepartmentTagLabel) {
//                make.trailing.equalTo(departmentTagLabel.mas_leading).offset(-6);
//            } else {
//                make.trailing.equalTo(bannerTitleContentView);
//            }
//            make.width.equalTo(membersCountLable.cmp_width);
//        }];
        
        [departmentTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.trailing.equalTo(bannerTitleContentView);
            make.left.equalTo(titleLable.mas_right).offset(2+4);
            make.width.equalTo(departmentTagLabel.cmp_width + 6);
            make.height.equalTo(departmentTagLabel.cmp_height + 4);
        }];
    }
}

#pragma mark - 群看板

- (void)setupGroupKanbanTool {
    if (![CMPFeatureSupportControl isChatViewSupportGroupKanban]) {
        return;
    }
    
    if (self.conversationType == ConversationType_PRIVATE) {
         return;
    }
    
//    if (self.childViewControllers.count) {
//           for (UIViewController *controller in self.childViewControllers) {
//               [controller willMoveToParentViewController:nil];
//               [controller.view removeFromSuperview];
//               [controller removeFromParentViewController];
//           }
//       }
       
//    if (self.segmentView) {
//       [self.segmentView removeFromSuperview];
//       self.segmentView = nil;
//    }
    self.conversationMessageCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.conversationMessageCollectionView.hidden = NO;
    [self.bannerNavigationBar hideBottomLine:NO];

    __weak typeof(self) weakSelf = self;
    [self getGroupKanbanInfoWithGroupId:self.targetId completion:^(NSArray *dataList) {
        if (dataList.count > 0) {
            [weakSelf setupGroupKanbanToolUIWithDataItems:[dataList copy]];
        }else{
            [_segScrollView removeFromSuperview];
            _segScrollView = nil;
            [_currentChildVCs removeAllObjects];
            
            if (self.childViewControllers.count) {
                   for (UIViewController *controller in self.childViewControllers) {
                       [controller willMoveToParentViewController:nil];
                       [controller.view removeFromSuperview];
                       [controller removeFromParentViewController];
                   }
               }
        }
    }];
}

- (void)setupGroupKanbanToolUIWithDataItems:(NSArray *)dataItems {
    NSDictionary *paramDic;
    NSString *appId;
    NSDictionary *params;
    NSMutableArray *paramDicArr = [NSMutableArray array];
    
    NSMutableSet *nowIdeSet = [NSMutableSet set];
    
    NSMutableArray *itemsArr = [[NSMutableArray alloc] init];
    CMPSegScrollViewItem *fItem = [[CMPSegScrollViewItem alloc] init];
    fItem.title = SY_STRING(@"rc_group_kanban_chat");
    fItem.identifier = @"kanban_firstindex";
    [itemsArr addObject:fItem];
    
    [nowIdeSet addObject:fItem.identifier];
    
    for (NSDictionary *dataItem in dataItems) {
        appId = dataItem[@"appId"];
        params = dataItem[@"param"];
        if ([params isKindOfClass:[NSNull class]]) {
            params = @{};
        }
        paramDic = @{
                  @"appId" : appId,
                  @"from" :  @"",
                  @"openApi" : @"openApp",
                  @"action" :  @"m3ShowGroupBoard",
                  @"params" : params ?: @{}
        };
        [paramDicArr addObject:paramDic];
        
        CMPSegScrollViewItem *aItem = [[CMPSegScrollViewItem alloc] init];
        aItem.title = dataItem[@"name"]? dataItem[@"name"]:@"";
        aItem.identifier = [NSString stringWithFormat:@"%@",appId];
        aItem.extra = [paramDic yy_modelToJSONString];
        [itemsArr addObject:aItem];
        
        [nowIdeSet addObject:aItem.identifier];
    }
    
    NSSet *set = [NSSet setWithArray:self.currentChildVCs.allKeys];
    for (NSString *ide in set) {
        if (![nowIdeSet containsObject:ide]) {
            UIViewController *controller = [self.currentChildVCs objectForKey:ide];
            if (controller) {
                [controller willMoveToParentViewController:nil];
                [controller.view removeFromSuperview];
                [controller removeFromParentViewController];
            }
            [self.currentChildVCs removeObjectForKey:ide];
        }
    }
   
    if (itemsArr.count>1) {
        
        self.conversationMessageCollectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
        [self.bannerNavigationBar hideBottomLine:YES];
        
        if (!_segScrollView) {
            _segScrollView = [[CMPSegScrollView alloc] init];
            _segScrollView.delegate = self;
            [self.view addSubview:_segScrollView];
            [_segScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bannerNavigationBar.mas_bottom);
                make.leading.trailing.equalTo(self.view);
                make.height.equalTo(50);
            }];
        }
        _segScrollView.itemsArr = itemsArr;
    }
}

- (void)ucGroupBoardSettingDidChangedNoti:(NSNotification *)noti {
    self.isUcGroupBoardSettingDidChanged = YES;
}

- (void)willReloadTabBarClearViewNotificationAction:(NSNotification *)notification {
    [self.actionSheet dissmiss];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.bannerNavigationBar.frame = CGRectMake(0, [UIView staticStatusBarHeight], self.view.width, 44);
    [self.bannerNavigationBar autoLayout];
    self.statusBar.frame = CGRectMake(0, 0, self.view.width,[UIView staticStatusBarHeight]);
}

// 屏蔽滑动返回
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

#pragma mark - 自定义PluginBoard UI

/**
 更新+号按钮点击之后的扩展功能item
 */
- (void)updatePluginBoardItem {
    self.chatSessionInputBarControl.pluginBoardView.contentView.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
    
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_ALBUM_TAG];
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_CAMERA_TAG];
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VOIP_TAG];
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG];
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
    
//    [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:PLUGIN_BOARD_ITEM_ALBUM_TAG
//                                                                 image:[UIImage imageNamed:@"rc_takepicture"]
//                                                                 title:SY_STRING(@"rc_PluginBoardPicture")];
//    [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:PLUGIN_BOARD_ITEM_CAMERA_TAG
//                                                                 image:[UIImage imageNamed:@"rc_opencamera"]
//                                                                 title:SY_STRING(@"rc_PluginBoardCamera")];
//    [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG
//                                                                 image:[UIImage imageNamed:@"rc_location"]
//                                                                 title:SY_STRING(@"rc_PluginBoardLocation")];
//    [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:PLUGIN_BOARD_ITEM_VOIP_TAG
//                                                                 image:[UIImage imageNamed:@"rc_VoIPAudio"]
//                                                                 title:SY_STRING(@"rc_PluginBoard_VoIPAudioCall")];
//    [self.chatSessionInputBarControl.pluginBoardView updateItemWithTag:PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG
//                                                                 image: [UIImage imageNamed:@"rc_VoIPVideo"]
//                                                                 title:SY_STRING(@"rc_PluginBoard_VoIPVideoCall")];
    
    CMPChatManager *chatManager =  [CMPChatManager sharedManager];
    BOOL isFileAssistant = self.isFileAssistant;
    
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_takepicture"]
                                                     title:SY_STRING(@"rc_PluginBoardPicture")
                                                     atIndex:0
                                                     tag:kPluginBoardItemPicture];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_VoIPVideo"]
                                                     title:SY_STRING(@"rc_PluginBoard_VoIPAudioAndVideoCall")
                                                     atIndex:1
                                                     tag:kPluginBoardItemVoiceAndVideoCall];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_associatedDocument"]
                                                     title:SY_STRING(@"ass_doc")
                                                     atIndex:2
                                                     tag:kPluginBoardItemAssociatedDocument];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_collection"]
                                                     title:SY_STRING(@"share_btn_collect")
                                                     atIndex:3
                                                     tag:kPluginBoardItemCollection];
//    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_quick_zhumu_meeting"]
//                                                     title:SY_STRING(@"quick_zhumu_meeting")
//                                                   atIndex:4
//                                                       tag:kPluginBoardItemQuickZhumuMeetting];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_location"]
                                                     title:SY_STRING(@"rc_PluginBoardLocation")
                                                     atIndex:4
                                                     tag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_quick_coll"]
                                                     title:SY_STRING(@"share_btn_new_coopa")
                                                     atIndex:5
                                                     tag:kPluginBoardItemQuickColl];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_form_template"]
                                                     title:SY_STRING(@"quick_form")
                                                     atIndex:6
                                                     tag:kPluginBoardItemFormTemplate];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_quick_meeting"]
                                                     title:SY_STRING(@"quick_meeting")
                                                     atIndex:7
                                                     tag:kPluginBoardItemQuickMeetting];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_quick_task"]
                                                     title:SY_STRING(@"quick_task")
                                                     atIndex:8
                                                     tag:kPluginBoardItemQuickTask];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_quick_schedule"]
                                                     title:SY_STRING(@"quick_schedule")
                                                     atIndex:9
                                                     tag:kPluginBoardItemQuickSchedule];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_sendfile"]
                                                     title:SY_STRING(@"rc_PluginBoardFile")
                                                     atIndex:10
                                                     tag:kPluginBoardItemFile];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"rc_businessCard"]
                                                     title:SY_STRING(@"msg_personal_card")
                                                     atIndex:11
                                                     tag:kPluginBoardItemBusinessCard];
    
    
    if (![CMPFeatureSupportControl isChatViewPluginBoardSupportLightCollItems] || isFileAssistant) {
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemAssociatedDocument];
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemCollection];
         //[self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemQuickZhumuMeetting];
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemBusinessCard];
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemQuickColl];
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemFormTemplate];
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemQuickMeetting];
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemQuickTask];
         [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemQuickSchedule];
    }
    
    if (isFileAssistant || !chatManager.isVideoEnable || !chatManager.videoStatus || ![[RCCall sharedRCCall] isAudioCallEnabled:self.conversationType] || ![[RCCall sharedRCCall] isVideoCallEnabled:self.conversationType]){
           [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemVoiceAndVideoCall];
    }
}

- (void)removeFilePluginBoardItem {
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemFile];
}

- (BOOL)isFileAssistant {
    BOOL isFileAssistant = [self.targetId isEqualToString: [RCIMClient sharedRCIMClient].currentUserInfo.userId];
    return isFileAssistant;
}

#pragma mark - PluginBoard Action

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    if ([self remindVideoExpireWithTag:tag]) {
        return;
    }

    [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    
    if (tag == kPluginBoardItemFile) { // 打开离线文档界面
        [self openOfflineFiles];
    } else if(tag == kPluginBoardItemBusinessCard) {
        [self showChooseMemberViewController];
    } else if(tag == kPluginBoardItemAssociatedDocument) {
        [self showChooseAccdocViewController];
    } else if(tag == kPluginBoardItemPicture) {
        [self openCustomAlbumOrCamera];
    } else if(tag == kPluginBoardItemVoiceAndVideoCall) {
        [self openVoiceOrVideoCall];
    } else if(tag == kPluginBoardItemCollection) {
        [self showChooseH5AppViewControllerWithAppId:@"60"];
    } else if(tag == kPluginBoardItemQuickColl) {
        [self enterQuickNewEntryPageWithAppId:@"1" paramObject:@{@"createType":@"freeColl"}];
    } else if(tag == kPluginBoardItemFormTemplate) {
        [self enterQuickNewEntryPageWithAppId:@"1" paramObject:@{@"createType":@"template"}];
    } else if(tag == kPluginBoardItemQuickMeetting) {
        [self enterQuickNewEntryPageWithAppId:@"6" paramObject:nil];
    } else if(tag == kPluginBoardItemQuickTask) {
        [self enterQuickNewEntryPageWithAppId:@"30" sourceType:@"100" paramObject:nil];
    } else if(tag == kPluginBoardItemQuickSchedule) {
        [self enterQuickNewEntryPageWithAppId:@"11" paramObject:nil];
    } else if(tag == kPluginBoardItemQuickZhumuMeetting) {
        [self jumpToZhumuApp];
    }
}

- (void)openOfflineFiles {
    if (CMPFeatureSupportControl.isChatViewUseMyFilesOpenOfflineFiles) {
        CMPMyFilesViewController *myFilesVC = [[CMPMyFilesViewController alloc] init];
        myFilesVC.delegate = self;
        [self.navigationController pushViewController:myFilesVC animated:YES];
    }else {
        SyLocalOfflineFilesListViewController *controller = [[SyLocalOfflineFilesListViewController alloc] init];
        controller.delegate = self;
        controller.allowRotation = NO;
        controller.isFromChatViewController = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

- (void)openCustomAlbumOrCamera {
    CMPActionSheet *  actionSheet  = [CMPActionSheet actionSheetWithTitle:nil sheetTitles:@[SY_STRING(@"video_component_take_photo"),SY_STRING(@"video_component_select_from_album")] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if (buttonIndex == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillShow object:nil];
            CMPCameraViewController *cameraVc = CMPCameraViewController.alloc.init;
            [self.navigationController presentViewController:cameraVc animated:YES completion:nil];
            __weak typeof(self) weakSelf = self;
            cameraVc.usePhotoClicked = ^(UIImage *img, NSDictionary *videoInfo) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
                [weakSelf sendShutterImgOrVideoFiles:img videoInfo:videoInfo];
            };
            cameraVc.didDismissBlock = ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
            };
        } else if (buttonIndex == 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillShow object:nil];
            [self openCustomAlbum];
        }
        #pragma clang diagnostic pop
    }];
    [actionSheet show];
    self.actionSheet = actionSheet;
}

- (void)openVoiceOrVideoCall {
    CMPActionSheet *  actionSheet  = [CMPActionSheet actionSheetWithTitle:nil sheetTitles:@[SY_STRING(@"rc_PluginBoard_VoIPAudioCall"),SY_STRING(@"rc_PluginBoard_VoIPVideoCall")] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if (buttonIndex == 1) {
           [CMPRuntimeUtils callMethodWithTarget:self selector:@selector(openDynamicFunction:) argumemts:@[@(kPluginVoiceCall)] returnValue:nil];
        } else if (buttonIndex == 2) {
           [CMPRuntimeUtils callMethodWithTarget:self selector:@selector(openDynamicFunction:) argumemts:@[@(kPluginVideoCall)] returnValue:nil];
        }
        #pragma clang diagnostic pop
    }];
    [actionSheet show];
    self.actionSheet = actionSheet;
}

- (void)jumpToZhumuApp {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"zhumu://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"zhumu://"]];
    } else {
        CMPAlertView *alertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"UpdatePackage_TipTitle")
                                                              message:SY_STRING(@"没有安装瞩目APP,点击下载跳转到下载页面")
                                                    cancelButtonTitle:SY_STRING(@"common_cancel")
                                                    otherButtonTitles:[NSArray arrayWithObjects:SY_STRING(@"UpdatePackage_Download"),nil]
                                                             callback:^(NSInteger buttonIndex) {
                                       if (buttonIndex == 1) {
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/id956446341"]];
                                       }
                                   }];
        [alertView show];
    }
}

#pragma mark - CMPMyFilesViewControllerDelegate

- (void)myFilesVCDocumentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSString *> *)urls {
    for (NSString *filePath in urls) {
//        BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
//        if(fileUrlAuthozied){
//            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
//            NSError *error;
//            [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
                NSString *fileName = [filePath lastPathComponent];
                [self sendLocalFilesWithFileName:fileName filePath:filePath];
//
//            }];
//            [url stopAccessingSecurityScopedResource];
//        }
    }
    
}

- (void)myFilesVCSendClicked:(NSArray<CMPFileManagementRecord *> *)selectedFiles {
    for (CMPFileManagementRecord *mfr in selectedFiles) {
        [self sendLocalFilesWithFileName:mfr.fileName filePath:mfr.filePath];
    }
}

#pragma mark 文件发送

/// 发送多文件分享过来的文件
- (void)sendFiesWtihFilePaths
{
//    if (self.filePaths.count == 0) return;
//    if (self.willForward) {
//        self.willForward();
//    }
//
    for (NSString *filePath in self.filePaths) {
        [self sendLocalFilesWithFileName:filePath.lastPathComponent filePath:filePath];
    }
    self.filePaths = nil;
}

- (void)setFilePaths:(NSArray *)filePaths {
    _filePaths = filePaths;
}

- (void)sendLocalFilesWithExtra:(NSDictionary *)extra mediaModel:(RCMediaMessageContent *)mediaModel {
    CMPChatSentFile *sentFile = [[CMPChatSentFile alloc] init];
    sentFile.dic = extra;
    
    if ([mediaModel isKindOfClass: RCImageMessage.class]) {
        
        sentFile.imageMsg = (RCImageMessage *)mediaModel;
        
    }else {
        
        sentFile.fileMsg = (RCFileMessage *)mediaModel;
    }
    
    [self fireSendingFile:sentFile];
}

- (void)sendLocalFilesWithFileName:(NSString *)fileName filePath:(NSString *)filePath {
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
  /*  NSString *tmpPath = filePath.stringByRemovingPercentEncoding;
    //拷贝到我们APP。才能进行发送操作
    if (tmpPath) {
        filePath = tmpPath;
    }*/
    NSString *newPath = filePath;//[FCFileManager copyFileToTempWithPath:filePath];
    NSInteger attType = [CMPFileManager getFileType:newPath];
    
    if (attType == QK_AttchmentType_Video) {
        NSString *filePath = newPath;
        NSInteger videoTime = [CMPCommonTool getVideoTimeByUrlString:filePath];
        NSDictionary *videoInfo = @{
            @"videoUrl": newPath,
            @"videoTime": @(videoTime)
        };
        [self sendLocalVideoWithVideoInfo:videoInfo];
        return;
    }
    
    CMPChatSentFile *sentFile = [[CMPChatSentFile alloc] init];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"toName"] = self.title;
    dic[@"msgId"] = [NSString uuid];
    dic[@"toId"] = self.targetId;
    dic[@"userId"] = [CMPCore sharedInstance].userID;
    dic[@"userName"] = [CMPCore sharedInstance].currentUser.name;
    dic[@"fileName"] = fileName;
    sentFile.dic = dic;
    
    if (attType == QK_AttchmentType_Image) {
        //是图片就发送文件
        RCImageMessage *imageMessage = [RCImageMessage messageWithImageURI:newPath];
        if (!imageMessage.localPath) {
            imageMessage.localPath = newPath;
        }
        
        sentFile.imageMsg = imageMessage;
        
    }
    ////ks fix -- V5-35269 iOS 聊天发送html格式的文件，显示为空(将other注释，否则html被转成gifmsg导致报错)
    else if (/*attType == QK_AttchmentType_Office_Other||*/attType == QK_AttchmentType_Gif) {
        //gif
        NSData *gifImageData = [NSData dataWithContentsOfFile:filePath];
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:gifImageData];
        NSString *tempLoadPath = [CMPFileManager gifMultiTempPath];
        [gifImageData writeToFile:tempLoadPath atomically:YES];
        RCGIFMessage *gifMsg = [RCGIFMessage messageWithGIFURI:tempLoadPath width:gifImage.size.width height:gifImage.size.height];
        if (!gifMsg.name) {
            gifMsg.name = fileName;
        }
        if (!gifMsg.localPath) {
            gifMsg.localPath = newPath;
        }
        sentFile.gifMsg = gifMsg;
        
        
    }
    else {
        RCFileMessage *message = [RCFileMessage messageWithFile:newPath];
        if (!message.name) {
            message.name = fileName;
        }
        if (!message.localPath) {
            message.localPath = newPath;
        }
        sentFile.fileMsg = message;
    }
    [self fireSendingFile:sentFile];
    
}

/// 发送视频文件
/// @param videoInfo 视频文件信息
- (void)sendLocalVideoWithVideoInfo:(NSDictionary *)videoInfo {
    NSString *filePath = videoInfo[@"videoUrl"];
    NSInteger videoTime = [videoInfo[@"videoTime"] integerValue];
    NSString *fileName = filePath.lastPathComponent;
    UIImage *thumImage =  [CMPCommonTool getScreenShotImageFromVideoUrl:filePath size:CGSizeMake(202, 202)];
    
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSString *tmpPath = filePath.stringByRemovingPercentEncoding;
    //拷贝到我们APP。才能进行发送操作
    if (tmpPath) {
        filePath = tmpPath;
    }
    NSString *newPath = [FCFileManager copyFileToTempWithPath:filePath];
    CMPChatSentFile *sentFile = [[CMPChatSentFile alloc] init];
    
    CMPVideoMessage *videoMessage = [CMPVideoMessage messageWithFile:newPath];
    videoMessage.timeDuration = videoTime;
    videoMessage.videoThumImage = thumImage;
    
    if (!videoMessage.name) {
        videoMessage.name = fileName;
    }
    if (!videoMessage.localPath) {
        videoMessage.localPath = newPath;
    }
    sentFile.videoMsg = videoMessage;
    [self fireSendingFile:sentFile];
}

/// 发送图片文件
/// @param videoInfo 视频文件信息
- (void)sendImages:(NSArray<UIImage *> *)images {
    [self cmp_showProgressHUD];
    self.uploadImagesCount = 0;
    self.sendImagesCount = images.count;
    //延时0.1秒为了显示先loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIImage *image in images) {
            RCImageMessage *imageMessage = [RCImageMessage messageWithImage:image];
            CMPChatSentFile *sentFile = [[CMPChatSentFile alloc] init];
            sentFile.imageMsg = imageMessage;
            [self fireSendingFile:sentFile];
        }
    });
}

- (void)fireSendingFile:(CMPChatSentFile *)sentFile{
    
    if (self.chatSessionInputBarControl.currentBottomBarStatus != KBottomBarDefaultStatus &&
        self.chatSessionInputBarControl.currentBottomBarStatus != KBottomBarRecordStatus) {
        [self.chatSessionInputBarControl resetToDefaultStatus];
    }
    
    if (sentFile.imageMsg) {
        [sentFile.imageMsg setExtra:sentFile.dic.JSONRepresentation];
        [self sendMessage:sentFile.imageMsg pushContent:nil];
    }
    else if (sentFile.videoMsg) {
        [sentFile.videoMsg setExtra:sentFile.dic.JSONRepresentation];
        [self sendMediaMessage:sentFile.videoMsg pushContent:@"" appUpload:YES];
    }
    else if (sentFile.gifMsg) {
        [sentFile.gifMsg setExtra:sentFile.dic.JSONRepresentation];
        [self sendMediaMessage:sentFile.gifMsg pushContent:@"" appUpload:YES];
    }
    else {
        [sentFile.fileMsg setExtra:sentFile.dic.JSONRepresentation];
        [self sendMediaMessage:sentFile.fileMsg pushContent:@"" appUpload:YES];
    }
    
}

#pragma mark - 自己拍摄的图片文件的发送（拍完后点击了发送按钮）

- (void)sendShutterImgOrVideoFiles:(UIImage *)img videoInfo:(NSDictionary *)videoInfo {
    //发送图片
    if (img) {
       [self performSelector:@selector(imageDidCapture:) withObject:img];
    }
    //发送视频
    if (videoInfo) {
        [self sendLocalVideoWithVideoInfo:videoInfo];
    }
}

#pragma mark - CMPImagePickerController

- (void)openCustomAlbum {
    CMPImagePickerController *imagePickerVc = [[CMPImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.sortAscendingByModificationDate = NO;
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    __weak typeof(self) weakSelf = self;
    imagePickerVc.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
        [weakSelf sendImages:photos];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
    };
    imagePickerVc.didFinishPickingVideoHandle = ^(UIImage *coverImage, PHAsset *asset) {
        [MBProgressHUD cmp_showProgressHUDWithText:SY_STRING(@"video_compress")];
        [[CMPImageManager manager] getVideoOutputPathWithAsset:asset success:^(NSString *outputPath) {
            [CMPCommonTool convertVideoQuailtyWithInputURL:[NSURL URLWithPathString:outputPath] completeHandler:^(NSString *outputUrl) {
                NSDictionary  *videoInfo = @{@"videoUrl" : outputUrl,
                                @"videoSize" : NSStringFromCGSize([CMPCommonTool getVideoSizeWithUrl:outputUrl]),
                                @"videoTime" : @([CMPCommonTool getVideoTimeByUrlString:outputUrl])
                };
                [weakSelf sendLocalVideoWithVideoInfo:videoInfo];
                [MBProgressHUD cmp_hideProgressHUD];
            }];
        } failure:^(NSString *errorMessage, NSError *error) {
            [MBProgressHUD cmp_hideProgressHUD];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
    };
    imagePickerVc.didFinishPickingGifImageHandle = ^(UIImage *animatedImage, id sourceAssets) {
        [[CMPImageManager manager] getOriginalPhotoDataWithAsset:sourceAssets completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            NSData *gifImageData = data;
            FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:gifImageData];
            NSString *tempLoadPath = [CMPFileManager gifMultiTempPath];
            [gifImageData writeToFile:tempLoadPath atomically:YES];
            RCGIFMessage *gifMsg = [RCGIFMessage messageWithGIFURI:tempLoadPath width:gifImage.size.width height:gifImage.size.height];
            [weakSelf sendMediaMessage:gifMsg pushContent:@"" appUpload:YES];
        }];
       [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
    };
    imagePickerVc.imagePickerControllerDidCancelHandle = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_CameraWillHide object:nil];
    };
    
}

#pragma mark - 文件发送回调

- (void)messageBaseCellUpdateSendingStatus:(NSNotification *)noti {
    NSString * const kCanRecieveMessages = [NSString stringWithFormat:@"%@,%@,%@",CONVERSATION_CELL_STATUS_SEND_FAILED,CONVERSATION_CELL_STATUS_SEND_SUCCESS,CONVERSATION_CELL_STATUS_SEND_CANCELED];
    
    RCMessageCellNotificationModel *model = noti.object;
    
    if ([kCanRecieveMessages containsString:model.actionName]) {
        //发完后滚动到底部
        NSInteger section = [self.conversationMessageCollectionView numberOfSections];
        if (section>0) {
            NSInteger row = [self.conversationMessageCollectionView numberOfItemsInSection:section-1];
            if (row>0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row-1 inSection:section-1];
                [self.conversationMessageCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionBottom) animated:YES];
            }
        }
    }
}

- (BOOL)remindVideoExpireWithTag:(NSInteger)tag {
    CMPChatManager *chatManager = [CMPChatManager sharedManager];
    if (tag == kPluginBoardItemVoiceAndVideoCall && chatManager.isRemindVideoExpire) {
        NSString *alreadyRemindDayStr = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultName_RemindVideoExpireDay];
        NSString *currentDayStr = [[NSDate date] formatDateDayString];
        if (![currentDayStr isEqualToString:alreadyRemindDayStr] || chatManager.videoExpirationDays == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:currentDayStr forKey:kUserDefaultName_RemindVideoExpireDay];
            NSString *message = [CMPChatManager sharedManager].videoExpirationRemindMsg;
            CMPAlertView * alert = [[CMPAlertView alloc] initWithTitle:@"" message:[NSString isNotNull:message] ? message : @"" cancelButtonTitle:SY_STRING(@"common_confirm") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                
            }];
            [alert show];
            return YES;
        }
    }
    
    return NO;
}

/**
 清空消息记录
 */
- (void)clearMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationDataRepository removeAllObjects];
        [self.conversationMessageCollectionView reloadData];
    });
}

- (void)setClearMessageFlag {
    _isClearMessage = YES;
}

- (void)receiveMessageNotification:(NSNotification *)notification {
    _isReceiveMessage = YES;
}

- (void)deleteMessageNotification:(NSNotification *)notification {
    _isSendMessage = YES;
}

/**
 清除未读消息
 */
- (void)clearUnread {
    CMPMessageObject *object = [[CMPMessageObject alloc] init];
    object.subtype = (CMPRCConversationType)self.conversationType;
    object.cId = self.targetId;
    object.type = CMPMessageTypeRC;
    [[CMPMessageManager sharedManager] readMessageWithAppId:object clearMessage:YES];
}

/**
 私聊文件开始下载，发送消息给对方
 */
- (void)sendFileStatusReceiptMsgUId:(NSString *)msgUId msgId:(NSString *)msgId status:(NSString *)fileStatusReceipt {
    CMPFileStatusReceiptMessage *message = [[CMPFileStatusReceiptMessage alloc] init];
    NSDictionary *extraDic = @{@"msgUId" : msgUId,
                               @"msgId" : msgId};
    message.extra = [extraDic JSONRepresentation];
    message.fileStatusReceipt = fileStatusReceipt;
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.targetId content:message pushContent:nil pushData:nil success:^(long messageId) {
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"RC---发送CMPFileStatusReceiptMessage失败nErrorCode=%ld", (long)nErrorCode);
    }];
}

- (NSCache<NSString *,NSOperation *> *)requestBusinessMessagesPermissionCache {
    if (!_requestBusinessMessagesPermissionCacheQueue) {
        _requestBusinessMessagesPermissionCacheQueue = [[NSOperationQueue alloc] init];
    }
    return _requestBusinessMessagesPermissionCache;
}

- (NSOperationQueue *)requestBusinessMessagesPermissionCacheQueue {
    if (!_requestBusinessMessagesPermissionCache) {
        _requestBusinessMessagesPermissionCache = [[NSCache alloc] init];
    }
    return _requestBusinessMessagesPermissionCacheQueue;
}

- (NSMutableDictionary *)quickProcessCacheDic {
    if (!_quickProcessCacheDic) {
        _quickProcessCacheDic = [NSMutableDictionary dictionary];
    }
    return _quickProcessCacheDic;
}

- (void)showChooseMemberViewController {
    CMPChatChooseBusinessController *controller = [[CMPChatChooseBusinessController alloc] init];
    controller.delegate = self;
    controller.type = @"member";
    controller.max = 5;
    [self pushInDetailWithViewController:controller];
}

- (void)showChooseAccdocViewController {
    CMPChatChooseBusinessController *controller = [[CMPChatChooseBusinessController alloc] init];
    controller.delegate = self;
    controller.type = @"accdoc";
    controller.max = 5;
    [self pushInDetailWithViewController:controller];
}

- (void)showChooseH5AppViewControllerWithAppId:(NSString *)appId {
    CMPChatChooseBusinessController *controller = [[CMPChatChooseBusinessController alloc] init];
    controller.delegate = self;
    controller.type = @"h5App";
    controller.appId = appId;
    controller.max = 5;
    [self pushInDetailWithViewController:controller];
}


- (void)didSelectWithMembers:(NSArray<NSDictionary<NSString *,id> *> *)members {
    for (NSDictionary *dic in members) {
        CMPBusinessCardMessage *message = [[CMPBusinessCardMessage alloc] init];
        message.personnelId = [dic objectForKey:@"id"];
        message.name = [dic objectForKey:@"title"];
        message.department = [dic objectForKey:@"dept"];;
        message.post = [dic objectForKey:@"post"];
        [[RCIM sharedRCIM] sendMessage:self.conversationType targetId:self.targetId content:message pushContent:@"[人员名片]" pushData:nil success:^(long messageId) {
            
           } error:^(RCErrorCode nErrorCode, long messageId) {
               
        }];
    }
}

- (void)didSelectWithAccdocsAndh5Apps:(NSArray<NSDictionary<NSString *,id> *> *)accdocs {
    for (NSDictionary *dic in accdocs) {
        [[CMPMessageManager sharedManager] sendBusinessMessageWithParam:dic receiverIds:self.targetId  success:^(NSString * _Nonnull messageId,id _Nonnull data) {
            
        } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
            
        }];
    }
}

- (void)getQuickProcessWithCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CMPGeneralBusinessMessageCell class]]) {
        NSString *key = [NSString stringWithLongLong:cell.model.messageId];
        NSOperation *value = [self.requestBusinessMessagesPermissionCache objectForKey:key];
        
        NSString *quickProcessJsonStr = [self.quickProcessCacheDic objectForKey:indexPath];
        if ([NSString isNotNull:quickProcessJsonStr] && [NSString isNull:cell.model.extra]) {
            cell.model.extra = quickProcessJsonStr;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.model.cellSize = CGSizeZero;
                [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            });
            return;
        }
        
        if (!value) {
            __weak  CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)cell.model.content;
            __weak typeof(self) weakSelf = self;
            NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                [[CMPMessageManager sharedManager] getQuickProcessWithId:businessMessage.appId messageCategory:businessMessage.messageCategory success:^(NSString * _Nonnull messageId,id _Nonnull data) {
                    if (data && [data  isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dataValueDic = data[@"data"];
                        if (dataValueDic && [dataValueDic isKindOfClass:[NSDictionary class]]) {
                            NSArray *items = [dataValueDic[@"extParam"][@"attitude"] JSONValue];
                            NSDictionary *quickProcessDic = @{
                                @"quickProcessItems" : items ?: [NSArray array],
                                @"quickProcessHandleParam" : dataValueDic[@"handleParam"] ?:[NSDictionary dictionary]
                            };
                            NSString *quickProcessJsonStr = [quickProcessDic JSONRepresentation];
                            cell.model.extra = [quickProcessDic JSONRepresentation];
                            [weakSelf.quickProcessCacheDic setObject:quickProcessJsonStr forKey:indexPath];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CGSize oldSize = cell.model.cellSize;
                                cell.model.cellSize = CGSizeZero;
                                [weakSelf.conversationMessageCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                                
                                //动态增加cell的高度后，整体offset滚动
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    CGSize newSize = cell.model.cellSize;
                                    CGFloat offsetY = newSize.height - oldSize.height;
                                    if (offsetY > 0) {
                                        CGFloat oldOffSetY = weakSelf.conversationMessageCollectionView.contentOffset.y;
                                        [weakSelf.conversationMessageCollectionView setContentOffset:CGPointMake(0, oldOffSetY+offsetY)];
                                    }
                                });
                            });
                        }
                    }
                } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
                           
                }];
         }];
        [self.requestBusinessMessagesPermissionCache setObject:op forKey:key];
        [self.requestBusinessMessagesPermissionCacheQueue addOperation:op];
    
        }
    }
}

- (void)generalBusinessMessageCell:(CMPGeneralBusinessMessageCell *)cell didSelectedButton:(NSUInteger)index quickprocessRequestParam:(NSDictionary *)quickprocessRequestParam {
    [[CMPMessageManager sharedManager] quickProcessWithParam:quickprocessRequestParam success:^(NSString * _Nonnull messageId, id  _Nonnull data) {
        cell.model.extra = nil;
        NSIndexPath *indexPath = [self.conversationMessageCollectionView indexPathForCell:cell];
        if (indexPath) {
            [self.quickProcessCacheDic removeObjectForKey:indexPath];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dataDic = data[@"data"];
            BOOL isSeccess = [dataDic[@"success"] boolValue];
            NSString *failInfo = dataDic[@"msg"] ?: @"";
            if (isSeccess) {
                [self cmp_showSuccessHUDWithText:SY_STRING(@"rc_msg_general_business_handel_success")];
            } else {
                [self cmp_showHUDWithText:failInfo completionBlock:^{
                    [self viewGeneralBusinessMessagePageWithMessageModel:cell.model];
                }];
            }
           cell.model.cellSize = CGSizeZero;
           NSIndexPath *indexPath = [self.conversationMessageCollectionView indexPathForCell:cell];
            if (indexPath) {
                [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
       });
    } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cmp_showHUDWithText:SY_STRING(@"rc_msg_general_business_handel_fail")];
        });
    }];
}

#pragma mark - 跳转页面

- (void)pushInDetailWithViewController:(UIViewController *)vc {
    if (CMP_IPAD_MODE &&
        [self cmp_canPushInDetail]) {
        [self cmp_clearDetailViewController];
        [self cmp_showDetailViewController:vc];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
 跳转到指定业务应用
 */
- (void)startAppWebViewWithAppId:(NSString *)appId from:(NSString *)from openApi:(NSString *)openApi action:(NSString *)action params:(id)params {
       NSDictionary *paramDic = @{
           @"appId" : appId ?: @"",
           @"from" : from ?: @"",
           @"openApi" : openApi ?: @"",
           @"action" : action ?: @"",
           @"params" : params ?: @{}
       };
       CMPBannerWebViewController *controller = [CMPBannerWebViewController bannerWebView1WithUrl:@"http://cmp/v1.0.0/page/cmp-app-access.html" params:paramDic];
       [self pushInDetailWithViewController:controller];
}

#pragma mark - 穿透页面

/*
 查看合并消息页面
 */
-(void)viewMergeMessagePageWithChatContentId:(NSString *)chatContentId {
    NSDictionary *paramDic = @{
        @"messageid":chatContentId,
        @"targetInfo":@{@"targetType":@(self.conversationType),
                        @"targetId":self.targetId}
    };
    [self startAppWebViewWithAppId:@"61" from:@"" openApi:@"messageRecord" action:@"detail" params:paramDic];
}

/*
 查看业务消息等消息页面
 */
-(void)viewGeneralBusinessMessagePageWithMessageCategoryId:(NSString *)messageCategoryId paramObject:(id)paramObject {
    [self startAppWebViewWithAppId:messageCategoryId from:@"im-card" openApi:@"" action:@"" params:paramObject];
}

/*
 查看业务消息消息页面
 */
-(void)viewGeneralBusinessMessagePageWithMessageModel:(RCMessageModel *)model {
    CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)model.content;
    NSString *mobileUrlParam = businessMessage.mobileUrlParam;
    if ([NSString isNotNull:mobileUrlParam]) {
        id paramObject = [businessMessage.mobileUrlParam JSONValue] ?: businessMessage.mobileUrlParam;
        if (businessMessage.mobileOpenEnable) {
            [self viewGeneralBusinessMessagePageWithMessageCategoryId:businessMessage.messageCategory paramObject:paramObject];
        }
    }else{
        //ks add -- ontimemeet
        if ([@"109" isEqualToString:businessMessage.messageCategory]) {
            if ([CMPMeetingManager isDateValidWithin30MinituesByTimestramp:model.sentTime]) {
                NSDictionary *info = businessMessage.messageCard;
                if (info) {
                    NSString *meetNumb = info[@"meetingNum"] ? : @"";
                    NSString *meetPwd = info[@"meetingPassword"];
                    NSString *meetLink = info[@"meetingLink"] ? : @"";
//                    NSString *isConsistent = info[@"isConsistent"];
//                    if (isConsistent && [@"0" isEqualToString:isConsistent]) {
//                        meetNumb = @"";//如果不一致 就将会议号滞空，就会走link逻辑
//                    }
                    [[CMPMeetingManager shareInstance] otmVerifyMeetingValidWithInfo:info completion:^(BOOL validable, NSError * _Nonnull error, id  _Nonnull ext) {
                        if (validable) {
                            [CMPMeetingManager otmOpenWithNumb:meetNumb pwd:meetPwd link:meetLink result:^(BOOL success, NSError * _Nonnull error) {
                                if (!success && error) {
                                    if (error.code == -104) {
                                        [CMPObject cmp_showHUDWithText:@"会议链接格式有误，无法打开"];
                                    }
                                }
                            }];
                        }else{
                            
                        }
                    }];
                }
            }
        }
    }
}

/*
 新建快捷入口
 */
-(void)enterQuickNewEntryPageWithAppId:(NSString *)appId paramObject:(NSDictionary *)paramDic {
    [self enterQuickNewEntryPageWithAppId:appId sourceType:@"61" paramObject:paramDic];
}

-(void)enterQuickNewEntryPageWithAppId:(NSString *)appId sourceType:(NSString *)sourceType paramObject:(NSDictionary *)paramDic {
    paramDic = paramDic?: @{};
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    [paramsDic setObject:sourceType forKey:@"sourceType"];
    [paramsDic setObject:self.targetId forKey:@"sourceId"];
    [self startAppWebViewWithAppId:appId from:@"" openApi:@"appCreatePage" action:@"" params:paramsDic];
}

- (void)redPacketSendFinish:(RCMessageContent*)msg {
    
    [self willSendMessage:msg];
}

- (void)redPacketOpenFinish:(RCMessageContent*)msg {
    
    [self willSendMessage:msg];
}

//处理撤回消息重新编辑显示
- (void)handleReeditDisplayMessageCell:(RCMessageBaseCell *)cell{
    /* 融云有自己的了，不用我们添加
    if ([cell isMemberOfClass:[RCTipMessageCell class]]) {
        
        if ([cell.model.content isMemberOfClass:[RCRecallNotificationMessage class]]) {
            
            NSDictionary *extraDic = [cell.model.extra JSONValue];
            
            if (extraDic) {
                
                NSString *content = extraDic[@"content"];
                NSString *time = extraDic[@"time"];
                
                NSDate *nowDate = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *timeDate = [dateFormatter dateFromString:time];
                NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:timeDate toDate:nowDate options:0];
                NSInteger minute = [dateComponents minute];
                
                BOOL isNeedReedit = minute <= 1 ? YES : NO;
                
                if (isNeedReedit) {//超过10分钟不显示重新编辑
                    
                    RCTipMessageCell *newCell = (RCTipMessageCell *)cell;
                    
                    NSDictionary *highlightedAttributeDictionary = @{
                                                                     @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : CMP_HEXCOLOR(0x3CBAFF)}
                                                                     };
                    [newCell.tipMessageLabel setAttributeDictionary:highlightedAttributeDictionary];
                    
                    NSString *textLabelStr = newCell.tipMessageLabel.text;
                    newCell.tipMessageLabel.text = [NSString stringWithFormat:@"%@ %@",textLabelStr,SY_STRING(@"msg_reedit")];
                    [newCell.tipMessageLabel setText:newCell.tipMessageLabel.text dataDetectorEnabled:YES];
                    NSRange range = NSMakeRange(textLabelStr.length + 1,SY_STRING(@"msg_reedit").length);
                    NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult phoneNumberCheckingResultWithRange:range
                                                                                                            phoneNumber:content];
                    [newCell.tipMessageLabel.attributedStrings addObject:textCheckingResult];
                    [newCell.tipMessageLabel setTextHighlighted:YES atPoint:CGPointZero];
                    
                    CGFloat maxMessageLabelWidth = newCell.baseContentView.bounds.size.width - 30 * 2;
                    NSString *__text = newCell.tipMessageLabel.text;
                    CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                                    font:[UIFont systemFontOfSize:14.0f]
                                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
                    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
                    CGSize __labelSize = CGSizeMake(__textSize.width + 10, __textSize.height + 6);
                    newCell.tipMessageLabel.frame = CGRectMake((newCell.baseContentView.bounds.size.width - __labelSize.width) / 2.0f - 5, 10,
                                                               __labelSize.width + 10, __labelSize.height);
                    
                }
                
                
            }
            
        }
        
    }
     */
    
}

//位置消息不允许多选
- (void)handleAllowsSelectionWithMessageCell:(RCMessageBaseCell *)cell model:(RCMessageModel *)messageModel{
//    if ([cell isMemberOfClass:[RCLocationMessageCell class]] ||
//        [cell isMemberOfClass:[RCVoiceMessageCell class]]
//        || [cell isKindOfClass:[RCTipMessageCell class]]) {
//        cell.allowsSelection = NO;
//    }
        
    //file(video)\image\gif\quote\text
    if ([cell isMemberOfClass:RCImageMessageCell.class]
        || [cell isKindOfClass:RCImageMessageCell.class]
        
        || [cell isMemberOfClass:RCGIFMessageCell.class]
        || [cell isKindOfClass:RCGIFMessageCell.class]
        
        || [cell isMemberOfClass:RCFileMessageCell.class]
        || [cell isKindOfClass:RCFileMessageCell.class]
        
        || [cell isMemberOfClass:RCTextMessageCell.class]
        || [cell isKindOfClass:RCTextMessageCell.class]
        
        || [cell isMemberOfClass:CMPQuoteMessageCell.class]
        || [cell isKindOfClass:CMPQuoteMessageCell.class]
        
        || [cell isMemberOfClass:CMPVideoMessageCell.class]
        || [cell isKindOfClass:CMPVideoMessageCell.class]
        
        ) {
        
        cell.allowsSelection = YES;
        
        //ks fix V5-8973 M3未发送成功的消息，被选中合并转发，点开之后显示空白
        if (![CMPFeatureSupportControl isChatViewLongTouchMenuContainsMultiSelect] || (messageModel.sentStatus == SentStatus_SENDING || messageModel.sentStatus == SentStatus_FAILED || messageModel.sentStatus == SentStatus_CANCELED)) {
            cell.allowsSelection = NO;
        }
        
        if (cell.allowsSelection) {
            if ([cell isMemberOfClass:RCFileMessageCell.class]
                || [cell isKindOfClass:RCFileMessageCell.class]) {
                if (!self.filePrivilege.sendFile) {
                    cell.allowsSelection = NO;
                }
            }
        }
        
    }else{
        cell.allowsSelection = NO;
    }
    
    
}

#pragma mark-
#pragma mark-群名称更新

/**
 处理收到群名称变更通知
 */
- (void)groupNameChanged:(NSNotification *)notification {
    NSDictionary *groupInfo = notification.object;
    NSString *groupId = groupInfo[@"groupId"];
    NSString *groupName = groupInfo[@"groupName"];
    if (![groupId isEqualToString:self.targetId]) {
        NSLog(@"RC---收到了不是本群的更名通知");
        return;
    }
    [self updateGroupName:groupName];
}

/**
 处理收到群人员变动通知
 */
- (void)membersChanged:(NSNotification *)notification {
    NSString *targetId = self.targetId;
    NSString *aTargetId = notification.object;
    if ([aTargetId isEqualToString:targetId] == NO) {
        return;
    }
   
    [CMPChatManager.sharedManager getGroupUserListByGroupId:targetId completion:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList) {
        CMPMessageObject *object = [CMPMessageManager.sharedManager messageWithAppID:targetId];
        [CMPMessageManager.sharedManager setGroupInfoWithMessage:object groupInfo:groupInfo];
        self.groupInfo = groupInfo;
        [self resetTitle:groupInfo.name];
    } fail:^(NSError *error, id ext) {}];
    
}



/**
 在聊天界面收到群名称更改通知
 */
- (void)updateTitle:(RCMessage *)message {
    RCMessageContent *messageContent =  message.content;
    if ([messageContent isKindOfClass:[RCGroupNotificationMessage class]]) {
        RCGroupNotificationMessage *groupMessage = (RCGroupNotificationMessage *)messageContent;
        if ([groupMessage.operation isEqualToString:GroupNotificationMessage_GroupOperationRename]) {
            NSDictionary *extraDic = [groupMessage.extra JSONValue];
            [self updateGroupName:extraDic[@"groupName"]];
        }
    }
}


/**
 更新群名（title、消息列表、缓存）
 */
- (void)updateGroupName:(NSString *)groupName {
    if ([NSString isNull:groupName]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新消息列表
        CMPMessageObject *object = [CMPMessageManager.sharedManager messageWithAppID:self.targetId];
        CMPRCGroupMemberObject *groupMember = object.extradDataModel.groupInfo;
        groupMember.name = groupName;
        [[CMPMessageManager sharedManager] setGroupInfoWithMessage:object groupInfo:groupMember];
        // 缓存到融云
        [[RCIM sharedRCIM] refreshGroupNameCache:groupName withGroupId:self.targetId];
        self.title = groupName;
        self.navigationItem.title = groupName;
        [self resetTitle:self.title];
    });
}

#pragma mark-
#pragma mark 文件权限控制

- (void)checkFilePrivilege {
    
    if (![CMPChatManager sharedManager].fileUploadEnable) {
        //不能上传附件、图片
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemPicture];
    }
    
    if (([CMPCore sharedInstance].serverIsLaterV7_0_SP1 &&
        self.conversationType == ConversationType_GROUP)
        || [CMPServerVersionUtils serverIsLaterV8_2]) {
        [self checkFilePrivilegeFromServerWithCallback:nil];
    } else {
        CMPRCGroupPrivilegeModel *privilege = [[CMPRCGroupPrivilegeModel alloc] init];
        privilege.receiveFile = YES;
        privilege.sendFile = [CMPChatManager sharedManager].fileUploadEnable;
        self.filePrivilege = privilege;
        if (!privilege.sendFile) {
            [self removeFilePluginBoardItem];
        }
    }
}

- (void)checkZhumuPermission {
    if (!CMPFeatureSupportControl.isChatViewCheckQuickNewEntryPrivilege) {
        return;
    }
    [self getZhumuPluginPermissionWithCompletion:^(BOOL isHaveZhumuPlugin) {
        if (!isHaveZhumuPlugin) {
            [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:kPluginBoardItemQuickZhumuMeetting];
        }
    }];
}

/**
 从服务器获取文件读写权限
 */
- (void)checkFilePrivilegeFromServerWithCallback:(void(^)(BOOL success, NSError *error,id ext))callback {
    if ([CMPServerVersionUtils serverIsLaterV8_2]) {
        
        __weak typeof(self) wSelf = self;
        void(^_setPri)(CMPRCGroupPrivilegeModel *, NSError *) = ^(CMPRCGroupPrivilegeModel * _Nonnull privilege, NSError * _Nonnull error){
            if (error) {
                [self removeFilePluginBoardItem];
                if (callback) {
                    callback(NO,error,privilege);
                }
                return;
            }
            self.filePrivilege = privilege;
            if (![CMPChatManager sharedManager].fileUploadEnable) {
                self.filePrivilege.sendFile = NO;
            }
            if (!self.filePrivilege.sendFile) {
                [self removeFilePluginBoardItem];
            }
            if (callback) {
                callback(YES,nil,privilege);
            }
        };
        
        void(^_fetchPri)(void) = ^{
            NSMutableDictionary *pa = [NSMutableDictionary dictionary];
            if (self.conversationType == ConversationType_GROUP) {
                [pa setObject:self.targetId forKey:@"groupId"];
            }
            [self.viewModel fetchChatFileOperationPrivilegeByParams:pa completion:^(CMPRCGroupPrivilegeModel * _Nonnull privilege, NSError * _Nonnull error, id  _Nonnull ext) {
                _setPri(privilege,error);
            }];
        };
        
        if (self.conversationType == ConversationType_GROUP) {
            [self.viewModel fetchGroupUserListByGroupId:self.targetId completion:^(CMPRCGroupMemberObject * _Nonnull memberObj, NSError * _Nonnull error, id  _Nonnull ext) {
                if (!error && ext) {
                    NSDictionary *au = ext[@"au"];
                    if (au && [au isKindOfClass:NSDictionary.class]) {
                        BOOL canSendFile = [au[@"sf"] boolValue];
                        BOOL canRecieveFile = [au[@"rf"] boolValue];
                        CMPRCGroupPrivilegeModel *pri = [[CMPRCGroupPrivilegeModel alloc] init];
                        pri.sendFile = canSendFile;
                        pri.receiveFile = canRecieveFile;
                        _setPri(pri,nil);
                        return;
                    }
                }
                _fetchPri();
            }];
        }else{
            [self.viewModel fetchMemberOnlineStatus:self.targetId result:^(NSDictionary * _Nonnull desDic, NSError * _Nonnull error, id  _Nonnull ext) {
                if (!error && desDic && ext) {
                    NSDictionary *au = ext[@"au"];
                    if (au && [au isKindOfClass:NSDictionary.class]) {
                        BOOL canSendFile = [au[@"sf"] boolValue];
                        BOOL canRecieveFile = [au[@"rf"] boolValue];
                        CMPRCGroupPrivilegeModel *pri = [[CMPRCGroupPrivilegeModel alloc] init];
                        pri.sendFile = canSendFile;
                        pri.receiveFile = canRecieveFile;
                        _setPri(pri,nil);
                        return;
                    }
                }
                _fetchPri();
            }];
        }
        
        
    }else{
        if (!_groupPrivilegeProvider) {
            _groupPrivilegeProvider = [[CMPRCGroupPrivilegeProvider alloc] init];
        }
        [_groupPrivilegeProvider
         rcGroupPrivilegeWithGroupID:self.targetId
         memberID:[CMPCore sharedInstance].userID
         completion:^(CMPRCGroupPrivilegeModel *privilege, NSError *error) {
             if (error) {
                 [self removeFilePluginBoardItem];
                 if (callback) {
                     callback(NO,error,privilege);
                 }
                 return;
             }
             self.filePrivilege = privilege;
             if (![CMPChatManager sharedManager].fileUploadEnable) {
                 self.filePrivilege.sendFile = NO;
             }
             if (!self.filePrivilege.sendFile) {
                 [self removeFilePluginBoardItem];
             }
            if (callback) {
                callback(YES,nil,privilege);
            }
         }];
    }
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - 检查快捷新建入口权限

- (void)checkQuickNewEntryPrivilege {
    if (!CMPFeatureSupportControl.isChatViewCheckQuickNewEntryPrivilege && self.isFileAssistant) {
        return;
    }
    
    NSArray *quickNewEntryItems = [[CMPMessageManager sharedManager] RCQuickNewEntryItemList];
    if (quickNewEntryItems.count == 5) {
        return;
    }
    
    NSArray *referenceDataArr = @[
        @{@"appID":@"1",@"tag":@(kPluginBoardItemQuickColl)},
        @{@"appID":@"1_2",@"tag":@(kPluginBoardItemFormTemplate)},
        @{@"appID":@"6",@"tag":@(kPluginBoardItemQuickMeetting)},
        @{@"appID":@"30",@"tag":@(kPluginBoardItemQuickTask)},
        @{@"appID":@"11",@"tag":@(kPluginBoardItemQuickSchedule)},
    ];
    
    [referenceDataArr enumerateObjectsUsingBlock:^(NSDictionary *dataDic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *appID = dataDic[@"appID"];
        NSInteger tag = [dataDic[@"tag"] integerValue];
        __block BOOL isFound = NO;
        [quickNewEntryItems enumerateObjectsUsingBlock:^(NSDictionary *quickItemDic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *quickAppID = quickItemDic[@"appID"];
            if ([appID isEqualToString:quickAppID]) {
                isFound = YES;
                *stop = YES;
            }
        }];
        if (!isFound) {
            [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:tag];
        }
    }];
}

#pragma mark - 网络请求

/**
 撤回业务消息卡片
 */
- (void)recallGeneralBusinessMessageWithMessageId:(NSString *)messageId {
    NSString *requestUrl = [CMPCore fullUrlForPath:@"/rest/uc/rong/appcard/revoke"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{ @"rongMsgId" : messageId ?: @"",
    };
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

/**
 获取群看板信息
 */
- (void)getGroupKanbanInfoWithGroupId:(NSString *)groupId completion:(void (^)(NSArray *dataList))completion {
    NSString *requestUrl = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/group/panels/%@",groupId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.requestType = kDataRequestType_Url;
    if (completion) {
        aDataRequest.userInfo = @{@"resultBlock" : [completion copy]};
    }
    self.getGroupKanbanInfoRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

/**
 获取瞩目权限
 */
- (void)getZhumuPluginPermissionWithCompletion:(void (^)(BOOL isHaveZhumuPlugin))completion {
    NSString *requestUrl = [CMPCore fullUrlForPath:@"/rest/m3/common/networkPlugin"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    if (completion) {
        aDataRequest.userInfo = @{@"resultBlock" : [completion copy]};
    }
    self.getZhumuPluginPermissionRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    NSString *title = self.titleContent;
    return title;
}


#pragma mark - CMPSegScrollViewDelegate
-(void)cmpSegScrollView:(CMPSegScrollView *)segScrollView
           didClickItem:(CMPSegScrollViewItem *)itemModel
{
    NSString *identifier = itemModel.identifier;
    if (!identifier || identifier.length == 0) {
        return;
    }
    [self.view endEditing:YES];
    for (CMPNavigationController *navVC in [self.currentChildVCs allValues]) {
        navVC.view.hidden = YES;
    }
    if ([identifier isEqualToString:@"kanban_firstindex"]) {
        self.conversationMessageCollectionView.hidden = NO;
    }else{
        self.conversationMessageCollectionView.hidden = YES;
        
        NSDictionary *paramDic = itemModel.extra ? [itemModel.extra JSONValue] : nil;
        if (paramDic) {
            CMPNavigationController *navVC = [self.currentChildVCs objectForKey:identifier];
             if (navVC) {
                 navVC.view.hidden = NO;
                 return;
             }
             CMPKanbanWebViewController *controller = [CMPKanbanWebViewController kanbanWebView1WithUrl:@"http://cmp/v1.0.0/page/cmp-app-access.html" params:paramDic];
            [controller.extDic addEntriesFromDictionary:@{@"targetType":@(self.conversationType),
                                                          @"targetName":self.navigationItem.title
                              }];
             navVC = [[CMPNavigationController alloc] initWithRootViewController:controller];
             navVC.showTabBarInRootVC = NO;
             [self.currentChildVCs setObject:navVC forKey:identifier];
             [self addChildViewController:navVC];
             [self.view insertSubview:navVC.view belowSubview:self.statusBar];
             [navVC didMoveToParentViewController:self];
              __weak typeof(navVC) weaknNavVC = navVC;
              __weak typeof(self) weakSelf = self;
            __weak typeof(CMPSegScrollView *) wSegScrollView = segScrollView;
             navVC.willShowViewControllerAlwaysCallBack = ^{
                if (weaknNavVC.viewControllers.count == 1) {
                    wSegScrollView.hidden = NO;
                    weakSelf.bannerNavigationBar.hidden = NO;
                    weakSelf.statusBar.hidden = NO;
                }
                else {
                    wSegScrollView.hidden = YES;
                    weakSelf.bannerNavigationBar.hidden = YES;
                    weakSelf.statusBar.hidden = YES;
                }
            };
            [navVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(weakSelf.view);
            }];
            for (UIView *subview in controller.view.subviews) {
                if ([subview isKindOfClass:[WKWebView class]]) {
                    [subview mas_makeConstraints:^(MASConstraintMaker *make) {
                       make.top.equalTo(controller.view.mas_top).offset(weakSelf.bannerNavigationBar.cmp_bottom + 50);
                        make.leading.trailing.bottom.equalTo(controller.view);
                    }];
                }
            }
        }
        
         
    }
}

-(NSMutableDictionary *)currentChildVCs
{
    if (!_currentChildVCs) {
        _currentChildVCs = [[NSMutableDictionary alloc] init];
    }
    return _currentChildVCs;
}


-(void)_updateGroupInfo
{
    if (self.conversationType != ConversationType_GROUP) {
        return;
    }
    __weak typeof(self) wSelf = self;
    [CMPChatManager.sharedManager getGroupUserListByGroupId:self.targetId completion:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList) {
        self.groupInfo = groupInfo;
        self.groupMemberList = nil;
        self.groupMemberList = [NSArray arrayWithArray:userList];
        [wSelf resetTitle:groupInfo.name];
    } fail:^(NSError *error, id ext) {
        if (error && error.code == 6114) {//V5-40363【应用检查】【部门群】部门删除时，原部门群还存在，且可发送消息
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:error.domain.length ? error.domain : @"当前群组已被解散" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                SEL aSel = NSSelectorFromString(@"deleteMessageFromList:");
                if ([[CMPChatManager sharedManager] respondsToSelector:aSel]) {
                    RCConversation *con = [[RCConversation alloc] init];
                    con.conversationType = wSelf.conversationType;
                    con.targetId = wSelf.targetId;
                    [[CMPChatManager sharedManager] performSelector:aSel withObject:con];
                }
                [wSelf.navigationController popViewControllerAnimated:YES];
            }];
            [ac addAction:cancel];
            [self presentViewController:ac animated:YES completion:^{}];
        }
    }];
    
    if (_isServerLater8_1) {
        NSString *isShowBeforeStr = [NSString stringWithBool:_isShowMemberPost];
        [CMPChatManager.sharedManager getPostShowStatusByTalkId:self.targetId completion:^(BOOL isShow, NSError *error) {
            if (!error) {
                NSString *isShowStr = [NSString stringWithBool:isShow];
                if (![isShowStr isEqualToString:isShowBeforeStr]) {
                    self->_isShowMemberPost = isShow;
                    [wSelf _loadExtendInfoForVisibleCells];
                }
            }
        }];
    }
}

-(BOOL)_canAtAll
{
    //如果是群主或管理员，再或者接口返回有权限
    NSString *loginUserId = [CMPCore sharedInstance].userID;
    if ([loginUserId isEqualToString:self.groupInfo.ownerId]
        ||[self.groupInfo.adminIds containsString:loginUserId]
        ||self.groupInfo.hasPermissionAtAll) {
        return YES;
    }
    return NO;
}


-(void)_quotingShowViewFuncBtnAct:(id)sender
{
    _currentReeditModel = nil;
    _quotedMessageModel = nil;
    [_quotingShowView removeFromSuperview];
    _quotingShowView = nil;
    self.conversationMessageCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


//ks fix --- V5-12680【ipv6专项】ios-卡片类信息提示收藏失败
- (BOOL)willSelectMessage:(RCMessageModel *)model {
    NSString *objName = model.objectName;
    if ([objName isEqualToString:[CMPGeneralBusinessMessage getObjectName]]
        ||[objName isEqualToString:[CMPBusinessCardMessage getObjectName]]
        ||[objName isEqualToString:[RCLocationMessage getObjectName]]
        ||[objName isEqualToString:[RCVoiceMessage getObjectName]]) {
        return NO;
    }
    return [super willSelectMessage:model];
}

-(CMPRCChatViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPRCChatViewModel alloc] init];
    }
    return _viewModel;
}

-(void)_actOnlineStatusTask
{
    if (self.conversationType == ConversationType_PRIVATE && ![self.targetId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]
        && ![CMPCommonManager isSeeyonRobotByUid:self.targetId]) {
        __weak typeof(self) wSelf = self;
        [self.viewModel fetchMemberOnlineStatus:self.targetId result:^(NSDictionary * _Nonnull desDic, NSError * _Nonnull error, id  _Nonnull ext) {
            if (!error && desDic) {
                if (!wSelf.onlineButton) {
                    wSelf.onlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    wSelf.onlineButton.titleLabel.font = [UIFont systemFontOfSize:10];
                    wSelf.onlineButton.userInteractionEnabled = NO;
                    [wSelf.onlineButton setBackgroundColor:UIColor.clearColor];
                    [wSelf.onlineButton setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
                    [wSelf.onlineButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
                    [wSelf.onlineButton sizeToFit];
                    wSelf.onlineButton.imageView.layer.cornerRadius = 4;
                    wSelf.onlineButton.imageView.layer.masksToBounds = YES;
                    [wSelf.bannerNavigationBar.titleExtContentView addSubview:wSelf.onlineButton];
                    [wSelf.onlineButton mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.offset(-2);
                        make.left.right.offset(0);
                        make.bottom.offset(-5);
                    }];
                }
                NSString *des = desDic[@"des"];
                UIColor *color_des = desDic[@"color_des"];
                UIColor *color_icon = desDic[@"color_icon"];
                [wSelf.onlineButton setTitle:des forState:UIControlStateNormal];
                [wSelf.onlineButton setTitleColor:color_des forState:UIControlStateNormal];
                UIImage *icon = [UIImage imageFromColor:color_icon withSize:CGSizeMake(8, 8)];
                [wSelf.onlineButton setImage:icon forState:UIControlStateNormal];
                
            }else{
                if (wSelf.onlineButton) {
                    [wSelf.onlineButton removeFromSuperview];
                    wSelf.onlineButton = nil;
                }
            }
        }];
    }
}

-(void)bottomBarStatusWillChange:(NSNotification *)sender
{
    NSNumber *val = sender.object;
    NSInteger status = val.integerValue;
    if (status == KBottomBarPluginStatus) {
        [self checkFilePrivilegeFromServerWithCallback:^(BOOL success, NSError *error, id ext) {
            
        }];
    }
}

@end
