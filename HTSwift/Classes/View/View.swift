//
//  ViewExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/23.
//

import Foundation

extension UIView: HTSwiftCompatible, AssociatedAble {}

public extension HTBox where Base: UIView {
	
	var controller: UIViewController? {
		var responder: UIResponder? = base
		while responder is UIViewController == false {
			responder = responder?.next
		}
		return responder as? UIViewController
	}
	
}
