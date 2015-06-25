//
//  BaseUIViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/25.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit

// 基础视图控制器
class BaseUIViewController: UIViewController {
    
    func saveUserInfo(json: JSON) {
        let data: AnyObject = "\(json)" as AnyObject
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(data, forKey: KeyConfig.UserInfo)
    }
    
    func getUserInfo() -> JSON {
        let defaults = NSUserDefaults.standardUserDefaults()
        let data: AnyObject? = defaults.objectForKey(KeyConfig.UserInfo)
        let jsonString: String = data as! String
        let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return JSON(data: dataFromString!)
    }
}
