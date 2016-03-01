//
//  Extension.swift
//  CloudTableViewController
//
//  Created by luojie on 16/2/29.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

extension UIView {
    convenience init(withConstraintWidth width: CGFloat, height: CGFloat) {
        self.init()
        addConstraint(
            NSLayoutConstraint(item: self,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1, constant: width)
        )
        
        addConstraint(
            NSLayoutConstraint(item: self,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1, constant: height)
        )
    }
}

func kWidth () ->CGFloat{
    
    return UIScreen.mainScreen().bounds.size.width;
}


extension UITableViewCell {
    
    func toSectionHeader(width width: CGFloat, height: CGFloat) -> UIView {
        
        let view = UIView(withConstraintWidth: width, height: height)
        view.addSubview(self)
        scallToFillSuperviewByConstraint()
        return view
    }
}

extension UIView {
    func scallToFillSuperviewByConstraint() {
        guard let superview = superview else { return }
        superview.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutAttribute.allBoundsAttributes.forEach {
            superview.addConstraint(
                NSLayoutConstraint(item: superview,
                    attribute: $0,
                    relatedBy: .Equal,
                    toItem: self,
                    attribute: $0,
                    multiplier: 1, constant: 0))
        }
    }
}

extension NSLayoutAttribute {
    static var allBoundsAttributes: [NSLayoutAttribute] {
        return [.Leading, .Top, .Trailing, .Bottom]
    }
}

class ModelTableViewCell: UITableViewCell, UIUpatable {
    var model: Any! { didSet { updateUI() } }
    func updateUI() {}
}

///  可刷新页面的能力
protocol UIUpatable {
    func updateUI()
}