//
//  SyFilePage.m
//  M1Core
//
//  Created by youlin guo on 14-3-13.
//
//

#import "SyFilePage.h"

@implementation SyFilePage

@synthesize totalCount = _totalCount;
@synthesize fileList = _fileList;

- (void)dealloc
{
	[_fileList release];
	[super dealloc];
}

@end
