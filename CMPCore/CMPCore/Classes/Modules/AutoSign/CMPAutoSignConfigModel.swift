//
//  CMPAutoSignCOnfigModel.swift
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/9.
//

import Foundation

class CMPSignInfoLBSModel:CMPObject {
    @objc var lid:String = ""
    @objc var railName:String = ""
    @objc var alias:String = ""
    @objc var longitude:String = ""
    @objc var latitude:String = ""
    @objc var range:Float = 200.0
    @objc var mapProvider:Int = 0
}

class CMPAutoSignConfigModel:CMPObject {
    @objc var auto:String = "0"
    @objc var signType:String = "1"
    @objc var lbs:Array<Dictionary<String, Any>>?
    @objc var wifi:Array<Dictionary<String, Any>>?
    @objc var fixTime:String = ""
    @objc var classType:String = "0"//签到班次类型
}
