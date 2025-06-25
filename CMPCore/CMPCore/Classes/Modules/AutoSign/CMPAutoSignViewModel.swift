//
//  CMPAutoSignViewModel.swift
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/9.
//

import Foundation

class CMPAutoSignViewModel:CMPBaseViewModel {
    let dataProvider:CMPAutoSignDataProvider = CMPAutoSignDataProvider.init()
    var configModel:CMPAutoSignConfigModel = CMPAutoSignConfigModel.init()
    var wifiDataProvider:CMPWiFiClockInProvider?
    var locationManager:KSLocationManager?
    var connectedWifiMacAddress = ""
    
    func preCheckAutoSignState(rsltBlk: @escaping ((_ state: Int,_ resp:Any?,_ err:NSError?) -> Void)){
        self.dataProvider.fetchSignConfig(result: { respData, error, ext in
            if (respData != nil){
                self.configModel = CMPAutoSignConfigModel.yy_model(withJSON: respData!) ?? CMPAutoSignConfigModel.init()
                if "1" == self.configModel.auto {
                    rsltBlk(1,respData,nil)
                }else{
                    rsltBlk(0,nil,NSError.init(domain: "can not sign now", code: -1001))
                }
            }else{
                rsltBlk(0,nil,error)
            }
        })
    }
    
    func signIn(result:@escaping (_ signSuccess:Int, _ error:NSError?, _ ext:Any?) -> Void){
//        let canSignWifi:Bool = self._ifCanSignByWifi()
        
        let lbsReqAct:()-> Void = {
            self._signByLbs { signResp, signErr, ext in
                if (signErr == nil && signResp != nil){
                    result(1,nil,nil)
                    return
                }
                result(0,signErr,ext)
                return
            }
        }
        
//        if canSignWifi {
//            if wifiDataProvider == nil {
//                wifiDataProvider = CMPWiFiClockInProvider.init()
//            }
//            let localWifiInfo:Dictionary? = CMPWiFiUtil.connectedWifiInfo()
//            if localWifiInfo == nil || localWifiInfo?.values.count == 0 {
//                lbsReqAct()
//                return
//            }
//            let localWifiBssid:String = localWifiInfo![CMPWiFiInfoKeyBSSID] as! String
//            let localWifiSsid:String = localWifiInfo![CMPWiFiInfoKeySSID] as! String
//            wifiDataProvider!.clockIn(withSSID: localWifiSsid, bssid: localWifiBssid, clockInTime: self.configModel.fixTime, success: {resp in
//                if resp.code == "200" {
//                    result(1,nil,nil)
//                }else{
//                    lbsReqAct()
//                }
//            }, fail: { err in
//                lbsReqAct()
//            })
//
//        }else{
            lbsReqAct()
//        }
    }
    
    private func _ifCanSignByWifi() -> Bool{
        if self.configModel.wifi == nil || self.configModel.wifi!.count == 0 {
            return false
        }
        let localWifiInfo:Dictionary? = CMPWiFiUtil.connectedWifiInfo()
        if localWifiInfo == nil || localWifiInfo?.values.count == 0 {
            return false
        }
        let localWifiBssid:String = localWifiInfo![CMPWiFiInfoKeyBSSID] as! String
        connectedWifiMacAddress = localWifiBssid
        for wifi : Dictionary in self.configModel.wifi! {
            if wifi["macAddress"] as! String == localWifiBssid {
                return true
            }
        }
        return false
    }
    
    private func _signByLbs(signRslt:@escaping (_ signResp:Any?,_ signErr:NSError?,_ ext:Any?)->Void) -> Void{

        if !CLLocationManager.locationServicesEnabled() {
            signRslt(nil,NSError.init(domain: "no sys locate permission", code: -1),nil)
            return
        }
        
        var signSource = "0"
        var macAddr = ""
        if self._ifCanSignByWifi() {
            macAddr = self.connectedWifiMacAddress
            if macAddr.count > 0 {
                signSource = "3"
            }
        }
        if signSource == "0" {
            if self.configModel.lbs == nil || self.configModel.lbs?.count == 0 {
                signRslt(nil,NSError.init(domain: "no oa lbs config", code: -2),nil)
                return
            }
        }
        
        if locationManager == nil{
            locationManager = KSLocationManager.init()
        }
        locationManager?.requestOnceLocation(locateResult: { curLoc, locErr in
            
        }, reverseResult: { curPlace, curPlaceName, reverseErr in
            if (reverseErr != nil) {
                signRslt(nil,reverseErr as NSError?,nil)
                return
            }
            if (curPlace?.count == 0){
                signRslt(nil,NSError.init(domain: "locate error", code: -3),nil)
                return
            }
            
            let curLoc:CLPlacemark! = curPlace!.first
            if signSource == "0" {
                var isInScope = false;
                for aLbsConfg:Dictionary in self.configModel.lbs! {
                    let relLoc:CLLocation = CLLocation.init(latitude: Double(aLbsConfg["latitude"] as! Substring)!, longitude: Double(aLbsConfg["longitude"] as! Substring)!)
                    let inScope:Bool = CMPLBSHelper.isInCircleScope(curLoc.location, relLoc, Double(aLbsConfg["range"] as! Int))
                    if inScope {
                        isInScope = true
                        break
                    }
                }
                if isInScope {
                    signSource = "2"
                }
            }

            if signSource == "0" {
                signRslt(nil,NSError.init(domain: "no fit condition", code: -4),nil)
                return
            }
            var signParams = [
                "sign":curPlaceName,
                "source":signSource,
                "deviceId":SvUDIDTools.udid(),
                "type":self.configModel.signType,
                "latitude":"\(curLoc.location!.coordinate.latitude)",
                "longitude":"\(curLoc.location!.coordinate.longitude)",
                "continent":"",
                "macAddress":macAddr,
                "country":curLoc.country ?? "",
                "town":curLoc.subLocality ?? "",
                "street":curLoc.thoroughfare ?? "",
                "nearAddress":"",
                "fixTime":self.configModel.fixTime,
                "classType":self.configModel.classType,
                "workDown":false
            ] as [String : Any]
            
            var province = curLoc.administrativeArea
            if (province == nil || province == "") {
                province = curLoc.locality ?? ""
            }
            signParams["province"] = province
            
            var city = curLoc.locality
            if (city == nil || city == "") {
                city = curLoc.administrativeArea ?? ""
            }
            signParams["city"] = city
            
            let nowDate = Date()
            let timestamp = CLong(nowDate.timeIntervalSince1970)
            signParams["timestamp"] = "\(timestamp)"
            
            var nonce:String = "\(timestamp)" + "\(Int(arc4random())*1000)" + ""
            nonce = nonce.md5()
            signParams["nonce"] = nonce
            
            let signStr = curPlaceName
            let longitude = "\(curLoc.location!.coordinate.longitude)"
            let latitude = "\(curLoc.location!.coordinate.latitude)"
            let macAddr = ""
            var digitSign:String=signStr+longitude+latitude+macAddr+"\(timestamp)"+"\(nonce)"+""
            digitSign = digitSign.md5()
            signParams["digitSign"] = digitSign
            
            self.dataProvider.signInByLbs(params: signParams as NSDictionary) { respObj, error, ext in
                if error != nil {
                    signRslt(nil,error,nil)
                    return
                }
                if ext == nil {
                    signRslt(nil,NSError.init(domain: "response nil", code: -6),nil)
                    return
                }
                let xx = (ext as? Dictionary<String, Any>)!["success"]
                if let yy = xx {
                    if yy as! Bool == true {
                        signRslt(ext,nil,ext)
                        return
                    }
                }
                signRslt(nil,NSError.init(domain: "\(String(describing: (ext as? Dictionary<String, Any>)!["msg"]))", code: -5),ext)
                return
            }
        })
    }
}
