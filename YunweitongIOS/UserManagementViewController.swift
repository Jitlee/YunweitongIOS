//
//  UserManagementViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/4.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class UserManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    private var data = [String: [JSON]]()
    
    private let headers = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "*"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return Array(self.data.keys)
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var tpIndex:Int = 0
        let headers = self.data.keys.array
        //遍历索引值
        for character in headers{
            //判断索引值和组名称相等，返回组坐标
            if character == title {
                return tpIndex
            }
            tpIndex++
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count > 0 {
            let keys = Array(data.keys)
            let key = keys[section]
            return data[key]!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(IdentifyConfig.Management, forIndexPath: indexPath) as! UITableViewCell
        
        if let umvc = cell as? UserManagementTableViewCell {
            let item = self.getItemWithIndexPath(indexPath)
            umvc.nameLabel.text = item?["RealName"].string!
        }
        return cell
    }
    
    private func loadData() {
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let userID = self.getCurrentUserID()
        let parameters = [
            "action":"getsupuser",
            "q0": userID
        ]
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {
                (req, res, data, error) in
                println("\(req)")
                if error != nil {
                    self.view.makeToast(message: "网络错误")
                } else {
                    let json = JSON(data!)
                    println("\(json)")
                    if !json.isEmpty {
                        if json["Status"].boolValue {
                            self.sort(json["ResultObject"])
                            self.tableView.reloadData()
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    @IBAction func showMenu(sender: UIBarButtonItem) {
        showMenu()
    }
    
    private func showMenu() {
        var alert = UIAlertController(
            title: "",
            message: "",
            preferredStyle: .ActionSheet
        )
        alert.addAction(UIAlertAction(
            title: "扫一扫",
            style: .Default) {
                (a) in
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "新增",
            style: .Default) {
                (a) in
                self.performSegueWithIdentifier(IdentifyConfig.AddUser, sender: nil)
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "取消",
            style: .Cancel) {
                (a) in
            }
        )
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = menuButton
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let keys = Array(data.keys)
            let key = keys[indexPath.section]
            self.data[key]?.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    private func sort(data: JSON) {
        self.data["*"] = [JSON]()
        let end = data.count - 1
        for i in 0...end {
            self.data["*"]?.append(data[i])
        }
    }
    
    private func getItemWithIndexPath(indexPath: NSIndexPath) -> JSON? {
        let keys = self.data.keys.array
        let key = keys[indexPath.section]
        let item = self.data[key]?[indexPath.row]
        return item
    }
}
