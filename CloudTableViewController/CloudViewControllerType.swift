//
//  CloudViewControllerType.swift
//  CloudTableViewController
//
//  Created by luojie on 16/3/2.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

protocol DataControllerVCType: class, UIUpatable {
    
    // MARK: - Required

    typealias DataController: CloudDataControllerType

}

extension DataControllerVCType where Self: AnyObject {
    
    // MARK: - Helper
    func startup() {
        refreshData() 
    }
    
    func refreshData() {
        dataController.getDataInBackground(
            didGet: { [weak self] in
                self?.updateUI()
            }
        )
        updateUI()
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

}

private struct AssociatedKeys {
    static var DataController = "dataController"
}

