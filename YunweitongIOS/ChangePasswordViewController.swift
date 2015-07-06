//
//  ChangePasswordViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/6.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var oldPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(sender: UIBarButtonItem) {
        submit()
    }
    
    
    private func submit() {
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let userID = self.getCurrentUserID()
        let oldPassword = oldPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        let parameters = [
            "action": "alertpwd",
            "q0": userID,
            "q1": oldPassword,  // 旧密码
            "q2": newPassword // 新密码
        ]
        self.view.makeToastActivity()
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {
                (req, res, data, error) in
                self.view.hideToastActivity()
                if error != nil {
                    self.view.makeToast(message: "网络错误")
                } else {
                    let json = JSON(data!)
                    if !json.isEmpty {
                        if json["Status"].boolValue {
                            self.view.makeToast(message: "修改成功")
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }

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
