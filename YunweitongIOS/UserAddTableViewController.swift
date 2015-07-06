//
//  UserAddTableViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/5.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class UserAddTableViewController: UITableViewController {

    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    private var userType = 20
    
    private struct UserType {
        static let Yunwei: String = "运维人员"
        static let YunweiValue: Int = 20
        static let Diaodu: String = "调度人员"
        static let DiaoduValue: Int = 40
    }
    
    private var dateFormat: NSDateFormatter!
    
    private var phone: String {
        return phoneTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var password: String {
        return passwordTextField.text!
    }
    
    private var name: String {
        return nameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var email: String {
        return emailTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var sex: String {
        return sexLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private var birthday: Int64 {
        let timeInterval:Double = datePicker.date.timeIntervalSince1970
        return NSNumber(double: timeInterval).longLongValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.locale = NSLocale(localeIdentifier: "Chinese")
        datePicker.maximumDate = NSDate()
        dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
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
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let _userInfo: JSON = [
            "User": [
                "Mobile": phone,
                "Password": password
            ],
            "UserInfo": [
                "RealName": name,
                "Email": email,
                "User_Sex": sex,
                "Birthday": "/Date(\(birthday))/",
                "GraduationData": "/Date(2649600000)/",
                "Create_User": userID,
                "UserType": self.userType
            ]
        ]
        println("\(_userInfo)")
        let parameters = [
            "action": "addsupuser",
            "q0": "\(_userInfo)"
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
                        if json["Status"].boolValue {
                            self.view.makeToast(message: "提交成功")
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
    
    private func chooseSex() {
        var alert = UIAlertController(
            title: "性别",
            message: "",
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        alert.addAction(UIAlertAction(
            title: "男",
            style: .Default) {
                (a) in
                self.sexLabel.text = "男"
                self.sexLabel.textColor = self.view.tintColor
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "女",
            style: .Destructive) {
                (a) in
                self.sexLabel.text = "女"
                self.sexLabel.textColor = UIColor.redColor()
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "取消",
            style: .Cancel) {
                (a) in
            }
        )
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sexLabel
            popoverController.sourceRect = sexLabel.bounds
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func chooseType() {
        var alert = UIAlertController(
            title: "人员类型",
            message: "请选择以下任意一种类型",
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        alert.addAction(UIAlertAction(
            title: UserType.Yunwei,
            style: .Default) {
                (a) in
                self.sexLabel.text = UserType.Yunwei
                self.userType = UserType.YunweiValue
                self.sexLabel.textColor = self.view.tintColor
            }
        )
        
        alert.addAction(UIAlertAction(
            title: UserType.Diaodu,
            style: .Destructive) {
                (a) in
                self.sexLabel.text = UserType.Diaodu
                self.userType = UserType.DiaoduValue
                self.sexLabel.textColor = UIColor.redColor()
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "取消",
            style: .Cancel) {
                (a) in
            }
        )
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sexLabel
            popoverController.sourceRect = sexLabel.bounds
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        switch indexPath.section {
        case 1:
            chooseType()
        case 2:
            chooseSex()
        default:break
        }
    }
    
    @IBAction func datePicker(sender: UIDatePicker) {
        birthdayLabel.text = dateFormat.stringFromDate(sender.date)
    }

}
