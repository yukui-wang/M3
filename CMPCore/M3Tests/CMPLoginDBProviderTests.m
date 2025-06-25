//
//  CMPLoginDBProviderTests.m
//  M3Tests
//
//  Created by CRMO on 2018/3/1.
//

#import <XCTest/XCTest.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/CMPLoginAccountModel.h>
#import <CMPLib/FMDB.h>

@interface CMPLoginDBProviderTests : XCTestCase

@property (strong, nonatomic) CMPLoginDBProvider *provider;
@property (strong, nonatomic) FMDatabase *db;

@end

@implementation CMPLoginDBProviderTests

- (void)setUp {
    [super setUp];
    _provider = [[CMPLoginDBProvider alloc] init];
    _db = [_provider valueForKey:@"database"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAddInUsedAccounnt {
    XCTAssertTrue([_provider deleteAccount:[self fullAccountModel]]);
    XCTAssertFalse([_provider addAccount:nil inUsed:YES]);
    XCTAssertTrue([_provider addAccount:[self fullAccountModel] inUsed:YES]);
    CMPLoginAccountModel *currentModel = [_provider inUsedAccountWithServerID:@"4728005408453761144"];
    XCTAssertNotNil(currentModel);
    
    XCTAssertTrue([_provider deleteAccount:[self fullAccountModel]]);
    currentModel = [_provider inUsedAccountWithServerID:@"4728005408453761144"];
    XCTAssertNil(currentModel);
}

- (void)testListOfServer {
    XCTAssertTrue([_provider deleteServerWithUniqueID:@"67fcfc57154ccd48bbebfac7b4da398d"]);
    XCTAssertTrue([_provider addServerWithModel:[self fullServerModel]]);
    
    NSArray *listServer = [_provider listOfServer];
    XCTAssert(listServer.count != 0);
    
    XCTAssertTrue([_provider deleteServerWithUniqueID:@"67fcfc57154ccd48bbebfac7b4da398d"]);
}

- (CMPLoginAccountModel *)fullAccountModel {
    CMPLoginAccountModel *model = [[CMPLoginAccountModel alloc] init];
    model.serverID = @"4728005408453761144";
    model.userID = @"2495398969959073132";
    model.loginName = @"zSPrNnrxF4s=";
    model.loginPassword = @"WodbVuAdAq4=!@#$%^&****(（）——+；‘【】，、，’·'!@#$%^&*()";
    model.name = @"名字超级超级超级超级超级超级超级长的测试1'";
    model.gesturePassword = @"";
    model.gestureMode = 0;
    model.inUsed = 1;
    model.loginResult = @"{ \"code\" : \"200\", \"data\" : { \"currentMember\" : { \"levelName\" : \"A集团职务\", \"nameSpell\" : \"mingzichaojichaojichaojichaojichaojichaojichaojichangdeceshi1\", \"tel\" : \"18000588704\", \"accMotto\" : \"\", \"accName\" : \"钟亮单位\", \"postName\" : \"iOS\", \"levelId\" : \"-4924740016723704090\", \"email\" : \"microcental_zll@163.com\", \"code\" : \"33\", \"id\" : \"-6695010102516826046\", \"officeNumber\" : \"66666666\", \"accShortName\" : \"ff\", \"accountId\" : \"3297271798837821839\", \"name\" : \"名字超级超级超级超级超级超级超级长的测试1\", \"iconUrl\" : \"http://192.168.10.238:8089/seeyon/fileUpload.do?method=showRTE&fileId=3674238253528403896&createDate=2018-01-30&type=image&showType=small\", \"departmentId\" : \"5365966853477846351\", \"departmentName\" : \"研发部\", \"postId\" : \"-1085449807140667290\" }, \"serverIdentifier\" : \"4728005408453761144\", \"statisticId\" : \"-8819609797978961057\", \"ticket\" : \"C4E82C3B1DA3318DF3D66873A729A2B4\", \"config\" : { \"allowUpdateAvatar\" : \"enable\", \"passwordOvertime\" : false, \"passwordStrong\" : true } }, \"time\" : \"1519897031544\", \"message\" : \"success\", \"version\" : \"1.0'\" }";
    model.pushConfig = nil;
    return model;
}

- (CMPServerModel *)fullServerModel {
    CMPServerModel *model = [[CMPServerModel alloc] init];
    model.serverID = @"5667477395508304470";
    model.host = @"m.seeyon.com";
    model.port = @"8080";
    model.isSafe = 1;
    model.scheme = @"https";
    model.inUsed = 1;
    model.serverVersion = @"1.6.2";
    return model;
}

@end
