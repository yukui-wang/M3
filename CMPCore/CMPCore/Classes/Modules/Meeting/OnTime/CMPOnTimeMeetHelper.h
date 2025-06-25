//
//  CMPOnTimeMeetHelper.h
//  M3
//
//  Created by Kaku Songu on 11/25/22.
//

#import <CMPLib/CMPObject.h>
#import "CMPOnTimeMeetViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOnTimeMeetHelper : CMPObject
@property (nonatomic,strong) CMPOnTimeMeetViewModel *viewModel;
- (void)ready;
+ (BOOL)ifServerSupport;
+ (NSDictionary *)quickItemConfig;
-(void)openPersonalMeeting;
+(void)openMeetingWithNumb:(NSString *)numb pwd:(NSString *)pwd link:(NSString *)link  result:(void (^ __nullable)(BOOL success,NSError *error))result;
+ (BOOL)isMsgValidWithTimestramp:(long long)createTime;
@end

NS_ASSUME_NONNULL_END
