//
//  CMPFolderMessage.swift
//  M3
//
//  Created by 程昆 on 2019/12/4.
//


class CMPFolderMessage: RCMessageContent {
    
    override class func getObjectName() -> String! {"OA:FolderMsg"}
    override class func persistentFlag() -> RCMessagePersistent {.MessagePersistent_ISCOUNTED}
    override func conversationDigest() -> String! {cmp_localizedString(key: "rc_msg_unknown_folder_tip")}

    @objc var title = ""
    @objc var content: NSString = ""
    @objc var chatContentId = ""
    @objc var extraData: Dictionary<String, Any>?
    
    override func encode() -> Data! {
        let dataDict:NSMutableDictionary = NSMutableDictionary.init()
        if let extraData = self.extraData  {
             dataDict["extraData"] = extraData;
        }
        dataDict["user"] = self.encode(self.senderUserInfo);
        let data = try! JSONSerialization.data(withJSONObject: dataDict)
        return data
    }
    override func decode(with data: Data!) {
        let dictionary = try? JSONSerialization.jsonObject(with: data)
        if let dic = dictionary as? Dictionary<String, Any> {
            let userinfoDic = dic["user"] as? [AnyHashable : Any] ?? [:]
            self.decodeUserInfo(userinfoDic)
        }
    }

}
