//
//  CMPOfflineContactsPlugin.m
//  M3
//
//  Created by CRMO on 2017/11/23.
//

#import "CMPOfflineContactsPlugin.h"
#import "CMPContactsManager.h"
#import "OfflineOrgUnit.h"
#import "CMPContactsSearchResultController.h"
#import "CMPContactsSearchResultView.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/Masonry.h>
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/NSObject+CMPHUDView.h>

#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPOfflineContactsPlugin()<CMPContactsSearchResultControllerDelegate>

@property (retain, nonatomic) CMPContactsSearchResultController *searchResultManager;

@end

@implementation CMPOfflineContactsPlugin

- (void)dealloc {
    _searchResultManager.delegate = nil;
    SY_RELEASE_SAFELY(_searchResultManager);
    [super dealloc];
}

- (void)getAccountInfo:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *accountID = [parameter objectForKey:@"accountID"];
    
    if ([NSString isNull:accountID]) {
        NSDictionary *errorDic= @{@"code" : @0,
                                  @"message" : @"参数错误",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [[CMPContactsManager defaultManager] accountInfoWithAccountID:accountID completion:^(BOOL isContactReady, OfflineOrgUnit *account) {
        if (!isContactReady) { // 通讯录没有准备好
            NSDictionary *errorDic= @{@"code" : @0,
                                      @"message" : @"通讯录还没准备好",
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        if (!account || account.oId == 0 || account.fa == 0 || [NSString isNull:account.n]) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"通讯录数据错误"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        NSDictionary *dic = [CMPOfflineContactsPlugin offlineOrgUnitToDic:account accountID:accountID];
        NSDictionary *accountDic = @{@"account" : dic};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[CMPOfflineContactsPlugin packRestHeadWithData:accountDic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getDepartmentList:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *accountID = [parameter objectForKey:@"accountID"];
    
    if ([NSString isNull:accountID]) {
        NSDictionary *errorDic= @{@"code" : @0,
                                  @"message" : @"参数错误",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [[CMPContactsManager defaultManager] departmentsWithAccountID:accountID
     completion:^(BOOL isContactReady, OfflineOrgUnit *myDepartment, NSArray<OfflineOrgUnit *> *childDepartments)
    {
        if (!isContactReady) { // 通讯录没有准备好
            NSDictionary *errorDic= @{@"code" : @0,
                                      @"message" : @"通讯录还没准备好",
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        if (!myDepartment || myDepartment.oId == 0 || myDepartment.fa == 0 || [NSString isNull:myDepartment.n]) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"通讯录数据错误"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        NSDictionary *myDepartmentDic = [CMPOfflineContactsPlugin offlineOrgUnitToDic:myDepartment accountID:accountID];
        
        NSMutableArray *departments = [NSMutableArray array];
        for (OfflineOrgUnit *child in childDepartments) {
            NSDictionary *childDic = [CMPOfflineContactsPlugin offlineOrgUnitToDic:child accountID:accountID];
            [departments addObject:childDic];
        }
        
        NSDictionary *dataDic = @{@"myDepartment" : myDepartmentDic,
                                     @"departments" : departments
                                     };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[CMPOfflineContactsPlugin packRestHeadWithData:dataDic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}

- (void)getDepartmentMemberList:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *accountID = [parameter objectForKey:@"accountID"];
    NSString *departmentID = [parameter objectForKey:@"departmentID"];
    NSNumber *pageNum = [parameter objectForKey:@"pageNum"];
    NSString *sortType = [parameter objectForKey:@"sortType"];
    
    if ([NSString isNull:accountID] ||
        [NSString isNull:departmentID] ||
        ![pageNum isKindOfClass:[NSNumber class]]) {
        NSDictionary *errorDic= @{@"code" : @0,
                                  @"message" : @"参数错误",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    BOOL memberFirst = NO;
    
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0 &&
        ![NSString isNull:sortType] &&
        [sortType isEqualToString:@"member"]) {
        memberFirst = YES;
    }
    
    [[CMPContactsManager defaultManager] childrensWithAccoundID:accountID
                                                   departmentID:departmentID
                                                        pageNum:pageNum
                                                    memberFirst:memberFirst
                                                     completion:^(BOOL isContactReady, NSInteger total, NSArray<OfflineOrgUnit *> *childDepartments, NSArray<CMPOfflineContactMember *> *members)
     {
         if (!isContactReady) { // 通讯录没有准备好
             NSDictionary *errorDic= @{@"code" : @0,
                                       @"message" : @"通讯录还没准备好",
                                       @"detail" : @""};
             CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
             return;
         }
         
         NSMutableArray *memberArr = [NSMutableArray array];
         NSMutableArray *childrenDepartmentArr = [NSMutableArray array];
         
         for (CMPOfflineContactMember *member in members) {
             NSDictionary *memberDic = [CMPOfflineContactsPlugin offlineContactMemberToDic:member];
             [memberArr addObject:memberDic];
         }
         
         for (OfflineOrgUnit *child in childDepartments) {
             NSDictionary *childDic = [CMPOfflineContactsPlugin offlineOrgUnitToDic:child accountID:accountID];
             [childrenDepartmentArr addObject:childDic];
         }
         
         NSDictionary *dataDic = @{@"childrenDepartments" : childrenDepartmentArr,
                                   @"members" : memberArr
                                   };
         NSDictionary *resultDic = @{@"code" : @"200",
                                     @"data" : dataDic,
                                     @"time" : @"",
                                     @"total" : [NSNumber numberWithInteger:total],
                                     @"message" : @"success",
                                     @"version" : @"1.0"
                                     };

         CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}

- (void)getMemberCard:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *accountID = [parameter objectForKey:@"accountID"];
    NSString *memberID = [parameter objectForKey:@"memberID"];
    
    if ([NSString isNull:accountID] ||
        [NSString isNull:memberID]) {
        NSDictionary *errorDic= @{@"code" : @0,
                                  @"message" : @"参数错误",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [[CMPContactsManager defaultManager] memberInfoForID:memberID
                                               accountID:accountID
                                              completion:^(CMPOfflineContactMember *member)
    {
        if (!member) {
            NSDictionary *errorDic= @{@"code" : @0,
                                      @"message" : @"member为空",
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        NSDictionary *memberDic = [CMPOfflineContactsPlugin offlineContactMemberToDic:member];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[CMPOfflineContactsPlugin packRestHeadWithData:memberDic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)showMemberSearch:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    /** V7.1新增参数， scope代表开启多维组织搜索false的话就是行政组织 **/
    BOOL isScopeSearch = [parameter[@"scope"] boolValue];
    /** V7.1新增参数， 多维组织单位id需要传给接口 **/
    NSString *businessID = parameter[@"businessId"];
    
    if (_searchResultManager) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"搜索框已经弹出"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    UIViewController *currentViewController = self.viewController;
    _searchResultManager = [[CMPContactsSearchResultController alloc] initWithFrame:currentViewController.view.frame
                                                                      showSearchBar:YES
                                                                            isScope:isScopeSearch
                                                                         businessID:businessID
                                                                    searchBarHeight:44
                                                                           delegate:self];
    
    NSString *searchText = parameter[@"searchText"];
    //如果有传占位文本，则显示
    if (searchText.length) {
        UISearchBar *searchBar = _searchResultManager.mainView.searchBar;
        searchBar.placeholder = searchText;
        UITextField *searchField = [CMPCommonTool getSearchFieldWithSearchBar:searchBar];
        NSDictionary *attrDic = @{NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"sup-fc2"] ,
                                  NSFontAttributeName : [UIFont systemFontOfSize:14]};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:searchBar.placeholder attributes:attrDic];
        searchField.attributedPlaceholder = attrStr;
        searchField.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    }
    
    [currentViewController.view addSubview:_searchResultManager.mainView];
    [_searchResultManager.mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(currentViewController.view);
    }];
    [_searchResultManager loadAllMember];
    [_searchResultManager.mainView focusTextView];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getDownloadState:(CDVInvokedUrlCommand *)command {
    [self _pollingDownloadState:command.callbackId];
}

// 轮询通讯录下载状态
- (void)_pollingDownloadState:(NSString *)callbackID {
    OfflineStatus status = [[CMPContactsManager defaultManager] offlineStatus];
    DDLogInfo(@"zl---轮询通讯录状态:%ld", status);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:status];
    if (status == OfflineStatusNormal ||
        status == OfflineStatusUpating) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _pollingDownloadState:callbackID];
        });
        [pluginResult setKeepCallbackAsBool:YES];
    } else {
        [pluginResult setKeepCallbackAsBool:NO];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)retryDownload:(CDVInvokedUrlCommand *)command {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CMPContactsManager defaultManager] beginUpdate];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

- (void)getDepartmentMemberSortType:(CDVInvokedUrlCommand *)command {
    CMPLoginConfigInfoModel_2 *config = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:config.firstShow];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark-
#pragma mark-CMPContactsSearchResultManagerDelegate

- (void)searchResultDidCacel:(CMPContactsSearchResultController *)manager {
    SY_RELEASE_SAFELY(_searchResultManager);
}

- (void)searchResultWillLoadData:(CMPContactsSearchResultController *)manager {
}

- (void)searchResultDidLoadData:(CMPContactsSearchResultController *)manager {
}

- (void)searchResultFailLoadData:(CMPContactsSearchResultController *)manager {
    [self cmp_showHUDWithText:SY_STRING(@"contacts_downloadFail")];
}

- (void)searchResultWillBeginDragging:(CMPContactsSearchResultController *)manager {
    [manager.mainView unFocusTextView];
}

- (void)searchResultDidSearch:(CMPContactsSearchResultController *)manager {
    [manager.mainView unFocusTextView];
}

#pragma mark-
#pragma mark-Private Method

+ (NSDictionary *)offlineOrgUnitToDic:(OfflineOrgUnit *)unit accountID:(NSString *)accountID {
    NSMutableDictionary *unitDic = [NSMutableDictionary dictionary];
    [unitDic setObject:[NSString stringWithLongLong:unit.oId] forKey:@"id"];
    if (![NSString isNull:unit.n]) {
        [unitDic setObject:unit.n forKey:@"name"];
    }
    [unitDic setObject:[NSString stringWithLongLong:unit.fa] forKey:@"parentId"];
    [unitDic setObject:accountID forKey:@"accoundId"];
    [unitDic setObject:[NSString stringWithInt:unit.internal] forKey:@"internal"];
    return unitDic;
}

+ (NSDictionary *)offlineContactMemberToDic:(CMPOfflineContactMember *)member {
    BOOL showOfficeNumber = YES;
    BOOL showMemberName = YES;
    BOOL showWeibo = YES;
    BOOL showPostName = YES;
    BOOL showTel = YES;
    BOOL showSp = YES;
    BOOL showEmail = YES;
    BOOL showAddress = YES;
    BOOL showPostcode = YES;
    BOOL showLevelName = YES;
    BOOL showWorkAddress = YES;
    BOOL showPostalAddress = YES;
    BOOL showMemberDept = YES;
    BOOL showWeChact = YES;
    
    if ([[CMPCore sharedInstance] serverIsLaterV2_5_0]) {
        CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
        NSString *configStr = currentUser.configInfo;
        CMPLoginConfigInfoModel_2 *model = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:configStr];
        NSDictionary *filedViewSet = model.fieldViewSet;
        if (filedViewSet.count != 0) {
            showOfficeNumber = [filedViewSet[@"officeNumber"] boolValue];
            showMemberName = [filedViewSet[@"memberName"] boolValue];
            showWeibo = [filedViewSet[@"weibo"] boolValue];
            showPostName = [filedViewSet[@"postName"] boolValue];
            showTel = [filedViewSet[@"tel"] boolValue];
            showEmail = [filedViewSet[@"email"] boolValue];
            showAddress = [filedViewSet[@"address"] boolValue];
            showPostcode = [filedViewSet[@"postcode"] boolValue];
            showLevelName = [filedViewSet[@"levelName"] boolValue];
            showWorkAddress = [filedViewSet[@"workAddress"] boolValue];
            showPostalAddress = [filedViewSet[@"postalAddress"] boolValue];
            showMemberDept = [filedViewSet[@"memberDept"] boolValue];
            showWeChact = [filedViewSet[@"weChat"] boolValue];
        }
    }
    
    NSMutableDictionary *memberDic = [NSMutableDictionary dictionary];
    [memberDic setObject:member.orgID forKey:@"id"];
    if (showMemberName) {
        [memberDic setObject:member.name forKey:@"name"];
    }
    [memberDic setObject:member.departmentId forKey:@"departmentId"];
    if (showMemberDept) {
        [memberDic setObject:member.department forKey:@"departmentName"];
    }
    [memberDic setObject:member.accountId forKey:@"accountId"];
    if (showPostName) {
        [memberDic setObject:member.postName forKey:@"postName"];
    }
    [memberDic setObject:member.postId forKey:@"postId"];
    [memberDic setObject:member.levelId forKey:@"levelId"];
    if (showLevelName) {
        [memberDic setObject:member.level forKey:@"levelName"];
    }
    if (showOfficeNumber) {
        [memberDic setObject:member.tel forKey:@"officeNumber"];
    }
    if (showTel) {
        [memberDic setObject:member.mobilePhone forKey:@"tel"];
    }
    if (showEmail) {
        [memberDic setObject:member.mail forKey:@"email"];
    }
    [memberDic setObject:member.nameSpell forKey:@"nameSpell"];
    if (showWorkAddress) {
        [memberDic setObject:member.workAddr forKey:@"workAddress"];
    }
    if (showWeChact) {
        [memberDic setObject:member.wx forKey:@"weChat"];
    }
    if (showWeibo) {
        [memberDic setObject:member.wb forKey:@"weibo"];
    }
    if (showAddress) {
        [memberDic setObject:member.homeAddr forKey:@"address"];
    }
    if (showPostcode) {
        [memberDic setObject:member.port forKey:@"postcode"];
    }
    if (showPostalAddress) {
        [memberDic setObject:member.communicationAddr forKey:@"postalAddress"];
    }
    [memberDic setObject:member.ins?:@"" forKey:@"ins"];
    [memberDic setObject:member.internal?:@"" forKey:@"internal"];
    
    // 副岗
    NSMutableArray *deputyPostArr = [NSMutableArray array];
    for (NSString *deputyPostName in member.deputyPost) {
        NSDictionary *dic = @{@"sp" : deputyPostName ?: @""};
        [deputyPostArr addObject:dic];
    }
    [memberDic setObject:deputyPostArr forKey:@"deputyPostName"];
    if (member.parentDepts) {
        [memberDic setObject:member.parentDepts forKey:@"parentDepts"];
    }
    return memberDic;
}

+ (NSDictionary *)packRestHeadWithData:(NSDictionary *)data {
    return @{@"code" : @"200",
             @"data" : data,
             @"time" : @"",
             @"message" : @"success",
             @"version" : @"1.0"
             };
}

@end
