//
//  CMPAutoSignManager.swift
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/9.
//

import PromiseKit
import Dispatch

class CMPAutoSignManager:CMPObject {
    
    static var aManager : CMPAutoSignManager?
    let viewModel:CMPAutoSignViewModel = CMPAutoSignViewModel.init()
    var window:UIWindow?
    
    @objc class func shareInstance() -> CMPAutoSignManager {
        if CMPAutoSignManager.aManager==nil {
            CMPAutoSignManager.aManager = CMPAutoSignManager.init()
        }
        return CMPAutoSignManager.aManager!
    }
    
    @objc class func serverVersionSupport() -> Bool {
        let _f = CMPServerVersionUtils.serverIsLaterV8_2()
        return _f
    }
    
    @objc func autoSignIn(result:@escaping (_ state: Int,_ resp:Any?,_ err:NSError?)->Void){
//        self._showAutoSignSuccessView()
        let r = CMPAutoSignManager.serverVersionSupport()
        if r == false {
            result(0,nil,NSError.init(domain: "server low", code: -1001))
            return
        }
        self.viewModel.preCheckAutoSignState { state_c, resp_c, err_c in
            if state_c == 0 {
                result(0,nil,err_c)
                return
            }
            self.viewModel.signIn { state_s, err_s, ext_s in
                if state_s == 1 {
                    self._showAutoSignSuccessView()
                }else{
                    result(0,nil,err_s)
                    NSLog("%@", err_s ?? "err nil")
                }
            }
        }
    }
    
    private func _showAutoSignSuccessView(){
        DispatchQueue.main.async {
            let aCtrl = CMPAutoSignViewController.init()
            aCtrl.fixTime = self.viewModel.configModel.fixTime
            aCtrl.signType = self.viewModel.configModel.signType
            aCtrl.didDismiss = {
                self.window?.rootViewController = nil
                self.window?.isHidden = true
                self.window = nil
                CMPHomeAlertManager.sharedInstance().taskDone()
                aCtrl.didDismiss = nil
            }
            self.window = UIWindow.init(frame: UIScreen.main.bounds)
            self.window?.rootViewController = aCtrl
            self.window?.windowLevel = UIWindow.Level.alert
            self.window?.makeKeyAndVisible()
            
            if CMPWiFiClockInHelper.responds(to: Selector(("_saveShowedState"))){
                CMPWiFiClockInHelper.perform(Selector(("_saveShowedState")))
            }
            
            if aCtrl.responds(to: Selector(("_hideClockInView"))){
                aCtrl.perform(Selector(("_hideClockInView")), with: nil, afterDelay: 5)
            }
        }
    }
    
}
