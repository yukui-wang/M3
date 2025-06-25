//
//  CMPAutoSignDataProvider.swift
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/9.
//

import Foundation

class CMPAutoSignDataProvider:CMPBaseDataProvider{
    
    func fetchSignConfig(result:@escaping (_ respObj:Any?,_ error:NSError?,_ ext:Any?) -> Void) {

        let dataRequest = CMPDataRequest()
        dataRequest.requestUrl = CMPCore.fullUrl(forPath: "/rest/attendance/checkNowAutoSignConfig")
        dataRequest.delegate = self
        dataRequest.requestMethod = kRequestMethodType_GET
        dataRequest.requestType = Int(kDataRequestType_Url)
        dataRequest.userInfo = [:]
        dataRequest.userInfo["completion"] = result
        CMPDataProvider.sharedInstance()?.add(dataRequest)
    }
    
    func signInByLbs(params:NSDictionary,result:@escaping (_ respObj:Any?,_ error:NSError?,_ ext:Any?) -> Void){
        let dataRequest = CMPDataRequest()
        dataRequest.requestUrl = CMPCore.fullUrl(forPath:"/rest/attendance/save/m3")
        dataRequest.delegate = self
        dataRequest.requestMethod = kRequestMethodType_POST
        dataRequest.requestType = Int(kDataRequestType_Url)
        dataRequest.requestParam = params.jsonRepresentation() as NSObject
        dataRequest.userInfo = [:]
        dataRequest.userInfo["completion"] = result
        CMPDataProvider.sharedInstance()?.add(dataRequest)
    }
    
    override func providerDidFinishLoad(_ aProvider: CMPDataProvider!, request aRequest: CMPDataRequest!, response aResponse: CMPDataResponse!) {
        let userInfo = aRequest.userInfo
        let completion = userInfo?["completion"] as? (Any?,NSError?,Any?) -> Void
        if completion != nil {
            let respObj = ((aResponse.responseStr as NSString).jsonValue()) as? [String:Any?]
            completion!(respObj?["data"] ?? nil,nil,respObj ?? [:])
        }
    }
    
    override func provider(_ aProvider: CMPDataProvider!, request aRequest: CMPDataRequest!, didFailLoadWithError error: Error!) {
        let userInfo = aRequest.userInfo
        if let completion = userInfo?["completion"] as? (Any?,NSError?,Any?) -> Void {
            completion(nil,error as NSError,nil)
        }
    }
}
