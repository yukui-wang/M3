//
//  M3Constant.h
//  CMPLib
//
//  Created by youlin on 2017/9/12.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#ifndef M3Constant_h
#define M3Constant_h

//  M3 应用ID
#define kM3AppID_Application @"52" // 应用
#define kM3AppID_Message @"55" //消息
#define kM3AppID_Contacts @"62"  //通讯录
#define kM3AppID_Todo @"58"  // 待办应用
#define kM3AppID_My @"56"    // 我的
#define kM3AppID_Shortcut @"-20000" // 快捷菜单
// M3 H5 页面URL地址
// 修改密码
#define kM3MyAccountPwdUrl @"http://my.m3.cmp/v1.0.0/layout/my-account-pwd.html"
#define kM3MyPersonUrl @"http://my.m3.cmp/v/layout/my-person.html?page=search-next&id=%@&from=%@&enableChat=%@"
#define kM3MyIndexUrl @"http://my.m3.cmp/v1.0.0/layout/my-index.html"
#define kM3TodoSearchUrl @"http://search.m3.cmp/v1.0.0/layout/todo-search.html"
#define kM3FrequentContactsUrl @"http://search.m3.cmp/v1.0.0/layout/frequent-contacts.html"
#define kM3UCGroupListPageUrl @"http://uc.v5.cmp/v/html/ucGroupListPage.html?cmp_orientation=auto"
#define kM3UCGroupListUrl   @"http://uc.v5.cmp/v/html/ucGroupList.html?cmp_orientation=auto"
#define kM3ProjectTeamUrl   @"http://search.m3.cmp/v1.0.0/layout/project-team.html"
#define kM3OrganizationUrl @"http://search.m3.cmp/v1.0.0/layout/organization.html"
#define kM3AllSearchUrl @"http://todo.m3.cmp/v1.0.0/layout/all-search.html"
#define kM3AllSearchUrl_180 @"http://todo.m3.cmp/v1.0.0/layout/todo-search.html"
#define kM3FullSearchUrl_180 @"http://fullsearch.v5.cmp/v1.0.0/layout/all-search.html" //搜消息、待办
#define kM3FullSearchUrl_830 @"http://fullsearch.v5.cmp/v1.0.0/layout/full-search.html" //全文检索
#define kM3RelatedContactsUrl @"http://search.m3.cmp/v1.0.0/layout/aspersonnel.html"//关连人员
#define kM3CommonAppUrl @"http://application.m3.cmp/v/layout/app-application.html" //常用应用

// M3 Rest 接口请求地址
#define kMemberIconUrl_M3_Param @"/rest/orgMember/avatar/%@?maxWidth=200"
#define kRCGroupIconUrl_M3_Param @"/rest/orgMember/groupavatar?groupId=%@&ucFlag=yes"
#define kM3AppStatisticsHideUrl @"/rest/m3/statistics/hide"
#define kM3AppStatisticsWakeUpUrl @"/rest/m3/statistics/wakeUp"


/* *******************************手机盾相关*********************************** */
// 获取手机盾cert及地址请求地址
#define kM3TrustdoServerInfoUrl @"/rest/m3/trustdo/sdk/server/info"
// 获取手机盾keyId请求地址
#define kM3TrustdoKeyUrl @"/rest/m3/trustdo/sdk/keyId/"
// 获取手机盾登录事件请求地址
#define kM3TrustdoLoginEventUrl @"/rest/m3/trustdo/sdk/login/event"
// 获取手机盾证书更新事件请求地址
#define kM3TrustdoUpdateCertEventUrl @"/rest/m3/trustdo/sdk/cert/event/"
/* *******************************手机盾相关*********************************** */

#define kM3CustomStartPageUrl @"/rest/m3/startPage/getCustom/iphone"


#endif /* M3Constant_h */
