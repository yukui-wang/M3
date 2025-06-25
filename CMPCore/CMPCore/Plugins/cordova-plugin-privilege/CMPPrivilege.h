//
//  CMPPrivilege.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/28.
//
//

#import <Foundation/Foundation.h>

@interface CMPPrivilege : NSObject <NSCoding>

@property(nonatomic, assign) BOOL hasColNew;//新建协同
@property(nonatomic, assign) BOOL hasAddressBook;//是否有通讯录权限
@property(nonatomic, assign) BOOL hasIndexPlugin;//是否有全文检索

//...

@end
