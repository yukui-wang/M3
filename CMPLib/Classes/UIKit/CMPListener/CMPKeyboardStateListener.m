//
//  KeyboardStateListener.m
//  SeeyonFlow
//
//  Created by admin on 12-5-6.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

#import "CMPKeyboardStateListener.h"

static CMPKeyboardStateListener *sharedObj;

@implementation CMPKeyboardStateListener

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHide) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CMPKeyboardStateListener *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[self alloc] init];
    });
    return sharedObj;
}

- (CGRect)keyboardRect {
    return _keyboardRect;
}

- (void)didShow {
    _visible = YES;
}

- (void)didHide {
    _visible = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self didShow];
    _keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

@end
