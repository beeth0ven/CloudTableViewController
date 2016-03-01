//
//  DataController.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation


extension CloudTableViewController {
    
    class DataController: CloudDataControllerType {
        
        let maxPage = 3
        
        var data = [String]()

        // MARK: - Required

        var refreshApi: String { return "getDataInBackground" }
        
        func parse(dic: [String : AnyObject]) {
            data = (0..<10).map(String.init)
            
            isLastPage = currentPage == maxPage
        }
        
        required init() {}
        
        // MARK: - Optional

        var getMoreDataApi: String { return "getMoreDataInBackground" }

        func parseMore(dic: [String : AnyObject]) {
            let moreData = (0..<10).map { (currentPage - 1) * 10 + $0 }.map(String.init)
            data += moreData
            
            isLastPage = currentPage == maxPage
        }
        
        func removeData() {
            data.removeAll(keepCapacity: true)
        }
    }
}
