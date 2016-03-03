//
//  CloudTableViewControllerType.swift
//  CloudTableViewController
//
//  Created by luojie on 16/3/1.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

/**
 Usage:
 ```swift


class CloudTableViewController: UITableViewController, CloudTableViewControllerType {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSourceAndDelegate()
        refreshData()
    }
    
    // MARK: - Required
    
    typealias SectionStyle = DefaultSectionStyle
    
    @IBInspectable var canRefresh: Bool {
        get { return canRefreshAssociatedValue }
        set { canRefreshAssociatedValue = newValue }
    }
    
    @IBInspectable var multiPages: Bool {
        get { return multiPagesAssociatedValue }
        set { multiPagesAssociatedValue = newValue }
    }
    
    func configureDataSourceAndDelegate() {
        
        dataSourceAndDelegate.reuseIdentifierForCellStyle = { _ in
            return "cell"
        }
        
        dataSourceAndDelegate.configureCellForCellStyle = {
            cell, cellStyle in
            
            switch cellStyle {
            case .Basic(let text):
                cell.textLabel?.text = text
            }
        }
    }
    
    func updateUI() {
        dataSourceAndDelegate.sections = [Section(sectionStyle: .Section, cellStyles: dataController.data.map { .Basic($0) })]
    }
    
    enum CellStyle {
        case Basic(String)
    }
}
 
 ```
 */
protocol CloudTableViewControllerType: DataControllerVCType, DataSourceAndDelegateTVCType {
    
    // MARK: - Required
    
    var canRefresh: Bool { get set }
    var multiPages: Bool { get set }
    
}

extension CloudTableViewControllerType where Self: AnyObject {
    
    // MARK: - Helper
    
    func startup() {
        
        dataSourceAndDelegate.tableView = tableView
        configureDataSourceAndDelegate()
        enableRefreshIfNeeded()
        refreshData()
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
    

    
    func getMoreData() {
        dataController.getMoreDataInBackground(
            didGet: { [weak self] in
                self?.updateUI()
            }
        )
    }
    
    // MARK: - Stored Properties


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
    static var CanRefreshAssociatedValue = "canRefreshAssociatedValue"
    static var MultiPagesAssociatedValue = "multiPagesAssociatedValue"
}


