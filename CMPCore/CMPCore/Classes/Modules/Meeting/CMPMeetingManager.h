//
//  CMPMeetingManager.h
//  M3
//
//  Created by Kaku Songu on 11/25/22.
//

#import <CMPLib/CMPObject.h>
#import "CMPMeetingConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPMeetingManager : CMPObject

+(instancetype)shareInstance;
+(void)ready;

+ (BOOL)otmIfServerSupport;
+ (NSDictionary *)otmQuickItemConfig;
- (BOOL)otmIfServerOpen;
- (BOOL)otmIfPersonalConfig;
- (void)otmBeginMeetingWithMids:(NSArray *)mids onVC:(UIViewController *)vc from:(MeetingOtmCreateFrom)from ext:(id)ext completion:(void(^)(id rslt, NSError *err, id ext,NSInteger step))completion;
- (void)otmVerifyMeetingValidWithInfo:(NSDictionary *)meetInfo completion:(void(^)(BOOL validable,NSError *error, id ext))completion;
- (void)otmOpenPersonalMeeting;
+ (void)otmOpenWithNumb:(NSString *)numb pwd:(NSString *)pwd link:(NSString *)link  result:(void (^ __nullable)(BOOL success,NSError *error))result;
+ (BOOL)isDateValidWithin30MinituesByTimestramp:(long long)createTime;

@end

NS_ASSUME_NONNULL_END
