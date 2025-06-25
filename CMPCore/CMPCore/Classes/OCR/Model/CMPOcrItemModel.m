//
//  CMPOcrItemModel.m
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import "CMPOcrItemModel.h"
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPUploadFileTool.h>

@implementation CMPOcrItemModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"packageId" : @"rPackageId",
             @"ID":@"id"
    };
}

@end
