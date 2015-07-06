//
//  QRCodeViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/3.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // NSURL
        var currentID = self.getCurrentUserID()
        let url = NSURL(string: "")
        var qrCode = QRCode(url!)
        qrCodeImageView.image = qrCode?.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
