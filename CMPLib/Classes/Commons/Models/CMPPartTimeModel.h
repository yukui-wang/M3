//
//  CMPPatTimeModel.h
//  M3
//
//  Created by CRMO on 2018/6/25.
//

#import "CMPObject.h"

@interface CMPPartTimeModel : CMPObject

@property (strong, nonatomic) NSString *serverID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *accountID;
@property (strong, nonatomic) NSString *accountName;
@property (strong, nonatomic) NSString *accountShortName;
@property (strong, nonatomic) NSNumber *createTime;
@property (strong, nonatomic) NSNumber *switchTime;

// 没有存数据库字段，在每次切换的时候动态获取
@property (strong, nonatomic) NSString *departmentID;
@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) NSString *levelID;
@property (strong, nonatomic) NSString *accountCode;

@property (strong, nonatomic) NSString *extend1;
@property (strong, nonatomic) NSString *extend2;
@property (strong, nonatomic) NSString *extend3;
@property (strong, nonatomic) NSString *extend4;
@property (strong, nonatomic) NSString *extend5;
@property (strong, nonatomic) NSString *extend6;
@property (strong, nonatomic) NSString *extend7;
@property (strong, nonatomic) NSString *extend8;
@property (strong, nonatomic) NSString *extend9;
@property (strong, nonatomic) NSString *extend10;

@end
