//
//  CloudTableViewControllerType.swift
//  CloudTableViewController
//
//  Created by luojie on 16/3/1.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

protocol CloudTableViewControllerType: class, UIUpatable {
    
    // MARK: - Required
    typealias SectionStyle
    typealias CellStyle
    typealias DataController: CloudDataControllerType
    
    var canRefresh: Bool { get set }
    var multiPages: Bool { get set }
    var tableView: UITableView! { get set }
    
    func configureDataSourceAndDelegate()
}

extension CloudTableViewControllerType where Self: AnyObject {
    // MARK: - Helper
    
    func setupDataSourceAndDelegate() {
        
        dataSourceAndDelegate.tableView = tableView
        configureDataSourceAndDelegate()
        enableRefreshIfNeeded()
        
    }
    
    func enableRefreshIfNeeded() {
        
        if canRefresh {
            dataSourceAndDelegate.mjRefreshClosure = {
                [unowned self] in
                self.refreshData()
            }
        }
        
        if multiPages {
            dataSourceAndDelegate.mjGetMoreDataClosure = {
                [unowned self] in
                self.getMoreData()
            }
        }
        
        dataController.refreshIndicator = tableView.mj_header
        dataController.getMoreDataIndicator = tableView.mj_footer
        
    }
    
    func refreshData() {
        dataController.getDataInBackground(
            didGet: { [weak self] in
                self?.updateUI()
            }
        )
        updateUI()
    }
    
    func getMoreData() {
        dataController.getMoreDataInBackground(
            didGet: { [weak self] in
                self?.updateUI()
            }
        )
    }
    
    // MARK: - Stored Properties

    var dataController: DataController {
        get {
            if let result = objc_getAssociatedObject(self, &AssociatedKeys.DataController) as? DataController {
                return result
            }
            let result = DataController()
            objc_setAssociatedObject(self, &AssociatedKeys.DataController, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return result
        }
        set { objc_setAssociatedObject(self, &AssociatedKeys.DataController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var dataSourceAndDelegate: MJRefreshDSAD<SectionStyle, CellStyle> {
        if let result = objc_getAssociatedObject(self, &AssociatedKeys.DataSourceAndDelegate) as? MJRefreshDSAD<SectionStyle, CellStyle> {
            return result
        }
        let result = MJRefreshDSAD<SectionStyle, CellStyle>()
        objc_setAssociatedObject(self, &AssociatedKeys.DataSourceAndDelegate, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return result
    }
    
    var canRefreshAssociatedValue: Bool {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.CanRefreshAssociatedValue) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.CanRefreshAssociatedValue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var multiPagesAssociatedValue: Bool {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.MultiPagesAssociatedValue) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.MultiPagesAssociatedValue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private struct AssociatedKeys {
    static var DataController = "dataController"
    static var DataSourceAndDelegate = "dataSourceAndDelegate"
    static var CanRefreshAssociatedValue = "canRefreshAssociatedValue"
    static var MultiPagesAssociatedValue = "multiPagesAssociatedValue"
}


