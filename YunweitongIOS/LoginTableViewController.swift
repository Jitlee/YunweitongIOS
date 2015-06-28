//
//  LoginViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/22.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class LoginTableViewController: UITableViewController {

    @IBOutlet weak var userNameTextFiled: UITextField!
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private var userName: String {
        return userNameTextFiled.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var password: String {
        return passwordTextFiled.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var deviceUUID: String {
        return UIDevice.currentDevice().identifierForVendor.UUIDString
    }
    
    private var systemVersion: String {
        return UIDevice.currentDevice().systemVersion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: UIButton) {
        login()
    }
    
    private func login() {
        if(!validate()) {
            return
        }
        
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let parameters = [
            "action": "login",
            "q0": userName,
            "q1": password,
            "q2": deviceUUID,
            "q3": systemVersion,
            "q4": "Apple"
        ]
        
        self.view.makeToastActivityWithMessage(message: "请稍候...")
        loginButton.enabled = false
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {
                (req, res, data, error) in
                self.view.hideToastActivity()
                self.loginButton.enabled = true
                if error != nil {
                    self.view.makeToast(message: "网络错误")
                } else {
                    let json = JSON(data!)
                    if !json.isEmpty {
                        if json["Status"].boolValue {
                            self.view.makeToast(message: "登录成功")
                            self.saveUserInfo(json["ResultObject"]) // 保存当前登陆用户信息
                            self.setCurrentUiserID(json["ResultObject"]["ID"].string!)
                            let userType = json["ResultObject"]["UserType"].int
                            var isPerfect:Bool = false
                            if userType == 10 {
                                let company = json["ResultObject"]["Company"].string!
                                isPerfect = !company.isEmpty
                            } else {
                                let realName = json["ResultObject"]["RealName"].string!
                                isPerfect = !realName.isEmpty
                            }
                            
                            if isPerfect {
                                // 开启定位功能
                                var app = UIApplication.sharedApplication().delegate as! AppDelegate
                                app.startUpdatingLocation()
                                // 进入主界面
                                self.performSegueWithIdentifier(IdentifyConfig.Home, sender: nil)
                            } else {
                                // 进入资料完善界面
                                self.performSegueWithIdentifier(IdentifyConfig.Perfect, sender: nil)
                            }
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    private func validate() -> Bool{
        let regex = RegexUtil()
        var userName = self.userName
        var password = self.password
        if(!regex.isPhoneNumber(userName)) {
            self.view.makeToast(message: "请输入有效的手机号码")
            return false
        } else if password.isEmpty {
            self.view.makeToast(message: "请输入密码")
            return false
        }
        
        return true
    }
    @IBAction func forget(sender: UIButton) {
        self.view.makeToast(message: "功能还未开发，敬请期待...")
    }

}
