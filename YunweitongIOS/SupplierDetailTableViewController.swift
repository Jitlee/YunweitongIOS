//
//  SupplierDetailTableViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/29.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

// 运维商详细控制视图
class SupplierDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var faxLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    private struct Field {
        static let Photo: String = "Photo"
        static let Name: String =  "Company"
        static let Contact: String = "ContactMan"
        static let Phone: String = "Mobile"
        static let Tel: String = "Tel"
        static let Email: String = "Email"
        static let Fax: String = "Fax"
        static let Address: String = "Address"
    }
    
    private let FieldLabelMap = [
        Field.Name: "公司名称",
        Field.Email: "电子邮箱",
        Field.Address: "公司地址",
        Field.Contact: "联系人",
        Field.Fax: "传真",
        Field.Phone: "联系人手机",
        Field.Tel: "联系电话"
    ]
    
    private var fieldMap: [String: UILabel]!
    private var userID: String!
    private var id: String!
    private var isInfoModified: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fieldMap = [
            Field.Name: nameLabel,
            Field.Address: addressLabel,
            Field.Contact: contactLabel,
            Field.Email: emailLabel,
            Field.Fax: faxLabel,
            Field.Phone: phoneLabel,
            Field.Tel: telLabel
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
        self.userID = userInfo["ID"].string!
        if !userInfo[Field.Name].string!.isEmpty {
            nameLabel.text = userInfo[Field.Name].string
        }
        if let photoData = self.getFile("user.png") {
            photoButton.setBackgroundImage(UIImage(data: photoData), forState: .Normal)
        }
        
        let url = "http://ritacc.net/API/YWT_Supplier.ashx"
        let parameters = [
            "action": "get",
            "q0": userInfo["SupplierID"].string!
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
                            self.id = json["ResultObject"]["ID"].string!
                            self.rendererInfo(json["ResultObject"])
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    private func rendererInfo(json: JSON) {
        if nil != json[Field.Contact].string && !json[Field.Contact].string!.isEmpty {
            contactLabel.text = json[Field.Contact].string
        }
        
        if nil != json[Field.Address].string && !json[Field.Address].string!.isEmpty {
            addressLabel.text = json[Field.Address].string
        }
        if nil != json[Field.Email].string && !json[Field.Email].string!.isEmpty {
            emailLabel.text = json[Field.Email].string
        }
        if nil != json[Field.Tel].string && !json[Field.Tel].string!.isEmpty {
            telLabel.text = json[Field.Tel].string
        }
        if nil != json[Field.Phone].string && !json[Field.Phone].string!.isEmpty {
            phoneLabel.text = json[Field.Phone].string
        }
        if nil != json[Field.Fax].string && !json[Field.Fax].string!.isEmpty {
            faxLabel.text = json[Field.Fax].string
        }
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
        } else if indexPath.section == 1 && indexPath.row == 0 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Contact)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Phone)
        } else if indexPath.section == 2 && indexPath.row == 0 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Tel)
        } else if indexPath.section == 2 && indexPath.row == 1 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Email)
        } else if indexPath.section == 2 && indexPath.row == 2 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Fax)
        } else if indexPath.section == 2 && indexPath.row == 3 {
            performSegueWithIdentifier(IdentifyConfig.FieldEdit, sender: Field.Address)
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
        
        let url = "http://ritacc.net/API/YWT_Supplier.ashx"
        let info = getInfo()
        let parameters = [
            "action": "addupdate",
            "q0": "\(JSON(info))",
            "q1": userID
        ]
        self.view.makeToastActivity()
        NSLog("\(parameters)")
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
        result["ID"] = self.id
        return result
    }
}
