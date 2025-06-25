//
//  CMPDBConnectionTests.m
//  M3Tests
//
//  Created by CRMO on 2018/3/16.
//

#import <XCTest/XCTest.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/FMDB.h>
#import <CMPLib/CMPDBAppInfo.h>
#import <CMPLib/SyFaceDownloadRecordObj.h>
#import <CMPLib/CMPOfflineFileRecord.h>
#import <CMPLib/CMPOfflineFileRecord.h>

@interface CMPDBConnectionTests : XCTestCase

@property (strong, nonatomic) CMPCommonDBProvider *provider;
@property (strong, nonatomic) FMDatabaseQueue *dataQueue;

@end

@implementation CMPDBConnectionTests

- (void)setUp {
    [super setUp];
    _provider = [CMPCommonDBProvider sharedInstance];
    _dataQueue = [_provider valueForKey:@"dataQueue"];
}

- (void)tearDown {
    [super tearDown];
    [_provider clearTableForClearCache];
}

- (void)testThredSafe {

}

- (void)testInit {
    XCTAssertNotNil(_provider);
    XCTAssertNotNil(_dataQueue);
}

- (void)testInsertAppInfo {
    for (int i = 0; i < 5; i++) {
        [_provider insertAppInfo:[self appInfo]
                    onCompletion:^(BOOL success) {
                        XCTAssertTrue(success);
                    }];
        
        [_provider appListWithServerID:@"5667477395508304470"
                               ownerID:@"cmp"
                                 appId:@"52"
                          onCompletion:^(NSArray *result) {
                              XCTAssertTrue(result.count == 1);
                              CMPDBAppInfo *appInfo = [result firstObject];
                              NSString *appInfoStr = [appInfo yy_modelToJSONString];
                              NSString *testInfoStr = [self appInfoStr];
                              XCTAssertTrue([appInfoStr isEqualToString:testInfoStr]);
                          }];
    }
    
    [_provider appListWithServerID:nil
                           ownerID:nil
                             appId:nil
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 0);
                      }];
    
    [_provider appListWithServerID:@"5667477395508304470"
                           ownerID:@"cmpppppp"
                             appId:@"52"
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 0);
                      }];
    
    [_provider appListWithServerID:@"5667477395508304470"
                           ownerID:@"cmp"
                             appId:@"ssss53"
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 0);
                      }];
    
    [_provider appListWithServerID:@"5667477395508304471"
                           ownerID:@"cmp"
                             appId:@"53"
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 0);
                      }];
    
    [_provider appListWithServerID:@"5667477395508304470"
                           ownerID:@"cmp"
                             appId:@"52"
                           version:@"1.0.0"
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 1);
                          CMPDBAppInfo *appInfo = [result firstObject];
                          NSString *appInfoStr = [appInfo yy_modelToJSONString];
                          NSString *testInfoStr = [self appInfoStr];
                          XCTAssertTrue([appInfoStr isEqualToString:testInfoStr]);
                      }];
    
    [_provider appListWithServerID:nil
                           ownerID:nil
                             appId:nil
                           version:nil
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 0);
                      }];
    
    [_provider appListWithServerID:@"5667477395508304470"
                           ownerID:@"cmp"
                             appId:@"52"
                           version:@"1.0.1"
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 0);
                      }];
}

/**
 测试AppInfo相关函数的异步嵌套执行
 */
- (void)testAsyncAppInfo {
    CMPDBAppInfo *appInfo = [self appInfo];
    [_provider insertAppInfo:appInfo
                onCompletion:^(BOOL success) {
                    XCTAssertTrue(success);
                    [_provider appListWithServerID:appInfo.serverID ownerID:appInfo.owerID appId:appInfo.appId onCompletion:^(NSArray *result) {
                        XCTAssertTrue(result.count == 1);
                        CMPDBAppInfo *app = [result firstObject];
                        [_provider deleteAppWithAppId:app.appId version:app.version owerID:app.owerID serverID:app.serverID onCompletion:^(BOOL success) {
                            XCTAssertTrue(success);
                        }];
                    }];
                }];
    [_provider appListWithServerID:appInfo.serverID ownerID:appInfo.owerID appId:appInfo.appId version:appInfo.version onCompletion:^(NSArray *result) {
        XCTAssertTrue(result.count == 0);
    }];
    
    
    [_provider insertAppInfo:appInfo
                onCompletion:^(BOOL success) {
                    XCTAssertTrue(success);
                }];
    __block NSArray *arr;
    [_provider appListWithServerID:appInfo.serverID ownerID:appInfo.owerID appId:appInfo.appId onCompletion:^(NSArray *result) {
        XCTAssertTrue(result.count == 1);
        arr = result;
    }];
    
    CMPDBAppInfo *app = [arr firstObject];
    XCTAssertNotNil(app);
    [_provider deleteAppWithAppId:app.appId version:app.version owerID:app.owerID serverID:app.serverID onCompletion:^(BOOL success) {
        XCTAssertTrue(success);
    }];
}

- (void)testDeleteAppInfo {
    CMPDBAppInfo *appInfo = [self appInfo];
    [_provider insertAppInfo:appInfo
                onCompletion:^(BOOL success) {
                    XCTAssertTrue(success);
                }];
    [_provider deleteAppWithAppId:appInfo.appId
                          version:appInfo.version
                           owerID:appInfo.owerID
                         serverID:appInfo.serverID
                     onCompletion:^(BOOL success) {
                         XCTAssertTrue(success);
                     }];
    [_provider appListWithServerID:appInfo.serverID
                           ownerID:appInfo.owerID
                             appId:appInfo.appId
                           version:appInfo.version
                      onCompletion:^(NSArray *result) {
                          XCTAssertTrue(result.count == 0);
                      }];
}

- (void)testInsertFaceRecord {
    SyFaceDownloadRecordObj *record = [self faceDownloadRecord];
    SyFaceDownloadObj *download = [self faceDownload];
    for (int i = 0; i < 5; i++) {
        [_provider insertFaceDownloadRecord:record
                               onCompletion:^(BOOL success) {
                                   XCTAssertTrue(success);
                               }];
        [_provider faceDownloadRecordsWithObj:download
                                 onCompletion:^(NSArray *result) {
                                     XCTAssertTrue(result.count == 1);
                                     SyFaceDownloadRecordObj *record = [result firstObject];
                                     NSString *recordStr = [record yy_modelToJSONString];
                                     NSString *faceStr = [self faceStr];
                                     XCTAssertTrue([recordStr isEqualToString:faceStr]);
                                 }];
    }
}

- (void)testDeleteFaceRecord {
    SyFaceDownloadObj *download = [self faceDownload];
    [_provider deleteFaceRecordsWithMemberId:download.memberId
                                    serverId:download.serverId
                                onCompletion:^(BOOL success) {
                                    XCTAssertTrue(success);
                                }];
    [_provider deleteAllFaceRecordsOnCompletion:^(BOOL success) {
        XCTAssertTrue(success);
    }];
}

- (void)testOfflineRecord {
    CMPOfflineFileRecord *record = [self offlineRecord];
    for (int i = 0; i < 5; i++) {
        [_provider insertOfflineFileRecord:record
                              onCompletion:^(BOOL success) {
                                  XCTAssertTrue(success);
                              }];
        [_provider offlineFileRecordsWithFileId:record.fileId
                                   lastModified:record.modifyTime
                                         origin:record.origin
                                       serverID:record.serverId
                                        ownerID:record.ownerId
                                   onCompletion:^(NSArray *result) {
                                       XCTAssertTrue(result.count == 1);
                                   }];
        [_provider offlineFileRecordsWithFileId:nil
                                   lastModified:record.modifyTime
                                         origin:record.origin
                                       serverID:record.serverId
                                        ownerID:record.ownerId
                                   onCompletion:^(NSArray *result) {
                                       XCTAssertTrue(result.count == 0);
                                   }];
        [_provider offlineFilesWithStartIndex:0
                                     rowCount:20
                                     serverID:record.serverId
                                      ownerID:record.ownerId
                                 onCompletion:^(NSArray *result) {
                                     XCTAssertTrue(result.count == 1);
                                     CMPOfflineFileRecord *aRecord = [result firstObject];
                                     XCTAssertTrue([record.fileId isEqualToString:aRecord.fileId]);
                                 }];
    }
    [_provider searchOfflineFilesWithKeyWord:@"M3"
                                  startIndex:0
                                    rowCount:20
                                    serverID:record.serverId
                                     ownerID:record.ownerId
                                onCompletion:^(NSArray *result) {
                                    XCTAssertTrue(result.count == 1);
                                    CMPOfflineFileRecord *aRecord = [result firstObject];
                                    XCTAssertTrue([record.fileId isEqualToString:aRecord.fileId]);
                                }];
    [_provider countOfSearchOfflineFilesWithKeyWord:@"M3"
                                           serverID:record.serverId
                                            ownerID:record.ownerId
                                       onCompletion:^(NSInteger total) {
                                           XCTAssertTrue(total == 1);
                                       }];
    [_provider countOfofflineFilesWithServerID:record.serverId
                                       ownerID:record.ownerId
                                  onCompletion:^(NSInteger total) {
        XCTAssertTrue(total == 1);
    }];
    [_provider deleteOfflineFileWithFileIDs:@[@"6855866301298066012"]
                                   serverID:record.serverId
                                    ownerID:record.ownerId
                               onCompletion:^(BOOL success) {
                                   XCTAssertTrue(success);
                               }];
    [_provider countOfofflineFilesWithServerID:record.serverId
                                       ownerID:record.ownerId
                                  onCompletion:^(NSInteger total) {
        XCTAssertTrue(total == 0);
    }];
}

- (void)testDownloadRecord {

}

#pragma mark-
#pragma mark 工具方法

- (CMPDBAppInfo *)appInfo {
    NSString *str = [self appInfoStr];
    CMPDBAppInfo *appInfo = [CMPDBAppInfo yy_modelWithJSON:str];
    return appInfo;
}

- (SyFaceDownloadRecordObj *)faceDownloadRecord {
    NSString *str = [self faceStr];
    SyFaceDownloadRecordObj *record = [SyFaceDownloadRecordObj yy_modelWithJSON:str];
    return record;
}

- (SyFaceDownloadObj *)faceDownload {
    SyFaceDownloadObj *download = [[SyFaceDownloadObj alloc] init];
    download.memberId = @"-7026752145924927995";
    download.serverId = @"5667477395508304470";
    download.downloadUrl = @"https://m.seeyon.com:8080/seeyon/rest/orgMember/avatar/-7026752145924927995?maxWidth=200";
    return download;
}

- (CMPOfflineFileRecord *)offlineRecord {
    NSString *str = [self offlineStr];
    CMPOfflineFileRecord *record = [CMPOfflineFileRecord yy_modelWithJSON:str];
    return record;
}

- (CMPOfflineFileRecord *)downloadRecord {
    NSString *str = [self downloadStr];
    CMPOfflineFileRecord *record = [CMPOfflineFileRecord yy_modelWithJSON:str];
    return record;
}

- (NSString *)appInfoStr {
    return @"{\"extend9\":\"\",\"bundle_identifier\":\"\",\"bundle_type\":\"default\",\"owerID\":\"cmp\",\"serverID\":\"5667477395508304470\",\"extend3\":\"\",\"extend12\":\"\",\"extend13\":\"\",\"team\":\"m3\",\"extend4\":\"\",\"extend10\":\"\",\"path\":\"\\/h5\\/7DC8F1FD-FFFA-42FE-A593-226BDF29E844\",\"extend5\":\"\",\"version\":\"1.0.0\",\"bundle_name\":\"application\",\"url_schemes\":\"application.m3.cmp\",\"extend14\":\"\",\"extend6\":\"\",\"downloadTime\":\"\",\"deployment_target\":\"\",\"extend11\":\"\",\"bundle_display_name\":\"application\",\"appId\":\"52\",\"extend7\":\"\",\"extend15\":\"\",\"extend1\":\"e4e0360f32a7252840f95cf4f6f2e708\",\"compatible_version\":\"\",\"desc\":\"\",\"icon_files\":\"\",\"extend8\":\"\",\"supported_platforms\":\"\",\"extend2\":\"\"}";
}

- (NSString *)faceStr {
    return @"{\"savePath\":\"Documents\\/File\\/FaceImagePath\\/-7026752145924927995.png\",\"extend1\":\"1521646636\",\"memberId\":\"-7026752145924927995\",\"downloaMd5\":\"6e93d13921445576d058392612afb643\",\"serverId\":\"5667477395508304470\"}";
}

- (NSString *)offlineStr {
    return @"{\"fileSize\":\"13746\",\"fileName\":\"M3技术框架统计.xlsx\",\"suffix\":\"xlsx\",\"savePath\":\"Documents\\/File\\/Local\\/1D307503-9244-4BC5-98FF-5AAB6365E281.zip\",\"fileId\":\"6855866301298066012\",\"serverIdentifier\":\"5667477395508304470\",\"ownerId\":\"-7026752145924927995\",\"saveName\":\"M3技术框架统计.xlsx\",\"createTime\":\"\",\"creatorName\":\"\",\"origin\":\"https:\\/\\/m.seeyon.com:8080\\/seeyon\",\"downloadTime\":\"2018-03-20 19:21:30 GMT+8\",\"modifyTime\":\"1521028920000\"}";
}

- (NSString *)downloadStr {
    return @"{\"fileSize\":\"13746\",\"fileName\":\"M3技术框架统计.xlsx\",\"suffix\":\"xlsx\",\"savePath\":\"Documents\\/File\\/Local\\/1D307503-9244-4BC5-98FF-5AAB6365E281.zip\",\"fileId\":\"6855866301298066012\",\"serverIdentifier\":\"5667477395508304470\",\"saveName\":\"M3技术框架统计.xlsx\",\"creatorName\":\"\",\"createTime\":\"\",\"origin\":\"https:\\/\\/m.seeyon.com:8080\\/seeyon\",\"downloadTime\":\"2018-03-20 19:21:30 GMT+8\",\"modifyTime\":\"1521028920000\"}";
}

@end
