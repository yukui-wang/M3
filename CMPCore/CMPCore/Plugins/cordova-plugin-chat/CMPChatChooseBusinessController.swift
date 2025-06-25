//
//  CMPChatChooseBusinessController.swift
//  M3
//
//  Created by 程昆 on 2019/11/4.
//

@objc protocol CMPChatChooseBusinessControllerDelegate {
    func didSelect(members: Array<Dictionary<String,Any>>)
    func didSelect(accdocsAndh5Apps: Array<Dictionary<String,Any>>)
}

@objc class CMPChatChooseBusinessController: CMPBannerWebViewController {
    
    @objc var type = "";
    @objc var appId:NSString? = nil
    @objc var max = 1
    
    @objc var delegate: CMPChatChooseBusinessControllerDelegate?

    override func viewDidLoad() {
        let url: NSString = "http://cmp/v1.0.0/page/cmp-im-select.html";
        let param : NSMutableDictionary = NSMutableDictionary.init()
        param["type"] = type;
        param["appId"] =  appId;
        if let appId = self.appId {
            param["appId"] =  appId;
        }
        param["max"] = max;
        let urlStr = url.urlCFEncoded() as String;
        let aUrl = URL(string: urlStr)
        let localHref = CMPCachedUrlParser.cachedPath(with: aUrl)
       
        self.closeButtonHidden = true;
        self.hideBannerNavBar = false;
        
        self.pageParam = ["url":localHref ?? "",
                          "param" : param]
        self.startPage = localHref;
        
        super.viewDidLoad()
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
