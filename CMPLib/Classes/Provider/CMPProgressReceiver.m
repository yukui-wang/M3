//
//  MProgressReceiver.m
//  M1Core
//
//  Created by youlin guo on 14-3-19.
//
//

#import "CMPProgressReceiver.h"

@implementation CMPProgressReceiver

- (void)setProgress:(float)progress {
    self.currentValue = progress;
	// 回掉给response
	if ([_response respondsToSelector:@selector(progressReceiverUpdate:)]) {
		[_response progressReceiverUpdate:self];
	}
}

- (void)request:(NSObject *)request didReceiveBytes:(long long)bytes
{
    self.didReceiveBytes = bytes;
}

@end
