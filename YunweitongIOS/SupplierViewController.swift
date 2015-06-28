//
//  SupplierViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/24.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

// 供应商视图控制器
class SupplierViewController: ResponsiveTextFieldViewController {

    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var cotactTextField: UITextField!
    @IBOutlet weak var mobilePhoneTextField: UITextField!
    @IBOutlet weak var telphoneNumberTextField: UITextField!
    @IBOutlet weak var faxTextField: UITextField!
    @IBOutlet weak var companyAddressTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private var companyName:String {
        return companyNameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var contact:String {
        return cotactTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var mobilePhone:String {
        return mobilePhoneTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var telphoneNumber:String {
        return telphoneNumberTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var email:String {
        return emailTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var fax:String {
        return faxTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var companyAddress:String {
        return companyAddressTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        var userInfo = self.getUserInfo()
        let userID = userInfo["ID"].string!
        
        //println("\(userInfo)")
        
        let url = "http://ritacc.net/API/YWT_Supplier.ashx"
        let companyInfo: JSON = [
            "ID": "",
            "Company": companyName,
            "ContactMan": contact,
            "Address": companyAddress,
            "Tel": telphoneNumber,
            "Mobile": mobilePhone,
            "Fax": fax,
            "Email": email
        ]
        let parameters = [
            "action": "addupdate",
            "q0": "\(companyInfo)",
            "q1": userID
        ]
        
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
                        //println("\(json)")
                        if json["Status"].boolValue {
                            self.view.makeToast(message: "提交成功")
                            userInfo["UserType"].int = 10
                            userInfo["Company"].string = companyInfo["Company"].string
                            userInfo["SupplierID"].string = json["ResultObject"].string!
                            self.saveUserInfo(userInfo)
                            // 开启定位功能
                            var app = UIApplication.sharedApplication().delegate as! AppDelegate
                            app.startUpdatingLocation()
                            self.performSegueWithIdentifier(IdentifyConfig.Home, sender: nil)
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    private func validate() -> Bool{
        let regex = RegexUtil()
        if companyName.isEmpty {
            self.view.makeToast(message: "请输入公司名称")
            return false
        } else if contact.isEmpty{
            self.view.makeToast(message: "请输入联系人")
            return false
        } else if !regex.isPhoneNumber(mobilePhone) {
            self.view.makeToast(message: "请输入有效的联系人手机号码")
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
