//
//  CMPOfflineContactsPlugin.h
//  M3
//
//  Created by CRMO on 2017/11/23.
//

#import <CordovaLib/CDVPlugin.h>

// 插件返回数据格式，为了h5适配问题，仿照rest接口包装一层。真实返回数据在data里面
//{
//    "code": "200",
//    "data": {
//        // 真实返回数据
//    },
//    "time": "",
//    "message": "success",
//    "version": "1.0"
//}

@interface CMPOfflineContactsPlugin : CDVPlugin

/**
 获取单位信息
 参数：accountID
 返回：
 {"account": {
 "id": "670869647114347",
 "name": "北京致远互联软件股份有限公司",
 "hasChildren": false,
 "parentId": null,
 "path": null,
 "parentPath": null
 }}
 */
- (void)getAccountInfo:(CDVInvokedUrlCommand *)command;

/**
 获取部门列表
 参数：accountID
 返回:
 {
 "myDepartment": {
 "id": "5631339208057833275",
 "name": "移动平台部",
 "code": null,（无）
 "hasChildren": false,（无）
 "parentId": "",
 "accountId": "670869647114347"
 },
 "departments": [
 {
 "id": "-5226842682007730694",
 "name": "总裁会",
 "code": null,
 "hasChildren": false,
 "parentId": null,
 "accountId": "670869647114347"
 }
 ]
 }
 */
- (void)getDepartmentList:(CDVInvokedUrlCommand *)command;

/**
 获取部门下人员列表
 参数：departmentID、accoundID、pageNum
 返回：
 {
 "total": "8",
 "childrenDepartments": [
 {
 "id": "-2840059185382995631",
 "name": "子部门1",
 "hasChildren": false,（无）
 "parentId": "",
 "accountId": "1984867692474419681"
 }
 ],
 "members": [
 {
 "id": "-681878654385304178",
 "name": "",
 "departmentId": "5631339208057833275",
 "departmentName": "移动平台部",
 "accountId": "670869647114347",
 "accName": "",
 "accShortName": "",（无）
 "accMotto": "",（无）
 "jobNumber": "",（无）
 "levelName": null,
 "postName": "",
 "postId": null,
 "levelId": null,
 "tel": null,
 "email": null,
 "nameSpell": "",
 "officeNumber": null,（无）
 "isVjoin": null,（无）
 "vjoinOrgName": null,（无）
 "vjoinAccName": null,（无）
 "customFields": null（无）
 }
 ],
 "parents": [
 {
 "departmentName": "北京致远互联软件股份有限公司",
 "departmentId": "670869647114347"
 }
 ]
 }

 */
- (void)getDepartmentMemberList:(CDVInvokedUrlCommand *)command;

/**
 获取人员卡片信息
 参数：accoundID、memberID
 返回：{
 "id": "-681878654385304178",
 "name": "",
 "iconUrl": "/seeyon/fileUpload.do?method=showRTE&fileId=-2942582779038383914&createDate=2017-07-12&type=image&showType=small",
 "code": null,
 "departmentId": "5631339208057833275",
 "departmentName": "移动平台部",
 "accountId": "670869647114347",
 "accName": "",
 "accShortName": "",
 "accMotto": "",
 "jobNumber": "",
 "levelName": " - ",
 "postName": "",
 "postId": null,
 "levelId": null,
 "tel": "",
 "email": "",
 "nameSpell": "",
 "officeNumber": "02866018088-715",
 "isVjoin": "0",
 "vjoinOrgName": null,
 "vjoinAccName": null,
 "customFields": {}
 }
 */
- (void)getMemberCard:(CDVInvokedUrlCommand *)command;

/**
 显示人员搜索界面
 */
- (void)showMemberSearch:(CDVInvokedUrlCommand *)command;


/**
 获取离线通讯录下载状态
 OfflineStatusNormal = 0,
 OfflineStatusUpating = 1,
 OfflineStatusFinish = 2,
 OfflineStatusFail = 3
 */
- (void)getDownloadState:(CDVInvokedUrlCommand *)command;

/**
 离线通讯录下载失败重试
 */
- (void)retryDownload:(CDVInvokedUrlCommand *)command;

/**
 获取部门、人员排序方式，2.5.0新增
 member 人员在前
 */
- (void)getDepartmentMemberSortType:(CDVInvokedUrlCommand *)command;

@end
