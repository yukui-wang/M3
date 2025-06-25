//
//  CMPJSLocalStorageDataHandler.m
//  M3
//
//  Created by Kaku Songu on 11/19/21.
//

#import "CMPJSLocalStorageDataHandler.h"
#import <CMPLib/CMPJSLocalStorageManager.h>
#import <CMPLib/GTMUtil.h>
#import <CMPLib/NSString+CMPString.h>
#import "CMPContactsManager.h"

@implementation CMPJSLocalStorageDataHandler

+ (void)initSeverVersion:(NSString *)serverVersion companyID:(NSString *)companyID {
    NSLog(@"ks log --- migrate initSeverVersion : %@     companyID:%@",serverVersion,companyID);
    [CMPJSLocalStorageManager setItem:companyID forKey:@"companyId"];
    [CMPJSLocalStorageManager setItem:serverVersion forKey:@"serverVersion"];
}

+ (void)saveServerInfo:(NSString *)data {
    //theme default dark
    NSLog(@"ks log --- migrate saveServerInfo : %@",data);
    if (data) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[data JSONValue]];
        if (dic) {
            NSString *editAddress = dic[@"ip"]?:@"";
            NSString *editPort = dic[@"port"]?:@"";
            NSString *editModel = dic[@"model"]?:@"";
            NSString *editAddressAndPort = [NSString stringWithFormat:@"%@_%@",editAddress,editPort];
            NSString *serverVersion = dic[@"serverVersion"]?:@"";
            NSString *ctxPath = [CMPCore sharedInstance].serverurlForSeeyon;
            
            NSString *ctxPath2 = dic[@"contextPath"]?:@"";
            if ([NSString isNull:ctxPath2]) {
                ctxPath2 = @"/seeyon";
            }
            NSString *staticPath = ctxPath;
            NSString *staticSuffix = @"";
            NSString *cdnDomain = @"";
            NSString *orgCode = dic[@"orgCode"]?:@"";
            
            NSString *url = [NSString stringWithFormat:@"%@://%@:%@",editModel,editAddress,editPort];
            NSString *serverId = dic[@"identifier"]?:@"";
            NSString *serverUrl = [url stringByAppendingString:@"/mobile_portal"];
            [dic setObject:url forKey:@"url"];
            [dic setObject:serverId forKey:@"serverID"];
            [dic setObject:serverUrl forKey:@"serverurl"];
            [dic setObject:ctxPath2 forKey:@"contextPath"];

            id updateServer = dic[@"updateServer"]?:@"";
            if ([updateServer isKindOfClass:[NSString class]]) {
                updateServer = [updateServer JSONValue];
            }
            [dic setObject:updateServer forKey:@"shellUpdateSever"];
            
            [CMPJSLocalStorageManager setItem:editAddress forKey:@"editAddress"];
            [CMPJSLocalStorageManager setItem:editPort forKey:@"editPort"];
            [CMPJSLocalStorageManager setItem:editModel forKey:@"editModel"];
            [CMPJSLocalStorageManager setItem:[dic JSONRepresentation] forKey:editAddressAndPort];
            [CMPJSLocalStorageManager setItem:serverVersion forKey:@"serverVersion"];
            [CMPJSLocalStorageManager setItem:ctxPath forKey:@"ctxPath"];
            [CMPJSLocalStorageManager setItem:staticPath forKey:@"staticPath"];
            [CMPJSLocalStorageManager setItem:staticSuffix forKey:@"staticSuffix"];
            [CMPJSLocalStorageManager setItem:cdnDomain forKey:@"cdnDomain"];
            [CMPJSLocalStorageManager setItem:orgCode forKey:@"orgCode"];
        }
    }
}

+ (void)saveLoginCache:(NSString *)data loginName:(NSString *)loginName password:(NSString *)password serverVersion:(NSString *)version {
    NSLog(@"ks log --- migrate saveLoginCache : %@  %@  %@  %@",data,loginName,password,version);
    [CMPJSLocalStorageManager setItem:version forKey:@"serverVersion"];
    [CMPJSLocalStorageManager setItem:[@{@"account":[GTMUtil decrypt:loginName]} JSONRepresentation] forKey:@"currentUserInfo"];
    NSDictionary *dic = [data JSONValue];
    if (dic && dic[@"data"]) {
        NSDictionary *obj = dic[@"data"];
        if (obj) {
            
            NSMutableDictionary *extInfo = [[NSMutableDictionary alloc] init];
            
            CMPServerModel *currentServer = [CMPCore sharedInstance].currentServer;
            NSString *serverUrl = [NSString stringWithFormat:@"%@://%@:%@",currentServer.scheme,currentServer.host,currentServer.port];
            
            NSDictionary *currentMember = obj[@"currentMember"];
            if (currentMember && [currentMember isKindOfClass:[NSDictionary class]]) {
                [extInfo addEntriesFromDictionary:currentMember];
                [CMPJSLocalStorageManager setItem:currentMember[@"accountId"] forKey:@"companyId"];
                [CMPJSLocalStorageManager setItem:currentMember[@"id"] forKey:[@"userId_" stringByAppendingString:serverUrl]];
            }

            NSString *iconUrl = [NSString stringWithFormat:@"%@/mobile_portal/seeyon/rest/orgMember/avatar/%@?maxWidth=200&data=%ld",serverUrl,currentMember[@"id"],random()*100];
            NSDictionary *config = obj[@"config"]?:@{};
            [extInfo addEntriesFromDictionary:config];
            [extInfo setObject:iconUrl forKey:@"iconUrl"];
            [extInfo setObject:@"true" forKey:@"loginStatus"];
            [extInfo setObject:(password?:@"") forKey:@"loginPwd"];
            [extInfo setObject:(loginName?:@"") forKey:@"loginName"];
            [extInfo setObject:[GTMUtil decrypt:loginName] forKey:@"account"];
            if ([NSString isNotNull:password]) {
                [extInfo setObject:password forKey:@"voiceLoginPwd"];
            }
            NSDictionary *finalDic = [self fixMemberInfoWithExtDic:extInfo];
            NSLog(@"ks log --- saveLoginCache --- currentMember:%@",finalDic);
            
            NSString *statisticId = obj[@"statisticId"]?:@"";
//            NSString *ticket = obj[@"ticket"]?:@"";
            [CMPJSLocalStorageManager setItem:statisticId forKey:@"statisticId"];
            [CMPJSLocalStorageManager setItem:finalDic[@"name"] forKey:@"name"];
            [CMPJSLocalStorageManager setItem:[serverUrl stringByAppendingString:@"/mobile_portal"] forKey:@"online-debug-url"];
            [CMPJSLocalStorageManager setItem:iconUrl forKey:@"iconUrl"];
        }
        
    }
}

+ (void)updateAccountID:(NSString *)accountID
            accountName:(NSString *)accountName
              shortName:(NSString *)shortName
            accountCode:(NSString *)accountCode
             configInfo:(NSString *)configInfo
            currentInfo:(id)currentInfo
                preInfo:(id)preInfo {
    NSLog(@"ks log --- migrate updateAccountID : %@  %@  %@  %@  %@",accountID,accountName,shortName,accountCode,configInfo);
    
    void(^blk)(void) = ^{
        NSDictionary *data = @{@"accountId" : accountID,
                               @"accName" : accountName,
                               @"accShortName" : shortName,
                               @"code" : accountCode
        };
        
        [CMPJSLocalStorageManager setItem:accountID forKey:@"companyId"];
        NSDictionary *aDic = [self fixMemberInfoWithExtDic:nil];
        if (aDic && !aDic[@"id"]) {
            if (preInfo && [preInfo isKindOfClass:CMPLoginAccountModel.class]) {
                CMPLoginAccountModel *preAcc = (CMPLoginAccountModel *)preInfo;
                NSDictionary *aaDic = [self fixMemberInfoWithExtDic:nil byCompanyId:preAcc.accountID];
                if (aaDic) {
                    NSMutableDictionary *aaaDic = [NSMutableDictionary dictionaryWithDictionary:aaDic];
                    [aaaDic addEntriesFromDictionary:data];
                    [self fixMemberInfoWithExtDic:aaaDic];
                }
            }
        }else{
            [self fixMemberInfoWithExtDic:data];
        }
        if (configInfo) {
            NSDictionary *configDic = [configInfo JSONValue];
            if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
                [self fixMemberInfoWithExtStr:configDic[@"data"]];
            }
        }
    };
    
    blk();
    
    return;//上述逻辑参考m3datauprage，觉得有些问题，下面是优化逻辑，暂时先注释保存
    
//    CMPLoginAccountModel *loginModel = [CMPCore sharedInstance].currentUser;
//    if (![accountID isEqualToString:loginModel.accountID]) {
//        NSString *idstr = [CMPCore sharedInstance].userID;
//        CMPServerModel *currentServer = [CMPCore sharedInstance].currentServer;
//        NSString *serverUrl = [NSString stringWithFormat:@"%@://%@:%@",currentServer.scheme,currentServer.host,currentServer.port];
//        NSString *iconUrl = [NSString stringWithFormat:@"%@/mobile_portal/seeyon/rest/orgMember/avatar/%@?maxWidth=200&data=%ld",serverUrl,idstr,random()*100];
//        [[CMPContactsManager defaultManager] memberInfoForID:idstr accountID:accountID completion:^(CMPOfflineContactMember *member) {
//            if (member) {
//                NSDictionary *dic = @{@"id":idstr,@"iconUrl":iconUrl,@"name":member.name,@"postName":member.postName};
//                [self fixMemberInfoWithExtDic:dic];
//            }
//            blk();
//        }];
//    }
//    else{
//        blk();
//    }
}

+ (void)saveConfigInfo:(NSString *)data {
    
    NSLog(@"ks log --- migrate saveConfigInfo : %@",data);
    if (data) {
        NSDictionary *res = [data JSONValue];
        NSDictionary *resData = res[@"data"];
        if (resData) {
            [self fixMemberInfoWithExtDic:resData];
        }else{
            //
        }
    }
}

+ (void)saveGestureState:(NSUInteger)state {
    NSLog(@"ks log --- migrate saveGestureState : %lu",(unsigned long)state);
    [self fixMemberInfoWithExtDic:@{@"gesture":@(state)}];
}

+ (void)saveV5Product:(NSString *)product {
    NSLog(@"ks log --- migrate saveV5Product : %@",product);
    [CMPJSLocalStorageManager setItem:product forKey:@"CMP_V5_PRODUCTEDITION"];
}



+(void)fixMemberInfoWithExtStr:(NSString *)extInfoStr
{
    if (extInfoStr &&[extInfoStr isKindOfClass:[NSString class]] && extInfoStr.length) {
        NSDictionary *extInfoDic = [extInfoStr JSONValue];
        [self fixMemberInfoWithExtDic:extInfoDic];
    }else{
        [self fixMemberInfoWithExtDic:extInfoStr];
    }
}

+(NSDictionary *)fixMemberInfoWithExtDic:(NSDictionary *)extInfoDic
{
    NSString *companyId = [CMPCore sharedInstance].currentUser.accountID;
    return [self fixMemberInfoWithExtDic:extInfoDic byCompanyId:companyId];
}

+(NSDictionary *)fixMemberInfoWithExtDic:(NSDictionary *)extInfoDic byCompanyId:(NSString *)companyId
{
    NSDictionary *resultDic;
    
    NSInteger serverNumber = [CMPCore sharedInstance].currentServer.serverVersionNumber;
    CMPServerModel *currentServer = [CMPCore sharedInstance].currentServer;
    NSString *server = [NSString stringWithFormat:@"%@://%@:%@",currentServer.scheme,currentServer.host,currentServer.port];
    NSString *userId = [CMPCore sharedInstance].userID;
//  if (serverNumber >= 210) {
    
    NSString *newKey = [NSString stringWithFormat:@"userId_%@server_%@companyId_%@",userId,server,companyId];
    NSMutableDictionary *finalDic = [[NSMutableDictionary alloc] initWithDictionary:[CMPJSLocalStorageDataHandler _memberConfigDefaultDic]];
    NSString *oriStr1 = [CMPJSLocalStorageManager getItem:newKey];
    if (oriStr1 && oriStr1.length) {
        NSDictionary *dic1 = [oriStr1 JSONValue];
        [finalDic addEntriesFromDictionary:dic1];
        
        resultDic = dic1;
    }

//  }else{
    
    NSString *oldKey = [NSString stringWithFormat:@"userId_%@server_%@",userId,server];
    NSMutableDictionary *finalDic2 = [[NSMutableDictionary alloc] initWithDictionary:[CMPJSLocalStorageDataHandler _memberConfigDefaultDic]];
    NSString *oriStr2 = [CMPJSLocalStorageManager getItem:oldKey];
    if (oriStr2 && oriStr2.length) {
        NSDictionary *dic2 = [oriStr2 JSONValue];
        [finalDic2 addEntriesFromDictionary:dic2];
        
        if (!resultDic) {
            resultDic = dic2;
        }
    }
//  }

    if (extInfoDic && [extInfoDic isKindOfClass:[NSDictionary class]]) {

        [finalDic addEntriesFromDictionary:extInfoDic];
        NSString *finalStr = [finalDic JSONRepresentation];
        [CMPJSLocalStorageManager setItem:finalStr forKey:newKey];
        
        resultDic = finalDic;
        
        [finalDic2 addEntriesFromDictionary:extInfoDic];
        NSString *finalStr2 = [finalDic2 JSONRepresentation];
        [CMPJSLocalStorageManager setItem:finalStr2 forKey:oldKey];
        
        if (!resultDic) {
            resultDic = finalDic2;
        }
    }
    NSLog(@"fixMemberInfoWithExtDic:%@,----- resultDic:%@",extInfoDic,resultDic);
    return resultDic;
}


+(NSDictionary *)_memberConfigDefaultDic
{
    return @{@"gesture":@(2),
             @"gesturePwd":@"",
             @"deviceState":@"",
             @"soundRemind":@(1),
             @"vibrationRemind":@(1),
             @"voiceStatus":@(2),
             @"voicePwd":@"",
             @"showAppCategory":@"true",
             @"indexPage":@"todo"
    };
}

@end
