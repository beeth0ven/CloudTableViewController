//
//  Request.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation

struct Request {
    
    static func post(api api: String, params: [String: AnyObject]? = nil, didGet: (Result) -> Void) {
        Queue.Main.executeAfter(seconds: 2, closure: {
            didGet(.Success([:]))
        })
    }
}

enum Result {
    case Success([String : AnyObject]), Failure
}