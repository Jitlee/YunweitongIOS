//
//  RegisterViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/22.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userNameTextFiled: UITextField!
    
    @IBOutlet weak var passwordTextFiled: UITextField!
    
    @IBOutlet weak var verifyTextField: UITextField!
    
    private var userName: String {
        return userNameTextFiled.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var password: String {
        return passwordTextFiled.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var verify: String {
        return verifyTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    @IBAction func register(sender: AnyObject) {
        register()
    }
    
    private func register() {
        if !validate() {
            return
        }
        
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let parameters = ["action": "reg",
            "q0": "{ \"Mobile\": \"\(userName)\", \"PassWord\": \"\(password)\"}"]
        
        self.view.makeToastActivityWithMessage(message: "请稍候...")
        registerButton.enabled = false
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {
            (req, res, data, error) in
            self.view.hideToastActivity()
            self.registerButton.enabled = true
            if error != nil {
                self.view.makeToast(message: "网络错误")
            } else {
                let json = JSON(data!)
                if !json.isEmpty {
                    if json["Status"].boolValue {
                        self.view.makeToast(message: "注册成功")
                        self.saveUserInfo(json["ResultObject"]) // 保存当前登陆用户信息
                        self.setCurrentUiserID(json["ResultObject"]["ID"].string!)
                        self.performSegueWithIdentifier(IdentifyConfig.Perfect, sender: nil)
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
        var verfiy = self.verify
        if !regex.isPhoneNumber(userName) {
            self.view.makeToast(message: "请输入有效的手机号码")
            return false
        } else if password.isEmpty {
            self.view.makeToast(message: "请输入密码")
            return false
        }else if verify != password {
            self.view.makeToast(message: "两次密码不一致")
            return false
        }
        
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
