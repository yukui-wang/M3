//
//  CMPOcrModulesManageCollectionViewModel.h
//  M3
//
//  Created by Kaku Songu on 12/21/21.
//

#import <CMPLib/CMPBaseViewModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrModulesManageCollectionItem : CMPObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,strong) id extend;

@end

@interface CMPOcrModulesManageCollectionViewModel : CMPBaseViewModel

@property (nonatomic,assign) NSInteger state;//0,1
@property (nonatomic,strong) NSArray *itemsArr;
@property (nonatomic,strong) NSMutableArray *itemsEditArr;

-(NSArray *)toShowArr;

@end

NS_ASSUME_NONNULL_END
