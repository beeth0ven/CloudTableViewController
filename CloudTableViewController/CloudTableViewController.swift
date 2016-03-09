//
//  CloudTableViewController.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

class CloudTableViewController: UITableViewController {

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        startup()
    }
    
  }

extension CloudTableViewController: CloudTableViewControllerType {
    
    // MARK: - CloudTableViewControllerType
    
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