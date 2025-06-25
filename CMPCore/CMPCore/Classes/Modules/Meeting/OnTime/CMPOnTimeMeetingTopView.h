//
//  CMPOnTimeMeetingTopView.h
//  M3
//
//  Created by Kaku Songu on 12/1/22.
//

#import "CMPWindowAlertBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOnTimeMeetingTopModel : NSObject

@property (nonatomic,copy) NSString *iconUrl;
@property (nonatomic,copy) NSString *creatorName;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *numb;
@property (nonatomic,copy) NSString *pwd;
@property (nonatomic,copy) NSString *link;
@property (nonatomic,copy) NSString *creatorId;
@property (nonatomic,assign) long long createTime;

@end

@interface CMPOnTimeMeetingTopView : CMPWindowAlertBaseView

/**
 meetingInfo:{
iconUrl: String
senderName;String
content:String
numb:String
pwd;String
senderId;String
sendTime:long
 }
 */
-(instancetype)initWithMeetingInfo:(CMPOnTimeMeetingTopModel *)meetingInfo;

@end

NS_ASSUME_NONNULL_END
