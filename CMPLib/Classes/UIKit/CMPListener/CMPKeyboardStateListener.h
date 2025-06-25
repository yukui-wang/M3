//
//  KeyboardStateListener.h
//  SeeyonFlow
//
//  Created by admin on 12-5-6.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CMPObject.h"

@interface CMPKeyboardStateListener : CMPObject {
    CGRect _keyboardRect;
}

@property (nonatomic, readonly, getter=isVisible) BOOL visible;

+ (CMPKeyboardStateListener *) sharedInstance;
- (CGRect )keyboardRect;

@end
