//
//  MJINGESignature
//  M1Core
//
//  Created by Generated by Java on 2014-04-16 15:28.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import "MJINGESignature.h"

@implementation MJINGESignature

- (void)dealloc
{
    [_fieldName release];
    [_fieldValue release];
    [_version release];
    
    [_recordID release];
    [_picData release];
    [_height release];
    
    [_width release];
    [_summaryID release];
    [_currentOrgID release];
    
    [_currentOrgName release];
    
    [super dealloc];
}
@end
