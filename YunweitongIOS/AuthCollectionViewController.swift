//
//  CompanyAuthTableViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/7.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class AuthCollectionViewController: UICollectionViewController {

    private var data: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPictures()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadPictures() {
        let userID = self.getCurrentUserID()
        let url = "http://ritacc.net/API/YWT_User.ashx"
        let parameters = [
            "action": "getcertifyfile",
            "q0": userID,
            "q1": "e" // P个人， E 运维商
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
                            let r = json["ResultObject"]
                            println("\(r)")
                            self.data = json["ResultObject"]
                            self.collectionView?.reloadData()
                        } else {
                            self.view.makeToast(message: json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }
    
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return data == nil ? 0 : 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        if let d = data {
            return d.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("资质认证", forIndexPath: indexPath) as! UICollectionViewCell
        
        // Configure the cell
        if var acc = cell as? AuthCollectionViewCell {
            acc.imageTitle.text = data?[indexPath.row]["CertifyTypeName"].string!
        }
        
        return cell
    }
}
