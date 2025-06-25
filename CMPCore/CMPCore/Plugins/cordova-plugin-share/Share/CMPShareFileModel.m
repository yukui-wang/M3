//
//  CMPShareFileModel.m
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import "CMPShareFileModel.h"
#import <CMPLib/MJExtension.h>

@implementation CMPShareFileModel

+ (NSDictionary *)mj_objectClassInArray {
    //fileList  shareBtnList
    return @{@"fileList" : @"CMPFileManagementRecord", 
             @"shareBtnList" : @"CMPShareBtnModel",
             @"shareOtherBtnList" : @"CMPShareBtnModel",
             @"businessBtnList" : @"CMPShareBtnModel"};
}

@end

@implementation CMPShareBtnModel


@end

