//
//  NSBundle+CMPImagePicker.m
//  CMPImagePickerController
//
//  Created by 谭真 on 16/08/18.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "NSBundle+CMPImagePicker.h"
#import "CMPImagePickerController.h"

@implementation NSBundle (CMPImagePicker)

+ (NSBundle *)CMP_imagePickerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[CMPImagePickerController class]];
    NSURL *url = [bundle URLForResource:@"CMPImagePickerController" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)CMP_localizedStringForKey:(NSString *)key {
    return [self CMP_localizedStringForKey:key value:@""];
}

+ (NSString *)CMP_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = [CMPImagePickerConfig sharedInstance].languageBundle;
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    return value1;
}

@end
