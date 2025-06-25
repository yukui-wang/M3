//
//  CMPFile.m
//  CMPCore
//
//  Created by youlin guo on 14-11-11.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "CMPFile.h"

@implementation CMPFile

+ (CMPFile *)fileWithPath:(NSString *)aPath
{
	CMPFile *aFile = [[CMPFile alloc] init];
	aFile.filePath = aPath;
	aFile.fileName = [aPath lastPathComponent];
	return aFile;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.fileID = [NSString uuid];
	}
	return self;
}

@end
