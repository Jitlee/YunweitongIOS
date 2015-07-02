//
//  PersonalDetailTableViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/29.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

// 个人资料详情控制试图
class PersonalDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var specialtyNameLabel: UILabel!
    @IBOutlet weak var graduationTimeLabel: UILabel!
    
    @IBOutlet weak var skillLabel: UILabel!
    @IBOutlet weak var specialtyLabel: UILabel!
    
    private struct Field {
        static let Name: String = "RealName"
        static let Sex: String = "User_Sex"
        static let Phone: String = "Mobile"
        static let Birthday: String = "Birthday"
        static let Email: String = "Email"
        static let Province: String = "Location_Province"
        static let City: String = "Location_City"
        static let County: String = "Location_County"
        static let Address: String = "User_Adress"
        static let Education: String = "HighestEducation"
        static let School: String = "Finish_School"
        static let SpecialtyName: String = "SpecialtyName"
        static let GraduationTime: String = "GraduationData"
        static let Skill: String = "SkillDescription"
        static let Specialty: String = "Specialty"
    }
    private let FieldLabelMap = [
        Field.Name: "姓名",
        Field.Email: "电子邮箱",
        Field.Address: "地址",
        Field.Education: "最高学历",
        Field.School: "毕业院校",
        Field.SpecialtyName: "专业名称",
        Field.Skill: "技能详情",
        Field.Specialty: "专长",
    ]
    private var fieldMap: [String: UILabel]!
    private var userID: String!
    private var id: String!
    private var isInfoModified: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fieldMap = [
            Field.Name: nameLabel,
            Field.Sex: sexLabel,
            Field.Email: emailLabel,
            Field.Address: addressLabel,
            Field.Education: educationLabel,
            Field.School: schoolLabel,
            Field.SpecialtyName: specialtyNameLabel,
            Field.Skill: skillLabel,
            Field.Specialty: specialtyLabel,
        ]

        
        loadInfo()
        
        startNotifaction()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadInfo() {
        let userInfo = self.getUserInfo()
        userID = userInfo["ID"].string!
        if !userInfo["RealName"].string!.isEmpty {
            nameLabel.text = userInfo["RealName"].string
        }
        if !userInfo["Mobile"].string!.isEmpty {
            phoneLabel.text = userInfo["Mobile"].string
        }
        
        let url = "http://ritacc.net/API/YWT_UserInfo.ashx"
        let parameters = [
            "action": "get",
            "q0": userID
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
                            self.id = json["ResultObject"]["YWTUser_ID"].string!
                            self.rendererInfo(json["ResultObject"])
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    private func rendererInfo(json: JSON) {
        if nil != json[Field.Sex].string && !json[Field.Sex].string!.isEmpty {
            sexLabel.text = json[Field.Sex].string
        }
        
        if nil != json[Field.Birthday].string && !json[Field.Birthday].string!.isEmpty {
            birthdayLabel.text = self.formatJSONDate(json[Field.Birthday].string!)
        }
        if nil != json[Field.Email].string &&  !json[Field.Email].string!.isEmpty {
            emailLabel.text = json[Field.Email].string
        }
        if !json[Field.Province].string!.isEmpty
            || !json[Field.City].string!.isEmpty
            || !json[Field.County].string!.isEmpty {
            areaLabel.text = json[Field.Province].string!
                + json[Field.City].string!
                + json[Field.County].string!
        }
        if nil != json[Field.Address].string &&  !json[Field.Address].string!.isEmpty {
            addressLabel.text = json[Field.Address].string
        }
        
        if nil != json[Field.Education].string &&  !json[Field.Education].string!.isEmpty {
            educationLabel.text = json[Field.Education].string
        }
        if nil != json[Field.School].string &&  !json[Field.School].string!.isEmpty {
            schoolLabel.text = json[Field.School].string
        }
        if nil != json[Field.SpecialtyName].string &&  !json[Field.SpecialtyName].string!.isEmpty {
            specialtyNameLabel.text = json[Field.SpecialtyName].string
        }
        if nil != json[Field.GraduationTime].string &&  !json[Field.GraduationTime].string!.isEmpty {
            graduationTimeLabel.text = self.formatJSONDate(json[Field.GraduationTime].string!)
        }
        
        if nil != json[Field.Specialty].string &&  !json[Field.Specialty].string!.isEmpty {
            specialtyLabel.text = json[Field.Specialty].string
        }
        if nil != json[Field.Skill].string &&  !json[Field.Skill].string!.isEmpty {
            graduationTimeLabel.text = json[Field.Skill].string
        }
    }
    
    private func formatJSONDate(jsonDateString: String) -> String {
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy年M月d日"
        let intervalString = jsonDateString.stringByReplacingOccurrencesOfString("/Date(", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString(")/", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        let interval = NSNumberFormatter().numberFromString(intervalString)?.doubleValue
        let date = NSDate(timeIntervalSince1970: interval! / 1000)
        return dateFormat.stringFromDate(date)
    }
    
    private func startNotifaction() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        center.addObserverForName(KeyConfig.FieldChanged, object: self.navigationController, queue: queue) { notification in
            if let key = notification?.userInfo?[KeyConfig.FieldChangedKey] as? String {
                if let value = notification?.userInfo?[KeyConfig.FieldChangedValue] as? String {
                    self.fieldMap[key]?.text = value
                    self.isInfoModified = true
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section == 0 && indexPath.row == 0 {
            
        } else if indexPath.section == 0 && indexPath.row == 1 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Name)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Email)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identify = segue.identifier {
            switch identify {
            case IdentifyConfig.FieldEdit:
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let tvc = nav.topViewController as? EditingFieldViewController {
                        if let key = sender as? String {
                            tvc.fieldName = key
                            tvc.fieldLabel = self.FieldLabelMap[key]
                            tvc.fieldValue = self.fieldMap[key]?.text
                        }
                    }
                }
            default: break
            }
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        if isInfoModified {
            saveInfo()
        }
    }
    
    private func saveInfo() {
        
        let url = "http://ritacc.net/API/YWT_UserInfo.ashx"
        let info = getInfo()
        let parameters = [
            "action": "addupdate",
            "q0": "\(JSON(info))",
            "q1": userID
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
                            self.isInfoModified = false
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    private func getInfo() -> [String: String] {
        var result = [String: String]()
        for (k, l) in fieldMap {
            result[k] = l.text!
        }
        result[Field.GraduationTime] = "/Date(1435849383)/"
        result[Field.Birthday] = "/Date(1435849383)/"
        
        result["YWTUser_ID"] = userID
        return result
    }
}
