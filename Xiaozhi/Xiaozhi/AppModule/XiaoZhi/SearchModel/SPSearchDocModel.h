//
//	SPSearchDocModel.h
//
//	Create by CRMO on 26/2/2017
//	Copyright © 2017. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface SPSearchDocModel : NSObject

@property (nonatomic, strong) NSString * frCreateTime;
@property (nonatomic, strong) NSString * frCreateUsername;
@property (nonatomic, strong) NSString * frId;
@property (nonatomic, strong) NSString * sourchId;
@property (nonatomic, assign) NSInteger frMineType;
@property (nonatomic, strong) NSString * frName;
@property (nonatomic, assign) NSInteger frSize;
@property (nonatomic, assign) NSInteger frType;
@property (nonatomic, assign) BOOL hasAtt;
@property (nonatomic, assign) BOOL isFolder;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
