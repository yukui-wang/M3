//
//	SPSearchDocModel.m
//
//	Create by CRMO on 26/2/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "SPSearchDocModel.h"

NSString *const kSPSearchDocModelFrCreateTime = @"fr_create_time";
NSString *const kSPSearchDocModelFrCreateUsername = @"fr_create_username";
NSString *const kSPSearchDocModelFrId = @"fr_id";
NSString *const kSPSearchDocModelSourceId = @"source_id";
NSString *const kSPSearchDocModelFrMineType = @"fr_mine_type";
NSString *const kSPSearchDocModelFrName = @"fr_name";
NSString *const kSPSearchDocModelFrSize = @"fr_size";
NSString *const kSPSearchDocModelFrType = @"fr_type";
NSString *const kSPSearchDocModelHasAtt = @"hasAtt";
NSString *const kSPSearchDocModelIsFolder = @"is_folder";

@interface SPSearchDocModel ()
@end
@implementation SPSearchDocModel




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSPSearchDocModelFrCreateTime] isKindOfClass:[NSNull class]]){
		self.frCreateTime = dictionary[kSPSearchDocModelFrCreateTime];
	}	
	if(![dictionary[kSPSearchDocModelFrCreateUsername] isKindOfClass:[NSNull class]]){
		self.frCreateUsername = dictionary[kSPSearchDocModelFrCreateUsername];
	}	
	if(![dictionary[kSPSearchDocModelFrId] isKindOfClass:[NSNull class]]){
		self.frId = dictionary[kSPSearchDocModelFrId];
	}
    if(![dictionary[kSPSearchDocModelSourceId] isKindOfClass:[NSNull class]]){
        self.sourchId = dictionary[kSPSearchDocModelSourceId];
    }
	if(![dictionary[kSPSearchDocModelFrMineType] isKindOfClass:[NSNull class]]){
		self.frMineType = [dictionary[kSPSearchDocModelFrMineType] integerValue];
	}

	if(![dictionary[kSPSearchDocModelFrName] isKindOfClass:[NSNull class]]){
		self.frName = dictionary[kSPSearchDocModelFrName];
	}	
	if(![dictionary[kSPSearchDocModelFrSize] isKindOfClass:[NSNull class]]){
		self.frSize = [dictionary[kSPSearchDocModelFrSize] integerValue];
	}

	if(![dictionary[kSPSearchDocModelFrType] isKindOfClass:[NSNull class]]){
		self.frType = [dictionary[kSPSearchDocModelFrType] integerValue];
	}

	if(![dictionary[kSPSearchDocModelHasAtt] isKindOfClass:[NSNull class]]){
		self.hasAtt = [dictionary[kSPSearchDocModelHasAtt] boolValue];
	}

	if(![dictionary[kSPSearchDocModelIsFolder] isKindOfClass:[NSNull class]]){
		self.isFolder = [dictionary[kSPSearchDocModelIsFolder] boolValue];
	}

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.frCreateTime != nil){
		dictionary[kSPSearchDocModelFrCreateTime] = self.frCreateTime;
	}
	if(self.frCreateUsername != nil){
		dictionary[kSPSearchDocModelFrCreateUsername] = self.frCreateUsername;
	}
	if(self.frId != nil){
		dictionary[kSPSearchDocModelFrId] = self.frId;
	}
	dictionary[kSPSearchDocModelFrMineType] = @(self.frMineType);
	if(self.frName != nil){
		dictionary[kSPSearchDocModelFrName] = self.frName;
	}
	dictionary[kSPSearchDocModelFrSize] = @(self.frSize);
	dictionary[kSPSearchDocModelFrType] = @(self.frType);
	dictionary[kSPSearchDocModelHasAtt] = @(self.hasAtt);
	dictionary[kSPSearchDocModelIsFolder] = @(self.isFolder);
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if(self.frCreateTime != nil){
		[aCoder encodeObject:self.frCreateTime forKey:kSPSearchDocModelFrCreateTime];
	}
	if(self.frCreateUsername != nil){
		[aCoder encodeObject:self.frCreateUsername forKey:kSPSearchDocModelFrCreateUsername];
	}
	if(self.frId != nil){
		[aCoder encodeObject:self.frId forKey:kSPSearchDocModelFrId];
	}
	[aCoder encodeObject:@(self.frMineType) forKey:kSPSearchDocModelFrMineType];	if(self.frName != nil){
		[aCoder encodeObject:self.frName forKey:kSPSearchDocModelFrName];
	}
	[aCoder encodeObject:@(self.frSize) forKey:kSPSearchDocModelFrSize];	[aCoder encodeObject:@(self.frType) forKey:kSPSearchDocModelFrType];	[aCoder encodeObject:@(self.hasAtt) forKey:kSPSearchDocModelHasAtt];	[aCoder encodeObject:@(self.isFolder) forKey:kSPSearchDocModelIsFolder];
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.frCreateTime = [aDecoder decodeObjectForKey:kSPSearchDocModelFrCreateTime];
	self.frCreateUsername = [aDecoder decodeObjectForKey:kSPSearchDocModelFrCreateUsername];
	self.frId = [aDecoder decodeObjectForKey:kSPSearchDocModelFrId];
	self.frMineType = [[aDecoder decodeObjectForKey:kSPSearchDocModelFrMineType] integerValue];
	self.frName = [aDecoder decodeObjectForKey:kSPSearchDocModelFrName];
	self.frSize = [[aDecoder decodeObjectForKey:kSPSearchDocModelFrSize] integerValue];
	self.frType = [[aDecoder decodeObjectForKey:kSPSearchDocModelFrType] integerValue];
	self.hasAtt = [[aDecoder decodeObjectForKey:kSPSearchDocModelHasAtt] boolValue];
	self.isFolder = [[aDecoder decodeObjectForKey:kSPSearchDocModelIsFolder] boolValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	SPSearchDocModel *copy = [SPSearchDocModel new];

	copy.frCreateTime = [self.frCreateTime copy];
	copy.frCreateUsername = [self.frCreateUsername copy];
	copy.frId = [self.frId copy];
	copy.frMineType = self.frMineType;
	copy.frName = [self.frName copy];
	copy.frSize = self.frSize;
	copy.frType = self.frType;
	copy.hasAtt = self.hasAtt;
	copy.isFolder = self.isFolder;

	return copy;
}
@end
