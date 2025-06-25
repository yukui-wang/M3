//
//  CMPOcrUploadManageView.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import <CMPLib/CMPBaseView.h>
@class CMPOcrPackageModel;
@interface CMPOcrUploadManageView : CMPBaseView

//带入已选数据，并返回修改后的数据
- (void)reloadDataWithFileArray:(NSArray *)fileArray forbidCreatePackage:(BOOL)forbidCreatePackage completion:(void(^)(NSArray *pickedFileArray))completion;

@property (nonatomic, copy) void(^PickPackageSectionBlock)(void);

@property (nonatomic, assign) BOOL canClickCreatePackage;

- (void)refreshWithPackage:(CMPOcrPackageModel *)package;

@end

