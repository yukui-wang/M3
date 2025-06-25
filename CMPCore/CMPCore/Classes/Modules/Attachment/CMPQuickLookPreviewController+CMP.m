//
//  CMPQuickLookPreviewController+CMP.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/21.
//

#import "CMPQuickLookPreviewController+CMP.h"
#import "CMPAttachmentHelper.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPRCGroupPrivilegeProvider.h"
#import <CMPLib/SyNothingView.h>
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPRCChatViewModel.h"
#import "CMPAttachmentHelper.h"
@implementation CMPQuickLookPreviewController (CMP)

static CMPRCGroupPrivilegeProvider *_groupPrivilegeProvider;
static CMPRCChatViewModel *_rcChatViewModel;

-(void)actionBeforeDownloadWithResult:(void(^)(void))rslt
{
    //处理权限前获取enableTrans是否开启
    [[CMPAttachmentHelper shareManager] updateAttaPreviewConfigWithCompletion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        [self handle:rslt];
    }];
}

- (void)handle:(void(^)(void))rslt{
    CMPFileFromType fromType = self.attReaderParam.fromType;
    if (fromType == CMPFileFromTypeSendToUC
        ||fromType == CMPFileFromTypeSendToUCGroup
        ||fromType == CMPFileFromTypeComeFromUC
        ||fromType == CMPFileFromTypeComeFromUCGroup
        ||[self.attReaderParam.url containsString:@"ucFlag=yes"]) {
        
        __weak typeof(self) wSelf = self;
        NSString *fileType = [self.attReaderParam.fileName componentsSeparatedByString:@"."].lastObject;
        BOOL enable = [[CMPAttachmentHelper shareManager] isSupportOnlinePreviewWithFileExtension:fileType];
        if (!enable) {//不能在线预览
            //判断下载权限
            [self _fetchDownloadPrivilege:^(BOOL canDownload) {
                if (canDownload) {
                    if (rslt) {
                        rslt();
                    }
                }else{
                    [wSelf _hasNoPrivilegeAction];
                }
            }];
            return;
        }
        //在线预览
        NSString *fileId = self.attReaderParam.fileId;
        [[CMPAttachmentHelper shareManager] fetchAttaPreviewUrlWithFileId:fileId completion:^(NSString * _Nonnull previewUrlStr, NSError * _Nonnull error, id  _Nonnull ext) {
            
            if (previewUrlStr) {//在线预览
                [wSelf officeOnlineLoadUrl:previewUrlStr];
                //右上角显示下载按钮
                [wSelf _fetchDownloadPrivilege:^(BOOL canDownload) {
                    wSelf.attReaderParam.canDownload = canDownload;
                    wSelf.attReaderParam.isShowShareBtn = NO;
                    wSelf.attReaderParam.isShowPrintBtn = NO;
                    wSelf.attReaderParam.canShowInThirdApp = NO;
                    [wSelf performSelector:@selector(customSetupBannerButtons)];
                }];
                return;
            }
            
            if (wSelf.canReceiveFile) {//先判断是否有权限，如果有，则不再继续请求
                if (rslt) {
                    rslt();
                }
            }else{
                [wSelf _fetchDownloadPrivilege:^(BOOL canDownload) {
                    if (canDownload) {
                        if (rslt) {
                            rslt();
                        }
                    }else{
                        [wSelf _hasNoPrivilegeAction];
                    }
                }];
            }
            
        }];
    }else{
        if (rslt) {
            rslt();
        }
    }
}

-(void)officeOnlineLoadUrl:(NSString *)url
{
    if (url) {
        NSString *aStr = url;
        if ([url containsString:@"?"]) {
            NSArray *arr = [url componentsSeparatedByString:@"?"];
            if (arr.count && ((NSString *)arr.lastObject).length>0) {
                aStr = [url stringByAppendingString:@"&cmp_orientation=auto"];
            }else{
                aStr = [url stringByAppendingString:@"cmp_orientation=auto"];
            }
        }else{
            aStr = [url stringByAppendingString:@"?cmp_orientation=auto"];
        }
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.startPage = aStr;
        aCMPBannerViewController.hideBannerNavBar = YES;
        [self addChildViewController:aCMPBannerViewController];
        [self.view addSubview:aCMPBannerViewController.view];
        [aCMPBannerViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.offset(0);
            make.top.equalTo(self.bannerNavigationBar.mas_bottom).offset(0);
        }];
        [aCMPBannerViewController.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
}

-(void)actionAfterFileDownload
{
    if (self.attReaderParam.logParams) {
        [[CMPAttachmentHelper shareManager] shareAttaActionLogType:2 withParams:self.attReaderParam.logParams completion:nil];
    }
}

-(void)_fetchDownloadPrivilege:(void(^)(BOOL))resultBlk
{
    if (resultBlk) {
        BOOL canDownload = [[CMPAttachmentHelper shareManager] isSupportOnlinePreviewDownload];
        NSString *groupId;
        id extra = self.attReaderParam.extra;
        if (extra && [extra isKindOfClass:[NSDictionary class]]) {
            groupId = [extra objectForKey:@"groupId"];
            if ([NSString isNull:groupId]) {
                id targetInfo = [extra objectForKey:@"targetInfo"];
                if (targetInfo) {
                    if ([targetInfo isKindOfClass:[NSString class]]) {
                        targetInfo = [targetInfo JSONValue];
                    }
                    if ([targetInfo isKindOfClass:[NSDictionary class]]) {
                        NSString *targetType = [NSString stringWithFormat:@"%@",targetInfo[@"targetType"]];
                        if ([targetType isEqualToString:@"3"]) {
                            groupId = targetInfo[@"targetId"]?:@"";
                        }
                    }
                }
            }
        }
        if ([CMPServerVersionUtils serverIsLaterV8_2]) {
            NSMutableDictionary *pa = [NSMutableDictionary dictionary];
            if ([NSString isNotNull:groupId]) {
                [pa setObject:groupId forKey:@"groupId"];
            }
            if (!_rcChatViewModel) {
                _rcChatViewModel = [[CMPRCChatViewModel alloc] init];
            }
            [_rcChatViewModel fetchChatFileOperationPrivilegeByParams:pa completion:^(CMPRCGroupPrivilegeModel * _Nonnull privilege, NSError * _Nonnull error, id  _Nonnull ext) {
                if (error) {
                    resultBlk(privilege.receiveFile && canDownload);
                }else{
                    resultBlk(privilege.receiveFile && canDownload);
                }
            }];
            return;
        } else {
            if ([NSString isNotNull:groupId]) {
                if (!_groupPrivilegeProvider) {
                    _groupPrivilegeProvider = [[CMPRCGroupPrivilegeProvider alloc] init];
                }
                [_groupPrivilegeProvider
                 rcGroupPrivilegeWithGroupID:groupId
                 memberID:[CMPCore sharedInstance].userID
                 completion:^(CMPRCGroupPrivilegeModel *privilege, NSError *error) {
                     if (error) {
                         resultBlk(NO);
                     }else{
                         resultBlk(privilege.receiveFile && canDownload);
                     }
                 }];
                return;
            }
            resultBlk(YES && canDownload);
        }
    }
}


-(void)_hasNoPrivilegeAction
{
    SyNothingView *_nothingView = [[SyNothingView alloc] init];
    [self.view addSubview:_nothingView];
    [_nothingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    [_nothingView customLayoutSubviews];
    
    [self showAlertMessage:SY_STRING(@"msg_noFilePrivilege")];
    
    for (UIViewController *child in self.childViewControllers) {
        if ([child isKindOfClass:QLPreviewController.class]) {
            [child.view removeFromSuperview];
            [child removeFromParentViewController];
        }
    }
}

@end
