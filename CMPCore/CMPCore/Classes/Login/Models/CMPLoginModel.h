//
//  CMPLoginModel.h
//  M3
//
//  Created by CRMO on 2017/11/3.
//

#import "CMPObject.h"
#import "CMPBaseResponse.h"

#pragma mark - currentMember -

@interface CurrentMember: CMPObject
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
@end

#pragma mark - config -

@interface Config: CMPObject
@property (nonatomic ,copy)NSString * allowUpdateAvatar;
@property (nonatomic ,assign)BOOL  passwordOvertime;
@property (nonatomic ,assign)BOOL  passwordStrong;
@end

#pragma mark - data -

@interface CMPLoginData: CMPObject
@property (nonatomic ,copy)NSString * ticket;
@property (nonatomic ,copy)NSString * statisticId;
@property (nonatomic ,strong)CurrentMember * currentMember;
@property (nonatomic ,strong)Config * config;
@property (nonatomic ,copy)NSString * serverIdentifier;
@end

@interface CMPLoginResponse : CMPBaseResponse
@property (nonatomic ,copy)NSString * code;
@property (nonatomic ,strong)CMPLoginData * data;
@property (nonatomic ,copy)NSString * time;
@property (nonatomic ,copy)NSString * message;
@property (nonatomic ,copy)NSString * version;

- (BOOL)requestSuccess;
@end


