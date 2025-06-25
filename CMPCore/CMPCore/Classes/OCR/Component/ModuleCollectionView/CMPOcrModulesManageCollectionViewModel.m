//
//  CMPOcrModulesManageCollectionViewModel.m
//  M3
//
//  Created by Kaku Songu on 12/21/21.
//

#import "CMPOcrModulesManageCollectionViewModel.h"

@implementation CMPOcrModulesManageCollectionItem

@end

@implementation CMPOcrModulesManageCollectionViewModel


-(NSArray *)toShowArr
{
    if (self.state == 1) {
        return self.itemsEditArr;
    }
    return self.itemsArr;
}

@end
