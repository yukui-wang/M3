//
//  CMPOfflineContactMember.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import "CMPOfflineContactMember.h"

@implementation CMPOfflineContactMember

-(NSString *)orgID
{
    return [NSString isNotNull:_orgID] ? _orgID :@"";
}
-(NSString *)sort
{
    return [NSString isNotNull:_sort]  ? _sort :@"";
}
-(NSString *)name
{
    return [NSString isNotNull:_name] ? _name :@"";
}

-(NSString *)nameSpell
{
    return [NSString isNotNull:_nameSpell]  ? _nameSpell :@"";
}

-(NSString *)tel
{
    return [NSString isNotNull:_tel] ? _tel :@"";
}
-(NSString *)mobilePhone
{
    return [NSString isNotNull:_mobilePhone] ? _mobilePhone :@"";
}

-(NSString *)mail
{
    return [NSString isNotNull:_mail] ? _mail :@"";
}

-(NSString *)mark
{
    return [NSString isNotNull:_mark] ? _mark :@"";
}

-(NSString *)postName
{
    return  [NSString isNotNull:_postName] ? _postName :@"";
}


-(NSString *)department
{
    return [NSString isNotNull:_department] ? _department :@"";
}

-(NSString *)departmentId
{
    return [NSString isNotNull:_departmentId] ? _departmentId :@"";
}

-(NSString *)account
{
    return [NSString isNotNull:_account] ? _account :@"";
}
-(NSString *)accountId
{
    return [NSString isNotNull:_accountId] ? _accountId :@"";
}

-(NSString *)level
{
    return [NSString isNotNull:_level] ? _level :@"";
}

-(NSString *)levelId
{
    return [NSString isNotNull:_levelId] ? _levelId :@"";
}

-(NSString *)postId
{
    return [NSString isNotNull:_postId] ? _postId :@"";
}

- (NSString *)workAddr {
    return [NSString isNotNull:_workAddr] ? _workAddr : @"";
}

- (NSString *)wx {
    return [NSString isNotNull:_wx] ? _wx : @"";
}

- (NSString *)wb {
    return [NSString isNotNull:_wb] ? _wb : @"";
}

- (NSString *)homeAddr {
    return [NSString isNotNull:_homeAddr] ? _homeAddr : @"";
}

- (NSString *)port {
    return  [NSString isNotNull:_port] ? _port : @"";
}

- (NSString *)communicationAddr {
    return  [NSString isNotNull:_communicationAddr]  ? _communicationAddr : @"";
}

//手机号码是否可用
- (BOOL)mobilePhoneAvailable {
    NSString *phone = self.mobilePhone;
    if ([NSString isNull:phone] ||
        [phone isEqualToString:kContactMemberHideVaule] ) {
        return NO;
    }
    return YES;
}

@end
