//
//  SyHandWriteSignatureViewController.m
//  M1IPhone
//
//  Created by guoyl on 13-5-7.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#define kActionSheetTag_Signature   100
#define kSyAlertPromptTag           3000

#import "SyHandWriteSignatureViewController.h"
#import "SyHandWriteSignatureView.h"
#import "CMPDataProvider.h"
#import "CMPDataRequest.h"
#import "CMPDataResponse.h"
#import "CMPCore.h"
#import "CMPGlobleManager.h"

@interface SyHandWriteSignatureViewController ()<UIActionSheetDelegate, CMPDataProviderDelegate> {
    SyHandWriteSignatureView *_handWriteSignatureView;
}

@property (nonatomic, retain) NSArray *signatureList;
@property (nonnull, copy)NSString *requestMSignatureListID;
@property (nonnull, copy)NSString *requestMSignatureStrID;
@property (nonatomic, retain) NSDictionary *selectedMSignature;

- (void)requestMSignatureList;
- (void)requestMSignatureStrWithPassWord:(NSString *)aPassword;
- (void)showInputPwdView;
- (void)showSignatureList;

@end

@implementation SyHandWriteSignatureViewController

- (void)dealloc
{
    [_signatureList release];
    [_requestMSignatureListID release];
    [_requestMSignatureStrID release];
    
    [_selectedMSignature release];
    [_signatureListUrl release];
    [_signaturePicUrl release];
    
    [_affairId release];
    
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    _handWriteSignatureView = (SyHandWriteSignatureView *)self.mainView;
    [_handWriteSignatureView setupWithInitSize:self.initSize];
    [_handWriteSignatureView.bottomSegControl addTarget:self action:@selector(segControlValueChange:) forControlEvents:UIControlEventValueChanged];
    self.backBarButtonItemHidden = NO;
    self.title = SY_STRING(@"Common_HandWrite");
    UIButton *doneButton = [UIButton transparentButtonWithFrame:CGRectMake(0, 0, 50, 35) title:SY_STRING(@"common_finshed")];
    [doneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:doneButton, nil]];
    _handWriteSignatureView.signatureButtonHidden = NO;
    [self requestMSignatureList];
}

- (void)segControlValueChange:(id)sender
{
    NSInteger selectedSegmentIndex = _handWriteSignatureView.bottomSegControl.selectedSegmentIndex;
    SySegmentedItem *aItem = [_handWriteSignatureView.bottomSegControl segmentedItemAtIndex:selectedSegmentIndex];
    if (selectedSegmentIndex == 0) {
        [_handWriteSignatureView showColorPickerView:nil];
    }
    else if (selectedSegmentIndex == 1) {
        [_handWriteSignatureView.handWriteView deleteText];
    }
    else if (selectedSegmentIndex == 2) {
        [_handWriteSignatureView clear];
    }
    else {
        if (aItem.tag == kSegmentedItemTag_DeleteSignatureButton) {
            [_handWriteSignatureView deleteSignatureImage];
        }
        else if (aItem.tag == kSegmentedItemTag_SignatureButton) {
            [self showSignatureList];
        }
    }
}

- (void)backBarButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handWriteSignatureViewControllerDidCancel:)]) {
        [self.delegate handWriteSignatureViewControllerDidCancel:self];
    }
}

- (void)doneButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(handWriteSignatureViewControllerDidFinished:result:signatureName:)]) {
        UIImage *aImage = [_handWriteSignatureView.handWriteView getScreenImage];
        if (!aImage) {
            [self showToastWithText:SY_STRING(@"Common_PlisInput")];
            return;
        }
        [self.delegate handWriteSignatureViewControllerDidFinished:self result:aImage signatureName:nil];
    }
}

#pragma -mark request data
- (void)requestMSignatureList
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = self.signatureListUrl;//[aStr stringByAppendingString:@"/rest/signet/signets"];
    aDataRequest.delegate = self;
    self.requestMSignatureListID = aDataRequest.requestID;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (void)requestMSignatureStrWithPassWord:(NSString *)aPassword
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = self.signaturePicUrl;//[aStr stringByAppendingString:@"/rest/signet/signetPic"];
    aDataRequest.delegate = self;
    self.requestMSignatureStrID = aDataRequest.requestID;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    NSString *markName = [self.selectedMSignature objectForKey:@"markName"];
    NSString *signatureID = [self.selectedMSignature objectForKey:@"id"];
    if (!_affairId) {
        _affairId = @"";
    }
    NSDictionary *aParamDict = [NSDictionary dictionaryWithObjectsAndKeys:aPassword, @"password", markName, @"markName", signatureID, @"signatureID", _affairId, @"affairId", nil];
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (void)showSignatureList
{
    if (self.signatureList.count ==0) {
        [self showToastWithText:SY_STRING(@"coll_nosignature")];
        return;
    }
    UIActionSheet *anActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                 destructiveButtonTitle:nil 
                                                      otherButtonTitles:nil];
    
    for (NSDictionary *aSignatureDict in self.signatureList) {
        NSString *aMarkName = [aSignatureDict objectForKey:@"markName"];
        [anActionSheet addButtonWithTitle:aMarkName];
    }
    [anActionSheet addButtonWithTitle:SY_STRING(@"common_cancel")];
	anActionSheet.cancelButtonIndex = anActionSheet.numberOfButtons - 1;
	anActionSheet.tag = kActionSheetTag_Signature;
	[anActionSheet showInView:self.view];	
	[anActionSheet release];
}

- (void)showInputPwdView
{
    UIAlertView *psdAlert =[[UIAlertView alloc] initWithTitle:SY_STRING(@"Common_InputSealPassWord") message:nil delegate:self cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:SY_STRING(@"common_ok"), nil];
	psdAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    psdAlert.tag = kSyAlertPromptTag;
    [psdAlert show];
    [psdAlert release];
}

#pragma -mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kActionSheetTag_Signature) {
        if (buttonIndex < self.signatureList.count) {
            self.selectedMSignature = [self.signatureList objectAtIndex:buttonIndex];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self showInputPwdView];
            });
        }
    }
}

#pragma -mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSyAlertPromptTag) {
		UITextField *aTextField = [alertView textFieldAtIndex:0];
        [aTextField resignFirstResponder];
        if (buttonIndex == 1) {
            NSString *pwd = aTextField.text;
            if (![NSString isNull:pwd]) {
                [self requestMSignatureStrWithPassWord:pwd];
            }
            else {
                [self showToastWithText:SY_STRING(@"Common_PassWordNONull")];
            }
        }
    }
}

/*
#pragma -mark SyBaseBizDelegate
- (void)bizDidStartLoad:(SyBaseBiz *)aBiz
{
    [self showLoadingView];
}

- (void)bizDidFinishLoad:(SyBaseBiz *)aBiz
{
    [self hideLoadingView];
    if (_getMSignatureListBiz == aBiz) {
        SyGetMSignatureListBiz *biz = (SyGetMSignatureListBiz *)aBiz;
        self.signatureList = biz.signatureList;
		_handWriteSignatureView.signatureButtonHidden = ![SyCore sharedSyCore].loginResult.hasSignetures;
//        if (self.signatureList.count == 0) {
//        }
//        else {
//            _handWriteSignatureView.signatureButtonHidden = NO;
//        }
    }
    else if (_getMSignatureBiz == aBiz) {
        SyGetMSignatureBiz *biz = (SyGetMSignatureBiz *)aBiz;
        [_handWriteSignatureView addSignatureImageWithBase64Str:biz.valueStr];
    }
}

- (void)biz:(SyBaseBiz *)aBiz didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
}*/


#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSString *aStr = aResponse.responseStr;
    NSString *aRequestID = aRequest.requestID;
    if (aRequestID == self.requestMSignatureListID) {
        self.signatureList = [aStr JSONValue];
        _handWriteSignatureView.signatureButtonHidden = self.signatureList.count == 0;
    }
    else if (aRequestID == self.requestMSignatureStrID) {
        if ([aStr isEqualToString:@"false"]) {
            [self showToastWithText:SY_STRING(@"Common_PasswordWrong")];
            return;
        }
        aStr = [aStr replaceCharacter:@"\"" withString:@""];
        [_handWriteSignatureView addSignatureImageWithBase64Str:aStr];
    }
}

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
//    NSString *aCallBackId = (NSString *)aRequest.userInfo;
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.domain];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
}


@end
