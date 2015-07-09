//
//  CompanyAuthTableViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/7.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices

class AuthCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var data: JSON?
    private var row: Int!
    private var button: UIButton!
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
        
        let userInfo = self.getUserInfo()
        var type = "p"
        if userInfo["UserType"].int! == 10 {
            type = "e"
        }
        let parameters = [
            "action": "getcertifyfile",
            "q0": userID,
            "q1": type // P个人， E 运维商
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
            acc.action = picker
            acc.row = indexPath.row
            acc.imageTitle.text = data?[indexPath.row]["CertifyTypeName"].string!
            
            if let fileName = data?[indexPath.row]["FileName"].string {
                if let url = NSURL(string: "http://ritacc.net" + fileName) {
                    if let photoData = NSData(contentsOfURL: url) {
                        if let photoImage = UIImage(data: photoData) {
                            acc.imageButton.setBackgroundImage(photoImage, forState: .Normal)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.collectionView?.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func picker(row: Int, sender: UIButton) {
        self.row = row
        self.button = sender
        var alert = UIAlertController(
            title: "上传",
            message: "",
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        alert.addAction(UIAlertAction(
            title: "从相机获取",
            style: .Default) {
                (a) in
                self.pickFromCamera(sender)
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "从相册获取",
            style: .Default) {
                (a) in
                self.pickFromAlbum(sender)
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "取消",
            style: .Cancel) {
                (a) in
            }
        )
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // 从摄像头
    func pickFromCamera(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePickerControl = UIImagePickerController()
            imagePickerControl.delegate = self
            imagePickerControl.sourceType = UIImagePickerControllerSourceType.Camera
            imagePickerControl.mediaTypes = [kUTTypeImage]
            imagePickerControl.showsCameraControls = true
            self.presentViewController(imagePickerControl, animated: true, completion: nil)
        }
    }
    
    // 从相册
    func pickFromAlbum(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let imagePickerControl = UIImagePickerController()
            imagePickerControl.delegate = self
            imagePickerControl.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
            imagePickerControl.allowsEditing=true
            self.presentViewController(imagePickerControl, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(false, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            upImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    private func upImage(image: UIImage) {
        let imageData = UIImagePNGRepresentation(image)
        let userID = self.getCurrentUserID()
        let url = "http://ritacc.net/API/YWT_UPUserFile.ashx"
        let action = self.data?[self.row]["CertifyTypeCode"].string!
        let parameters:Dictionary<String, String!>  = [
            "action": action,
            "q0": userID,
            "q1": userID,
            "from": "IOS"
        ]
        let urlRequest = self.urlRequestWithComponents(url, parameters: parameters, imageData: imageData)
        self.view.makeToastActivity()
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .responseJSON {
                (req, res, data, error) in
                self.view.hideToastActivity()
                if error != nil {
                    println(error)
                    println(req)
                    println(res)
                    self.view.makeToast(message: "网络错误")
                } else {
                    let json = JSON(data!)
                    if !json.isEmpty {
                        self.button.setBackgroundImage(image, forState: .Normal)
                    }
                }
        }
    }
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String!>?, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "NET-POST-boundary-\(arc4random())-\(arc4random())";
        let contentType = "multipart/form-data;boundary=\(boundaryConstant)"
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\n--\(boundaryConstant)\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"uploadFile\"; filename=\"song.png\"\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\n\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        if let p = parameters {
            // add parameters
            for (key, value) in p {
                uploadData.appendData("\n--\(boundaryConstant)\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\n\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        uploadData.appendData("\n--\(boundaryConstant)--\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }

}
