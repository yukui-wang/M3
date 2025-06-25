//
//  CMPAutoSignViewController.swift
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/9.
//

import Foundation
import UIKit

class CMPAutoSignViewController:CMPWiFiClockInViewController{
    
    var fixTime:String = ""
    var signType:String = ""
    
    override func viewDidLoad() {
        self.clockInSetting = CMPWiFiClockInSettingResponse.init()
        self.clockInSetting.clockInTime = fixTime
        
        super.viewDidLoad()
        var workTitle = "考勤时间"
        if signType == "1" {
            workTitle = NSLocalizedString("WiFiClockIn_clockInTime", comment: "")
        }else if signType == "2" {
            workTitle = NSLocalizedString("WiFiClockIn_clockOffTime", comment: "")
        }
        self.clockInView.workTimeLabel.text = workTitle + " " + fixTime
        self.clockInView.clockInButton.removeFromSuperview()
        self.clockInView.viewWithTag(111)?.removeFromSuperview()
        
        let signResultLb = UILabel.init()
        signResultLb.translatesAutoresizingMaskIntoConstraints = false
        signResultLb.textAlignment = NSTextAlignment.right
        signResultLb.font = UIFont.systemFont(ofSize: 17)
        signResultLb.textColor = UIColor.cmp_color(withName: "theme-fc")
        signResultLb.sizeToFit()
        self.clockInView.addSubview(signResultLb)
        
        let cons1:NSLayoutConstraint = NSLayoutConstraint (item: signResultLb, attribute: .right, relatedBy: .equal, toItem: self.clockInView, attribute: .right, multiplier: 1, constant: -25)
        let cons2:NSLayoutConstraint = NSLayoutConstraint (item: signResultLb, attribute: .centerY, relatedBy: .equal, toItem: self.clockInView.timeLabel, attribute: .centerY, multiplier: 1, constant: 0)
        
        let signResultLogo = UIImageView.init()
        signResultLogo.image = UIImage.init(named: "autoSignSuc")
        signResultLogo.translatesAutoresizingMaskIntoConstraints = false
        self.clockInView.addSubview(signResultLogo)
        
        let cons3:NSLayoutConstraint = NSLayoutConstraint (item: signResultLogo, attribute: .right, relatedBy: .equal, toItem: signResultLb, attribute: .left, multiplier: 1, constant: -0)
        let cons4:NSLayoutConstraint = NSLayoutConstraint (item: signResultLogo, attribute: .centerY, relatedBy: .equal, toItem: signResultLb, attribute: .centerY, multiplier: 1, constant: 0)
        self.clockInView.addConstraints([cons1,cons2,cons3,cons4])
        
        let cons5:NSLayoutConstraint = NSLayoutConstraint (item: signResultLogo, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 56)
        let cons6:NSLayoutConstraint = NSLayoutConstraint (item: signResultLogo, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 54)
        signResultLogo.addConstraints([cons5,cons6])
        
        signResultLb.text = "打卡成功!"
        
    }
    
    override func _refreshWifiName(){
        
    }
    
}
