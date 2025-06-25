//
//  CMPMemberInfoToLocalPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/27.
//
//

#import "CMPTelPlugin.h"
#import "AppDelegate.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import "SyQRCodeController.h"
#import "CMPScanWebViewController.h"
#import <ContactsUI/CNContactViewController.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
@interface  CMPTelPlugin ()<CNContactViewControllerDelegate>
@property (nonatomic, copy)NSString *callbackId;
@property (nonatomic, strong)NSDictionary *paramDict;

@end

@implementation CMPTelPlugin
- (void)dealloc
{
    self.callbackId = nil;
    self.paramDict = nil;
}
- (void)syncToLocal:(CDVInvokedUrlCommand*)command
{
    
    self.callbackId = command.callbackId;
    self.paramDict = [[command arguments] firstObject];
    /*查看是否有权限，没有获取权限*/
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status != CNAuthorizationStatusAuthorized) {
        __weak typeof(self) weakSelf = self;
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 授权成功
                dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf addNewContact];
                });
            } else {
                // 授权失败
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:31001], @"code", @"保存失败", @"message",@"",@"detail", nil];
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
                [weakSelf.commandDelegate sendPluginResult:result callbackId:self.callbackId];
                
                NSString *app_Name = [[NSBundle mainBundle]
                                                           objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                                    NSString *message = [NSString stringWithFormat:SY_STRING(@"Contact_Permisson_Setting"),app_Name];
                                    [CMPDevicePermissionHelper showAlertWithTitle:SY_STRING(@"Contact_Unavailable_title") messsage:message];
            }
        }];
    } else {
        //已经授权过
        [self addNewContact];
    }
}

- (void)addNewContact {
    if ([self.viewController isKindOfClass:[CMPTabBarViewController class]]) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf addNewContactView];
        });
    }
    else {
        [self addNewContactView];
    }
}

- (void)addNewContactView API_AVAILABLE(ios(9.0)) {
    //1.创建Contact对象，必须是可变的
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    //2.为contact赋值，我这里是最简单的，setValueWithContact中会给出常用值的对应关系
    [self setValueWithContact:contact];
    //3.创建新建好友页面
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
    //代理内容根据自己需要实现
    controller.delegate = self;
    //4.跳转
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    
    navigation.navigationBar.tintColor = [UIColor blackColor];
    
    [self.viewController presentViewController:navigation animated:YES completion:nil];
       [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ABNewPersonViewWillShow object:nil];
}
- (void)setValueWithContact:(CNMutableContact *)contact API_AVAILABLE(ios(9.0)) {
    contact.familyName = [self.paramDict objectForKey:@"name"];;
    NSString *aMobilePhone = [self.paramDict objectForKey:@"mobilePhone"];
    NSString *aOfficePhone = [self.paramDict objectForKey:@"officePhone"];
    NSString *email = [self.paramDict objectForKey:@"email"];
    aMobilePhone = [self checkNull:aMobilePhone];
    aOfficePhone = [self checkNull:aOfficePhone];
    email = [self checkNull:email];
    NSString *imageData = [self.paramDict objectForKey:@"imageData"];
    imageData = [self checkNull:imageData];
    if (imageData && imageData.length >0) {
        // base64 to NSData
        NSURL  *imageURL = [NSURL URLWithString:imageData];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        contact.imageData = data;
    }
    else {
        NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"guesture.bundle/ic_def_person.png"]);
        contact.imageData = data;
    }
    NSMutableArray *phoneNumbers = [NSMutableArray array];
    if (aMobilePhone) {
        CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:aMobilePhone]];
        [phoneNumbers addObject:phoneNumber];
        
    }
    if (aOfficePhone) {
        CNLabeledValue *tel = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMain value:[CNPhoneNumber phoneNumberWithStringValue:aOfficePhone]];
        [phoneNumbers addObject:tel];
    }
    if (phoneNumbers.count > 0) {
        contact.phoneNumbers = phoneNumbers;
    }
    if (email) {
        CNLabeledValue *mail = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:email];
        contact.emailAddresses = @[mail];
    }
}
//该协议是在创建新的名片界面点击取消或者确定后的回调
- (void)contactViewController:(CNContactViewController *)contactViewController didCompleteWithContact:(nullable CNContact *)contact  API_AVAILABLE(ios(9.0)) {
    CDVPluginResult *result = nil;
    if (contact) {
        result =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    }else {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:31001], @"code", @"保存失败", @"message",@"",@"detail", nil];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];

    //[viewController dismissViewControllerAnimated:YES completion:nil];
    UIViewController * presentingViewController = contactViewController.presentingViewController;
    while (presentingViewController.presentingViewController) {
        presentingViewController = presentingViewController.presentingViewController;
    }
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ABNewPersonViewWillHide object:nil];

}

- (NSString *)checkNull:(NSString *)string
{
    if (!string ) {
        return nil;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    if ([string.lowercaseString isEqualToString:@"null"]||[string.lowercaseString isEqualToString:@"<null>"] ) {
        return nil;
    }
    if ([string isEqualToString:@""]) {
        return nil;
    }
    return string;
}

@end
