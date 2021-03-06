//
//  AuthCollectionViewCell.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/7/7.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit

class AuthCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageTitle: UILabel!
    var action: ((row: Int, sender: UIButton)->Void)?
    var row: Int = 0
    @IBAction func pick(sender: UIButton) {
        if nil != action {
            action!(row: row, sender: sender)
        }
    }
}
