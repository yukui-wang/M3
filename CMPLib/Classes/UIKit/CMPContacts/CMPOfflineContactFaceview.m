//
//  CMPOfflineContactFaceview.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import "CMPOfflineContactFaceview.h"
#import "CMPConstant.h"
//@implementation CMPOfflineContactFaceview
//
//- (id)init
//{
//    if (self = [super init]) {
//        self.backgroundColor = [UIColor redColor];
//        self.textColor = [UIColor whiteColor];
//        self.textAlignment = NSTextAlignmentCenter;
//        self.layer.cornerRadius = 20;
//        self.layer.masksToBounds = YES;
//        self.font = FONTSYS(14);
//    }
//    return self;
//}
//- (void)layoutText:(NSString *)text {
//    if ([NSString isNull:text]) {
//        self.text = @"";
//        return;
//    }
//    if (text.length <3) {
//        self.text = text;
//    }
//    else {
//        if ([self IsChinese:text]) {
//            NSString *s = [text substringFromIndex:text.length -2];
//            self.text = s;
//        }
//        else {
//            NSString *s = [text substringToIndex:2];
//            self.text = s;
//        }
//    }
//}
//
//- (void)layoutBKColorWithIndex:(NSInteger)index
//{
//    NSInteger i = index%10;
////    按顺序：1.E95A4C     2.4098E6   3.A47566   4.D57171    5.BFA587
////    6.8A8A8A    7.F7B55E    8.F2725E    9.568AAD     10.4DA9EB
//    switch (i) {
//        case 0:
//            self.backgroundColor = UIColorFromRGB(0xE95A4C);
//            break;
//        case 1:
//            self.backgroundColor = UIColorFromRGB(0x4098E6);
//            break;
//        case 2:
//            self.backgroundColor = UIColorFromRGB(0xA47566);
//            break;
//        case 3:
//            self.backgroundColor = UIColorFromRGB(0xD57171);
//            break;
//        case 4:
//            self.backgroundColor = UIColorFromRGB(0xBFA587);
//            break;
//        case 5:
//            self.backgroundColor = UIColorFromRGB(0x8A8A8A);
//            break;
//        case 6:
//            self.backgroundColor = UIColorFromRGB(0xF7B55E);
//            break;
//        case 7:
//            self.backgroundColor = UIColorFromRGB(0xF2725E);
//            break;
//        case 8:
//            self.backgroundColor = UIColorFromRGB(0x568AAD);
//            break;
//        case 9:
//            self.backgroundColor = UIColorFromRGB(0x4DA9EB);
//            break;
//        default:
//            break;
//    }
//
//}
//
//-(BOOL)IsChinese:(NSString *)str {
//    for(int i=0; i< [str length];i++){
//        int a = [str characterAtIndex:i];
//        if( a > 0x4e00 && a < 0x9fff) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//@end

@implementation CMPOfflineContactFaceview



- (void)setup
{
    [super setup];
    self.loadImageLazily = YES;
    faceImgView_.circularColor = [UIColor whiteColor];
}

- (void)setMemberId:(NSString *)memberId
{
    if ([NSString isNull:memberId]) {
        _memberId = nil;
        self.memberIcon = nil;
    }
    else if (![_memberId isEqualToString:memberId]) {
        _memberId = [memberId copy];
        SyFaceDownloadObj *memberIcon = [[SyFaceDownloadObj alloc] init];
        memberIcon.memberId = memberId;
        memberIcon.serverId = [CMPCore sharedInstance].serverID;
        memberIcon.downloadUrl = [CMPCore memberIconUrlWithId:_memberId];
        self.memberIcon = memberIcon;
    }
}
@end
