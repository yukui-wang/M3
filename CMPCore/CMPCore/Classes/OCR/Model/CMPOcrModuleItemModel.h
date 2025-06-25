//
//  CMPOcrModuleItemModel.h
//  M3
//
//  Created by Kaku Songu on 12/14/21.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrModuleItemModel : CMPObject
/*
templateName    string
必须
模板名称
templateId    number
必须
报销流程模板ID
formId    number
必须
表单id
sortNO    number
必须
排序号
isOften    number
必须
是否是常用分类 1:是 0：否
lastUsedTag    number
必须
上次是否使用的该模板 1.是 0.否
 isDeleted    number
 必须
 删除标识1:已删除 0:未删除
 */
@property (nonatomic,copy) NSString *oid;
@property (nonatomic,copy) NSString *templateName;
@property (nonatomic,copy) NSString *templateId;
@property (nonatomic,copy) NSString *formId;
@property (nonatomic,assign) NSInteger sortNO;
@property (nonatomic,assign) NSInteger isOften;
@property (nonatomic,assign) NSInteger lastUsedTag;
@property (nonatomic,assign) NSInteger isDeleted;

@end

NS_ASSUME_NONNULL_END
