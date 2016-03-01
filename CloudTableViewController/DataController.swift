//
//  DataController.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation


extension CloudTableViewController {
    
    
    class DataController {
        
        // MARK: - Required
        
        var data = [String]()
        
        private(set) var isLastPage = false
        
        private var currentPage = 1
        
        private var isGetingData = false
        
        func removeData() {
            data.removeAll(keepCapacity: true)
        }
        
        private func parse(dic: [String : AnyObject]) {
            data = (0..<10).map(String.init)
        }
        
        private func parseMore(dic: [String : AnyObject]) {
            let moreData = (0..<10).map { (currentPage - 1) * 10 + $0 }.map(String.init)
            data += moreData
            
            if currentPage == 3 {
                isLastPage = true
            }
        }
        
        var refreshApi = "getDataInBackground"
        var refreshParams: [String: AnyObject]?
        
        var getMoreDataApi = "getMoreDataInBackground"
        var getMoreDataParams: [String: AnyObject]?
        
        // MARK: - Helper
        
        func reset() {
            removeData()
            isLastPage = false
            currentPage = 1
        }
        
        var shouldRefreshData: Bool { return true }
        
        func getDataInBackground(indicator indicator: InternetIndicator? = nil, didGet: () -> Void, didFail: (() -> Void)? = nil) {
            
            guard shouldRefreshData else { return }
            guard !isGetingData else { return }
            isGetingData = true
            print(__FUNCTION__)
            
            reset()
            
            indicator?.willAccessInternet()
            
            Request.post(api: refreshApi, params: refreshParams) {
                [weak self] result in
                
                self?.isGetingData = false
                indicator?.didAccessInternet()
                
                switch result {
                case .Success(let dic):
                    self?.parse(dic)
                    didGet()
                    
                case .Failure:
                    didFail?()
                    
                }
            }
        }
        
        var shouldGetMoreDataData: Bool { return true }

        func getMoreDataInBackground(indicator indicator: GetMoreDataIndicator? = nil, didGet: () -> Void, didFail: (() -> Void)? = nil) {
            
            guard shouldGetMoreDataData else { return }
            guard !isGetingData && !isLastPage else { return }
            isGetingData = true
            
            currentPage++
            
            indicator?.willAccessInternet()
            print(__FUNCTION__)
            
            Request.post(api: getMoreDataApi, params: getMoreDataParams) {
                [weak self] result in
                self?.isGetingData = false
                indicator?.didAccessInternet()
                
                switch result {
                case .Success(let dic):
                    self?.parseMore(dic)
                    
                    if self?.isLastPage == true {
                        indicator?.didGetAllData()
                    }
                    
                    didGet()
                    
                case .Failure:
                    didFail?()
                    
                }
            }
            
        }
        
    }
}
