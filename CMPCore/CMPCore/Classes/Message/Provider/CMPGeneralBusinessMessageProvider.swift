//
//  CMPGeneralBusinessMessageProvider.swift
//  M3
//
//  Created by 程昆 on 2019/11/8.
//

@objc class CMPGeneralBusinessMessageProvider: CMPObject,CMPDataProviderDelegate {
    static var sendMessagtUrl = "/rest/uc/rong/appcard/send";
    static var getQuickProcesstUrl = "/rest/uc/rong/quickprocess";
    
    @objc func sendBusinessMessage(param:NSDictionary,receiverIds:String,success:@escaping (_ messageId:String,_ data:Any) -> Void,fail:@escaping (_ error:NSError,_ messageId:String) -> Void) {
        let pramaDic =  NSMutableDictionary.init(dictionary: param)
        pramaDic["receiverIds"] = receiverIds;
        
        let dataRequest = CMPDataRequest()
//        dataRequest.requestUrl = CMPCore.sharedInstance().serverurl + CMPGeneralBusinessMessageProvider.sendMessagtUrl
        dataRequest.requestUrl = CMPCore.fullUrl(forPath: CMPGeneralBusinessMessageProvider.sendMessagtUrl)
        dataRequest.delegate = self
        dataRequest.requestMethod = kRequestMethodType_POST
        dataRequest.requestType = Int(kDataRequestType_Url)
        dataRequest.requestParam = pramaDic.jsonRepresentation() as NSObject
        dataRequest.userInfo = [:]
        dataRequest.userInfo["messageId"] = pramaDic["id"];
        dataRequest.userInfo["successClosure"] = success
        dataRequest.userInfo["failClosure"] = fail
        CMPDataProvider.sharedInstance()?.add(dataRequest)
    }
    
    @objc func getQuickProcess(id:String,messageCategory:String,success:@escaping (_ messageId:String,_ data:Any) -> Void,fail:@escaping (_ error:NSError,_ messageId:String) -> Void) {
        let pramaDic =  NSMutableDictionary()
        pramaDic["id"] = id;
        pramaDic["messageCategory"] = messageCategory;
        
        let dataRequest = CMPDataRequest()
//        dataRequest.requestUrl = CMPCore.sharedInstance().serverurl + CMPGeneralBusinessMessageProvider.getQuickProcesstUrl + "/" + id + "/" + messageCategory
        dataRequest.requestUrl = CMPCore.fullUrl(forPath:CMPGeneralBusinessMessageProvider.getQuickProcesstUrl)+"/" + id + "/" + messageCategory
        dataRequest.delegate = self
        dataRequest.requestMethod = kRequestMethodType_GET
        dataRequest.requestType = Int(kDataRequestType_Url)
        dataRequest.userInfo = [:]
        dataRequest.userInfo["messageId"] = id;
        dataRequest.userInfo["successClosure"] = success
        dataRequest.userInfo["failClosure"] = fail
        CMPDataProvider.sharedInstance()?.add(dataRequest)
    }
    
    @objc func quickProcess(param:NSDictionary,success:@escaping (_ messageId:String,_ data:Any) -> Void,fail:@escaping (_ error:NSError,_ messageId:String) -> Void) {
        let dataRequest = CMPDataRequest()
        dataRequest.requestUrl = CMPCore.fullUrl(forPath:CMPGeneralBusinessMessageProvider.getQuickProcesstUrl)
        dataRequest.delegate = self
        dataRequest.requestMethod = kRequestMethodType_POST
        dataRequest.requestType = Int(kDataRequestType_Url)
        dataRequest.requestParam = param.jsonRepresentation() as NSObject
        dataRequest.userInfo = [:]
        dataRequest.userInfo["messageId"] = "";
        dataRequest.userInfo["successClosure"] = success
        dataRequest.userInfo["failClosure"] = fail
        CMPDataProvider.sharedInstance()?.add(dataRequest)
    }
    
    func providerDidFinishLoad(_ aProvider: CMPDataProvider!, request aRequest: CMPDataRequest!, response aResponse: CMPDataResponse!) {
        let userInfo = aRequest.userInfo
        let messageId = userInfo?["messageId"] as? String;
        let data = (aResponse.responseStr as NSString).jsonValue() ?? ""
        if let successClosure = userInfo?["successClosure"] as? (String,Any) -> Void {
            if let aMessageId = messageId {
                successClosure(aMessageId,data)
            } else {
                successClosure("",data)
            }
            
        }
    }
    
    func provider(_ aProvider: CMPDataProvider!, request aRequest: CMPDataRequest!, didFailLoadWithError error: Error!) {
        let userInfo = aRequest.userInfo
        let messageId = userInfo?["messageId"] as! String;
        if let failClosure = userInfo?["failClosure"] as? (NSError,String) -> Void {
            failClosure(error as NSError,messageId)
        }
    }
}
