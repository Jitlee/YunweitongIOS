//
//  RegexUtil.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/23.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import Foundation

// 常用正则表达式
struct RegexUtil {
    
    // 手机号码
    let phone: String = "^((13[0-9])|(15[012356789])|(17[678])|(18[0-9])|(14[57]))[0-9]{8}$"
    
    func isPhoneNumber(text: String) -> Bool {
        return text =~ phone
    }
}