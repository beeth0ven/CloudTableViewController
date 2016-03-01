//
//  CloudTableViewController.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

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