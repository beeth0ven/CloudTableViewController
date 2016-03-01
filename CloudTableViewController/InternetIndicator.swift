//
//  InternetIndicator.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation

/// 网络指示器，表示是否正在访问网络，可看做是一个小型代理
protocol InternetIndicator: class {
    func willAccessInternet()   // 即将访问网络
    func didAccessInternet()    // 网络访问结束
}

protocol GetMoreDataIndicator: InternetIndicator {
    func didGetAllData() // 已取得所有数据
}

extension UIRefreshControl: InternetIndicator {
    
    func willAccessInternet() {
        beginRefreshing()
    }
    
    func didAccessInternet() {
        endRefreshing()
    }
}

extension UIActivityIndicatorView: InternetIndicator {
    
    func willAccessInternet() {
        startAnimating()
    }
    
    func didAccessInternet() {
        stopAnimating()
    }
}

extension  MJRefreshHeader: InternetIndicator {
    func willAccessInternet() {
        beginRefreshing()
    }
    
    func didAccessInternet() {
        endRefreshing()
    }
}

extension MJRefreshFooter: GetMoreDataIndicator {
    
    func willAccessInternet() {}
    
    func didAccessInternet() {
        endRefreshing()
    }
    
    func didGetAllData() {
        endRefreshingWithNoMoreData()
    }
}
