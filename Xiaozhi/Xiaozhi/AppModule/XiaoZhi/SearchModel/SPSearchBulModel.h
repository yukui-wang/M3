//
//	SPSearchBulModel.h
//
//	Create by CRMO on 26/2/2017
//	Copyright © 2017. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface SPSearchBulModel : NSObject

@property (nonatomic, assign) double accountId;
@property (nonatomic, assign) BOOL attachmentsFlag;
@property (nonatomic, strong) NSObject * auditAdvice;
@property (nonatomic, strong) NSObject * auditDate;
@property (nonatomic, strong) NSObject * auditUserId;
@property (nonatomic, strong) NSObject * brief;
@property (nonatomic, strong) NSObject * choosePublshId;
@property (nonatomic, strong) NSObject * content;
@property (nonatomic, strong) NSObject * contentName;
@property (nonatomic, assign) NSInteger createDate;
@property (nonatomic, assign) double createUser;
@property (nonatomic, strong) NSString * dataFormat;
@property (nonatomic, assign) BOOL deletedFlag;
@property (nonatomic, strong) NSString * ext1;
@property (nonatomic, strong) NSString * ext2;
@property (nonatomic, strong) NSString * ext3;
@property (nonatomic, strong) NSObject * ext4;
@property (nonatomic, strong) NSString * ext5;
@property (nonatomic, assign) NSString *idField;
@property (nonatomic, strong) NSObject * keywords;
@property (nonatomic, assign) BOOL newField;
@property (nonatomic, assign) BOOL noDelete;
@property (nonatomic, assign) BOOL noEdit;
@property (nonatomic, strong) NSObject * pigeonholeDate;
@property (nonatomic, strong) NSObject * pigeonholePath;
@property (nonatomic, strong) NSObject * pigeonholeUserId;
@property (nonatomic, assign) NSInteger publishChoose;
@property (nonatomic, assign) NSInteger publishDate;
@property (nonatomic, strong) NSString * publishDateFormat;
@property (nonatomic, assign) NSInteger publishDepartmentId;
@property (nonatomic, strong) NSObject * publishDeptName;
@property (nonatomic, strong) NSString * publishMemberName;
@property (nonatomic, strong) NSString * publishScope;
@property (nonatomic, assign) double publishUserId;
@property (nonatomic, assign) NSInteger readCount;
@property (nonatomic, strong) NSObject * readFlag;
@property (nonatomic, strong) NSObject * showPublishName;
@property (nonatomic, assign) BOOL showPublishUserFlag;
@property (nonatomic, strong) NSObject * spaceType;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) NSString * stringId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger topOrder;
@property (nonatomic, assign) double typeId;
@property (nonatomic, strong) NSObject * typeName;
@property (nonatomic, assign) NSInteger updateDate;
@property (nonatomic, assign) double updateUser;
@property (nonatomic, strong) NSString * writePublish;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
