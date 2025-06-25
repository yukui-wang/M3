//
//  CMPLbsShowItem.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/26.
//
//

#import <CMPLib/CMPObject.h>

@interface CMPLbsShowItem : CMPObject
{
    double        lbsLongitude;
    double        lbsLatitude;
    NSString        *lbsAddr;
    NSString        *lbsContinent;
    NSString        *lbsCountry;
    NSString        *lbsProvince;
    NSString        *lbsCity;
    NSString        *lbsTown;
    NSString        *lbsStreet;
    NSString        *lbsNearAddress;
    NSString        *lbsAddressCode;
    NSInteger        lbsAddressType;
    NSInteger        category;
    NSString        *createDate;
    long long        referenceSummaryId;
    long long        referenceRecordId;
    long long        referenceFormId;
    NSString        *referenceFieldName;
    long long        referenceTemplateId;
    NSString        *lbsComment;
    long long        lbsId;
    long long        referenceFormMasterDataId;
    NSArray        *attachmentList;
    NSString        *senderIds;
    NSArray        *senderNames;
    NSInteger        lbsType;
    
}
@property(nonatomic, assign)double        lbsLongitude;
@property(nonatomic, assign)double        lbsLatitude;
@property(nonatomic, copy)NSString        *lbsAddr;
@property(nonatomic, copy)NSString        *lbsContinent;
@property(nonatomic, copy)NSString        *lbsCountry;
@property(nonatomic, copy)NSString        *lbsProvince;
@property(nonatomic, copy)NSString        *lbsCity;
@property(nonatomic, copy)NSString        *lbsTown;
@property(nonatomic, copy)NSString        *lbsStreet;
@property(nonatomic, copy)NSString        *lbsNearAddress;
@property(nonatomic, copy)NSString        *lbsAddressCode;
@property(nonatomic, assign)NSInteger        lbsAddressType;
@property(nonatomic, assign)NSInteger        category;
@property(nonatomic, copy)NSString        *createDate;
@property(nonatomic, assign)long long        referenceSummaryId;
@property(nonatomic, assign)long long        referenceRecordId;
@property(nonatomic, assign)long long        referenceFormId;
@property(nonatomic, copy)NSString        *referenceFieldName;
@property(nonatomic, assign)long long        referenceTemplateId;
@property(nonatomic, copy)NSString        *lbsComment;
@property(nonatomic, assign)long long        lbsId;
@property(nonatomic, assign)long long        referenceFormMasterDataId;
@property(nonatomic, assign)long long        ownerId;
@property(nonatomic, assign)long long        dptId;
@property(nonatomic, assign)long long        levelId;
@property(nonatomic, assign)NSInteger        state;

//目前没有的
@property(nonatomic, retain)NSArray        *attachmentList;
@property(nonatomic, copy)NSString        *senderIds;
@property(nonatomic, retain)NSArray        *senderNames;
@property(nonatomic, assign)NSInteger        lbsType;


@end

