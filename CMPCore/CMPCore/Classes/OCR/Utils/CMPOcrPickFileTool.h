//
//  CMPOcrPickFileTool.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/26.
//

#import <CMPLib/CMPObject.h>

@class CMPOcrFileModel;
@interface CMPOcrPickFileTool : CMPObject
- (void)showSheetForPickToVC:(UIViewController *)vc Completion:(void(^)(NSArray<CMPOcrFileModel *> *))completion;
- (void)pushPickToVC:(UIViewController *)targetVC Completion:(void(^)(NSArray<CMPOcrFileModel *> *))completion;
@end


