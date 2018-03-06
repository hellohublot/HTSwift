//
//  ViewExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/23.
//

import Foundation

public extension UIView {
	
	var controller: UIViewController? {
		var responder: UIResponder? = self
		while responder is UIViewController == false {
			responder = responder?.next
		}
		return responder as? UIViewController
	}
	
}
