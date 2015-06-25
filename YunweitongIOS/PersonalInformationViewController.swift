//
//  PersonalInformationTableViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/23.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class PersonalInformationViewController: BaseUIViewController {
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    
    private var name: String {
        return nameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submit(sender: AnyObject) {
        submit()
    }
    
    private func submit() {
        if !validate() {
            return
        }
        
        //let userInfo = self.getUserInfo()
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let parameters = ["action": "edit",
            "q0": "{ \"RealName\": \"\(name)\""]
        
        self.view.makeToastActivityWithMessage(message: "请稍候...")
        self.submitButton.enabled = false
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {
                (req, res, data, error) in
                self.view.hideToastActivity()
                self.submitButton.enabled = true
                if error != nil {
                    self.view.makeToast(message: "网络错误")
                } else {
                    let json = JSON(data!)
                    if !json.isEmpty {
                        if json["Status"].boolValue {
                            self.view.makeToast(message: "提交成功")
                            self.performSegueWithIdentifier(IdentifyConfig.Home, sender: nil)
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    private func validate() -> Bool {
        if name.isEmpty {
            self.view.makeToast(message: "请输入真实姓名")
            return false
        }
        return true
    }
}
