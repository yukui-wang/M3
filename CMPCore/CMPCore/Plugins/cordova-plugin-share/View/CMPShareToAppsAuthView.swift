//
//  CMPShareToAppsAuthView.swift
//  M3
//
//  Created by MacBook on 2019/12/2.
//

import UIKit

@objcMembers class CMPShareToAppsAuthView: UIView {
    
    private let kSeparatorLineThin: CGFloat = 0.5
    private let kBottomViewH: CGFloat = 54.0
    
    var showTitleString: String?
    var btn1Title: String?
    var btn2Title: String?
    
    var selectedCheckBox: CMPCheckBoxView?
    var cofirmClickedClosure: ((Int)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cmp_setCornerRadius(6.0)
        backgroundColor = UIColor.cmp_color(withName: "white-bg1")
        
        configViews()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configViews() {
        
        var selfH: CGFloat = 160.0
        self.cmp_height = selfH
        
        let tipsLabelTitle = showTitleString == nil ? "share_auth_tips_string".localizeString : showTitleString!
        let tipsLabelH = tipsLabelTitle.cmp_heightForComment(fontSize: 17.0, width: self.width - 56.0)
        if tipsLabelH - 21.0 > 0 {
            selfH = 160.0 + tipsLabelH - 21.0
            self.cmp_height = selfH
            self.cmp_y = (UIScreen.main.bounds.size.height - selfH)/2.0
        }
        
        //底部view
        let bottomView = UIView(frame: CGRect(x: 0, y: selfH - kBottomViewH, width: width, height: kBottomViewH))
        bottomView.backgroundColor = UIColor.clear
        self.addSubview(bottomView)
        //垂直割线
        let verticalSeparator = UIView(frame: CGRect(x: 0, y: 0, width: kSeparatorLineThin, height: 22.0))
        verticalSeparator.center = CGPoint(x: width/2.0, y: bottomView.height/2.0)
        verticalSeparator.backgroundColor = UIColor.cmp_color(withName: "cmp-bdc")
        bottomView.addSubview(verticalSeparator)
        //取消
        let btnW = (width - kSeparatorLineThin)/2.0
        let cancelLabel = UILabel(frame: CGRect(x: 0, y: 0, width: btnW, height: bottomView.height))
        cancelLabel.textColor = UIColor.cmp_color(withName: "desc-fc")
        cancelLabel.font = UIFont.systemFont(ofSize: 16.0)
        cancelLabel.text = "common_cancel".localizeString
        cancelLabel.textAlignment = .center
        bottomView.addSubview(cancelLabel)
        //确定按钮
        let confirmBtn = UIButton(frame: CGRect(x: verticalSeparator.frame.maxX, y: 0, width: btnW, height: cancelLabel.height))
        confirmBtn.setTitle("common_ok".localizeString, for: .normal)
        confirmBtn.setTitleColor(UIColor.cmp_color(withName: "theme-bdc"), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        confirmBtn.addTarget(self, action: #selector(confirmClicked), for: .touchUpInside)
        bottomView.addSubview(confirmBtn)
        
        //水平分割线
        let horizonSeparator = UIView(frame: CGRect(x: 0, y: bottomView.frame.minY, width: width, height: kSeparatorLineThin))
        horizonSeparator.backgroundColor = verticalSeparator.backgroundColor
        self.addSubview(horizonSeparator)
        
        
        //上部view
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: horizonSeparator.frame.minY))
        topView.backgroundColor = UIColor.clear
        self.addSubview(topView)
        
        let topCover = UIButton(frame: topView.bounds)
        topCover.backgroundColor = UIColor.clear
        topView.addSubview(topCover)
        
        
        let tipslabelX: CGFloat = 38.0
        //提示文字label
        let tipsLabel = UILabel(frame: CGRect(x: tipslabelX, y: 0, width: topView.width - 56.0, height: topView.height/2.0))
        tipsLabel.numberOfLines = 0
        tipsLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        tipsLabel.textAlignment = .left
        tipsLabel.text = tipsLabelTitle
        tipsLabel.cmp_height = tipsLabelH
        tipsLabel.cmp_y = 30
        tipsLabel.textColor = UIColor.cmp_color(withName: "main-fc")
        topView.addSubview(tipsLabel)
        //允许 按钮
        let allowBtnTitle = btn1Title == nil ? "share_auth_btn_allow".localizeString : btn1Title!
        let allowBtnW = allowBtnTitle.cmp_widthForComment(fontSize: 16.0) + 20.0
        let allowBtn = CMPCheckBoxView(frame: CGRect(x: tipslabelX, y: tipsLabel.frame.maxY + 10.0, width: allowBtnW, height: 25.0))
        allowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        allowBtn.setTitle(allowBtnTitle, for: .normal)
        topView.addSubview(allowBtn)
        allowBtn.isSelected = false
        allowBtn.addTarget(self, action: #selector(stateClicked), for: .touchUpInside)
        allowBtn.tag = 1
        allowBtn.setTitleColor(UIColor.cmp_color(withName: "sup-fc1"), for: .normal)
        
        //不允许 按钮
        let notallowBtnTitle = btn2Title == nil ? "share_auth_btn_notallow".localizeString : btn2Title!
        let notallowBtnW = notallowBtnTitle.cmp_widthForComment(fontSize: 16.0) + 16.0
        let notallowBtn = CMPCheckBoxView(frame: CGRect(x: allowBtn.frame.maxX + 10.0, y: allowBtn.cmp_y, width: notallowBtnW, height: allowBtn.height))
        notallowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        notallowBtn.setTitle(notallowBtnTitle, for: .normal)
        topView.addSubview(notallowBtn)
        notallowBtn.isSelected = true
        notallowBtn.addTarget(self, action: #selector(stateClicked), for: .touchUpInside)
        notallowBtn.tag = 0
        notallowBtn.setTitleColor(UIColor.cmp_color(withName: "sup-fc1"), for: .normal)
        
        selectedCheckBox = notallowBtn
        
    }
    
    //MARK:- 按钮点击
    @objc func confirmClicked() {
        if cofirmClickedClosure != nil {
            cofirmClickedClosure!(selectedCheckBox?.tag ?? 0)
        }
    }
    
    @objc func stateClicked(sender: CMPCheckBoxView?) {
        selectedCheckBox?.isSelected = false
        selectedCheckBox = sender
        selectedCheckBox?.isSelected = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews {
            view .removeFromSuperview()
        }
        
        configViews()
    }
    
}
