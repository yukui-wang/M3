//
//  CMPContactsTableManager.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "CMPContactsTableManager.h"
#import <CMPLib/CMPOfflineContactMember.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/ZipArchiveUtils.h>

@implementation CMPContactsTableManager

+ (void)createTables:(FMDatabase *)contactsDB
{
    //-- 人员表 NAME_SPELL - 全拼 NAME_SP -拼音首字母
    NSString *memberTableSql = @"CREATE TABLE IF NOT EXISTS [TB_MEMBER] (\
    [ID] TEXT, \
    [SORT] INTEGER, \
    [NAME] TEXT, \
    [NAME_SPELL] TEXT,\
    [NAME_SP] TEXT, \
    [NAME_SPH] TEXT, \
    [TEL] TEXT, \
    [MOBILE_PHONE] TEXT, \
    [WS] TEXT, \
    [INS] INTEGER, \
    [MAIL] TEXT, \
    [MARK] TEXT,\
    [ELEVEL] TEXT,\
    [EPOST] TEXT,\
    [EXT_FIELD] TEXT,\
    [WORKADDR] TEXT,\
    [WX] TEXT,\
    [WB] TEXT,\
    [HOMEADDR] TEXT,\
    [PORT] TEXT,\
    [COMMUNICATIONADDR] TEXT,\
    [VIEW] INTEGER,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";
    //-- 职务级别表 /*GROUP_LEVEL -- 集团职务级别ID  LEVEL -- 职务级别ID，与职务级别对象的ID是两个不同的东西*/
    NSString *levelTableSql = @"CREATE TABLE IF NOT EXISTS [TB_LEVEL] (\
    [ID] TEXT, \
    [NAME] TEXT, \
    [SORT] INTEGER, \
    [MARK] TEXT, \
    [AID] TEXT, \
    [SCOPE] INTEGER, \
    [GROUP_LEVEL] TEXT,\
    [LEVEL] IINTEGER,\
    [EXT_FIELD] TEXT,\
    [VIEW] INTEGER,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";
    //-- 岗位表
    NSString *postTableSql = @"CREATE TABLE IF NOT EXISTS [TB_POST] (\
    [ID] TEXT, \
    [NAME] TEXT, \
    [SORT] INTEGER, \
    [MARK] TEXT,\
    [EXT_FIELD] TEXT,\
    [VIEW] INTEGER,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";
    //-- 关系表
    NSString *relationTableSql = @"CREATE TABLE IF NOT EXISTS [TB_RELATION] (\
    [ID] TEXT ,\
    [MID] TEXT, \
    [AID] TEXT, \
    [DID] TEXT,\
    [PID] TEXT,\
    [LID] TEXT, \
    [SHOW_TEL] INTEGER, \
    [SHOW_LEVEL] INTEGER, \
    [AVAILABLE_FLOW] INTEGER , \
    [AVAILABLE_FORM] INTEGER , \
    [AVAILABLE_EDOC] INTEGER , \
    [AVAILABLE_CONTACTS] INTEGER ,\
    [EXT_FIELD] TEXT,\
    [TYPE] TEXT,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";
    //-- 单位表
    NSString *unitTableSql = @"CREATE TABLE IF NOT EXISTS [TB_UNIT] (\
    [ID] TEXT , \
    [NAME] TEXT,\
    [SORT] INTEGER, \
    [PARENT_ID] TEXT, \
    [TYPE] TEXT,\
    [SCOPE] INTEGER,\
    [PATH] TEXT, \
    [ORG_MARK] TEXT,\
    [INTERNAL] INTEGER,\
    [EXT_FIELD] TEXT,\
    [VIEW] INTEGER,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";
    //-- 更新日志表
    NSString *updateLogTableSql = @"CREATE TABLE IF NOT EXISTS [TB_UPDATE_LOG] (\
    [TYPE] TEXT,\
    [MD5] TEXT,\
    [UPDATE_DATE] TEXT,\
    [AID] TEXT,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";//key-value  m(人员)- md5  AID -- 单位id
    //-- 统计表
    NSString *statisticsTableSql = @"CREATE TABLE IF NOT EXISTS [TB_STATISTICS] (\
    [AID] TEXT,\
    [UID] TEXT,\
    [COUNT] INTEGER,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";//用于统计部门人员数量等等
    //-- 单位权限设置表
    NSString *settingTableSql = @"CREATE TABLE IF NOT EXISTS [TB_ACCOUNT_SETTING] (\
    [AID] TEXT,\
    [ACCESSABLE] INTEGER,\
    [MD5] TEXT,\
    [SETTING] TEXT,\
    [EXTENT1] TEXT,\
    [EXTENT2] TEXT,\
    [EXTENT3] TEXT,\
    [EXTENT4] TEXT,\
    [EXTENT5] TEXT)";
    
    [contactsDB executeUpdate:levelTableSql];
    [contactsDB executeUpdate:memberTableSql];
    [contactsDB executeUpdate:postTableSql];
    [contactsDB executeUpdate:relationTableSql];
    [contactsDB executeUpdate:unitTableSql];
    [contactsDB executeUpdate:updateLogTableSql];
    [contactsDB executeUpdate:statisticsTableSql];
    [contactsDB executeUpdate:settingTableSql];
    
}



+ (void)clearTable:(FMDatabase *)contactsDB{
    NSString *deletaSql = @"delete from  TB_MEMBER";
    [contactsDB executeUpdate:deletaSql];
    
    deletaSql = @"delete from  TB_LEVEL";
    [contactsDB executeUpdate:deletaSql];
    
    deletaSql = @"delete from  TB_POST";
    [contactsDB executeUpdate:deletaSql];
    
    deletaSql = @"delete from  TB_RELATION";
    [contactsDB executeUpdate:deletaSql];
    
    deletaSql = @"delete from  TB_UNIT";
    [contactsDB executeUpdate:deletaSql];
    
    deletaSql = @"delete from  TB_UPDATE_LOG";
    [contactsDB executeUpdate:deletaSql];
    
    deletaSql = @"delete from  TB_STATISTICS";
    [contactsDB executeUpdate:deletaSql];
    
    deletaSql = @"delete from  TB_ACCOUNT_SETTING";
    [contactsDB executeUpdate:deletaSql];
        
    [CMPContactsTableManager defaultValusForTables:contactsDB];
    
    //清除后默认设置
    [CMPContactsTableManager createTables:contactsDB];
    [CMPContactsTableManager defaultValusForTables:contactsDB];

}

+ (void)defaultValusForTables:(FMDatabase *)contactsDB
{
    NSString *deleteSql = @"delete from TB_POST where id = '-1' and  name = '-1'";
    [contactsDB executeUpdate:deleteSql];

    NSString *postSql = @"insert into TB_POST (ID,NAME,SORT,MARK,VIEW,EXT_FIELD) values ('-1','-1',-1,'-1',1,'')";
    [contactsDB executeUpdate:postSql];
    
    deleteSql = @"delete from TB_LEVEL where id = '-1' and  name = '-1'";
    [contactsDB executeUpdate:deleteSql];

    NSString *levelSql = @"insert into TB_LEVEL (ID,NAME,SORT,MARK,AID,SCOPE,VIEW,GROUP_LEVEL,LEVEL,EXT_FIELD) values ('-1','-1',-1,'','',0,1,'-1',1,'')";
    [contactsDB executeUpdate:levelSql];

}

+ (NSArray *)sqlArrayWithPath:(NSString *)path info:(NSDictionary *)info
{
    NSString *name = [info objectForKey:@"name"];
    //解压zip 并转换为list string
    NSArray *stringList = [CMPContactsTableManager jsonStringFormPath:path name:name] ;
    if (!stringList || stringList.count == 0) {
        return nil;
    }
    NSString *type = [info objectForKey:@"type"];
    type = type.uppercaseString;
    if ([type isEqualToString:@"M"]) {//人员
        return  [CMPContactsTableManager memberSqlWithJsonStr:stringList];
    }
    else if ([type isEqualToString:@"P"]) {//岗位
        return  [CMPContactsTableManager postSqlWithJsonStr:stringList];
    }
    else if ([type isEqualToString:@"L"]) {//职务级别
        return [CMPContactsTableManager levelSqlWithJsonStr:stringList];
    }
    else if ([type isEqualToString:@"MR"]) {//关系表
        return [CMPContactsTableManager relationSqlWithJsonStr:stringList];
    }
    else if ([type isEqualToString:@"U"]||[type isEqualToString:@"A"]||[type isEqualToString:@"D"]) {//集团,单位,部门
        return  [CMPContactsTableManager unitSqlWithJsonStr:stringList];
    }
    else {
        return nil;
    }
}


+ (NSArray *)jsonStringFormPath:(NSString *)filePath name:(NSString *)name
{
    NSString *docpath = [CMPFileManager createFullPath:@"Documents/File/OfflineTemp"];
    NSString *path = [NSString stringWithFormat:@"%@/%@",docpath,name];
    BOOL ret =  [ZipArchiveUtils unZipArchiveNOPassword:filePath unzipto:path];
    if (ret) {
        NSArray *array = [[NSFileManager defaultManager] subpathsAtPath:path];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (NSString *p in array) {
            NSString *subPath = [NSString stringWithFormat:@"%@/%@",path,p];
            NSString *jsonString = [NSString stringWithContentsOfFile:subPath encoding:NSUTF8StringEncoding error:nil];
            if (!jsonString) {
                NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                jsonString = [NSString stringWithContentsOfFile:subPath encoding:enc error:nil];
            }
            NSArray *stringList = [jsonString componentsSeparatedByString:@"\n"];
            [result addObjectsFromArray:stringList];
        }
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
        return [result autorelease];
    }
    [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    return nil;
}

+ (NSArray *)memberSqlWithJsonStr:(NSArray *)stringList
{
    NSMutableArray *sqlList = [[NSMutableArray alloc] init];
    for (NSInteger t = 0 ; t< stringList.count; t++) {
        NSString *str = [stringList objectAtIndex:t];
        if (str.length == 0) {
            continue;
        }
        NSDictionary *dic = [str JSONValue];
        NSString *handle =  [dic objectForKey:@"handle"];
        NSDictionary *entity = [dic objectForKey:@"entity"];
        //
        if ([handle isEqualToString:@"insert"]) {
            NSString *memberid =  [entity objectForKey:@"oId"] ?: @"";
            NSString *sort =  [entity objectForKey:@"s"] ?: @"";
            NSString *name =  [entity objectForKey:@"n"] ?: @"";
            NSString *nsmeSpell = [entity objectForKey:@"py"] ?: @"";
            NSString *nameSpellHead = [entity objectForKey:@"pyh"] ?: @"";
           
            NSString *tel =  [entity objectForKey:@"off"] ?: @"";
            NSString *mobilePhone =  [entity objectForKey:@"te"] ?: @"";
            NSString *mail =  [entity objectForKey:@"em"] ?: @"";
            NSString *mark =  [entity objectForKey:@"m"] ?: @"";
            NSString *ws =  [entity objectForKey:@"ws"] ?: @"";
            NSString *ins =  [entity objectForKey:@"ins"] ?: @"";
            NSString *view =  [entity objectForKey:@"v"] ?: @"";
            NSString *eLevel =  [entity objectForKey:@"eLevel"] ?: @"";
            NSString *ePost =  [entity objectForKey:@"ePost"] ?: @"";
            
            NSString *workAddr = [entity objectForKey:@"workadds"] ?: @""; // 工作地址
            NSString *wx = [entity objectForKey:@"wx"] ?: @""; // 微信
            NSString *wb = [entity objectForKey:@"wb"] ?: @""; // 微博
            NSString *homeAddr = [entity objectForKey:@"homeadds"] ?: @""; // 家庭住址
            NSString *port = [entity objectForKey:@"port"] ?: @""; // 邮政编码
            NSString *communicationAddr = [entity objectForKey:@"adds"] ?: @""; // 通信地址
            
            if ([NSString isNull:nsmeSpell] || nsmeSpell.length ==0) {
                nsmeSpell = @"#";
            }
            else {
                nsmeSpell = nsmeSpell.uppercaseString;
            }
            NSString *nameSP = [nsmeSpell substringToIndex:1];
           
            NSString *extend = [entity objectForKey:@"EXT_FIELD"];
            if ([NSString isNull:extend]) {
                extend = @"";
            }
            NSString *valusString = [NSString stringWithFormat:@"'%@',%@,'%@','%@','%@','%@','%@','%@','%@','%@','%@',%@,'%@','%@',%@,'%@','%@','%@','%@','%@','%@','%@'",memberid,sort,name,nsmeSpell,nameSP,nameSpellHead,tel,mobilePhone,mail,mark,ws,ins,eLevel,ePost,view,extend, workAddr, wx, wb, homeAddr, port, communicationAddr];
            NSString *sql = [NSString stringWithFormat:@"insert into TB_MEMBER (ID,SORT,NAME,NAME_SPELL,NAME_SP,NAME_SPH,TEL,MOBILE_PHONE,MAIL,MARK,WS,INS,ELEVEL,EPOST,VIEW,EXT_FIELD,WORKADDR,WX,WB,HOMEADDR,PORT,COMMUNICATIONADDR) values (%@)",valusString];
            [sqlList addObject:sql];
        }
        else if ([handle isEqualToString:@"delete"])  {
            NSArray *condition = [entity objectForKey:@"condition"];
            if (condition.count == 0) {
                continue;
            }
            NSMutableString *conditionStr = [NSMutableString string];
            for (NSInteger i = 0 ; i < condition.count; i++) {
                NSDictionary *child = [condition objectAtIndex:i];
                NSString *key =  [child objectForKey:@"key"];
                if ([key isEqual:@"oId"]) {
                    key = @"id";
                }
                NSString *value =  [child objectForKey:@"value"];
                if (i != 0) {
                    [conditionStr appendString:@" and "];
                }
                [conditionStr appendFormat:@" %@ = '%@' ",key,value];
                
            }
            if (conditionStr.length >0) {
                NSString *sql = [NSString stringWithFormat:@"delete from TB_MEMBER where %@ ",conditionStr];
                [sqlList addObject:sql];
            }
        }
    }
    stringList = nil;
    return [sqlList autorelease];
}

+ (NSArray *)postSqlWithJsonStr:(NSArray *)stringList{
   
    NSMutableArray *sqlList = [[NSMutableArray alloc] init];
    for (NSInteger t = 0 ; t< stringList.count; t++) {
        NSString *str = [stringList objectAtIndex:t];
        if (str.length == 0) {
            continue;
        }
        NSDictionary *dic = [str JSONValue];
        NSString *handle =  [dic objectForKey:@"handle"];
        NSDictionary *entity = [dic objectForKey:@"entity"];
        if ([handle isEqualToString:@"insert"]) {
            NSString *postId = [entity objectForKey:@"oId"];
            NSString *name = [entity objectForKey:@"n"];
            NSString *sort = [entity objectForKey:@"s"];
            NSString *mark = [entity objectForKey:@"m"];
            NSString *view =  [entity objectForKey:@"v"];
            NSString *extend = [entity objectForKey:@"EXT_FIELD"];
            if ([NSString isNull:extend]) {
                extend = @"";
            }
            NSString *valusString = [NSString stringWithFormat:@"'%@','%@',%@,'%@',%@,'%@'",postId,name,sort,mark,view,extend];
            NSString *sql = [NSString stringWithFormat:@"insert into TB_POST (ID,NAME,SORT,MARK,VIEW,EXT_FIELD) values (%@)",valusString];
            [sqlList addObject:sql];
        }
        else if ([handle isEqualToString:@"delete"])  {
            NSArray *condition = [entity objectForKey:@"condition"];
            if (condition.count == 0) {
                continue;
            }
            NSMutableString *conditionStr = [NSMutableString string];
            for (NSInteger i = 0 ; i < condition.count; i++) {
                NSDictionary *child = [condition objectAtIndex:i];
                NSString *key =  [child objectForKey:@"key"];
                NSString *value =  [child objectForKey:@"value"];
                if ([key isEqual:@"oId"]) {
                    key = @"id";
                }
                if (i != 0) {
                    [conditionStr appendString:@" and "];
                }
                [conditionStr appendFormat:@" %@ = '%@' ",key,value];
                
            }
            if (conditionStr.length >0) {
                NSString *sql = [NSString stringWithFormat:@"delete from TB_POST where %@ ",conditionStr];
                [sqlList addObject:sql];
            }
        }

    }
    stringList = nil;
    return [sqlList autorelease];
}

+ (NSArray *)levelSqlWithJsonStr:(NSArray *)stringList{
    
    NSMutableArray *sqlList = [[NSMutableArray alloc] init];
    for (NSInteger t = 0 ; t< stringList.count; t++) {
        NSString *str = [stringList objectAtIndex:t];
        if (str.length == 0) {
            continue;
        }
        NSDictionary *dic = [str JSONValue];
        NSString *handle =  [dic objectForKey:@"handle"];
        NSDictionary *entity = [dic objectForKey:@"entity"];
        
        if ([handle isEqualToString:@"insert"]) {
            NSString *levelId = [entity objectForKey:@"oId"];
            NSString *name = [entity objectForKey:@"n"];
            NSString *sort = [entity objectForKey:@"s"];
            NSString *mark = [entity objectForKey:@"m"];
            NSString *aId = [entity objectForKey:@"aId"];
            NSString *scope = @"0";//[dic objectForKey:@"m"];
            NSString *view =  [entity objectForKey:@"v"];
            NSString *groupLevel =  [entity objectForKey:@"gl"];
            NSString *level =  [entity objectForKey:@"l"];
            NSString *extend = [entity objectForKey:@"EXT_FIELD"];
            if ([NSString isNull:extend]) {
                extend = @"";
            }
            NSString *valusString = [NSString stringWithFormat:@"'%@','%@',%@,'%@','%@',%@,%@,'%@',%@,'%@'",levelId,name,sort,mark,aId,scope,view,groupLevel,level,extend];
            NSString *sql = [NSString stringWithFormat:@"insert into TB_LEVEL (ID,NAME,SORT,MARK,AID,SCOPE,VIEW,GROUP_LEVEL,LEVEL,EXT_FIELD) values (%@)",valusString];
            [sqlList addObject:sql];
        }
        else if ([handle isEqualToString:@"delete"])  {
            NSArray *condition = [entity objectForKey:@"condition"];
            if (condition.count == 0) {
                continue;
            }
            NSMutableString *conditionStr = [NSMutableString string];
            for (NSInteger i = 0 ; i < condition.count; i++) {
                NSDictionary *child = [condition objectAtIndex:i];
                NSString *key =  [child objectForKey:@"key"];
                NSString *value =  [child objectForKey:@"value"];
                if ([key isEqual:@"oId"]) {
                    key = @"id";
                }
                if (i != 0) {
                    [conditionStr appendString:@" and "];
                }
                [conditionStr appendFormat:@" %@ = '%@' ",key,value];
                
            }
            if (conditionStr.length >0) {
                NSString *sql = [NSString stringWithFormat:@"delete from TB_LEVEL where %@ ",conditionStr];
                [sqlList addObject:sql];
            }
        }
    }
    stringList = nil;
    return [sqlList autorelease];
}

+ (NSArray *)relationSqlWithJsonStr:(NSArray *)stringList{
    
    NSMutableArray *sqlList = [[NSMutableArray alloc] init];
    for (NSInteger t = 0 ; t< stringList.count; t++) {
        NSString *str = [stringList objectAtIndex:t];
        if (str.length == 0) {
            continue;
        }
        NSDictionary *dic = [str JSONValue];
        NSString *handle =  [dic objectForKey:@"handle"];
        NSDictionary *entity = [dic objectForKey:@"entity"];
        if ([handle isEqualToString:@"insert"]) {
            NSString *oId = [entity objectForKey:@"oId"];
            NSString *mid = [entity objectForKey:@"mId"];
            NSString *aid = [entity objectForKey:@"aId"];
            NSString *type = [entity objectForKey:@"t"];
            NSString *did = [entity objectForKey:@"dId"];
            NSString *pid = [entity objectForKey:@"pId"];
            NSString *lid = [entity objectForKey:@"lId"];
            //以下暂无
            NSString *availableFlow= @"4";// [dic objectForKey:@"n"];
            NSString *availableForm = @"4";//[dic objectForKey:@"n"];
            NSString *availableEdoc = @"4";// [dic objectForKey:@"n"];
            NSString *availableContacts = @"4";// [dic objectForKey:@"n"];
            NSString *showTel = @"4";// [dic objectForKey:@"n"];
            NSString *showLevel = @"4";// [dic objectForKey:@"n"];
            NSString *extend = [entity objectForKey:@"EXT_FIELD"];
            if ([NSString isNull:extend]) {
                extend = @"";
            }
            NSString *valusString = [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@',%@,%@,%@,%@,%@,%@,'%@'",oId,mid,aid,type,did,pid,lid,availableFlow,availableForm,availableEdoc,availableContacts,showTel,showLevel,extend];
            NSString *sql = [NSString stringWithFormat:@"insert into TB_RELATION (ID,MID,AID,TYPE,DID,PID,LID,AVAILABLE_FLOW,AVAILABLE_FORM,AVAILABLE_EDOC,AVAILABLE_CONTACTS,SHOW_TEL,SHOW_LEVEL,EXT_FIELD) values (%@)",valusString];
            [sqlList addObject:sql];
        }
        else if ([handle isEqualToString:@"delete"])  {
            NSArray *condition = [entity objectForKey:@"condition"];
            if (condition.count == 0) {
                continue;
            }
            NSMutableString *conditionStr = [NSMutableString string];
            for (NSInteger i = 0 ; i < condition.count; i++) {
                NSDictionary *child = [condition objectAtIndex:i];
                NSString *key =  [child objectForKey:@"key"];
                NSString *value =  [child objectForKey:@"value"];
                if (i != 0) {
                    [conditionStr appendString:@" and "];
                }
                [conditionStr appendFormat:@" %@ = '%@' ",key,value];
               
            }
            if (conditionStr.length >0) {
                NSString *sql = [NSString stringWithFormat:@"delete from TB_RELATION where %@ ",conditionStr];
                [sqlList addObject:sql];
            }
        }
    }
    stringList = nil;
    return [sqlList autorelease];
}


+ (NSArray *)unitSqlWithJsonStr:(NSArray *)stringList {
    NSMutableArray *sqlList = [[NSMutableArray alloc] init];
    for (NSInteger t = 0 ; t< stringList.count; t++) {
        NSString *str = [stringList objectAtIndex:t];
        if (str.length == 0) {
            continue;
        }
        NSDictionary *dic = [str JSONValue];
        NSString *handle =  [dic objectForKey:@"handle"];
        NSDictionary *entity = [dic objectForKey:@"entity"];
        
        if ([handle isEqualToString:@"insert"]) {
            NSString *uId = [entity objectForKey:@"aId"];
            NSString *name = [entity objectForKey:@"n"];
            NSString *sort = [entity objectForKey:@"s"];
            NSString *parentId = [entity objectForKey:@"fa"];
            NSString *type = [entity objectForKey:@"t"];
            NSString *path = [entity objectForKey:@"pa"];
            NSString *orgMark = [entity objectForKey:@"m"];
            NSString *internal= [entity objectForKey:@"ins"]; // 是否外部单位
            NSString *view =  [entity objectForKey:@"v"];
            NSString *scope =  [entity objectForKey:@"sc"];
            NSString *extend = [entity objectForKey:@"EXT_FIELD"];
            if ([NSString isNull:extend]) {
                extend = @"";
            }
            NSString *valusString = [NSString stringWithFormat:@"'%@','%@',%@,'%@','%@','%@','%@',%@,%@,%@,'%@'",uId,name,sort,parentId,type,path,orgMark,internal,view,scope,extend];
            NSString *sql = [NSString stringWithFormat:@"insert into TB_UNIT (ID,NAME,SORT,PARENT_ID,TYPE,PATH,ORG_MARK,INTERNAL,VIEW,SCOPE,EXT_FIELD) values (%@)",valusString];
            [sqlList addObject:sql];
        }
        else if ([handle isEqualToString:@"delete"])  {
            NSArray *condition = [entity objectForKey:@"condition"];
            if (condition.count == 0) {
                continue;
            }
            NSMutableString *conditionStr = [NSMutableString string];
            for (NSInteger i = 0 ; i < condition.count; i++) {
                NSDictionary *child = [condition objectAtIndex:i];
                NSString *key =  [child objectForKey:@"key"];
                NSString *value =  [child objectForKey:@"value"];
                if ([key isEqual:@"oId"]) {
                    key = @"id";
                }
                if (i != 0) {
                    [conditionStr appendString:@" and "];
                }
                [conditionStr appendFormat:@" %@ = '%@' ",key,value];
                
            }
            if (conditionStr.length >0) {
                NSString *sql = [NSString stringWithFormat:@"delete from TB_UNIT where %@ ",conditionStr];
                [sqlList addObject:sql];
            }
        }

    }
    stringList = nil;
    return [sqlList autorelease];
}


+ (BOOL)needUpdateAccountSettingSql:(MAccountAvailableEntity *)entity db:(FMDatabase *)contactsDB{
    if (entity.change == 1) {
        return YES;
    }
    NSString *deleteSql = [NSString stringWithFormat:@"select count (*) from TB_ACCOUNT_SETTING where AID = '%lld'",entity.accountId];
    FMResultSet *set = [contactsDB executeQuery:deleteSql];
    NSInteger count = 0;
    while ([set next]) {
        count = [set intForColumnIndex:0];
    }
    return count == 0;
}

+ (void)runInsertAccountSettingSql:(MAccountAvailableEntity *)entity db:(FMDatabase *)contactsDB
{
    NSString *aid = [NSString stringWithFormat:@"%lld",entity.accountId];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from TB_ACCOUNT_SETTING where AID = '%@'",aid];
    [contactsDB executeUpdate:deleteSql];

    NSString *accessable = [NSString stringWithFormat:@"%d",entity.accessable];
    NSString *md5 = entity.md5;
    NSString *setting = [entity.setting JSONRepresentation];

    NSString *valusString = [NSString stringWithFormat:@"'%@',%@,'%@','%@'",aid,accessable,md5,setting];
    NSString *sql = [NSString stringWithFormat:@"insert into TB_ACCOUNT_SETTING (AID,ACCESSABLE,MD5,SETTING) values (%@)",valusString];
    [contactsDB executeUpdate:sql];
}

+ (NSString *)jsonForAccountSettingInSql:(FMDatabase *)contactsDB
{
    NSString *accountID =  [CMPCore sharedInstance].currentUser.accountID;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *sql = [NSString stringWithFormat: @"select MD5 from TB_ACCOUNT_SETTING where AID = %@",accountID];
    FMResultSet *set =  [contactsDB executeQuery:sql];
    while ([set next]) {
        NSString *md5 = [set stringForColumn:@"MD5"];
        if (![NSString isNull:md5]&& ![NSString isNull:accountID] ) {
            [dic setObject:md5 forKey:accountID];
        }
    }
    return [dic JSONRepresentation];
}

+ (NSDictionary *)getAccountSetting:(FMDatabase *)contactsDB
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSString *sql = @"select * from TB_ACCOUNT_SETTING";
    FMResultSet *set =  [contactsDB executeQuery:sql];
    while ([set next]) {
        NSString *type = [set stringForColumn:@"AID"];
        NSString *value = [set stringForColumn:@"MD5"];
        [result setObject:value forKey:type];
    }
    return result;
}

+ (NSArray *)updateLogWithType:(NSString *)type value:(NSString *)value aId:(NSString *)aId
{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from TB_UPDATE_LOG WHERE TYPE = '%@' AND AID = '%@'",type.lowercaseString,aId];
    
    NSString *valusString = [NSString stringWithFormat:@"'%@','%@','%@'",type.lowercaseString,value,aId];
    NSString *sql = [NSString stringWithFormat:@"insert into TB_UPDATE_LOG (TYPE,MD5,AID) values (%@)",valusString];
    return [NSArray arrayWithObjects:deleteSql,sql, nil];
}

+ (NSDictionary *)getAllupdateLog:(FMDatabase *)contactsDB aId:(NSString *)aId sId:(NSString *)sId
{
    if (!aId || !sId) {
        return nil;
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSString *sql = [NSString stringWithFormat:@"select * from TB_UPDATE_LOG WHERE AID = '%@'",aId];
    FMResultSet *set =  [contactsDB executeQuery:sql];
    while ([set next]) {
        NSString *type = [set stringForColumn:@"TYPE"];
        NSString *value = [set stringForColumn:@"MD5"];
        // 修改崩溃bug
        if (type && value) {
            [result setObject:value forKey:type];
        }
    }
    [result setObject:aId forKey:@"aId"];
    [result setObject:sId forKey:@"sId"];
    return result;
}


//创建临时表

+ (BOOL)isExitTempTable:(FMDatabase *)db {
    
    NSString * sql = [NSString stringWithFormat:@"select name from sqlite_master where type = 'table' and name = '%@'",kContactsTempTable];
    FMResultSet * rs = [db executeQuery:sql];
    BOOL isExistTable = NO;
    while ([rs next]) {
        NSString *name = [rs stringForColumn:@"name"];
        if ([name isEqualToString:kContactsTempTable]) {
            isExistTable = YES;
        }
    }
    return isExistTable;
}
+ (void)dropTempTable:(FMDatabase *)db
{
    NSString *temTableSql =   [NSString stringWithFormat:@"DROP TABLE  IF EXISTS %@",kContactsTempTable];
    [db executeUpdate:temTableSql];
}

+ (void)createTempTable:(FMDatabase *)db {
    [CMPContactsTableManager dropTempTable:db];
    NSString* accountID = [CMPCore sharedInstance].currentUser.accountID;
    
    NSString *sql = [NSString stringWithFormat:@"CREATE table %@ as \
                     SELECT DISTINCT * FROM \
                     ( \
                     SELECT  DISTINCT  \
                     m.sort         AS memberSort ,\
                     m.name         AS memberName ,\
                     m.ins          AS ins ,\
                     r.mid          AS memberId ,\
                     m.name_spell   AS pinYin ,\
                     m.name_sp      AS py ,\
                     m.name_sph     AS pyh ,\
                     r.did          AS departmentId ,\
                     d.name         AS department ,\
                     d.internal     AS department_internal ,\
                     r.aid          AS accountId ,\
                     a.name         AS account ,\
                     p.ID           AS postId ,\
                     p.name         AS postName  ,\
                     m.ePost        AS ePost ,\
                     l.id           AS levelId ,\
                     l.name         AS level ,\
                     m.eLevel       AS eLevel ,\
                     m.tel          AS tel ,\
                     m.mobile_phone AS mobilePhone ,\
                     m.mail         AS mail ,\
                     m.mark         AS mark ,\
                     r.show_tel     AS show_tel ,\
                     r.show_level   AS show_level ,\
                     r.type         AS type, \
                     m.WORKADDR         AS workAddr ,\
                     m.WX         AS wx ,\
                     m.WB         AS wb ,\
                     m.HOMEADDR         AS homeAddr ,\
                     m.PORT         AS port ,\
                     m.COMMUNICATIONADDR         AS communicationAddr \
                     FROM  TB_MEMBER      AS m ,\
                     TB_RELATION    AS r ,\
                     TB_POST        AS p ,\
                     TB_UNIT        AS d ,\
                     TB_UNIT        AS a ,\
                     TB_LEVEL       AS l \
                     where r.MID = m.ID \
                     and r.PID =  p.ID \
                     and r.DID = d.ID \
                     and r.AID = a.ID \
                     and r.LID = l.id \
                     and r.AID = %@ \
                     and r.AVAILABLE_CONTACTS = 1 \
                     ORDER BY r.type DESC \
                     ) \
                     AS tmp_tb_memeber ",kContactsTempTable,accountID];
    [db executeUpdate:sql];
}

+ (NSString *)pinyin:(NSString *)name
{
    if ([NSString isNull:name]) {
        return  @"";
    }
    NSMutableString *nameM = [[NSMutableString  alloc] initWithString:name];
    CFStringTransform((__bridge CFMutableStringRef)nameM, 0, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)nameM, 0, kCFStringTransformStripDiacritics, NO);
    NSString *pingyin = [nameM uppercaseString];
    pingyin = [pingyin replaceCharacter:@" " withString:@""];
    [nameM release];
    nameM = nil;
    return  pingyin;
}

//暂时不用了

//- (NSString *)pinyin:(NSString *)name
//{
//    return @"ABDCC";
//    if ([NSString isNull:name]) {
//        return  @"";
//    }
//    NSMutableString *nameM = [[NSMutableString  alloc] initWithString:name];
//    CFStringTransform((__bridge CFMutableStringRef)nameM, 0, kCFStringTransformMandarinLatin, NO);
//    CFStringTransform((__bridge CFMutableStringRef)nameM, 0, kCFStringTransformStripDiacritics, NO);
//    NSString *pingyin = [nameM uppercaseString];
//    [nameM release];
//    nameM = nil;
//    return  pingyin;
//}
//
//
//- (void)insertStatisticsSql:(NSDictionary *)entity
//{
//    NSString *aId = [entity objectForKey:@"oId"];
//    NSString *uId = [entity objectForKey:@"m"];
//    NSString *count = [entity objectForKey:@"t"];
//    NSString *valusString = [NSString stringWithFormat:@"'%@','%@','%@'",aId,uId,count];
//    NSString *sql = [NSString stringWithFormat:@"insert into TB_STATISTICS (AID,UID,COUNT) values (%@)",valusString];
//}

//常用联系人--协同权限
+ (void)insertFequestFrequentContacts:(NSArray *)dataList db:(FMDatabase *)db
{
    NSString *frequentTableSql = @"CREATE TABLE IF NOT EXISTS [TB_FREQUENT] (\
    [id] TEXT, \
    [name] TEXT, \
    [iconUrl] TEXT,\
    [code] TEXT,\
    [departmentId] TEXT,\
    [departmentName] TEXT,\
    [accountId] TEXT,\
    [accName] TEXT,\
    [accShortName] TEXT,\
    [accMotto] TEXT,\
    [jobNumber] TEXT,\
    [levelName] TEXT,\
    [postName] TEXT,\
    [postId] TEXT,\
    [levelId] TEXT,\
    [tel] TEXT,\
    [email] TEXT,\
    [nameSpell] TEXT,\
    [officeNumber] TEXT,\
    [isVjoin] TEXT,\
    [vjoinOrgName] TEXT,\
    [vjoinAccName] TEXT,\
    [customFields] TEXT)";
    NSString *deletaSql = @"delete from  TB_FREQUENT";
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:frequentTableSql];
    [array addObject:deletaSql];
    NSString *defaultsql = @"insert into TB_FREQUENT (id,name,iconUrl,code,departmentId,departmentName,accountId,accName,accShortName,accMotto,jobNumber,levelName,postName,postId,levelId,tel,email,nameSpell,officeNumber,isVjoin,vjoinOrgName,vjoinAccName,customFields) values ";
    for (NSDictionary *dic in dataList) {
        NSString *userId = [CMPContactsTableManager dic:dic key:@"id"];
        NSString *name = [CMPContactsTableManager dic:dic key:@"name"];
        NSString *iconUrl =  [CMPContactsTableManager dic:dic key:@"iconUrl"];
        NSString *code = [CMPContactsTableManager dic:dic key:@"code"];
        NSString *departmentId = [CMPContactsTableManager dic:dic key:@"departmentId"];
        NSString *departmentName = [CMPContactsTableManager dic:dic key:@"departmentName"];
        NSString *accountId = [CMPContactsTableManager dic:dic key:@"accountId"];
        NSString *accName = [CMPContactsTableManager dic:dic key:@"accName"];
        NSString *accShortName = [CMPContactsTableManager dic:dic key:@"accShortName"];
        NSString *accMotto = [CMPContactsTableManager dic:dic key:@"accMotto"];
        NSString *jobNumber = [CMPContactsTableManager dic:dic key:@"jobNumber"];
        NSString *levelName = [CMPContactsTableManager dic:dic key:@"levelName"];
        NSString *postName = [CMPContactsTableManager dic:dic key:@"postName"];
        NSString *postId = [CMPContactsTableManager dic:dic key:@"postId"];
        NSString *levelId = [CMPContactsTableManager dic:dic key:@"levelId"];
        NSString *tel = [CMPContactsTableManager dic:dic key:@"tel"];
        NSString *email = [CMPContactsTableManager dic:dic key:@"email"];
        NSString *nameSpell = [CMPContactsTableManager dic:dic key:@"nameSpell"];
        NSString *officeNumber = [CMPContactsTableManager dic:dic key:@"officeNumber"];
        NSString *isVjoin = [CMPContactsTableManager dic:dic key:@"isVjoin"];
        NSString *vjoinOrgName = [CMPContactsTableManager dic:dic key:@"vjoinOrgName"];
        NSString *vjoinAccName = [CMPContactsTableManager dic:dic key:@"vjoinAccName"];
        NSString *customFields = [CMPContactsTableManager dic:dic key:@"customFields"];
        NSString *sql = [NSString stringWithFormat:@"%@ ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",defaultsql,userId,name,iconUrl,code,departmentId,departmentName,accountId,accName,accShortName,accMotto,jobNumber,levelName,postName,postId,levelId,tel,email,nameSpell,officeNumber,isVjoin,vjoinOrgName,vjoinAccName                      ,customFields];
        [array addObject:sql];
    }
    BOOL isRollBack = NO;
    [db beginTransaction];
    @try {
        for (NSString *aql in array) {
            [db executeUpdate:aql];
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    }
    @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
}


+ (NSString *)dic:(NSDictionary *)dic key:(NSString *)key
{
    NSString *result = [dic objectForKey:key];
    if (result &&([result isKindOfClass:[NSArray class]] ||[result isKindOfClass:[NSDictionary class]])) {
        return [result JSONRepresentation];
    }
    if ([NSString isNull:result]) {
        return  @"";
    }
    return result;
}

//选人零时表
+ (void)createFlowTempTable:(FMDatabase *)db {
    NSString *temTableSql =   [NSString stringWithFormat:@"DROP TABLE  IF EXISTS %@",kFlowTempTable];
    [db executeUpdate:temTableSql];
    NSString* accountID = [CMPCore sharedInstance].currentUser.accountID;
    
    NSString *sql = [NSString stringWithFormat:@"CREATE table %@ as \
                     SELECT DISTINCT * FROM \
                     ( \
                     SELECT  DISTINCT  \
                     m.sort         AS memberSort ,\
                     m.name         AS memberName ,\
                     m.ins          AS ins ,\
                     r.mid          AS memberId ,\
                     m.name_spell   AS pinYin ,\
                     m.name_sp      AS py ,\
                     m.name_sph     AS pyh ,\
                     r.did          AS departmentId ,\
                     d.name         AS department ,\
                     d.internal     AS department_internal ,\
                     r.aid          AS accountId ,\
                     a.name         AS account ,\
                     p.ID           AS postId ,\
                     p.name         AS postName  ,\
                     m.ePost        AS ePost ,\
                     l.id           AS levelId ,\
                     l.name         AS level ,\
                     m.eLevel       AS eLevel ,\
                     m.tel          AS tel ,\
                     m.mobile_phone AS mobilePhone ,\
                     m.mail         AS mail ,\
                     m.mark         AS mark ,\
                     r.show_tel     AS show_tel ,\
                     r.show_level   AS show_level ,\
                     r.type         AS type, \
                     m.WORKADDR         AS workAddr ,\
                     m.WX         AS wx ,\
                     m.WB         AS wb ,\
                     m.HOMEADDR         AS homeAddr ,\
                     m.PORT         AS port ,\
                     m.COMMUNICATIONADDR         AS communicationAddr \
                     FROM  TB_MEMBER      AS m ,\
                     TB_RELATION    AS r ,\
                     TB_POST        AS p ,\
                     TB_UNIT        AS d ,\
                     TB_UNIT        AS a ,\
                     TB_LEVEL       AS l \
                     where r.MID = m.ID \
                     and r.PID =  p.ID \
                     and r.DID = d.ID \
                     and r.AID = a.ID \
                     and r.LID = l.id \
                     and r.AID = %@ \
                     and r.AVAILABLE_FLOW = 1 \
                     and r.type = 1 \
                     ) \
                     AS tmp_tb_memeber ",kFlowTempTable,accountID];
    [db executeUpdate:sql];
}
@end
