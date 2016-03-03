//
//  DataSourceAndDelegateTVCType.swift
//  CloudTableViewController
//
//  Created by luojie on 16/3/2.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

protocol DataSourceAndDelegateTVCType: UIUpatable {
    
    // MARK: - Required
    typealias SectionStyle
    typealias CellStyle
    
    var tableView: UITableView! { get set }
    
    func configureDataSourceAndDelegate()
    
}

extension DataSourceAndDelegateTVCType where Self: AnyObject {
    
    // MARK: - Helper
    
    func startup() {
        
        dataSourceAndDelegate.tableView = tableView
        configureDataSourceAndDelegate()
        updateUI()
    }
    
    // MARK: - Stored Properties
    
    var dataSourceAndDelegate: MJRefreshDSAD<SectionStyle, CellStyle> {
        if let result = objc_getAssociatedObject(self, &AssociatedKeys.DataSourceAndDelegate) as? MJRefreshDSAD<SectionStyle, CellStyle> {
            return result
        }
        let result = MJRefreshDSAD<SectionStyle, CellStyle>()
        objc_setAssociatedObject(self, &AssociatedKeys.DataSourceAndDelegate, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return result
    }
}


private struct AssociatedKeys {
    static var DataSourceAndDelegate = "dataSourceAndDelegate"
}