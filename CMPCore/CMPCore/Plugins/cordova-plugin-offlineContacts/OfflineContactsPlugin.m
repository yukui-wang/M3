//
//  OfflineContactsPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/14.
//
//

#import "OfflineContactsPlugin.h"
#import "CMPOfflineContactViewController.h"
#import "CMPContactsManager.h"
@implementation OfflineContactsPlugin

- (void)openOfflineContacts:(CDVInvokedUrlCommand *)command {
    CMPOfflineContactViewController *viewController = [[CMPOfflineContactViewController alloc] init];
    [self.viewController.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    viewController = nil;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}
- (void)getMemberInfo:(CDVInvokedUrlCommand *)command {
    NSDictionary *parameter = [command.arguments lastObject];
    NSString *memberId = [parameter objectForKey:@"memberId"];
    NSString *departmentId = [parameter objectForKey:@"departmentId"];
    NSString *accpuntId = [parameter objectForKey:@"accpuntId"];
    [[CMPContactsManager defaultManager]memberInfoForId:memberId departmentId:departmentId accpuntId:accpuntId completion:^(CMPOfflineContactMember *result) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:result.orgID forKey:@"id"];
        [info setObject:result.name forKey:@"name"];
        [info setObject:result.nameSpell forKey:@"nameSpell"];

        [info setObject:result.accountId forKey:@"accountId"];
        [info setObject:result.account forKey:@"accName"];
        [info setObject:result.account forKey:@"accShortName"];

        [info setObject:result.departmentId forKey:@"departmentId"];
        [info setObject:result.department forKey:@"departmentName"];
        
        [info setObject:result.levelId forKey:@"levelId"];
        [info setObject:result.level forKey:@"levelName"];
        
        [info setObject:result.postId forKey:@"postId"];
        [info setObject:result.postName forKey:@"postName"];
        
        [info setObject:result.mobilePhone forKey:@"tel"];
        [info setObject:result.tel forKey:@"officeNumber"];
        [info setObject:result.mail forKey:@"email"];
        
        [info setObject:@"" forKey:@"accMotto"];
        [info setObject:@"" forKey:@"jobNumber"];
        [info setObject:@"" forKey:@"iconUrl"];
        [info setObject:result.sort forKey:@"code"];
                
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }];
}

/**
 * 获取单位下一级子部门列表，我的部门信息
 *
 * @param accountId(单位ID)
 * @return {
 * "code": 200,
 * "data": {
 * "myDepartment": {
 * "id": "5631339208057833275",
 * "name": "移动门户部",
 * "iconUrl": null,
 * "code": null,
 * "count": 5,
 * "hasChildren": false,
 * "parentId": null
 * },
 * "departments": [
 * {
 * "id": "-5226842682007730694",
 * "name": "总裁会",
 * "iconUrl": null,
 * "code": null,
 * "count": 11,
 * "hasChildren": false,
 * "parentId": null
 * },
 * {
 * "id": "-5227015721478108734",
 * "name": "运营体系",
 * "iconUrl": null,
 * "code": null,
 * "count": 55,
 * "hasChildren": true,
 * "parentId": null
 * }
 * ],
 * "account": {
 * "id": "670869647114347",
 * "name": "北京致远互联软件股份有限公司",
 * "iconUrl": "http://119.61.20.17:9543/seeyon/fileUpload.do?method=showRTE&fileId=-				4225380057496402860&type=image",
 * "code": "01",
 * "count": 0,
 * "hasChildren": true,
 * "parentId": null
 * }
 * },
 * "time": 1483410649931,
 * "message": "success",
 * "version": "1.0"
 * }
 * @throws
 */
- (void)getDepartmentsByAccountId:(CDVInvokedUrlCommand *)command {
//    SELECT * FROM tb_unit where ID = '%ld'
}

/**
 * 部门下的子部门和人员
 *
 * @param departmentId 部门ID
 * @param pageSize     每一页的大小
 * @param pageNo       页数
 * @return {
 * "code": 200,
 * "data": {
 * "total": 10,
 * "childrenDepartments": [{
 * "id": "-3815455821472706664",
 * "name": "业务支持部",
 * "iconUrl": null,
 * "code": null,
 * "count": 13,
 * "hasChildren": true,
 * "parentId": null
 * }, {
 * "id": "3857526727474234079",
 * "name": "贵州项目部",
 * "iconUrl": null,
 * "code": null,
 * "count": 12,
 * "hasChildren": false,
 * "parentId": null
 * }],
 * "members": [{
 * "id": "-8340276788570666112",
 * "name": "胡守云",
 * "iconUrl": "/personal/user-5.gif",
 * "code": "01",
 * "departmentId": -5226842682007730694,
 * "departmentName": "总裁会",
 * "accountId": 670869647114347,
 * "accName": "北京致远互联软件股份有限公司",
 * "accShortName": "致远软件",
 * "accMotto": "",
 * "jobNumber": "",
 * "levelName": "副总裁",
 * "postName": "政务事业部总经理",
 * "postId": 8052231215681914818,
 * "levelId": 3132400937611641556,
 * "tel": "13908057455",
 * "email": "husy@seeyon.com",
 * "nameSpell": "hushouyun",
 * "officeNumber": "102"
 * }, {
 * "id": "-410203251132381630",
 * "name": "宋建成",
 * "iconUrl": "showType=small",
 * "code": "01",
 * "departmentId": -9009643780873829629,
 * "departmentName": "政务事业部",
 * "accountId": 670869647114347,
 * "accName": "北京致远互联软件股份有限公司",
 * "accShortName": "致远软件",
 * "accMotto": "",
 * "jobNumber": "",
 * "levelName": "助理总裁",
 * "postName": "政务事业部常务副总经理",
 * "postId": -6616114972831627650,
 * "levelId": 1954805673275376034,
 * "tel": "13601851955",
 * "email": "songjc@seeyon.com",
 * "nameSpell": "songjiancheng",
 * "officeNumber": ""
 * }],
 * "parents": [{
 * "departmentName": "北京致远互联软件股份有限公司",
 * "departmentId": "670869647114347"
 * }, {
 * "departmentName": "政务事业部",
 * "departmentId": "-9009643780873829629"
 * }]
 * },
 * "time": 1483411269593,
 * "message": "success",
 * "version": "1.0"
 * }
 * @throws
 */

- (void)getChildrenByDepartmentId:(CDVInvokedUrlCommand *)command {
//    SELECT * FROM tb_unit where ID = '%ld' 
}

/**
 * 获取全部单位列表
 *
 * @return {
 * "code": 200,
 * "data": [{
 * "id": "670869647114347",
 * "name": "北京致远互联软件股份有限公司",
 * "iconUrl": "http://119.61.20.17:9543/seeyon/fileUpload.do?method=showRTE&fileId=-4225380057496402860&type=image",
 * "code": "01",
 * "count": 0,
 * "hasChildren": true,
 * "parentId": null
 * }],
 * "time": 1483411551046,
 * "message": "success",
 * "version": "1.0"
 * }
 * @throws
 */
- (void)getAllAccounts:(CDVInvokedUrlCommand *)command {
//    CREATE TABLE [TB_UNIT] (    [ID] TEXT ,     [NAME] TEXT,    [SORT] TEXT,     [PARENT_ID] TEXT,     [TYPE] TEXT,    [SCOPE] INTEGER,    [PATH] TEXT,     [ORG_MARK] TEXT,    [INTERNAL] INTEGER,    [VIEW] INTEGER)
//    SELECT * FROM tb_unit where type = 'A' 
}

/**
 * 搜索人员，通过人名和手机号
 *
 * @param accountId 单位ID
 * @param pageSize  每一页的条数
 * @param pageNo    页数
 * @param condition 条件
 * @return {
 * "code": 200,
 * "data": {
 * "total": 1,
 * "data": [{
 * "id": "4528522864631235519",
 * "name": "实施管理员1",
 * "iconUrl": "http://119.61.20.17:9543/seeyon/apps_res/v3xmain/images/personal/pic.gif",
 * "code": "01",
 * "departmentId": 2523958172950283465,
 * "departmentName": "实施管理部",
 * "accountId": 670869647114347,
 * "accName": "北京致远互联软件股份有限公司",
 * "accShortName": "致远软件",
 * "accMotto": "",
 * "jobNumber": null,
 * "levelName": "实习",
 * "postName": "【虚拟账号】",
 * "postId": 3497677697094467946,
 * "levelId": 4097573400198136329,
 * "tel": "",
 * "email": "",
 * "nameSpell": "shishiguanliyuan1",
 * "officeNumber": ""
 * }]
 * },
 * "time": 1483412148365,
 * "message": "success",
 * "version": "1.0"
 * }
 */
- (void)searchMembers:(CDVInvokedUrlCommand *)command {
    
}
@end
