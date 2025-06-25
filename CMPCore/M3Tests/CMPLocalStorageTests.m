//
//  CMPLocalStorageTests.m
//  M3Tests
//
//  Created by CRMO on 2018/3/29.
//

#import <XCTest/XCTest.h>
#import <CMPLib/FMDB.h>
#import "CMPLocalStorageDbProvider.h"

@interface CMPLocalStorageTests : XCTestCase
@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) CMPLocalStorageDbProvider *provider;
@end

typedef struct Test {
    NSInteger departmentLimit;
    NSInteger departmentOffset;
    NSInteger memberLimit;
    NSInteger memberOffset;
} Test;

@implementation CMPLocalStorageTests

- (void)setUp {
    [super setUp];
    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [libDir stringByAppendingPathComponent:@"WebKit/LocalStorage/file__0.localstorage"];
    _db = [FMDatabase databaseWithPath:dbPath];
    _provider = [[CMPLocalStorageDbProvider alloc] init];
    [_db open];
}

- (void)tearDown {
    [super tearDown];
    [_db close];
}

- (void)testExample {
    FMResultSet *set = [_db executeQuery:@"select * from ItemTable"];
    while ([set next]) {
        NSString *key = [set stringForColumn:@"key"];
        NSData *data = [set dataForColumn:@"value"];
        NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
        NSLog(@"key:%@,value:%@", key, value);
    }
    NSString *testStr = @"你好，我想写入localStorage";
    NSData *testData = [testStr dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
    [_db executeUpdate:@"insert into ItemTable (key, value) values ('test', ?)", testData];
}

- (void)testGetValue {
    XCTAssertTrue([_provider saveValue:@"哈哈哈" forKey:@"hah"]);
    NSString *testData = [_provider valueWithKey:@"hah"];
    XCTAssertTrue([testData isEqualToString:@"哈哈哈"]);
}

- (void)testSum {
//    // count == 0
//    XCTAssertTrue([self memberCountWithPage:1 count:0] == 20);
//    XCTAssertTrue([self memberCountWithPage:2 count:0] == 20);
//    XCTAssertTrue([self memberCountWithPage:3 count:0] == 20);
//    XCTAssertTrue([self offsetWithPage:1 count:0] == 0);
//    XCTAssertTrue([self offsetWithPage:2 count:0] == 20);
//    XCTAssertTrue([self offsetWithPage:3 count:0] == 40);
//
//    // count == 15
//    XCTAssertTrue([self memberCountWithPage:1 count:15] == 5);
//    XCTAssertTrue([self memberCountWithPage:2 count:15] == 20);
//    XCTAssertTrue([self memberCountWithPage:3 count:15] == 20);
//    XCTAssertTrue([self offsetWithPage:1 count:15] == 0);
//    XCTAssertTrue([self offsetWithPage:2 count:15] == 5);
//    XCTAssertTrue([self offsetWithPage:3 count:15] == 25);
//    XCTAssertTrue([self offsetWithPage:4 count:15] == 45);
//
//    // count == 20
//    XCTAssertTrue([self memberCountWithPage:1 count:20] == 0);
//    XCTAssertTrue([self memberCountWithPage:2 count:20] == 20);
//    XCTAssertTrue([self memberCountWithPage:3 count:20] == 20);
//    XCTAssertTrue([self offsetWithPage:1 count:20] == 0);
//    XCTAssertTrue([self offsetWithPage:2 count:20] == 0);
//    XCTAssertTrue([self offsetWithPage:3 count:20] == 20);
//    XCTAssertTrue([self offsetWithPage:4 count:20] == 40);
//
//    // count ==
//    XCTAssertTrue([self memberCountWithPage:1 count:25] == 0);
//    XCTAssertTrue([self memberCountWithPage:2 count:25] == 15);
//    XCTAssertTrue([self memberCountWithPage:3 count:25] == 20);
//    XCTAssertTrue([self offsetWithPage:1 count:25] == 0);
//    XCTAssertTrue([self offsetWithPage:2 count:25] == 0);
//    XCTAssertTrue([self offsetWithPage:3 count:25] == 15);
//    XCTAssertTrue([self offsetWithPage:4 count:25] == 35);
//
//    // count == 40
//    XCTAssertTrue([self memberCountWithPage:1 count:40] == 0);
//    XCTAssertTrue([self memberCountWithPage:2 count:40] == 0);
//    XCTAssertTrue([self memberCountWithPage:3 count:40] == 20);
//    XCTAssertTrue([self offsetWithPage:1 count:40] == 0);
//    XCTAssertTrue([self offsetWithPage:2 count:40] == 0);
//    XCTAssertTrue([self offsetWithPage:3 count:40] == 0);
//    XCTAssertTrue([self offsetWithPage:4 count:40] == 20);
//    XCTAssertTrue([self offsetWithPage:5 count:40] == 40);
//
//    // count == 45
//    XCTAssertTrue([self memberCountWithPage:1 count:45] == 0);
//    XCTAssertTrue([self memberCountWithPage:2 count:45] == 0);
//    XCTAssertTrue([self memberCountWithPage:3 count:45] == 15);
//    XCTAssertTrue([self memberCountWithPage:4 count:45] == 20);
//    XCTAssertTrue([self offsetWithPage:1 count:45] == 0);
//    XCTAssertTrue([self offsetWithPage:2 count:45] == 0);
//    XCTAssertTrue([self offsetWithPage:3 count:45] == 0);
//    XCTAssertTrue([self offsetWithPage:4 count:45] == 15);
//    XCTAssertTrue([self offsetWithPage:5 count:45] == 35);
    
}

- (NSInteger)memberCountWithPage:(NSInteger)page count:(NSInteger)count {
    NSInteger a = 20 * page - count;
    a = a > 20 ? 20 : a;
    a = a < 0 ? 0 : a;
    return a;
}

- (NSInteger)offsetWithPage:(NSInteger)page count:(NSInteger)count {
    if (page <= (count / 20 + 1)) {
        return 0;
    } else if (page == (count / 20 + 2)) {
        return 20 - count % 20;
    }
    return (page - 1)* 20 - count;
}

- (Test)testWithPage:(NSInteger)page dSum:(NSInteger)dSum mSum:(NSInteger)mSum {
    Test t;
    
    NSInteger memberLimit = 0;
    NSInteger memberOffset = 0;
    NSInteger departmentLimit = 0;
    NSInteger departmentOffset = 0;
    
    // 每页返回的人员个数 = 20 - 该页子部门数
    NSInteger hybridPage = dSum / 20 + 1;
    
    if (page < hybridPage) {
        departmentLimit = 20;
        departmentOffset = (page - 1) * 20;
        memberLimit = 0;
        memberOffset = 0;
    } else if (page == hybridPage) {
        departmentLimit = dSum % 20;
        departmentOffset = (page - 1) * 20;
        memberLimit = 20 - departmentLimit;
        memberOffset = 0;
    } else {
        departmentLimit = 0;
        departmentOffset = 0;
        memberLimit = 20;
        memberOffset = (page - hybridPage - 1) * 20 + (20 - dSum % 20);
    }
    
    t.departmentLimit = departmentLimit;
    t.departmentOffset = departmentOffset;
    t.memberLimit = memberLimit;
    t.memberOffset = memberOffset;
    
    return t;
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
