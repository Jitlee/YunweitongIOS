//
//  BaseUIViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/25.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit

// 基础视图控制器
extension UIViewController {
    
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
    
    func getCurrentUserID() -> String! {
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        return app.currentUserID
    }
    
    func setCurrentUiserID(id: String) {
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.currentUserID = id
    }
    
    private func saveFile(data: NSData, fileName: String) -> String? {
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true);
        if let dir = paths.first as? String {
            if !fileManager.fileExistsAtPath(dir) {
                var error: NSError?
                if !fileManager.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil, error: &error) {
                    println("\(error)")
                    return nil
                }
            }
            
            let filePath = dir.stringByAppendingPathComponent(fileName)
            if fileManager.createFileAtPath(filePath, contents: data, attributes: nil) {
                return filePath
            }
        }
        return nil
    }
}
