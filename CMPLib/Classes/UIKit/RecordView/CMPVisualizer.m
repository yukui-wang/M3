//
//  SyVisualizer.m
//  M1Core
//
//  Created by wujs on 13-1-15.
//
//

#import "CMPVisualizer.h"

@implementation CMPVisualizer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        powers = [[NSMutableArray alloc] initWithCapacity:self.frame.size.width / 2];
    }
    return self;
}
- (void)setPower:(float) p {
	
 	[powers addObject:[NSNumber numberWithFloat:p]];
    
 	while ( powers.count * 2 > self.frame.size.width ) {
		[powers removeObjectAtIndex:0];
	}
    
 	if ( p < minPower ) {
		minPower = p;
	}
}

- (void)clear {
    [powers removeAllObjects];
}

- (void)drawRect:(CGRect)rect {
    
 	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize size = self.frame.size;
    
 	for ( int i = 0; i < powers.count; i++ ) {
  		float newPower = [[powers objectAtIndex:i] floatValue];
		float height = (1 - newPower / minPower) * (size.height / 2);
		CGContextMoveToPoint(context, i * 2.1, size.height / 2 - height);
		CGContextAddLineToPoint(context, i * 2.1, size.height / 2 + height);
		CGContextSetRGBStrokeColor( context, 0.5, 0.5, 0.2, 0.99 );
		CGContextStrokePath( context );
	}
}


- (void)dealloc {
	powers = nil;
}


@end
