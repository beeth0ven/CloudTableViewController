//
//  CloudTableViewController.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

class CloudTableViewController: UITableViewController {
    // MARK: - Required
    
    @IBInspectable var canRefresh: Bool = false
    @IBInspectable var multiPages: Bool = false
    
    private var dataController = DataController() // View Model
    
    var dataSourceAndDelegate = MJRefreshDSAD<SectionStyle, CellStyle>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSourceAndDelegate()
        refreshData()
    }
    
    
    func setupDataSourceAndDelegate() {
        
        dataSourceAndDelegate.tableView = tableView
        configureDataSourceAndDelegate()
        enableRefreshIfNeeded()

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
        dataSourceAndDelegate.sections = [Section(sectionStyle: .Default, cellStyles: dataController.data.map { .Basic($0) })]
    }
    
    enum CellStyle {
        case Basic(String)
    }
    
    // MARK: - Helper

    func resetData() {
        tableView.mj_footer?.endRefreshing()
        dataSourceAndDelegate.sections = []
    }
    
    @IBAction func refreshData() {
        resetData()
        dataController.getDataInBackground(
            indicator: tableView.mj_header,
            didGet: { [weak self] in
                self?.updateUI()
            }
        )
    }
    
    func getMoreData() {
        dataController.getMoreDataInBackground(
            indicator: tableView.mj_footer,
            didGet: { [weak self] in
                self?.updateUI()
            })
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
        
    }

}