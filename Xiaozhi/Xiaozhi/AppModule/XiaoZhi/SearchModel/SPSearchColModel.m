//
//	SPSearchModel.m
//
//	Create by CRMO on 25/2/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "SPSearchColModel.h"

NSString *const kRootClassActivityId = @"activityId";
NSString *const kRootClassAffairId = @"affairId";
NSString *const kRootClassAffairSentCanForward = @"affairSentCanForward";
NSString *const kRootClassAffairState = @"affairState";
NSString *const kRootClassBackFromName = @"backFromName";
NSString *const kRootClassBodyType = @"bodyType";
NSString *const kRootClassCanDeleteORarchive = @"canDeleteORarchive";
NSString *const kRootClassCanForward = @"canForward";
NSString *const kRootClassCaseId = @"caseId";
NSString *const kRootClassCommentReply = @"commentReply";
NSString *const kRootClassDisAgreeOpinionPolicy = @"disAgreeOpinionPolicy";
NSString *const kRootClassFromName = @"fromName";
NSString *const kRootClassFullBFName = @"fullBFName";
NSString *const kRootClassFullfromName = @"fullfromName";
NSString *const kRootClassHasAttsFlag = @"hasAttsFlag";
NSString *const kRootClassHasFavorite = @"hasFavorite";
NSString *const kRootClassImportantLevel = @"importantLevel";
NSString *const kRootClassIsCoverTime = @"isCoverTime";
NSString *const kRootClassNodeName = @"nodeName";
NSString *const kRootClassProcessId = @"processId";
NSString *const kRootClassReplyCounts = @"replyCounts";
NSString *const kRootClassReplyCountsNum = @"replyCountsNum";
NSString *const kRootClassStartDate = @"startDate";
NSString *const kRootClassStartMemberId = @"startMemberId";
NSString *const kRootClassStartMemberName = @"startMemberName";
NSString *const kRootClassState = @"state";
NSString *const kRootClassSubState = @"subState";
NSString *const kRootClassSubStateName = @"subStateName";
NSString *const kRootClassSubject = @"subject";
NSString *const kRootClassSummaryId = @"summaryId";
NSString *const kRootClassSurplusTime = @"surplusTime";
NSString *const kRootClassTemplateId = @"templateId";
NSString *const kRootClassWorkitemId = @"workitemId";

@interface SPSearchColModel ()
@end
@implementation SPSearchColModel




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kRootClassActivityId] isKindOfClass:[NSNull class]]){
		self.activityId = [dictionary[kRootClassActivityId] integerValue];
	}

	if(![dictionary[kRootClassAffairId] isKindOfClass:[NSNull class]]){
		self.affairId = dictionary[kRootClassAffairId];
	}

	if(![dictionary[kRootClassAffairSentCanForward] isKindOfClass:[NSNull class]]){
		self.affairSentCanForward = [dictionary[kRootClassAffairSentCanForward] boolValue];
	}

	if(![dictionary[kRootClassAffairState] isKindOfClass:[NSNull class]]){
		self.affairState = [dictionary[kRootClassAffairState] integerValue];
	}

	if(![dictionary[kRootClassBackFromName] isKindOfClass:[NSNull class]]){
		self.backFromName = dictionary[kRootClassBackFromName];
	}	
	if(![dictionary[kRootClassBodyType] isKindOfClass:[NSNull class]]){
		self.bodyType = dictionary[kRootClassBodyType];
	}	
	if(![dictionary[kRootClassCanDeleteORarchive] isKindOfClass:[NSNull class]]){
		self.canDeleteORarchive = [dictionary[kRootClassCanDeleteORarchive] boolValue];
	}

	if(![dictionary[kRootClassCanForward] isKindOfClass:[NSNull class]]){
		self.canForward = [dictionary[kRootClassCanForward] boolValue];
	}

	if(![dictionary[kRootClassCaseId] isKindOfClass:[NSNull class]]){
		self.caseId = [dictionary[kRootClassCaseId] doubleValue];
	}

	if(![dictionary[kRootClassCommentReply] isKindOfClass:[NSNull class]]){
		self.commentReply = dictionary[kRootClassCommentReply];
	}	
	if(![dictionary[kRootClassDisAgreeOpinionPolicy] isKindOfClass:[NSNull class]]){
		self.disAgreeOpinionPolicy = [dictionary[kRootClassDisAgreeOpinionPolicy] integerValue];
	}

	if(![dictionary[kRootClassFromName] isKindOfClass:[NSNull class]]){
		self.fromName = dictionary[kRootClassFromName];
	}	
	if(![dictionary[kRootClassFullBFName] isKindOfClass:[NSNull class]]){
		self.fullBFName = dictionary[kRootClassFullBFName];
	}	
	if(![dictionary[kRootClassFullfromName] isKindOfClass:[NSNull class]]){
		self.fullfromName = dictionary[kRootClassFullfromName];
	}	
	if(![dictionary[kRootClassHasAttsFlag] isKindOfClass:[NSNull class]]){
		self.hasAttsFlag = [dictionary[kRootClassHasAttsFlag] boolValue];
	}

	if(![dictionary[kRootClassHasFavorite] isKindOfClass:[NSNull class]]){
		self.hasFavorite = [dictionary[kRootClassHasFavorite] boolValue];
	}

	if(![dictionary[kRootClassImportantLevel] isKindOfClass:[NSNull class]]){
		self.importantLevel = [dictionary[kRootClassImportantLevel] integerValue];
	}

	if(![dictionary[kRootClassIsCoverTime] isKindOfClass:[NSNull class]]){
		self.isCoverTime = [dictionary[kRootClassIsCoverTime] boolValue];
	}

	if(![dictionary[kRootClassNodeName] isKindOfClass:[NSNull class]]){
		self.nodeName = dictionary[kRootClassNodeName];
	}	
	if(![dictionary[kRootClassProcessId] isKindOfClass:[NSNull class]]){
		self.processId = dictionary[kRootClassProcessId];
	}	
	if(![dictionary[kRootClassReplyCounts] isKindOfClass:[NSNull class]]){
		self.replyCounts = dictionary[kRootClassReplyCounts];
	}	
	if(![dictionary[kRootClassReplyCountsNum] isKindOfClass:[NSNull class]]){
		self.replyCountsNum = [dictionary[kRootClassReplyCountsNum] integerValue];
	}

	if(![dictionary[kRootClassStartDate] isKindOfClass:[NSNull class]]){
		self.startDate = dictionary[kRootClassStartDate];
	}	
	if(![dictionary[kRootClassStartMemberId] isKindOfClass:[NSNull class]]){
		self.startMemberId = [dictionary[kRootClassStartMemberId] doubleValue];
	}

	if(![dictionary[kRootClassStartMemberName] isKindOfClass:[NSNull class]]){
		self.startMemberName = dictionary[kRootClassStartMemberName];
	}	
	if(![dictionary[kRootClassState] isKindOfClass:[NSNull class]]){
		self.state = [dictionary[kRootClassState] integerValue];
	}

	if(![dictionary[kRootClassSubState] isKindOfClass:[NSNull class]]){
		self.subState = [dictionary[kRootClassSubState] integerValue];
	}

	if(![dictionary[kRootClassSubStateName] isKindOfClass:[NSNull class]]){
		self.subStateName = dictionary[kRootClassSubStateName];
	}	
	if(![dictionary[kRootClassSubject] isKindOfClass:[NSNull class]]){
		self.subject = dictionary[kRootClassSubject];
	}	
	if(![dictionary[kRootClassSummaryId] isKindOfClass:[NSNull class]]){
		self.summaryId = [dictionary[kRootClassSummaryId] doubleValue];
	}

	if(![dictionary[kRootClassSurplusTime] isKindOfClass:[NSNull class]]){
		self.surplusTime = dictionary[kRootClassSurplusTime];
	}	
	if(![dictionary[kRootClassTemplateId] isKindOfClass:[NSNull class]]){
		self.templateId = dictionary[kRootClassTemplateId];
	}	
	if(![dictionary[kRootClassWorkitemId] isKindOfClass:[NSNull class]]){
		self.workitemId = [dictionary[kRootClassWorkitemId] doubleValue];
	}

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kRootClassActivityId] = @(self.activityId);
	dictionary[kRootClassAffairId] = self.affairId;
	dictionary[kRootClassAffairSentCanForward] = @(self.affairSentCanForward);
	dictionary[kRootClassAffairState] = @(self.affairState);
	if(self.backFromName != nil){
		dictionary[kRootClassBackFromName] = self.backFromName;
	}
	if(self.bodyType != nil){
		dictionary[kRootClassBodyType] = self.bodyType;
	}
	dictionary[kRootClassCanDeleteORarchive] = @(self.canDeleteORarchive);
	dictionary[kRootClassCanForward] = @(self.canForward);
	dictionary[kRootClassCaseId] = @(self.caseId);
	if(self.commentReply != nil){
		dictionary[kRootClassCommentReply] = self.commentReply;
	}
	dictionary[kRootClassDisAgreeOpinionPolicy] = @(self.disAgreeOpinionPolicy);
	if(self.fromName != nil){
		dictionary[kRootClassFromName] = self.fromName;
	}
	if(self.fullBFName != nil){
		dictionary[kRootClassFullBFName] = self.fullBFName;
	}
	if(self.fullfromName != nil){
		dictionary[kRootClassFullfromName] = self.fullfromName;
	}
	dictionary[kRootClassHasAttsFlag] = @(self.hasAttsFlag);
	dictionary[kRootClassHasFavorite] = @(self.hasFavorite);
	dictionary[kRootClassImportantLevel] = @(self.importantLevel);
	dictionary[kRootClassIsCoverTime] = @(self.isCoverTime);
	if(self.nodeName != nil){
		dictionary[kRootClassNodeName] = self.nodeName;
	}
	if(self.processId != nil){
		dictionary[kRootClassProcessId] = self.processId;
	}
	if(self.replyCounts != nil){
		dictionary[kRootClassReplyCounts] = self.replyCounts;
	}
	dictionary[kRootClassReplyCountsNum] = @(self.replyCountsNum);
	if(self.startDate != nil){
		dictionary[kRootClassStartDate] = self.startDate;
	}
	dictionary[kRootClassStartMemberId] = @(self.startMemberId);
	if(self.startMemberName != nil){
		dictionary[kRootClassStartMemberName] = self.startMemberName;
	}
	dictionary[kRootClassState] = @(self.state);
	dictionary[kRootClassSubState] = @(self.subState);
	if(self.subStateName != nil){
		dictionary[kRootClassSubStateName] = self.subStateName;
	}
	if(self.subject != nil){
		dictionary[kRootClassSubject] = self.subject;
	}
	dictionary[kRootClassSummaryId] = @(self.summaryId);
	if(self.surplusTime != nil){
		dictionary[kRootClassSurplusTime] = self.surplusTime;
	}
	if(self.templateId != nil){
		dictionary[kRootClassTemplateId] = self.templateId;
	}
	dictionary[kRootClassWorkitemId] = @(self.workitemId);
	return dictionary;

}
@end
