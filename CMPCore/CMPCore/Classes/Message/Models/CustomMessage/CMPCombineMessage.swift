//
//  CMPCombineMessage.swift
//  M3
//
//  Created by 程昆 on 2019/11/5.
//

import UIKit

func cmp_localizedString(key:String ) -> String {
    return Bundle.main.localizedString(forKey: key, value:nil ,table: nil )
}

class CMPCombineMessage: RCMessageContent {
    
    override class func getObjectName() -> String! {"OA:MergeTransmitMsg"}
    override class func persistentFlag() -> RCMessagePersistent {.MessagePersistent_ISCOUNTED}
    override func conversationDigest() -> String! {cmp_localizedString(key: "rc_msg_combine_vard")}

    @objc var title = ""
    @objc var content: NSString = ""
    @objc var chatContentId = ""
    @objc var extraData: Dictionary<String, Any>?
    @objc var contentModels: [ContentModel] {
        get {
            var models:[ContentModel] = []
            let contents = content.jsonValue() as? [[String:Any]] ?? []
            for dic in contents {
                let model = ContentModel()
                model.type = dic["type"] as? String ?? ContentType.text.rawValue
                model.content = dic["content"] as? NSString ?? ""
                model.deCodeContent = model.content.emojiDecode() ?? (model.content as String)
                model.externalId = dic["externalId"] as? String
                model.createDate = dic["createDate"] as? String ?? ""
                model.creatorId = dic["creatorId"] as? String ?? ""
                model.creatorName = dic["creatorName"] as? String ?? ""
                models.append(model)
            }
            return models
        }
    }
    
    override func encode() -> Data! {
        let dataDict:NSMutableDictionary = NSMutableDictionary.init()
        dataDict["title"] = self.title;
        dataDict["content"] = self.content;
        dataDict["chatContentId"] = self.chatContentId;
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
            self.title = dic["title"] as? String ?? ""
            self.content = dic["content"] as? NSString ?? ""
            self.chatContentId = dic["chatContentId"] as? String ?? ""
            self.extraData = dic["extraData"] as? Dictionary<String, Any>
            let userinfoDic = dic["user"] as? [AnyHashable : Any] ?? [:]
            self.decodeUserInfo(userinfoDic)
        }
    }
    
    enum ContentType: String {
        case text,image,file
    }
    
    @objc class ContentModel: NSObject {
       @objc var type = ContentType.text.rawValue
       @objc var content :NSString = ""
       @objc var deCodeContent = ""
       @objc var externalId: String?
       @objc var createDate = ""
       @objc var creatorId = ""
       @objc var creatorName = ""
    }
}
