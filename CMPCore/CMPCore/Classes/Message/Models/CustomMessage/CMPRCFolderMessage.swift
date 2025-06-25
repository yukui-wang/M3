//
//  CMPRCFolderMessage.swift
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/8/31.
//

//ks add 单纯是为了解决jira bug（V5-11391 致信端发送文件夹，用iOS端M3查看没有提示），兼容pc端，因为pc端是RC开头，不明白为什么不统一，也不敢轻易修改，所以兼容吧（但是pc判断什么消息类型不是通过objectname来判断的，是不是可以修改呢？？？）
class CMPRCFolderMessage: CMPFolderMessage {
    
    override class func getObjectName() -> String! {"RC:FolderMsg"}
}
