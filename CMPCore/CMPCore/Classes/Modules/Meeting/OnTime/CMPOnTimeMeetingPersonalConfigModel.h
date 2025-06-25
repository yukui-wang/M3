//
//  CMPOnTimeMeetingPersonalConfigModel.h
//  M3
//
//  Created by Kaku Songu on 11/27/22.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOnTimeMeetingPersonalConfigModel : CMPObject

@property (nonatomic,copy) NSString *configId;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *link;
@property (nonatomic,copy) NSString *meetingNumber;
@property (nonatomic,copy) NSString *meetingPassword;
@property (nonatomic,assign) long createDate;
@property (nonatomic,assign) long modifyDate;

@end

NS_ASSUME_NONNULL_END
