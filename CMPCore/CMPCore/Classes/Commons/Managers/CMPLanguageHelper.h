//
//  CMPLanguageHelper.h
//  M3
//
//  Created by 程昆 on 2019/7/2.
//

#import <CMPLib/CMPObject.h>

@interface CMPLanguageHelper : CMPObject

+ (void)checkAndSwichAvailableLanguage;
+ (NSArray *)availableLanguageList;
+ (void)refreshDataAndInterfaceDidSuccess:(void(^)(void))success fail:(void(^)(NSError *error))fail;

@end


