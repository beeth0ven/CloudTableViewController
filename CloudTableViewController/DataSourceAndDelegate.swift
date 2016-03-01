//
//  DataSourceAndDelegate.swift
//  SectionsAsDataSource
//
//  Created by luojie on 16/1/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

// MARK: - Public

/**
 Turn UITableView delegate based API to block based API, Usage:
 ```swift
class ViewController: UIViewController {
 
    var dataSourceAndDelegate = DataSourceAndDelegate<SectionStyle, CellStyle>()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            dataSourceAndDelegate.tableView = tableView
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSourceAndDelegate()
        refreshData()
    }
    
    func setupDataSourceAndDelegate() {

        dataSourceAndDelegate.tableView = tableView

        dataSourceAndDelegate.reuseIdentifierForCellStyle = {
            cellStyle in
            return "cell"
        }
        
        dataSourceAndDelegate.configureCellForCellStyle = {
            cell, cellStyle in
            cell.textLabel?.text = cellStyle.rawValue
        }
        
        dataSourceAndDelegate.titleForSectionStyle = {
            sectionStyle in
            return sectionStyle.rawValue
        }
        
        dataSourceAndDelegate.didSelectCellStyle = {
            cellStyle in
            print("did Select: \(cellStyle.rawValue)")
        }
    }
    
    func refreshData() {
        dataSourceAndDelegate.sections = [
            Section(sectionStyle: .OverView, cellStyles: [.Name, .Detail, .Time]),
            Section(sectionStyle: .Author,   cellStyles: [.AuthorName, .AuthorImage, .AuthorAge]),
            Section(sectionStyle: .Footer,   cellStyles: [.LikeNumber, .FollowNumer, .Time]),
        ]
    }
    
    enum SectionStyle: String {
        case OverView
        case Author
        case Footer
    }
    
    enum CellStyle: String {
        case Name
        case Detail
        case Time
        
        case AuthorName
        case AuthorImage
        case AuthorAge
        
        case LikeNumber
        case FollowNumer
    }
}
 
 ```
 */


class DataSourceAndDelegate<SectionStyle, CellStyle>: NSObject, UITableViewDataSource, UITableViewDelegate, UIUpatable {
    
    // MARK: Properties
    
    var sections: [Section<SectionStyle, CellStyle>] = [] { didSet { updateUI() } }
    
    weak var tableView: UITableView! { didSet { tableView.dataSource = self; tableView.delegate = self } }
    weak var tableFooterView: UIView?
    weak var noContentFooterView: UIView?

    // Configure Cell
    var reuseIdentifierForCellStyle:     ((CellStyle) -> String)!
    var configureCellForCellStyle:       ((UITableViewCell, CellStyle) -> Void)?
    var titleForSectionStyle:            ((SectionStyle) -> String?)?
    var modelForCellStyle:               ((CellStyle) -> Any?)?
    
    // Configure Section
    var reuseIdentifierForSectionStyle:  ((SectionStyle) -> String)!
    var configureCellForSectionStyle:    ((UITableViewCell, SectionStyle) -> Void)?
    var modelForSectionStyle:            ((SectionStyle) -> Any?)?
    var viewForHeaderForSectionStyle:    ((SectionStyle) -> UIView?)?

    // Delegate
    var didSelectCellStyle:              ((CellStyle) -> Void)?
    var scrollViewDidScroll:            ((UIScrollView) -> Void)?
    var scrollViewDidEndDecelerating:   ((UIScrollView) -> Void)?
    
    
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cellStyles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellStyle = cellStyleAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierForCellStyle(cellStyle))!
        configureCell(cell, withModel: modelForCellStyle?(cellStyle))
        configureCellForCellStyle?(cell, cellStyle)
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, withModel model: Any?) {
        guard
            let modelCell = cell as? ModelTableViewCell,
            model = model else { return }
        
        modelCell.model = model
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForSectionStyle?(sections[section].sectionStyle)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionStyle = sections[section].sectionStyle
        
        if let view = viewForHeaderForSectionStyle?(sectionStyle) {
            return view
        }
        
        
        if let identifier = reuseIdentifierForSectionStyle?(sectionStyle),
            cell = tableView.dequeueReusableCellWithIdentifier(identifier) {
                
                configureCell(cell, withModel: modelForSectionStyle?(sectionStyle))
                configureCellForSectionStyle?(cell, sectionStyle)
                return cell.toSectionHeader(width: kWidth(), height: tableView.sectionHeaderHeight)
        }
        
        return nil
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellStyle = cellStyleAtIndexPath(indexPath)
        didSelectCellStyle?(cellStyle)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollViewDidScroll?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndDecelerating?(scrollView)
    }
    
    // MARK: UITableViewDataSource
    func updateUI() {
        tableView.reloadData()
        
        tableView.tableFooterView = tableFooterView
        
        if let noContentFooterView = noContentFooterView
            where  allCellStylesCount == 0 {
                
                tableView.tableFooterView = noContentFooterView
        }
    }
    
    private var allCellStylesCount: Int {
        return sections.reduce(0, combine: { $0 + $1.cellStyles.count } )
    }
    
    // Helper
    func cellStyleAtIndexPath(indexPath: NSIndexPath) -> CellStyle {
        return sections[indexPath.section].cellStyles[indexPath.item]
    }
}

// Provide Struct For Each Section
struct Section<SectionStyle, CellStyle> {
    var sectionStyle: SectionStyle
    var cellStyles:  [CellStyle]
    
    subscript(index: Int) -> CellStyle {
        get { return cellStyles[index] }
        set { cellStyles[index] = newValue }
    }
}


/// 默认的 SectionStyle , 通常在只有一种 Section 时使用
enum SectionStyle {
    case Default   //目录
}


/// 提供上拉加载更多功能
class MJRefreshDSAD<SectionStyle, CellStyle>: DataSourceAndDelegate<SectionStyle, CellStyle> {
    
    var mjRefreshClosure: (() -> Void)?     { didSet { updateMJHeaderIfNeeded() } }
    var mjGetMoreDataClosure: (() -> Void)? { didSet { updateMJFooterIfNeeded() } }
    
    func updateMJHeaderIfNeeded() {
        
        if let closure = mjRefreshClosure {
            tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: closure)
        } else {
            tableView.mj_header = nil
        }
    }
    
    func updateMJFooterIfNeeded() {
        if let closure = mjGetMoreDataClosure {
            tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: closure)
        } else {
            tableView.mj_footer = nil
        }
    }
    
}
