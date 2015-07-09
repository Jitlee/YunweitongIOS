//
//  ChangePhotoTableViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/27.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChangePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ImageSize: CGFloat = 96.0

    override var preferredContentSize: CGSize {
        get {
            return CGSizeMake(250,88)
        }
        set { super.preferredContentSize = newValue }
    }
    
    // 从摄像头
    @IBAction func pickFromCamera(sender: UIButton) {
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
    @IBAction func pickFromAlbum(sender: UIButton) {
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
        self.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let newImage = imageWidthNewSize(image, scaledToSize: CGSizeMake(ImageSize,ImageSize))
            notificationWithImageChange(newImage)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imageWidthNewSize(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        let originSize = image.size
        var strechWidth: CGFloat = newSize.width
        var strechHeight: CGFloat = newSize.height
        if originSize.height / originSize.width > newSize.height / newSize.width {
            // 以宽度为准
            strechHeight = originSize.height * strechWidth / originSize.width
        } else {
            // 以高度度为准
            strechWidth = originSize.width * strechHeight / originSize.height
        }
        let x = (newSize.width - strechWidth) * 0.5
        let y = (newSize.height - strechHeight) * 0.5
        
        UIGraphicsBeginImageContext(newSize);
        image.drawInRect(CGRectMake(x, y, strechWidth, strechHeight))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func notificationWithImageChange(image: UIImage) {
        let center = NSNotificationCenter.defaultCenter()
        let delegateObject = self.popoverPresentationController?.delegate
        let notification = NSNotification(name: KeyConfig.PickerImageInfo, object: delegateObject, userInfo: [KeyConfig.PickerImageInfoKey: image])
        center.postNotification(notification)
    }
}
