//
//  Regex.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/23.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import Foundation

struct Regex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        var error: NSError?
        regex = NSRegularExpression(pattern: pattern,
            options: .CaseInsensitive,
            error: &error)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matchesInString(input,
            options: nil,
            range: NSMakeRange(0, count(input))) {
                return matches.count > 0
        } else {
            return false
        }
    }
}

infix operator =~ {
    associativity none
    precedence 130
}

func =~(lhs: String, rhs: String) -> Bool {
    return Regex(rhs).match(lhs)
}