//
//  EditingFieldViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/1.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit

class EditingFieldViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var fieldName: String!
    var fieldLabel: String! {
        didSet {
            self.title = fieldLabel
        }
    }
    
    var fieldValue: String!
    
    private var value: String {
        return textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fieldValue != "未设置" {
            self.textField.text = fieldValue
        }
        self.textField.resignFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(sender: AnyObject) {
        save()
    }
    
    func save() {
        let center = NSNotificationCenter.defaultCenter()
        let delegateObject = self.parentViewController?.navigationController
        println("\(self.parentViewController?.navigationController?.presentedViewController)")
        let notification = NSNotification(
            name: KeyConfig.FieldChanged,
            object: delegateObject,
            userInfo: [
                KeyConfig.FieldChangedKey: fieldName,
                KeyConfig.FieldChangedValue: value
            ])
        center.postNotification(notification)
        self.parentViewController?.navigationController?.popViewControllerAnimated(true)
    }
}
