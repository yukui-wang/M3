//
//  CMPLoginModel.h
//  M3
//
//  Created by CRMO on 2017/11/3.
//

#import <CMPLib/CMPObject.h>
#import "CMPBaseResponse.h"

#pragma mark - currentMember -

@interface CMPLoginResponseCurrentMember: CMPObject
@property (nonatomic ,copy)NSString * jobNumber;
@property (nonatomic ,copy)NSString * userId;
@property (nonatomic ,copy)NSString * departmentName;
@property (nonatomic ,copy)NSString * postId;
@property (nonatomic ,copy)NSString * nameSpell;
@property (nonatomic ,copy)NSString * levelName;
@property (nonatomic ,copy)NSString * tel;
@property (nonatomic ,copy)NSString * accShortName;
@property (nonatomic ,copy)NSString * email;
@property (nonatomic ,copy)NSString * postName;
@property (nonatomic ,copy)NSString * iconUrl;
@property (nonatomic ,copy)NSString * code;
@property (nonatomic ,copy)NSString * officeNumber;
@property (nonatomic ,copy)NSString * accMotto;
@property (nonatomic ,copy)NSString * accountId;
@property (nonatomic ,copy)NSString * levelId;
@property (nonatomic ,copy)NSString * accName;
@property (nonatomic ,copy)NSString * departmentId;
@property (nonatomic ,copy)NSString * name;
/** 1130新增字段 **/
@property (nonatomic ,copy)NSString * loginName;
@end

#pragma mark - config -

@interface CMPLoginResponseConfig: CMPObject
@property (nonatomic ,copy)NSString * allowUpdateAvatar;
@property (nonatomic ,copy)NSString * csrfToken;
@property (nonatomic ,assign)BOOL  passwordOvertime;
@property (nonatomic ,assign)BOOL  passwordStrong;
@property (nonatomic ,assign)BOOL  passwordChangeForce;
@property (nonatomic ,assign)BOOL  devBindingForce;
@property (nonatomic ,strong)NSDictionary *uiSkin;

@end

#pragma mark - data -

@interface CMPLoginData: CMPObject
@property (nonatomic ,copy)NSString * ticket;
@property (nonatomic ,copy)NSString * statisticId;
@property (nonatomic ,strong)CMPLoginResponseCurrentMember * currentMember;
@property (nonatomic ,strong)CMPLoginResponseConfig * config;
@property (nonatomic ,copy)NSString * serverIdentifier;
@end

@interface CMPLoginResponse : CMPBaseResponse
@property (nonatomic ,strong)CMPLoginData * data;
- (BOOL)requestSuccess;
@end


