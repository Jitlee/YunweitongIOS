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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(IdentifyConfig.Management, forIndexPath: indexPath) as! UITableViewCell
        return cell
    }
    
    private func loadData() {
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let userID = self.getCurrentUserID()
        let parameters = [
            "action":"getsupuser",
            "q1": userID
        ]
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {
                (req, res, data, error) in
                
                if error != nil {
                    self.view.makeToast(message: "网络错误")
                } else {
                    let json = JSON(data!)
                    NSLog("\(json)")
                    if !json.isEmpty {
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
}
