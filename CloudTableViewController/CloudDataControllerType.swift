//
//  CloudDataControllerType.swift
//  CloudTableViewController
//
//  Created by luojie on 16/3/1.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation

protocol CloudDataControllerType: class {
    
    // MARK: - Required
    init()
    
    var refreshApi: String { get }
    func parse(dic: [String : AnyObject])
    
    // MARK: - Optional
    
    
    var shouldRefreshData: Bool { get }
    var shouldGetMoreDataData: Bool { get }
    
    var refreshParams: [String: AnyObject]? { get }
    var getMoreDataParams: [String: AnyObject]? { get }
    
    var getMoreDataApi: String { get }
    func parseMore(dic: [String : AnyObject])
    
    func removeData()
}


extension CloudDataControllerType where Self: AnyObject {
    
    // MARK: - Optional
    
    var shouldRefreshData: Bool { return true }
    var shouldGetMoreDataData: Bool { return true }
    
    var refreshParams: [String: AnyObject]? { return nil }
    var getMoreDataParams: [String: AnyObject]? { return nil }
    
    var getMoreDataApi: String { return "" }
    func parseMore(dic: [String : AnyObject]) { }
    
    func reset() {
        removeData()
        isLastPage = false
        currentPage = 1
        getMoreDataIndicator?.didAccessInternet()
    }
    
    func removeData() { }
    
    // MARK: - Helper
    
    func getDataInBackground(didGet didGet: () -> Void, didFail: (() -> Void)? = nil) {
        
        guard !isGetingData else { return }
        guard shouldRefreshData else {
            didFail?()
            return
        }
        isGetingData = true
        print(__FUNCTION__)
        
        reset()
        
        self.refreshIndicator?.willAccessInternet()
        
        Request.post(api: refreshApi, params: refreshParams) {
            [weak self] result in
            
            self?.isGetingData = false
            self?.refreshIndicator?.didAccessInternet()
            
            switch result {
            case .Success(let dic):
                self?.parse(dic)
                
                if self?.isLastPage == true {
                    self?.getMoreDataIndicator?.didGetAllData()
                }
                
                didGet()
                
            case .Failure:
                didFail?()
                
            }
        }
    }
    
    
    func getMoreDataInBackground(didGet didGet: () -> Void, didFail: (() -> Void)? = nil) {
        
        guard !isGetingData && !isLastPage else { return }
        guard shouldRefreshData else {
            didFail?()
            return
        }
        
        isGetingData = true
        
        currentPage++
        
        
        self.getMoreDataIndicator?.willAccessInternet()
        print(__FUNCTION__)
        
        Request.post(api: getMoreDataApi, params: getMoreDataParams) {
            [weak self] result in
            self?.isGetingData = false
            self?.getMoreDataIndicator?.didAccessInternet()
            
            switch result {
            case .Success(let dic):
                self?.parseMore(dic)
                
                if self?.isLastPage == true {
                    self?.getMoreDataIndicator?.didGetAllData()
                }
                
                didGet()
                
            case .Failure:
                didFail?()
                
            }
        }
        
    }
    
    // MARK: - Stored Properties
    
    var isLastPage: Bool {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.IsLastPage) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.IsLastPage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    
    var currentPage: Int {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.CurrentPage) as? Int ?? 1 }
        set { objc_setAssociatedObject(self, &AssociatedKeys.CurrentPage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var isGetingData: Bool {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.IsGetingData) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.IsGetingData, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    weak var refreshIndicator: InternetIndicator? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.RefreshIndicator) as? InternetIndicator }
        set { objc_setAssociatedObject(self, &AssociatedKeys.RefreshIndicator, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    weak var getMoreDataIndicator: GetMoreDataIndicator? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.GetMoreDataIndicator) as? GetMoreDataIndicator }
        set { objc_setAssociatedObject(self, &AssociatedKeys.GetMoreDataIndicator, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}




private struct AssociatedKeys {
    static var IsLastPage = "isLastPage"
    static var CurrentPage = "currentPage"
    static var IsGetingData = "isGetingData"
    static var RefreshIndicator = "refreshIndicator"
    static var GetMoreDataIndicator = "getMoreDataIndicator"
}
