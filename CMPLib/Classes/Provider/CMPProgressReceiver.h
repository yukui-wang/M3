//
//  MProgressReceiver.h
//  M1Core
//
//  Created by youlin guo on 14-3-19.
//
//

#import <Foundation/Foundation.h>

@protocol CMPProgressReceiverDelegate;

@interface CMPProgressReceiver : NSObject

@property (nonatomic, assign)float minValue, maxValue, currentValue;
@property (nonatomic, assign)float progress;
@property (nonatomic, assign)long long didReceiveBytes;
@property (nonatomic, assign)id userInfo;
@property (nonatomic, assign)id<CMPProgressReceiverDelegate> response;

@end

@protocol CMPProgressReceiverDelegate <NSObject>

- (void)progressReceiverUpdate:(CMPProgressReceiver *)aReceiver;

@end
