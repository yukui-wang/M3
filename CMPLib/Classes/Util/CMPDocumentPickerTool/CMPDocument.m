//
//  CMPDocument.m
//  FileAccess_iCloud_QQ_Wechat
//
//  Created by Hao on 2017/7/28.
//  Copyright © 2017年 zzh. All rights reserved.
//

#import "CMPDocument.h"

@implementation CMPDocument

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    
    _data = contents;
    
    return YES;
}

@end
