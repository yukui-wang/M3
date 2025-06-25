//
//	SPSearchBulModel.m
//
//	Create by CRMO on 26/2/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "SPSearchBulModel.h"

NSString *const kSPSearchBulModelAccountId = @"accountId";
NSString *const kSPSearchBulModelAttachmentsFlag = @"attachmentsFlag";
NSString *const kSPSearchBulModelAuditAdvice = @"auditAdvice";
NSString *const kSPSearchBulModelAuditDate = @"auditDate";
NSString *const kSPSearchBulModelAuditUserId = @"auditUserId";
NSString *const kSPSearchBulModelBrief = @"brief";
NSString *const kSPSearchBulModelChoosePublshId = @"choosePublshId";
NSString *const kSPSearchBulModelContent = @"content";
NSString *const kSPSearchBulModelContentName = @"contentName";
NSString *const kSPSearchBulModelCreateDate = @"createDate";
NSString *const kSPSearchBulModelCreateUser = @"createUser";
NSString *const kSPSearchBulModelDataFormat = @"dataFormat";
NSString *const kSPSearchBulModelDeletedFlag = @"deletedFlag";
NSString *const kSPSearchBulModelExt1 = @"ext1";
NSString *const kSPSearchBulModelExt2 = @"ext2";
NSString *const kSPSearchBulModelExt3 = @"ext3";
NSString *const kSPSearchBulModelExt4 = @"ext4";
NSString *const kSPSearchBulModelExt5 = @"ext5";
NSString *const kSPSearchBulModelIdField = @"id";
NSString *const kSPSearchBulModelKeywords = @"keywords";
NSString *const kSPSearchBulModelNewField = @"new";
NSString *const kSPSearchBulModelNoDelete = @"noDelete";
NSString *const kSPSearchBulModelNoEdit = @"noEdit";
NSString *const kSPSearchBulModelPigeonholeDate = @"pigeonholeDate";
NSString *const kSPSearchBulModelPigeonholePath = @"pigeonholePath";
NSString *const kSPSearchBulModelPigeonholeUserId = @"pigeonholeUserId";
NSString *const kSPSearchBulModelPublishChoose = @"publishChoose";
NSString *const kSPSearchBulModelPublishDate = @"publishDate";
NSString *const kSPSearchBulModelPublishDateFormat = @"publishDateFormat";
NSString *const kSPSearchBulModelPublishDepartmentId = @"publishDepartmentId";
NSString *const kSPSearchBulModelPublishDeptName = @"publishDeptName";
NSString *const kSPSearchBulModelPublishMemberName = @"publishMemberName";
NSString *const kSPSearchBulModelPublishScope = @"publishScope";
NSString *const kSPSearchBulModelPublishUserId = @"publishUserId";
NSString *const kSPSearchBulModelReadCount = @"readCount";
NSString *const kSPSearchBulModelReadFlag = @"readFlag";
NSString *const kSPSearchBulModelShowPublishName = @"showPublishName";
NSString *const kSPSearchBulModelShowPublishUserFlag = @"showPublishUserFlag";
NSString *const kSPSearchBulModelSpaceType = @"spaceType";
NSString *const kSPSearchBulModelState = @"state";
NSString *const kSPSearchBulModelStringId = @"stringId";
NSString *const kSPSearchBulModelTitle = @"title";
NSString *const kSPSearchBulModelTopOrder = @"topOrder";
NSString *const kSPSearchBulModelTypeId = @"typeId";
NSString *const kSPSearchBulModelTypeName = @"typeName";
NSString *const kSPSearchBulModelUpdateDate = @"updateDate";
NSString *const kSPSearchBulModelUpdateUser = @"updateUser";
NSString *const kSPSearchBulModelWritePublish = @"writePublish";

@interface SPSearchBulModel ()
@end
@implementation SPSearchBulModel




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSPSearchBulModelAccountId] isKindOfClass:[NSNull class]]){
		self.accountId = [dictionary[kSPSearchBulModelAccountId] doubleValue];
	}

	if(![dictionary[kSPSearchBulModelAttachmentsFlag] isKindOfClass:[NSNull class]]){
		self.attachmentsFlag = [dictionary[kSPSearchBulModelAttachmentsFlag] boolValue];
	}

	if(![dictionary[kSPSearchBulModelAuditAdvice] isKindOfClass:[NSNull class]]){
		self.auditAdvice = dictionary[kSPSearchBulModelAuditAdvice];
	}	
	if(![dictionary[kSPSearchBulModelAuditDate] isKindOfClass:[NSNull class]]){
		self.auditDate = dictionary[kSPSearchBulModelAuditDate];
	}	
	if(![dictionary[kSPSearchBulModelAuditUserId] isKindOfClass:[NSNull class]]){
		self.auditUserId = dictionary[kSPSearchBulModelAuditUserId];
	}	
	if(![dictionary[kSPSearchBulModelBrief] isKindOfClass:[NSNull class]]){
		self.brief = dictionary[kSPSearchBulModelBrief];
	}	
	if(![dictionary[kSPSearchBulModelChoosePublshId] isKindOfClass:[NSNull class]]){
		self.choosePublshId = dictionary[kSPSearchBulModelChoosePublshId];
	}	
	if(![dictionary[kSPSearchBulModelContent] isKindOfClass:[NSNull class]]){
		self.content = dictionary[kSPSearchBulModelContent];
	}	
	if(![dictionary[kSPSearchBulModelContentName] isKindOfClass:[NSNull class]]){
		self.contentName = dictionary[kSPSearchBulModelContentName];
	}	
	if(![dictionary[kSPSearchBulModelCreateDate] isKindOfClass:[NSNull class]]){
		self.createDate = [dictionary[kSPSearchBulModelCreateDate] integerValue];
	}

	if(![dictionary[kSPSearchBulModelCreateUser] isKindOfClass:[NSNull class]]){
		self.createUser = [dictionary[kSPSearchBulModelCreateUser] doubleValue];
	}

	if(![dictionary[kSPSearchBulModelDataFormat] isKindOfClass:[NSNull class]]){
		self.dataFormat = dictionary[kSPSearchBulModelDataFormat];
	}	
	if(![dictionary[kSPSearchBulModelDeletedFlag] isKindOfClass:[NSNull class]]){
		self.deletedFlag = [dictionary[kSPSearchBulModelDeletedFlag] boolValue];
	}

	if(![dictionary[kSPSearchBulModelExt1] isKindOfClass:[NSNull class]]){
		self.ext1 = dictionary[kSPSearchBulModelExt1];
	}	
	if(![dictionary[kSPSearchBulModelExt2] isKindOfClass:[NSNull class]]){
		self.ext2 = dictionary[kSPSearchBulModelExt2];
	}	
	if(![dictionary[kSPSearchBulModelExt3] isKindOfClass:[NSNull class]]){
		self.ext3 = dictionary[kSPSearchBulModelExt3];
	}	
	if(![dictionary[kSPSearchBulModelExt4] isKindOfClass:[NSNull class]]){
		self.ext4 = dictionary[kSPSearchBulModelExt4];
	}	
	if(![dictionary[kSPSearchBulModelExt5] isKindOfClass:[NSNull class]]){
		self.ext5 = dictionary[kSPSearchBulModelExt5];
	}	
	if(![dictionary[kSPSearchBulModelIdField] isKindOfClass:[NSNull class]]){
		self.idField = dictionary[kSPSearchBulModelIdField];
	}

	if(![dictionary[kSPSearchBulModelKeywords] isKindOfClass:[NSNull class]]){
		self.keywords = dictionary[kSPSearchBulModelKeywords];
	}	
	if(![dictionary[kSPSearchBulModelNewField] isKindOfClass:[NSNull class]]){
		self.newField = [dictionary[kSPSearchBulModelNewField] boolValue];
	}

	if(![dictionary[kSPSearchBulModelNoDelete] isKindOfClass:[NSNull class]]){
		self.noDelete = [dictionary[kSPSearchBulModelNoDelete] boolValue];
	}

	if(![dictionary[kSPSearchBulModelNoEdit] isKindOfClass:[NSNull class]]){
		self.noEdit = [dictionary[kSPSearchBulModelNoEdit] boolValue];
	}

	if(![dictionary[kSPSearchBulModelPigeonholeDate] isKindOfClass:[NSNull class]]){
		self.pigeonholeDate = dictionary[kSPSearchBulModelPigeonholeDate];
	}	
	if(![dictionary[kSPSearchBulModelPigeonholePath] isKindOfClass:[NSNull class]]){
		self.pigeonholePath = dictionary[kSPSearchBulModelPigeonholePath];
	}	
	if(![dictionary[kSPSearchBulModelPigeonholeUserId] isKindOfClass:[NSNull class]]){
		self.pigeonholeUserId = dictionary[kSPSearchBulModelPigeonholeUserId];
	}	
	if(![dictionary[kSPSearchBulModelPublishChoose] isKindOfClass:[NSNull class]]){
		self.publishChoose = [dictionary[kSPSearchBulModelPublishChoose] integerValue];
	}

	if(![dictionary[kSPSearchBulModelPublishDate] isKindOfClass:[NSNull class]]){
		self.publishDate = [dictionary[kSPSearchBulModelPublishDate] integerValue];
	}

	if(![dictionary[kSPSearchBulModelPublishDateFormat] isKindOfClass:[NSNull class]]){
		self.publishDateFormat = dictionary[kSPSearchBulModelPublishDateFormat];
	}	
	if(![dictionary[kSPSearchBulModelPublishDepartmentId] isKindOfClass:[NSNull class]]){
		self.publishDepartmentId = [dictionary[kSPSearchBulModelPublishDepartmentId] integerValue];
	}

	if(![dictionary[kSPSearchBulModelPublishDeptName] isKindOfClass:[NSNull class]]){
		self.publishDeptName = dictionary[kSPSearchBulModelPublishDeptName];
	}	
	if(![dictionary[kSPSearchBulModelPublishMemberName] isKindOfClass:[NSNull class]]){
		self.publishMemberName = dictionary[kSPSearchBulModelPublishMemberName];
	}	
	if(![dictionary[kSPSearchBulModelPublishScope] isKindOfClass:[NSNull class]]){
		self.publishScope = dictionary[kSPSearchBulModelPublishScope];
	}	
	if(![dictionary[kSPSearchBulModelPublishUserId] isKindOfClass:[NSNull class]]){
		self.publishUserId = [dictionary[kSPSearchBulModelPublishUserId] doubleValue];
	}

	if(![dictionary[kSPSearchBulModelReadCount] isKindOfClass:[NSNull class]]){
		self.readCount = [dictionary[kSPSearchBulModelReadCount] integerValue];
	}

	if(![dictionary[kSPSearchBulModelReadFlag] isKindOfClass:[NSNull class]]){
		self.readFlag = dictionary[kSPSearchBulModelReadFlag];
	}	
	if(![dictionary[kSPSearchBulModelShowPublishName] isKindOfClass:[NSNull class]]){
		self.showPublishName = dictionary[kSPSearchBulModelShowPublishName];
	}	
	if(![dictionary[kSPSearchBulModelShowPublishUserFlag] isKindOfClass:[NSNull class]]){
		self.showPublishUserFlag = [dictionary[kSPSearchBulModelShowPublishUserFlag] boolValue];
	}

	if(![dictionary[kSPSearchBulModelSpaceType] isKindOfClass:[NSNull class]]){
		self.spaceType = dictionary[kSPSearchBulModelSpaceType];
	}	
	if(![dictionary[kSPSearchBulModelState] isKindOfClass:[NSNull class]]){
		self.state = [dictionary[kSPSearchBulModelState] integerValue];
	}

	if(![dictionary[kSPSearchBulModelStringId] isKindOfClass:[NSNull class]]){
		self.stringId = dictionary[kSPSearchBulModelStringId];
	}	
	if(![dictionary[kSPSearchBulModelTitle] isKindOfClass:[NSNull class]]){
		self.title = dictionary[kSPSearchBulModelTitle];
	}	
	if(![dictionary[kSPSearchBulModelTopOrder] isKindOfClass:[NSNull class]]){
		self.topOrder = [dictionary[kSPSearchBulModelTopOrder] integerValue];
	}

	if(![dictionary[kSPSearchBulModelTypeId] isKindOfClass:[NSNull class]]){
		self.typeId = [dictionary[kSPSearchBulModelTypeId] doubleValue];
	}

	if(![dictionary[kSPSearchBulModelTypeName] isKindOfClass:[NSNull class]]){
		self.typeName = dictionary[kSPSearchBulModelTypeName];
	}	
	if(![dictionary[kSPSearchBulModelUpdateDate] isKindOfClass:[NSNull class]]){
		self.updateDate = [dictionary[kSPSearchBulModelUpdateDate] integerValue];
	}

	if(![dictionary[kSPSearchBulModelUpdateUser] isKindOfClass:[NSNull class]]){
		self.updateUser = [dictionary[kSPSearchBulModelUpdateUser] doubleValue];
	}

	if(![dictionary[kSPSearchBulModelWritePublish] isKindOfClass:[NSNull class]]){
		self.writePublish = dictionary[kSPSearchBulModelWritePublish];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kSPSearchBulModelAccountId] = @(self.accountId);
	dictionary[kSPSearchBulModelAttachmentsFlag] = @(self.attachmentsFlag);
	if(self.auditAdvice != nil){
		dictionary[kSPSearchBulModelAuditAdvice] = self.auditAdvice;
	}
	if(self.auditDate != nil){
		dictionary[kSPSearchBulModelAuditDate] = self.auditDate;
	}
	if(self.auditUserId != nil){
		dictionary[kSPSearchBulModelAuditUserId] = self.auditUserId;
	}
	if(self.brief != nil){
		dictionary[kSPSearchBulModelBrief] = self.brief;
	}
	if(self.choosePublshId != nil){
		dictionary[kSPSearchBulModelChoosePublshId] = self.choosePublshId;
	}
	if(self.content != nil){
		dictionary[kSPSearchBulModelContent] = self.content;
	}
	if(self.contentName != nil){
		dictionary[kSPSearchBulModelContentName] = self.contentName;
	}
	dictionary[kSPSearchBulModelCreateDate] = @(self.createDate);
	dictionary[kSPSearchBulModelCreateUser] = @(self.createUser);
	if(self.dataFormat != nil){
		dictionary[kSPSearchBulModelDataFormat] = self.dataFormat;
	}
	dictionary[kSPSearchBulModelDeletedFlag] = @(self.deletedFlag);
	if(self.ext1 != nil){
		dictionary[kSPSearchBulModelExt1] = self.ext1;
	}
	if(self.ext2 != nil){
		dictionary[kSPSearchBulModelExt2] = self.ext2;
	}
	if(self.ext3 != nil){
		dictionary[kSPSearchBulModelExt3] = self.ext3;
	}
	if(self.ext4 != nil){
		dictionary[kSPSearchBulModelExt4] = self.ext4;
	}
	if(self.ext5 != nil){
		dictionary[kSPSearchBulModelExt5] = self.ext5;
	}
	dictionary[kSPSearchBulModelIdField] = self.idField;
	if(self.keywords != nil){
		dictionary[kSPSearchBulModelKeywords] = self.keywords;
	}
	dictionary[kSPSearchBulModelNewField] = @(self.newField);
	dictionary[kSPSearchBulModelNoDelete] = @(self.noDelete);
	dictionary[kSPSearchBulModelNoEdit] = @(self.noEdit);
	if(self.pigeonholeDate != nil){
		dictionary[kSPSearchBulModelPigeonholeDate] = self.pigeonholeDate;
	}
	if(self.pigeonholePath != nil){
		dictionary[kSPSearchBulModelPigeonholePath] = self.pigeonholePath;
	}
	if(self.pigeonholeUserId != nil){
		dictionary[kSPSearchBulModelPigeonholeUserId] = self.pigeonholeUserId;
	}
	dictionary[kSPSearchBulModelPublishChoose] = @(self.publishChoose);
	dictionary[kSPSearchBulModelPublishDate] = @(self.publishDate);
	if(self.publishDateFormat != nil){
		dictionary[kSPSearchBulModelPublishDateFormat] = self.publishDateFormat;
	}
	dictionary[kSPSearchBulModelPublishDepartmentId] = @(self.publishDepartmentId);
	if(self.publishDeptName != nil){
		dictionary[kSPSearchBulModelPublishDeptName] = self.publishDeptName;
	}
	if(self.publishMemberName != nil){
		dictionary[kSPSearchBulModelPublishMemberName] = self.publishMemberName;
	}
	if(self.publishScope != nil){
		dictionary[kSPSearchBulModelPublishScope] = self.publishScope;
	}
	dictionary[kSPSearchBulModelPublishUserId] = @(self.publishUserId);
	dictionary[kSPSearchBulModelReadCount] = @(self.readCount);
	if(self.readFlag != nil){
		dictionary[kSPSearchBulModelReadFlag] = self.readFlag;
	}
	if(self.showPublishName != nil){
		dictionary[kSPSearchBulModelShowPublishName] = self.showPublishName;
	}
	dictionary[kSPSearchBulModelShowPublishUserFlag] = @(self.showPublishUserFlag);
	if(self.spaceType != nil){
		dictionary[kSPSearchBulModelSpaceType] = self.spaceType;
	}
	dictionary[kSPSearchBulModelState] = @(self.state);
	if(self.stringId != nil){
		dictionary[kSPSearchBulModelStringId] = self.stringId;
	}
	if(self.title != nil){
		dictionary[kSPSearchBulModelTitle] = self.title;
	}
	dictionary[kSPSearchBulModelTopOrder] = @(self.topOrder);
	dictionary[kSPSearchBulModelTypeId] = @(self.typeId);
	if(self.typeName != nil){
		dictionary[kSPSearchBulModelTypeName] = self.typeName;
	}
	dictionary[kSPSearchBulModelUpdateDate] = @(self.updateDate);
	dictionary[kSPSearchBulModelUpdateUser] = @(self.updateUser);
	if(self.writePublish != nil){
		dictionary[kSPSearchBulModelWritePublish] = self.writePublish;
	}
	return dictionary;

}

@end
