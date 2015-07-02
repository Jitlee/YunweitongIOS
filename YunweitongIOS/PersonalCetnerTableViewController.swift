//
//  PersonalCetnerUIViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/27.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

class PersonalCetnerTableViewController:  UITableViewController, UIPopoverPresentationControllerDelegate {
    
    private var userInfo: JSON!
    
    override func viewDidLoad() {
        photoCell.selectionStyle = UITableViewCellSelectionStyle.None
        initUserInfo()
        initPhotoManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - 头像处理
    @IBOutlet weak var photoCell: UITableViewCell!
    @IBOutlet weak var photoButton: UIButton!
    
    private func initPhotoManager() {
        // 从服务器下载头像
        if let url = NSURL(string: "http://ritacc.net" + userInfo["UserImg"].string!) {
            if let photoData = NSData(contentsOfURL: url) {
                if let photoImage = UIImage(data: photoData) {
                    self.photoButton.setBackgroundImage(photoImage, forState: .Normal)
                    self.saveFile(photoData, fileName: "user.png")
                }
            }
        }
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        center.addObserverForName(KeyConfig.PickerImageInfo, object: self, queue: queue) { notification in
            if let image = notification?.userInfo?[KeyConfig.PickerImageInfoKey] as? UIImage {
                
                
                let imageData = UIImagePNGRepresentation(image)
                let userID = self.getCurrentUserID()
                let url = "http://ritacc.net/API/YWT_UPFile.ashx"
                let parameters:Dictionary<String, String>  = [
                    "action": "userimg",
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
                                //if json["Status"].boolValue {
                                    self.photoButton.setBackgroundImage(image, forState: UIControlState.Normal)
                                //} else {
                                  //  self.view.makeToast(message: json["ReturnMsg"].string!)
                                //}
                            }
                        }
                }
                
            }
        }

    }
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>?, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
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
    
    // MARK: -名称
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    private func initUserInfo() {
        userInfo = self.getUserInfo()
        switch userInfo["UserType"].int! {
            case 10:
                userTypeLabel.text = "供应商"
                nameLabel.text = userInfo["Company"].string
            default:
                userTypeLabel.text = "运维人员"
                nameLabel.text = userInfo["RealName"].string
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identify = segue.identifier {
            switch identify {
            case IdentifyConfig.ChangePhoto:
                if let tvc = segue.destinationViewController as? ChangePhotoViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                }
            default:
                break
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            if userTypeLabel.text == "供应商" {
                performSegueWithIdentifier(IdentifyConfig.SupplierDetail, sender: self)
            } else {
                performSegueWithIdentifier(IdentifyConfig.PersonalDetail, sender: self)
            }
        }
    }
}
