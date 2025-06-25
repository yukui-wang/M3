//
//	SPSearchModel.h
//
//	Create by CRMO on 25/2/2017
//	Copyright © 2017. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface SPSearchColModel : NSObject

@property (nonatomic, assign) NSInteger activityId;
@property (nonatomic, assign) NSString *affairId;
@property (nonatomic, assign) BOOL affairSentCanForward;
@property (nonatomic, assign) NSInteger affairState;
@property (nonatomic, strong) NSString * backFromName;
@property (nonatomic, strong) NSString * bodyType;
@property (nonatomic, assign) BOOL canDeleteORarchive;
@property (nonatomic, assign) BOOL canForward;
@property (nonatomic, assign) double caseId;
@property (nonatomic, strong) NSString * commentReply;
@property (nonatomic, assign) NSInteger disAgreeOpinionPolicy;
@property (nonatomic, strong) NSString * fromName;
@property (nonatomic, strong) NSString * fullBFName;
@property (nonatomic, strong) NSString * fullfromName;
@property (nonatomic, assign) BOOL hasAttsFlag;
@property (nonatomic, assign) BOOL hasFavorite;
@property (nonatomic, assign) NSInteger importantLevel;
@property (nonatomic, assign) BOOL isCoverTime;
@property (nonatomic, strong) NSObject * nodeName;
@property (nonatomic, strong) NSString * processId;
@property (nonatomic, strong) NSString * replyCounts;
@property (nonatomic, assign) NSInteger replyCountsNum;
@property (nonatomic, strong) NSString * startDate;
@property (nonatomic, assign) double startMemberId;
@property (nonatomic, strong) NSString * startMemberName;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger subState;
@property (nonatomic, strong) NSString * subStateName;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, assign) double summaryId;
@property (nonatomic, strong) NSString * surplusTime;
@property (nonatomic, strong) NSObject * templateId;
@property (nonatomic, assign) double workitemId;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
