//
//  CMPLbsShowItem.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/26.
//
//

#import "CMPLbsShowItem.h"

@implementation CMPLbsShowItem
@synthesize  lbsLongitude;
@synthesize  lbsLatitude;
@synthesize  lbsAddr;
@synthesize  lbsContinent;
@synthesize  lbsCountry;
@synthesize  lbsProvince;
@synthesize  lbsCity;
@synthesize  lbsTown;
@synthesize  lbsStreet;
@synthesize  lbsNearAddress;
@synthesize  lbsAddressCode;
@synthesize  lbsAddressType;
@synthesize  category;
@synthesize  createDate;
@synthesize  referenceSummaryId;
@synthesize  referenceRecordId;
@synthesize  referenceFormId;
@synthesize  referenceFieldName;
@synthesize  referenceTemplateId;
@synthesize  lbsComment;
@synthesize  lbsId;
@synthesize  referenceFormMasterDataId;
@synthesize  attachmentList;
@synthesize  senderIds;
@synthesize  senderNames;
@synthesize  lbsType;


- (void)dealloc
{
    [lbsAddr release];
    [lbsContinent release];
    [lbsCountry release];
    [lbsProvince release];
    [lbsCity release];
    [lbsTown release];
    [lbsStreet release];
    [lbsNearAddress release];
    [lbsAddressCode release];
    [createDate release];
    [referenceFieldName release];
    [lbsComment release];
    [attachmentList release];
    [senderIds release];
    [senderNames release];
    
    [super dealloc];
}

@end
